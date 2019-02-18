#!/bin/bash
# Checks if the ZooKeeper instance is alive by sending the four letter word ruok.
test "$(echo ruok | nc -q 3 127.0.0.1 ${ZK_CLIENT_PORT:-2181})" == "imok" && exit 0 || exit 1
