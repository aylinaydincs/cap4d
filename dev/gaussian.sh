#!/bin/bash
#SBATCH --job-name=gaussian
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
    echo "Usage:"
    echo "  sbatch gaussian_avatar.sh <run_name> [avatar_config] [anim_sequence]"
    echo ""
    echo "Arguments:"
    echo "  <run_name>      : examples/output altında mevcut klasör"
    echo "  [avatar_config]: default = configs/avatar/high_quality.yaml"
    echo "  [anim_sequence]: default = sequence_01"
    exit 1
fi

RUN_NAME="$1"
AVATAR_CONFIG="${2:-configs/avatar/high_quality.yaml}"
ANIM_SEQUENCE="${3:-sequence_01}"

########################################
# Job header
########################################

echo "===== Starting Job $SLURM_JOB_ID ====="
echo "Run name        : $RUN_NAME"
echo "Avatar config   : $AVATAR_CONFIG"
echo "Anim sequence   : $ANIM_SEQUENCE"
echo "Hostname        : $(hostname)"
echo ""

########################################
# GPU check
########################################

nvidia-smi || echo "⚠️ nvidia-smi not available inside container"
echo ""

########################################
# Environment setup
########################################

cd /workspace
echo "Working directory: $(pwd)"

export PYTHONPATH="$(realpath "./"):${PYTHONPATH}"

########################################
# Sanity checks
########################################

OUT_ROOT="examples/output/${RUN_NAME}"
REF_DIR="${OUT_ROOT}/reference_images"
GEN_DIR="${OUT_ROOT}/generated_images"

if [ ! -d "$REF_DIR" ]; then
    echo "❌ Missing reference_images:"
    echo "   $REF_DIR"
    exit 1
fi

if [ ! -d "$GEN_DIR" ]; then
    echo "❌ Missing generated_images:"
    echo "   $GEN_DIR"
    exit 1
fi

echo "✔ Found reference_images and generated_images"
echo ""

########################################
# Run GaussianAvatar training + animation
########################################

echo "--- Training GaussianAvatar ---"
bash scripts/gaussian_avatar.sh \
    "$RUN_NAME" \
    "$AVATAR_CONFIG" \
    "$ANIM_SEQUENCE"

########################################
# Job end
########################################

echo ""
echo "===== Job Finished Successfully ====="
echo "Run name : $RUN_NAME"
echo "Output   : examples/output/${RUN_NAME}"
