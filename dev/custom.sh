#!/bin/bash

#SBATCH --job-name=cap4d_pixel3dmm
#SBATCH --output=logs/cap4d_pix3d-%j.out
#SBATCH --error=logs/cap4d_pix3d-%j.err

#SBATCH --container-image=ghcr.io#aylinaydincs/cap4d:latest
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
export FLAME_USERNAME=aylin.aydin@std.bogazici.edu.tr
export FLAME_PWD=bogazici1234
export PIXEL3DMM_PATH=$(realpath "./pixel3dmm")  # set this to where you would like to clone the Pixel3DMM repo (absolute path)
export CAP4D_PATH=$(realpath "./")  # set this to the cap4d directory (absolute path)

# ============================
# INSTALL PIXEL3DMM
# ============================
bash scripts/install_pixel3Dmm.sh

# ============================
# RUN TRACKING
# ============================

mkdir -p examples/output/aylin/

echo "--- Running reference image tracking ---"

# Process a directory of (reference) images
bash scripts/track_video_pixel3dmm.sh examples/input/aylin/images/cam0/ examples/output/aylin/reference_tracking/

echo "--- Running driving video tracking ---"
# Optional: process a driving (or reference) video
bash scripts/track_video_pixel3dmm.sh examples/input/animation/example_video.mp4 examples/output/aylin/driving_video_tracking/


# ============================
# OPTIONAL: RUN FULL CAP4D PIPELINE
# ============================
echo "--- Running CAP4D test_pipeline ---"
bash scripts/generate_aylin.sh

echo "===== JOB FINISHED SUCCESSFULLY ====="