#!/bin/bash
#SBATCH --job-name=pixel3dmm_track
#SBATCH --output=logs/track_%j.out
#SBATCH --error=logs/track_%j.err

#SBATCH --container-image=ghcr.io\#aylinaydincs/cap4d:latest
#SBATCH --container-mounts /users/aylin.aydin/experiments/cap4d:/workspace
#SBATCH --gpus=1
#SBATCH --cpus-per-gpu=4
#SBATCH --mem=40G
#SBATCH --time=12:00:00

echo "===== JOB START ====="
date

# -----------------------
# ENV
# -----------------------
cd /workspace
echo "Working directory: $(pwd)"

export PYTHONPATH="$(realpath "./"):${PYTHONPATH}"
export CAP4D_PATH=/workspace
export PIXEL3DMM_PATH=/workspace/pixel3dmm

echo "Installing pixel3dmm deps..."
ppython -m pip install --upgrade pip

cd /workspace

export PYTHONPATH=/workspace/pixel3dmm/src:$PYTHONPATH

python -m pip install --upgrade pip

pip install -r clean_requirements.txt

# native extension (still needed)
cd pixel3dmm/src/pixel3dmm/preprocessing/PIPNet/FaceBoxesV2/utils/nms
python setup.py build_ext --inplace


# -----------------------
# PATHS
# -----------------------
BASE=/users/aylin.aydin/experiments/cap4d/nersemble-data
OUT=test/eval_data

mkdir -p logs

# -----------------------
# LOOP OVER ALL VIDEOS
# -----------------------
for video in $BASE/*/*.mp4; do

    ID=$(basename $(dirname "$video"))
    OUTDIR="$OUT/$ID/driving_tracking"

    echo "----------------------------------"
    echo "Processing ID: $ID"
    echo "Video: $video"
    echo "Output: $OUTDIR"

    mkdir -p "$OUTDIR"

    bash scripts/track_video_pixel3dmm.sh \
        "$video" \
        "$OUTDIR"

done

echo "===== JOB FINISHED ====="
date
