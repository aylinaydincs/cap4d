#!/bin/bash
set -e

# =========================================================
# Usage
# =========================================================
if [ -z "$1" ]; then
    echo "Usage:"
    echo "  bash train_and_animate_gaussianavatar.sh <run_name> [avatar_config] [anim_sequence]"
    echo ""
    echo "Arguments:"
    echo "  <run_name>      : output klasör adı (örn: aylin_hq)"
    echo "  [avatar_config]: default = configs/avatar/high_quality.yaml"
    echo "  [anim_sequence]: default = sequence_01"
    exit 1
fi

# =========================================================
# Arguments
# =========================================================
RUN_NAME="$1"
AVATAR_CONFIG="${2:-configs/avatar/high_quality.yaml}"
ANIM_SEQUENCE="${3:-sequence_01}"

AVATAR_TAG="$(basename "$AVATAR_CONFIG" .yaml)"

# =========================================================
# Paths
# =========================================================
OUT_ROOT="examples/output/${RUN_NAME}"

REF_DIR="${OUT_ROOT}/reference_images/"
GEN_DIR="${OUT_ROOT}/generated_images/"
AVATAR_DIR="${OUT_ROOT}/avatar"
ANIM_DIR="${OUT_ROOT}_${AVATAR_TAG}/animation_${ANIM_SEQUENCE}"

# =========================================================
# Info
# =========================================================
echo "========================================================="
echo " GaussianAvatar TRAIN + ANIMATE"
echo "---------------------------------------------------------"
echo " RUN_NAME        : $RUN_NAME"
echo " AVATAR_CONFIG   : $AVATAR_CONFIG"
echo " ANIM_SEQUENCE   : $ANIM_SEQUENCE"
echo "---------------------------------------------------------"
echo " REF_DIR         : $REF_DIR"
echo " GEN_DIR         : $GEN_DIR"
echo "========================================================="

mkdir -p "$AVATAR_DIR" "$ANIM_DIR"

# =========================================================
# GPU check
# =========================================================
echo ""
echo ">>> GPU Check"
nvidia-smi || echo "⚠️ WARNING: GPU not detected"

# =========================================================
# Timing helpers
# =========================================================
TOTAL_START_TS=$(date +%s)
declare -a STEP_NAMES=()
declare -a STEP_DURATIONS=()

log_step() {
    local NAME="$1"
    shift

    echo ""
    echo ">>> [STEP START] $NAME"
    local START_TS
    START_TS=$(date +%s)

    "$@"

    local END_TS
    END_TS=$(date +%s)
    local DUR=$((END_TS - START_TS))

    STEP_NAMES+=("$NAME")
    STEP_DURATIONS+=("$DUR")

    echo "<<< [STEP END]   $NAME (${DUR}s)"
}

format_duration() {
    local T=$1
    printf "%02d min %02d s" $((T / 60)) $((T % 60))
}

# =========================================================
# STEP 1 — GaussianAvatar training
# =========================================================
log_step "GaussianAvatar training" \
    python gaussianavatars/train.py \
        --config_path "$AVATAR_CONFIG" \
        --source_paths "$REF_DIR" "$GEN_DIR" \
        --model_path "$AVATAR_DIR"

# =========================================================
# STEP 2 — Animation render + export
# =========================================================
log_step "Animation render + export" \
    python gaussianavatars/animate.py \
        --model_path "$AVATAR_DIR" \
        --target_animation_path "examples/input/animation/${ANIM_SEQUENCE}/fit.npz" \
        --target_cam_trajectory_path "examples/input/animation/${ANIM_SEQUENCE}/orbit.npz" \
        --output_path "$ANIM_DIR" \
        --export_ply 1 \
        --compress_ply 0

# =========================================================
# Summary
# =========================================================
TOTAL_END_TS=$(date +%s)
TOTAL_DUR=$((TOTAL_END_TS - TOTAL_START_TS))

echo ""
echo "==================== SUMMARY ===================="
for i in "${!STEP_NAMES[@]}"; do
    printf " - %-26s : %s\n" \
        "${STEP_NAMES[$i]}" \
        "$(format_duration "${STEP_DURATIONS[$i]}")"
done
echo "-------------------------------------------------"
echo " Total time  : $(format_duration "$TOTAL_DUR")"
echo " Output dir  : $OUT_ROOT"
echo "================================================="
