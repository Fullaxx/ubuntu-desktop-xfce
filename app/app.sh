#!/bin/bash
# This script runs as root

# Remove leftovers from a previous run (docker restart)
source /app/cleanup.sh

source /app/imagestart.sh

source /app/tiger.sh
