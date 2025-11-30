FROM nvidia/cuda:12.1.1-devel-ubuntu22.04
LABEL maintainer="Aylin Aydın"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PYTHONUNBUFFERED=1

# gsplat CUDA extension'larının derleneceği klasör
ENV TORCH_EXTENSIONS_DIR=/tmp/torch_extensions

# Sistem paketleri
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 python3-pip python3-dev python-is-python3 \
        git wget curl unzip \
        build-essential cmake ninja-build \
        libglib2.0-0 libsm6 libxext6 libxrender1 libgl1 \
        ffmpeg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# pip / setuptools / wheel güncelle
RUN python3 -m pip install --upgrade pip setuptools wheel

# PyTorch + CUDA 12.1
RUN pip install --no-cache-dir \
        torch==2.4.1 \
        torchvision==0.19.1 \
        torchaudio==2.4.1 \
        --extra-index-url https://download.pytorch.org/whl/cu121

WORKDIR /workspace

# Kodları içeri kopyala
#COPY . /workspace
COPY requirements_aylin.txt .

# Python dependency'leri kur
# (buradaki requirements_aylin.txt, senin son gönderdiğin ve
# en altta numpy==1.26.4 + opencv-python-headless==4.9.0.80 olan dosya)
RUN pip install --no-cache-dir -r requirements_aylin.txt

# Chumpy
RUN git clone https://github.com/mattloper/chumpy.git /tmp/chumpy && \
    pip install --no-build-isolation /tmp/chumpy && \
    rm -rf /tmp/chumpy

# PyTorch3D: A100 (8.0), A40 (8.6), RTX40 (8.9) için derle
ENV FORCE_CUDA=1
ENV TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9"
RUN TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9" pip install --no-build-isolation \
    "git+https://github.com/facebookresearch/pytorch3d.git@stable"

# gsplat CUDA extension'ını build-time'da derle (GPU gerekmez, sadece CUDA toolchain lazım)
RUN mkdir -p /tmp/torch_extensions && \
    python3 - << 'EOF'
import os
os.environ["TORCH_EXTENSIONS_DIR"] = "/tmp/torch_extensions"
import gsplat
from gsplat.cuda import _backend
print("Built gsplat CUDA extension at:", os.environ["TORCH_EXTENSIONS_DIR"])
EOF

# Projeyi import edebilmek için
ENV PYTHONPATH=/experiments/cap4d

#CMD ["bash"]
