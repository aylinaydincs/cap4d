#!/bin/bash
#SBATCH --container-image ghcr.io\#bouncmpe/cuda-python3
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=8
#SBATCH --mem-per-gpu=40G
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

source /opt/python3/venv/base/bin/activate
python3 -c 'import pandas; print("Pandas Version:", pandas.__version__)'