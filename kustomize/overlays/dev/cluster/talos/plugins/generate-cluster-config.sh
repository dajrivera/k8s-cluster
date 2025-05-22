#!/bin/bash

RESOURCE_LIST=$(cat) # read the `kind: ResourceList` from stdin
CONF=($(yq e '.functionConfig.spec.configPaths[]' <<<"$RESOURCE_LIST"))
OUTPUT_PATH=$(yq e '.functionConfig.spec.outputPath' <<<"$RESOURCE_LIST")

GIT_ROOT=$(git rev-parse --show-toplevel)
# file/folder renames/moves can change the order of file hashes impacting the final hash.
# we sort file hashes before generating the final config hash to be consistent.
CONF_HASH=$(find ${CONF[@]/#/${GIT_ROOT}} -name '*.yaml' -type f -print | git hash-object --stdin-paths | sort -ds | git hash-object --stdin)

cat <<EOF
kind: ResourceList
items:
- kind: ConfigMap
  apiVersion: v1
  metadata:
    name: cluster-config-hash
    namespace: talos-system
  data:
    clusterConfigHash: $CONF_HASH
EOF