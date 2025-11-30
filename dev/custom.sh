#!/bin/bash

#SBATCH --job-name=cap4d_pixel3dmm
#SBATCH --output=logs/cap4d_pix3d-%j.out
#SBATCH --error=logs/cap4d_pix3d-%j.err

#SBATCH --container-image=ghcr.io\#aylinaydincs/cap4d:latest
#SBATCH --container-mounts /users/aylin.aydin/experiments/cap4d:/workspace
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=4
#SBATCH --mem-per-gpu=40G
#SBATCH --time=24:00:00

set -e

echo "===== Starting Job $SLURM_JOB_ID ====="
echo "Running on $(hostname)"
nvidia-smi
echo ""

cd /workspace
echo "Working directory: $(pwd)"

# ============================
# ENV VARIABLES
# ============================
export FLAME_USERNAME="aylin.aydin@std.bogazici.edu.tr"
export FLAME_PWD="bogazici1234"

export PIXEL3DMM_PATH="/workspace/pixel3dmm"
export CAP4D_PATH="/workspace"

# PYTHONPATH – cap4d + pixel3dmm + flowface
export PYTHONPATH="/workspace:/workspace/pixel3dmm:/workspace/flowface:${PYTHONPATH}"

echo "Python path:"
python3 - << 'EOF'
import sys, pprint
pprint.pp(sys.path)
EOF

# ============================
# GEREKLİ PAKETLER
# ============================
python3 -m pip install --no-cache-dir tyro wandb

# ============================
# INSTALL PIXEL3DMM
# ============================
bash scripts/install_pixel3dmm.sh

# ============================
# RUN TRACKING
# ============================

#mkdir -p examples/output/aylin/

echo "--- Running reference image tracking ---"

# Process a directory of (reference) images
bash scripts/track_video_pixel3dmm.sh examples/input/aylin/images/cam0/ examples/output/aylin/reference_tracking/

echo "--- Running driving video tracking ---"
# Optional: process a driving (or reference) video
#bash scripts/track_video_pixel3dmm.sh examples/input/animation/example_video.mp4 examples/output/aylin/driving_video_tracking/


# ============================
# OPTIONAL: RUN FULL CAP4D PIPELINE
# ============================
echo "--- Running CAP4D test_pipeline ---"
bash scripts/generate_aylin.sh

echo "===== JOB FINISHED SUCCESSFULLY ====="