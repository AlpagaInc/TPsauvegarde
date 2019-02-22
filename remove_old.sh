#! /bin/bash

# Get oldest backup
OLDEST_DIR=$(ssh backup "ls -td */ /root/ | tail -n 1")

# Execute rm by ssh
ssh "rm -r backup:/root/$OLDEST_DIR"
