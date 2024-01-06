#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Utility function to modify startup command
modify_startup() {
  MODIFIED_STARTUP=$(echo "$1" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
  echo "$MODIFIED_STARTUP"
}

# Modify the startup command
MODIFIED_STARTUP=$(modify_startup "$STARTUP")

# Aikar Flags
if [ "${AIKAR_FLAGS}" = 1 ]; then
    MODIFIED_STARTUP=$(echo "${MODIFIED_STARTUP}" | sed -E 's/-Xmx([0-9]+)[KMG]?/& -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Daikars.new.flags=true/')
    echo -e "\033[1;32mBLAZEDMC \033[1;30m» \033[0mEnabled Aikar's Flags"
fi

# Print Java version
printf "\033[1;32mBLAZEDMC \033[1;30m» \033[0m java -version\n"
java -version

# Print startup command to console
echo -e "\033[1;32mBLAZEDMC \033[1;30m» \033[0m ${MODIFIED_STARTUP}"

# Run the server
eval "$MODIFIED_STARTUP"