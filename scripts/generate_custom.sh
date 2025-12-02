#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: bash generate_custom.sh <user_name>"
    exit 1
fi

USER_NAME=$1

echo "=== Running generate_custom.sh for user: $USER_NAME ==="

# ---------------------------
# Timing helpers
# ---------------------------

TOTAL_START_TS=$(date +%s)

# Arrays to store step names & durations
declare -a STEP_NAMES=()
declare -a STEP_DURATIONS=()

log_step() {
    local STEP_NAME="$1"
    shift

    echo ""
    echo ">>> [STEP START] $STEP_NAME"
    local START_TS=$(date +%s)

    # Run the actual command
    "$@"

    local END_TS=$(date +%s)
    local DURATION=$((END_TS - START_TS))

    STEP_NAMES+=("$STEP_NAME")
    STEP_DURATIONS+=("$DURATION")

    echo "<<< [STEP END]   $STEP_NAME (took ${DURATION}s)"
    echo ""
}

format_duration() {
    local SECONDS_TOTAL=$1
    local M=$((SECONDS_TOTAL / 60))
    local S=$((SECONDS_TOTAL % 60))
    if [ "$M" -gt 0 ]; then
        printf "%d min %02d s" "$M" "$S"
    else
        printf "%d s" "$S"
    fi
}

# ---------------------------
# Pipeline steps
# ---------------------------

# 1) MMDM image generation
log_step "MMDM image generation" \
    python cap4d/inference/generate_images.py \
        --config_path configs/generation/high_quality.yaml \
        --reference_data_path examples/input/"$USER_NAME"/ \
        --output_path examples/output/"$USER_NAME"/

# 2) GaussianAvatar training
log_step "GaussianAvatar training" \
    python gaussianavatars/train.py \
        --config_path configs/avatar/high_quality.yaml \
        --source_paths examples/output/"$USER_NAME"/reference_images/ examples/output/"$USER_NAME"/generated_images/ \
        --model_path examples/output/"$USER_NAME"/avatar/

# 3) Animation render + export
log_step "Animation render + export" \
    python gaussianavatars/animate.py \
        --model_path examples/output/"$USER_NAME"/avatar/ \
        --target_animation_path examples/input/animation/sequence_01/fit.npz \
        --target_cam_trajectory_path examples/input/animation/sequence_01/orbit.npz \
        --output_path examples/output/"$USER_NAME"/animation_01/ \
        --export_ply 1 \
        --compress_ply 0

# ---------------------------
# Final summary
# ---------------------------

TOTAL_END_TS=$(date +%s)
TOTAL_DURATION=$((TOTAL_END_TS - TOTAL_START_TS))

echo ""
echo "==================== Timing Summary ===================="
for i in "${!STEP_NAMES[@]}"; do
    NAME="${STEP_NAMES[$i]}"
    DUR="${STEP_DURATIONS[$i]}"
    printf " - %-28s : %s\n" "$NAME" "$(format_duration "$DUR")"
done

echo "--------------------------------------------------------"
echo " Total pipeline time       : $(format_duration "$TOTAL_DURATION")"
echo "========================================================"
echo ""
