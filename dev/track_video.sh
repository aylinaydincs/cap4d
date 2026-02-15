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

# --------------------------------------------------
# INSTALL ENVIRONMENT.YML PACKAGES VIA PIP
# --------------------------------------------------
pip install \
    numpy \
    scipy \
    opencv-python \
    imageio \
    matplotlib \
    tqdm \
    scikit-image \
    pyyaml \
    loguru \
    mediapy \
    onnxruntime \
    insightface \
    tensorboard \
    distinctipy \
    pyvista \
    face-alignment \
    tyro \
    wandb \
    environs

# --------------------------------------------------
# L2CS (eye tracking dependency)
# --------------------------------------------------
pip install git+https://github.com/Ahmednull/L2CS-Net.git

# --------------------------------------------------
# BUILD FACEBOXES (CRITICAL)
# --------------------------------------------------
cd pixel3dmm/src/pixel3dmm/preprocessing/PIPNet/FaceBoxesV2/utils/nms

python setup.py build_ext --inplace

cd /workspace

pip install git+https://github.com/facebookresearch/pytorch3d.git@stable
pip install git+https://github.com/NVlabs/nvdiffrast.git

pip instal -e .

./install_preprocessing_pipeline.sh


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
