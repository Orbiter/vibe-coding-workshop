
# pull a new ollama docker container
docker pull ollama/ollama

# get the user to run the container; they must not use root, otherwise the files in the shared volumes have the wrong user right
UID_GID="$(id -u):$(id -g)"

# stop the container and remove them
docker stop ollama-cpu
docker stop ollama-gpu
docker rm ollama-cpu
docker rm ollama-gpu

# we start them again, it will use the new image, if existent
docker run -d \
       --restart always \
       --user "${UID_GID}" \
       -e OLLAMA_SCHED_SPREAD=true \
       -e OLLAMA_CONTEXT_LENGTH=32768 \
       -e OLLAMA_KEEP_ALIVE=1h \
       -e OLLAMA_MAX_LOADED_MODELS=6 \
       -e OLLAMA_NUM_PARALLEL=4 \
       -e OLLAMA_ORIGINS=* \
       -v /models/ollama-cpu:/root/.ollama \
       -p 0.0.0.0:11435:11434 \
       --name ollama-cpu \
       ollama/ollama
docker run -d \
       --restart always \
       --user "${UID_GID}" \
       --gpus=all \
       -e OLLAMA_SCHED_SPREAD=true \
       -e OLLAMA_CONTEXT_LENGTH=32768 \
       -e OLLAMA_KEEP_ALIVE=1h \
       -e OLLAMA_MAX_LOADED_MODELS=6 \
       -e OLLAMA_NUM_PARALLEL=4 \
       -e OLLAMA_ORIGINS=* \
       -v /models/ollama-gpu:/root/.ollama \
       -p 0.0.0.0:11436:11434 \
       --name ollama-gpu \
       ollama/ollama

# Remove unused images
docker image prune -f

