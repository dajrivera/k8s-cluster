#!/bin/bash

RESOURCE_LIST=$(cat) # read the `kind: ResourceList` from stdin
CONF_PATH=$(echo "$RESOURCE_LIST" | yq e '.functionConfig.spec.configPath' - )
OUTPUT_PATH=$(echo "$RESOURCE_LIST" | yq e '.functionConfig.spec.outputPath' - )

CONF_PATH_GIT="$(git rev-parse --show-prefix)${CONF_PATH}"
# CONF_HASH=$(git ls-files -co --exclude-standard --full-name ":(glob)${CONF_PATH}/**" | git hash-object --stdin-paths | git hash-object --stdin)
CONF_HASH=$(find "$PWD/$CONF_PATH" -type f -print | git hash-object --stdin-paths | git hash-object --stdin)

#cp -r $CONF_PATH/* $OUTPUT_PATH

cat <<EOF
kind: ResourceList
items:
- kind: ConfigMap
  apiVersion: v1
  metadata:
    name: cluster-config-hash
    namespace: omni-system
  data:
    clusterConfigPath: $CONF_PATH_GIT
    clusterConfigHash: $CONF_HASH
EOF