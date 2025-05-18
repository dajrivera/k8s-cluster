#!/bin/bash

ENVIRONMENT="dev"
KUSTOMIZE_SRC="kustomize/overlays/${ENVIRONMENT}"
RESOURCES=$(find ${KUSTOMIZE_SRC}/*/ -mindepth 1 -maxdepth 1 -type d)

while read RESOURCE; do
  APP=${RESOURCE#*$ENVIRONMENT/}
  MANIFESTS_DST="manifests/${ENVIRONMENT}/${APP}"
  #echo ENVIRONMENT=$ENVIRONMENT
  #echo RESOURCE=$RESOURCE
  #echo MANIFESTS_DST=$MANIFESTS_DST

  echo -n Generating ${APP}...
  kustomize build "$RESOURCE" --load-restrictor LoadRestrictionsNone --enable-helm --enable-alpha-plugins --enable-exec -o "$MANIFESTS_DST"
  echo done.
done <<<"$RESOURCES"
