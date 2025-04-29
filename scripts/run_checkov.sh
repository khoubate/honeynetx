#!/bin/bash

# Run Checkov security scan and save JSON results

# Configuration
OUTPUT_DIR="$(pwd)/outputs/checkov"
SCAN_DIR="$(pwd)"
CHECKOV_IMAGE="docker.io/bridgecrew/checkov"
RESULT_FILE="checkov_results.json"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

echo "Starting Checkov scan..."
echo "Scan directory: ${SCAN_DIR}"
echo "Output file: ${OUTPUT_DIR}/${RESULT_FILE}"

# Run Checkov in Docker with JSON output
docker run --rm \
  -v "${SCAN_DIR}":/src \
  -v "${OUTPUT_DIR}":/output \
  "${CHECKOV_IMAGE}" \
  -d /src \
  --quiet \
  -o json --output-file-path "/output/${RESULT_FILE}"

# Check execution status
if [ $? -eq 0 ]; then
  echo -e "\nScan completed successfully"
  echo "Results saved to: ${OUTPUT_DIR}/${RESULT_FILE}"
else
  echo -e "\nScan failed" >&2
  exit 1
fi