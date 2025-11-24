# Local Usage:
# ```
# docker build -t ghcr.io/bouncmpe/cuda-python3 containers/cuda-python3/
# docker run -it --rm --gpus=all ghcr.io/bouncmpe/cuda-python3
# ```

# Base image
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

LABEL maintainer="Aylin Aydın"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev python-is-python3 \
    git wget curl unzip \
    build-essential cmake ninja-build \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    torch==2.4.1+cu121 \
    torchvision==0.19.1+cu121 \
    torchaudio==2.4.1+cu121 \
    --extra-index-url https://download.pytorch.org/whl/cu121


COPY requirements_aylin.txt /workspace/requirements.txt

RUN python3 -m pip install --no-cache-dir -r /workspace/requirements.txt

WORKDIR /workspace
COPY . /workspace

CMD ["bash"]
