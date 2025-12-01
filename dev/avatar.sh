#!/bin/bash
#SBATCH --job-name=cap4d_felix
#SBATCH --output=logs/felix-%j.out
#SBATCH --error=logs/felix-%j.err

#SBATCH --container-image=ghcr.io#aylinaydincs/cap4d:latest
#SBATCH --container-mounts /users/aylin.aydin/experiments/cap4d:/workspace
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=4
#SBATCH --mem=40G
#SBATCH --time=10:00:00

set -e

echo "===== Starting Job $SLURM_JOB_ID ====="
echo "Running on: $(hostname)"
nvidia-smi
echo ""

cd /workspace
echo "Working directory: $(pwd)"

echo "--- Running generate_felix.sh ---"
bash scripts/generate_felix.sh

echo "===== Job Finished Successfully ====="
