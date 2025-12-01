#!/bin/bash
#SBATCH --job-name=aylin
#SBATCH --output=logs/aylin-%j.out
#SBATCH --error=logs/aylin-%j.err

#SBATCH --container-image=ghcr.io\#aylinaydincs/cap4d:latest
#SBATCH --container-mounts /users/aylin.aydin/experiments/cap4d:/workspace
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=4
#SBATCH --mem=40G
#SBATCH --time=12:00:00

set -e

echo "===== Starting Job $SLURM_JOB_ID ====="
echo "Running on: $(hostname)"
nvidia-smi
echo ""

cd /workspace
echo "Working directory: $(pwd)"

export PYTHONPATH=$(realpath "./"):$PYTHONPATH

echo "--- Running generate_aylin.sh ---"
bash scripts/generate_aylin.sh

echo "===== Job Finished Successfully ====="
