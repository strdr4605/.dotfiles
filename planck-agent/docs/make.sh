#!/bin/bash
# Regenerate the planck-agent architecture diagram.
#
# Steps:
#   1. Render planck.svg from ~/.config/planck-agent/config.json (Python).
#   2. Rasterize planck.svg -> planck.png (rsvg-convert) for d2 image shape.
#   3. Render architecture.d2 and legend.d2 -> {svg,png}.
#
# Requirements: d2, python3, rsvg-convert.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
VENV="${HERE}/.venv"

if [[ ! -x "${VENV}/bin/python" ]]; then
  python3 -m venv "${VENV}"
  "${VENV}/bin/pip" install --quiet svgwrite
fi

echo "==> Generating planck.svg from config.json"
"${VENV}/bin/python" "${HERE}/gen_planck_svg.py"
"${VENV}/bin/python" "${HERE}/gen_planck_svg.py" --legend

echo "==> Rasterizing planck.svg -> planck.png"
rsvg-convert -w 846 -h 360 "${HERE}/planck.svg" -o "${HERE}/planck.png"
rsvg-convert -w 846 -h 360 "${HERE}/planck-legend.svg" -o "${HERE}/planck-legend.png"

echo "==> Rendering architecture.d2 -> architecture.{svg,png}"
d2 --theme=300 --sketch --scale=0.7 "${HERE}/architecture.d2" "${HERE}/architecture.png"
d2 --theme=300 --sketch --scale=0.7 "${HERE}/architecture.d2" "${HERE}/architecture.svg"

echo "==> Rendering legend.d2 -> legend.{svg,png}"
d2 --theme=300 --sketch --scale=0.7 "${HERE}/legend.d2" "${HERE}/legend.png"
d2 --theme=300 --sketch --scale=0.7 "${HERE}/legend.d2" "${HERE}/legend.svg"

echo "Done."
ls -lh "${HERE}"/planck.{svg,png} "${HERE}"/architecture.{svg,png} "${HERE}"/legend.{svg,png}
