#!/usr/bin/env bash
set -u
set -o pipefail

host="localhost"
port="11434"
model="qwen3.5:4b"

usage() {
  local auto_granted_list=""
  auto_granted_list="$(
    printf '%s\n' "$auto_granted_command_patterns" |
      awk 'NF { if (seen) printf ", "; printf "%s", $0; seen=1 }'
  )"
  cat <<USAGE
Usage: opx.sh [options] <prompt>
Options:
  -m <model>      model name (default: $model)
  -h <host>       hostname (default: $host)
  -p <port>       port number (default: $port)
  -a              auto-grant configured safe commands
  --help          show help and exit
USAGE

  printf '\nAuto-granted commands (used only with -a): %s\n' "$auto_granted_list"
}

reasoning_effort="none"
auto_grant_enabled=0
auto_granted_command_patterns=$'ls\nls *\npwd\ngit status\ngit diff\ngit diff *'
system_prompt="You are a Linux system operator running inside the user's current working directory with access to a bash tool for local inspection. Submit only single safe shell commands to the bash tool. Do not submit commands containing pipes, semicolons, ampersands, redirection operators, or embedded newlines, because the runner rejects them. If a task needs multiple shell commands, submit them one at a time. Use short answers."
tools="$(jq -cn '[{type:"function",function:{name:"bash",description:"Run a single shell command and return stdout/stderr.",parameters:{type:"object",properties:{command:{type:"string",description:"Single shell command (no pipes or redirection)."}},required:["command"],additionalProperties:false},strict:true}}]')"
stdout_needs_newline=0

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

log() {
  if [ "$stdout_needs_newline" -eq 1 ]; then
    printf '\n'
    stdout_needs_newline=0
  fi
  printf '[opx] %s\n' "$1" >&2
}

if [ $# -eq 0 ]; then
  usage >&2
  exit 1
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    -m)
      shift
      [ $# -gt 0 ] || { usage >&2; exit 1; }
      model="$1"
      shift
      ;;
    -h)
      shift
      [ $# -gt 0 ] || { usage >&2; exit 1; }
      host="$1"
      shift
      ;;
    -p)
      shift
      [ $# -gt 0 ] || { usage >&2; exit 1; }
      port="$1"
      shift
      ;;
    -a)
      auto_grant_enabled=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      usage >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [ $# -eq 0 ]; then
  usage >&2
  exit 1
fi

prompt="$*"
extra=""

if [ ! -t 0 ]; then
  if ! IFS= read -r -d '' extra; then
    true
  fi
fi

if [ -n "$extra" ]; then
  prompt="${prompt}"$'\n\n```\n'"${extra}"$'\n```'
fi
messages="$(jq -cn --arg system "$system_prompt" --arg prompt "$prompt" '[{role:"system",content:$system},{role:"user",content:$prompt}]')"
log "Initialized conversation with system prompt and user prompt."

tool_name=""
tool_args_unescaped=""
tool_id=""
tool_input=""

classify_bash_command() {
  local cmd="$1"
  local pattern
  case "$cmd" in
    *'|'*|*';'*|*'&'*|*'>'*|*'<'*|*$'\n'*|*$'\r'*)
      printf '%s\n' "rejected"
      return
      ;;
  esac

  if [ "$auto_grant_enabled" -eq 1 ]; then
    while IFS= read -r pattern; do
      [ -n "$pattern" ] || continue
      case "$cmd" in
        $pattern)
          printf '%s\n' "auto-granted"
          return
          ;;
      esac
    done <<<"$auto_granted_command_patterns"
  fi
  printf '%s\n' "ask-user"
}

request_tool_approval() {
  local cmd="$1"
  printf 'Tool request: %s\nApprove? [Y/n]: ' "$cmd" >&2
  IFS= read -r reply
  case "${reply}" in
    ""|[Yy]|[Yy][Ee][Ss])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

tool_result_exit_code=0
tool_result_stdout=""
tool_result_stderr=""

