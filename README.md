# About
Dockerfile for Jupyter Notebook + Keras + TensorFlow + CUDA

# Requirement
* nvidia-docker

# Originated from
* https://hub.docker.com/r/jupyter/tensorflow-notebook/ (non-GPU version)

# Usage
## Build Docker image
```
docker build -t akimateras/keras-notebook-gpu <project-dir>
```

## Run Docker container
```
nvidia-docker run -d \
    -p 8888:8888 \
    -v /your/notebook/directory:/home/jovyan \
    --name keras-notebook \
    akimateras/keras-notebook-gpu
```

You can see authentication URL by `docker logs keras-notebook`.
