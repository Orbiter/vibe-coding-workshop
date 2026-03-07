# OPX

`opx.sh` is a very small, very direct agentic tool runner written in Bash.

It is prepared for educational purpose: the code is intentionally compact enough to read in one sitting, while still showing the core mechanics of a real tool-using agent. In that sense it aims to be both the simplest and the mightiest version of an agent runner:

- simple, because the implementation is short and local
- mighty, because it can let a model inspect the current machine, request tools, run commands, and continue reasoning over the results

## What It Does

`opx.sh` sends a prompt to a chat-completions-compatible model, exposes one tool named `bash`, and then runs the classic agentic loop until the model stops requesting tools.

The tool is intentionally narrow:

- one shell command at a time
- no pipes or redirection
- optional approval by the user
- optional auto-approval for configured safe commands

That constraint is a feature. It keeps the runner easy to explain and makes the control flow visible.

## The Agentic Loop

The core of the program starts at the `while :; do` loop in [`opx.sh`](/Users/admin/git/vibe-coding-workshop/agents/opx/opx.sh).

That loop follows the standard agent pattern:

1. Build a request from the current conversation state.
2. Ask the model for the next assistant action.
3. Read normal assistant text and any requested tool call.
4. If a tool was requested, run it.
5. Append the tool result to the conversation.
6. Ask the model again.
7. Stop when the model returns a final answer without another tool call.

In short:

```text
prompt -> model -> tool request -> tool result -> model -> ... -> final answer
```

That is the essential agentic loop. Everything else in the file exists to make that loop safe, small, and understandable.

## The Agentic Loop Code

This is the actual code of the agentic loop in `opx.sh`

```
while :; do
  # Start a fresh turn before asking the model what to do next.
  tool_name=""; tool_args_unescaped=""; tool_id=""; tool_input=""
  json="$(jq -cn --arg model "$model" --argjson messages "$messages" --argjson tools "$tools" '{model:$model,messages:$messages,tools:$tools,stream:false}')"

  # Call the LLM and request the next assistant response from the model.
  response=""
  if ! response="$(curl -sS -f -H "Content-Type: application/json" -d "$json" "$url")"; then
    echo "Network error" >&2
    exit 1
  fi

  # Extract assistant text plus any requested tool call from the response.
  extract_response_fields "$response"
  if [ -n "$chunk" ]; then printf '%s' "$chunk"; fi

  # Feed tool results back into the conversation until the model stops asking.
  if handle_tool_call; then
    log "Tool result appended to the conversation; continuing the loop."
    continue
  fi

  # No tool call means the current assistant answer is final.
  break
done
```

## Running It

Basic usage:

```bash
./opx.sh -m qwen3.5:4b "inspect the repo and summarize the current diff"
```

With auto-approval for configured safe commands:

```bash
./opx.sh -m qwen3.5:4b -a "make a git diff and draft a commit message"
```

Help:

```bash
./opx.sh --help
```

## Design Intent

This is not a general framework. It is a minimal reference implementation.

The goal is to show that an agent does not need a large runtime to be real. A short Bash program can already demonstrate the core idea:

- the model can decide
- the system can supervise
- tools can be executed
- results can be fed back into the next reasoning step

That is enough to teach the essence of agentic behavior.
