#!/bin/bash

ENVIRONMENT="dev"
KUSTOMIZE_SRC="kustomize/overlays/${ENVIRONMENT}"
RESOURCES=$(find ${KUSTOMIZE_SRC}/*/ -mindepth 1 -maxdepth 1 -type d)

while read RESOURCE; do
  APP="${RESOURCE#*$ENVIRONMENT/}"
  HELM_BASE="helm/base/${APP}"
  HELM_OVERLAY="helm/overlays/${ENVIRONMENT}/${APP}"
  KUSTOMIZE_BASE="kustomize/base/${APP}"
  MANIFESTS_DST="manifests/${ENVIRONMENT}/${APP}"

  # echo APP=$APP
  # echo ENVIRONMENT=$ENVIRONMENT
  # echo RESOURCE=$RESOURCE
  # echo HELM_BASE=$HELM_BASE
  # echo HELM_OVERLAY=$HELM_OVERLAY
  # echo KUSTOMIZE_BASE=$KUSTOMIZE_BASE
  # echo MANIFESTS_DST=$MANIFESTS_DST

  echo -n "Generating manifest files for ${APP}..."

  # check for changes
  # need to check app specific helm/{base,overlays}, kustomize/{base,overlays}
  CHANGES_LIST=$(git diff --staged --name-only HEAD "$HELM_BASE" "$HELM_OVERLAY" "$KUSTOMIZE_BASE" "$RESOURCE")
  if [ ! -z "$CHANGES_LIST" ]; then
    # cleanup existing manifests
    rm -rf "${MANIFESTS_DST}"

    # create output directory if it does not exist
    mkdir -p "$MANIFESTS_DST"

    # build new manifests
    kustomize build "$RESOURCE" --load-restrictor LoadRestrictionsNone --enable-helm --enable-alpha-plugins --enable-exec -o "$MANIFESTS_DST"

    # when run as commit hook, we should
    # add generated files to staging
    # git add "$MANIFESTS_DST"

    echo "done."

    continue
  fi

  echo "skipping (no changes detected)."
done <<<"$RESOURCES"