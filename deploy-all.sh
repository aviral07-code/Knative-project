#!/bin/bash
set -euo pipefail

if [ -z "${DOCKER_USER:-}" ]; then
  echo "Set DOCKER_USER to your Docker Hub username."
  exit 1
fi

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "${ROOT_DIR}"

mkdir -p manifests/generated

for chain in concurrency rps custom; do
  sed "s/YOUR_DOCKER_USER/${DOCKER_USER}/g" \
    "chain-${chain}.yaml" \
    > "chain-${chain}-deploy.yaml"
  kubectl apply -f "chain-${chain}-deploy.yaml"
done

kubectl wait --for=condition=ready ksvc \
  func-a-conc func-b-conc func-c-conc \
  func-a-rps  func-b-rps  func-c-rps  \
  func-a-custom func-b-custom func-c-custom \
  --timeout=300s

kubectl get ksvc
