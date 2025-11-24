# Local Usage:
# ```
# docker build -t ghcr.io/bouncmpe/cuda-python3 containers/cuda-python3/
# docker run -it --rm --gpus=all ghcr.io/bouncmpe/cuda-python3
# ```

# Base image
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

LABEL maintainer="Aylin Aydın"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev python-is-python3 \
    git wget curl unzip \
    build-essential cmake ninja-build \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
        torch==2.4.1 \
        torchvision==0.19.1 \
        torchaudio==2.4.1 \
        --extra-index-url https://download.pytorch.org/whl/cu121


WORKDIR /workspace
COPY . /workspace

RUN grep -Ev '^(torch==|torchvision==|torchaudio==|pytorch3d|chumpy)' \
        requirements_aylin.txt > requirements_nocuda.txt && \
    pip install --no-cache-dir -r requirements_nocuda.txt

RUN python3 -m pip install --no-cache-dir -r /workspace/requirements.txt

RUN git clone https://github.com/mattloper/chumpy.git /tmp/chumpy && \
    pip install --no-cache-dir --no-build-isolation /tmp/chumpy && \
    rm -rf /tmp/chumpy

ENV FORCE_CUDA=1
RUN pip install --no-build-isolation \
    "git+https://github.com/facebookresearch/pytorch3d.git@stable"

CMD ["/bin/bash"]