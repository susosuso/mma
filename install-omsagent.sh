#!/bin/bash

# Download oms agent
echo "Download oms agent..."
wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh 

# Onboard Oms agent
echo "Onboard Oms agent..."
sh onboard_agent.sh "$@"

echo "Launching terminal..."
bash