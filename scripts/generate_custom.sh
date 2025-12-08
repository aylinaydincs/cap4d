#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: bash generate_custom.sh <user_name> [gen_config] [avatar_config] [anim_sequence]"
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

# Config isimlerinden kısa tag çıkar
GEN_TAG="$(basename "$GEN_CONFIG" .yaml)"
AVATAR_TAG="$(basename "$AVATAR_CONFIG" .yaml)"

# Tüm run için uniq output id
RUN_ID="${USER_NAME}__${GEN_TAG}__${AVATAR_TAG}__${ANIM_SEQUENCE}"

# Ana output klasörü
OUT_ROOT="examples/output/${RUN_ID}"

echo "=== Running generate_custom.sh for user: $USER_NAME ==="
echo "    GEN_CONFIG      : $GEN_CONFIG"
echo "    AVATAR_CONFIG   : $AVATAR_CONFIG"
echo "    ANIM_SEQUENCE   : $ANIM_SEQUENCE"
echo "    RUN_ID          : $RUN_ID"
echo "    OUT_ROOT        : $OUT_ROOT"

mkdir -p "$OUT_ROOT"

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
    local START_TS
    START_TS=$(date +%s)

    # Run the actual command
    "$@"

    local END_TS
    END_TS=$(date +%s)
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
        --config_path "$GEN_CONFIG" \
        --reference_data_path "examples/input/${USER_NAME}/" \
        --output_path "${OUT_ROOT}/"

# 2) GaussianAvatar training
log_step "GaussianAvatar training" \
    python gaussianavatars/train.py \
        --config_path "$AVATAR_CONFIG" \
        --source_paths "${OUT_ROOT}/reference_images/" "${OUT_ROOT}/generated_images/" \
        --model_path "${OUT_ROOT}/avatar/"

# 3) Animation render + export
log_step "Animation render + export" \
    python gaussianavatars/animate.py \
        --model_path "${OUT_ROOT}/avatar/" \
        --target_animation_path "examples/input/animation/${ANIM_SEQUENCE}/fit.npz" \
        --target_cam_trajectory_path "examples/input/animation/${ANIM_SEQUENCE}/orbit.npz" \
        --output_path "${OUT_ROOT}/animation_${ANIM_SEQUENCE}/" \
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
echo " Run ID                    : $RUN_ID"
echo " Output root               : $OUT_ROOT"
echo "========================================================"
echo ""
