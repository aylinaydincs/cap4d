#!/bin/bash

# Usage check
if [ -z "$1" ]; then
    echo "Usage: bash test_pipeline.sh <user_name>"
    exit 1
fi

USER_NAME=$1

echo "Running pipeline for user: $USER_NAME"

# Create output directory
mkdir -p examples/output/$USER_NAME

############################################
# 1. Test MMDM image generation
############################################
python cap4d/inference/generate_images.py \
    --config_path configs/generation/high_quality.yaml \
    --reference_data_path examples/input/$USER_NAME/ \
    --output_path examples/output/$USER_NAME/


############################################
# 2. Test GaussianAvatars fitting
############################################
python gaussianavatars/train.py \
    --config_path configs/avatar/default.yaml \
    --source_paths examples/output/$USER_NAME/reference_images/ examples/output/$USER_NAME/generated_images/ \
    --model_path examples/output/$USER_NAME/avatar/


############################################
# 3. Test rendering + export
############################################
python gaussianavatars/animate.py \
    --model_path examples/output/$USER_NAME/avatar/ \
    --target_animation_path examples/input/animation/sequence_01/fit.npz \
    --target_cam_trajectory_path examples/input/animation/sequence_01/orbit.npz  \
    --output_path examples/output/$USER_NAME/animation_01/ \
    --export_ply 1 \
    --compress_ply 0