run_tool() {
  local cmd="$1"
  local decision
  tool_result_exit_code=1
  tool_result_stdout=""
  tool_result_stderr=""

  if [ -z "$cmd" ]; then
    tool_result_stderr="Empty command"
    return
  fi
  decision="$(classify_bash_command "$cmd")"
  log "Tool decision: $decision: $cmd."
  case "$decision" in
    rejected)
      tool_result_stderr="Rejected: unsafe command, try a safe approach: don't send multi-command lines, send commands separately."
      return
      ;;
    ask-user)
      if ! request_tool_approval "$cmd"; then
        log "Tool denied by user: $cmd."
        tool_result_stderr="Rejected by user, try a different approach"
        return
      fi
      ;;
    auto-granted)
      ;;
  esac

  local stdout_capture=""
  log "Executing: $cmd."
  stdout_capture="$(eval "$cmd" 2>&1)"
  tool_result_exit_code=$?
  tool_result_stdout="$stdout_capture"
  tool_result_stderr=""
  log "Tool finished with exit code $tool_result_exit_code: $cmd."
}

extract_response_fields() {
  local response="$1"
  chunk="$(jq -r '.choices[0].message.content // empty' <<<"$response")"
  tool_name="$(jq -r '.choices[0].message.tool_calls[0].function.name // .choices[0].message.tool_calls[0].name // empty' <<<"$response")"
  tool_id="$(jq -r '.choices[0].message.tool_calls[0].id // empty' <<<"$response")"
  tool_args_unescaped="$(jq -r '.choices[0].message.tool_calls[0].function.arguments // empty' <<<"$response")"
  if [ -n "$tool_args_unescaped" ] && [ "$tool_name" != "bash" ]; then tool_name="bash"; fi
  if [ -z "$tool_name" ]; then log "Model returned a final answer without a tool call."; fi
}

handle_tool_call() {
  if [ "$tool_name" != "bash" ] || [ -z "$tool_args_unescaped" ]; then return 1; fi
  tool_input="$(jq -r '.command // empty' <<<"$tool_args_unescaped")"
  if [ -z "$tool_input" ]; then return 1; fi
  run_tool "$tool_input"
  tool_result_json="$(jq -cn --arg tool "bash" --arg stdout "$tool_result_stdout" --arg stderr "$tool_result_stderr" --argjson exit_code "$tool_result_exit_code" '{tool:$tool,exit_code:$exit_code,stdout:$stdout,stderr:$stderr}')"
  messages="$(jq --arg id "${tool_id:-call_1}" --arg args "$tool_args_unescaped" '. + [{role:"assistant",tool_calls:[{id:$id,type:"function",function:{name:"bash",arguments:$args}}]}]' <<<"$messages")"
  messages="$(jq --arg id "${tool_id:-call_1}" --arg content "$tool_result_json" '. + [{role:"tool",tool_call_id:$id,content:$content}]' <<<"$messages")"
}

url="http://$host:$port/v1/chat/completions"

# The Agentic Loop
while :; do
  # Start a fresh turn before asking the model what to do next.
  tool_name=""; tool_args_unescaped=""; tool_id=""; tool_input=""
  log "Starting agent loop turn."
  json="$(jq -cn --arg model "$model" --arg reasoning_effort "$reasoning_effort" --argjson messages "$messages" --argjson tools "$tools" '{model:$model,reasoning_effort:$reasoning_effort,messages:$messages,tools:$tools,stream:false}')"

  # Call the LLM and request the next assistant response from the model.
  response=""
  log "Sending conversation to model $model at $host:$port."
  if ! response="$(curl -sS -f -H "Content-Type: application/json" -d "$json" "$url")"; then
    echo "Network error" >&2
    exit 1
  fi

  # Extract assistant text plus any requested tool call from the response.
  extract_response_fields "$response"
  if [ -n "$chunk" ]; then
    printf '%s' "$chunk"
    if [ "${chunk: -1}" = $'\n' ]; then stdout_needs_newline=0; else stdout_needs_newline=1; fi
  fi

  # Feed tool results back into the conversation until the model stops asking.
  if handle_tool_call; then
    log "Tool result appended to the conversation; continuing the loop."
    continue
  fi

  # No tool call means the current assistant answer is final.
  if [ "$stdout_needs_newline" -eq 1 ]; then printf '\n'; stdout_needs_newline=0; fi
  log "Agent loop finished."
  break
done
