#!/bin/bash

base_folder=${1:-""}

# Paths - referenced via base module
BASE_CONFIG_A="${base_folder}promtail-base-a.yaml"
BASE_CONFIG_B="${base_folder}promtail-base-b.yaml"
PIPELINE_CONFIG="${base_folder}generated/pipeline-docker.yaml"
FINAL_CONFIG="${base_folder}generated/promtail-config.yaml"

if [ ! -d "generated" ]; then
  mkdir "generated"
  chown -R usr_collector:grp_collector "generated"
fi

# Generate pipeline-docker.yaml
cat <<EOF > "$PIPELINE_CONFIG"
pipeline_stages:
  - json:
      expressions:
        log: log
  - output:
      source: log
  - regex:
      expression: '/var/lib/docker/containers/(?P<container_id>[a-f0-9]+)/.*\.log'
      source: filename
EOF

# Add replace stages: map container ID -> name
docker ps --no-trunc --format '{{.ID}} {{.Names}}' | while read -r id name; do
  cat <<EOF >> "$PIPELINE_CONFIG"
  - replace:
      expression: '(${id})'
      source: container_id
      replace: '${name}'
EOF
done

cat <<EOF >> "$PIPELINE_CONFIG"
  - labels:
      container_name: container_id
EOF

chown usr_collector:grp_collector $BASE_CONFIG_A
chown usr_collector:grp_collector $BASE_CONFIG_B

if [ ! -f $FINAL_CONFIG ]; then
  touch $FINAL_CONFIG
fi
chown usr_collector:grp_collector $FINAL_CONFIG
chmod g+w $FINAL_CONFIG

# Merge files
echo "$(cat $BASE_CONFIG_A)" > $FINAL_CONFIG
sed 's/^/    /' "$PIPELINE_CONFIG" >> $FINAL_CONFIG
echo "$(cat $BASE_CONFIG_B)" >> $FINAL_CONFIG

echo "✅ Merged config generated at $FINAL_CONFIG"