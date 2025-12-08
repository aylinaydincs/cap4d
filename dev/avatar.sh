#!/bin/bash
#SBATCH --job-name=avatar
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

#SBATCH --container-image=ghcr.io\#aylinaydincs/cap4d:latest
#SBATCH --container-mounts /users/aylin.aydin/experiments/cap4d:/workspace
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=4
#SBATCH --mem=40G
#SBATCH --time=12:00:00

set -e

########################################
# Argument parsing with defaults
########################################

if [ -z "$1" ]; then
    echo "Usage: sbatch avatar.sh <user_name> [gen_config] [avatar_config] [anim_sequence]"
    echo ""
    echo "  <user_name>     : zorunlu (ör: aylin)"
    echo "  [gen_config]    : opsiyonel, varsayılan: configs/generation/high_quality.yaml"
    echo "  [avatar_config] : opsiyonel, varsayılan: configs/avatar/high_quality.yaml"
    echo "  [anim_sequence] : opsiyonel, varsayılan: sequence_01"
    exit 1
fi

USER_NAME="$1"
GEN_CONFIG="${2:-configs/generation/high_quality.yaml}"
AVATAR_CONFIG="${3:-configs/avatar/high_quality.yaml}"
ANIM_SEQUENCE="${4:-sequence_01}"

########################################
# Job header
########################################

echo "===== Starting Job $SLURM_JOB_ID for USER: $USER_NAME ====="
echo "Running on: $(hostname)"
echo "GEN_CONFIG      : $GEN_CONFIG"
echo "AVATAR_CONFIG   : $AVATAR_CONFIG"
echo "ANIM_SEQUENCE   : $ANIM_SEQUENCE"
echo ""

nvidia-smi || echo "nvidia-smi not available inside container"
echo ""

########################################
# Environment setup
########################################

cd /workspace
echo "Working directory: $(pwd)"

export PYTHONPATH="$(realpath "./"):${PYTHONPATH}"

########################################
# Run pipeline
########################################

echo "--- Running generate_custom.sh for USER: $USER_NAME ---"
bash scripts/generate_custom.sh "$USER_NAME" "$GEN_CONFIG" "$AVATAR_CONFIG" "$ANIM_SEQUENCE"

echo "===== Job Finished Successfully for USER: $USER_NAME ====="
