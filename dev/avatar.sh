#!/bin/bash
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

#SBATCH --container-image=ghcr.io#aylinaydincs/cap4d:latest
#SBATCH --container-mounts /users/aylin.aydin/experiments/cap4d:/workspace
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=4
#SBATCH --mem=40G
#SBATCH --time=12:00:00

set -e

# ===== PARAMETER CHECK =====
if [ -z "$1" ]; then
    echo "Usage: sbatch run_custom.sbatch <user_name>"
    exit 1
fi

USER_NAME=$1

echo "===== Starting Job $SLURM_JOB_ID for USER: $USER_NAME ====="
echo "Running on: $(hostname)"
nvidia-smi
echo ""

cd /workspace
echo "Working directory: $(pwd)"

export PYTHONPATH=$(realpath "./"):$PYTHONPATH

echo "--- Running generate_custom.sh for USER: $USER_NAME ---"
bash scripts/generate_custom.sh "$USER_NAME"

echo "===== Job Finished Successfully ====="

