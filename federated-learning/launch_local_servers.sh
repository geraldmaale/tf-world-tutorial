#!/bin/sh

rm -f /tmp/config.json

read -r -a instances <<< "$@"

length=${#instances[@]}

port=4000
i=0
echo "{" >> /tmp/config.json
for instance in "${instances[@]}"
do
    if [ "$i" = "$((length-1))" ]; then
        echo "  \"$instance\": \"localhost:$port\"" >> /tmp/config.json
    else
        echo "  \"$instance\": \"localhost:$port\"," >> /tmp/config.json
    fi
    port=$((port+1))
    i=$((i+1))
done
echo "}" >> /tmp/config.json

pids=()
for instance in "${instances[@]}"
do
    python -m tf_encrypted.player --config /tmp/config.json $instance > /dev/null 2> "${instance}-errors.log" &
    pids+=( $! )
done

echo ${pids[@]} > servers.pid

echo "When done run './kill_servers.sh' to clean up the running servers."