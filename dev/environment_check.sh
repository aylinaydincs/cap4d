#!/bin/bash
#SBATCH --job-name=env_check
#SBATCH --partition=batch
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=8
#SBATCH --mem-per-gpu=40G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

# KENDİ IMAGE'IN
#SBATCH --container-image=ghcr.io/aylinaydincs/cap4d:latest

mkdir -p logs

python3 - << 'EOF'
import sys, torch

print("==== Python ====")
print(sys.version)
print()

print("==== PyTorch ====")
print("torch.__version__      :", torch.__version__)
print("torch.cuda.is_available:", torch.cuda.is_available())
print("torch.cuda.device_count:", torch.cuda.device_count())

if torch.cuda.is_available():
    print("Current device index   :", torch.cuda.current_device())
    print("Device name            :", torch.cuda.get_device_name(0))
EOF
