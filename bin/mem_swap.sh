#!/bin/bash

# Get memory stats
page_size=$(sysctl -n hw.pagesize)
pages_free=$(vm_stat | awk '/Pages free/ {gsub(/\./, "", $3); print $3}')
pages_active=$(vm_stat | awk '/Pages active/ {gsub(/\./, "", $3); print $3}')
pages_inactive=$(vm_stat | awk '/Pages inactive/ {gsub(/\./, "", $3); print $3}')
pages_wired=$(vm_stat | awk '/Pages wired down/ {gsub(/\./, "", $4); print $4}')
pages_compressed=$(vm_stat | awk '/Pages occupied by compressor/ {gsub(/\./, "", $5); print $5}')

# Calculate memory in GB
mem_used=$(echo "scale=1; ($pages_active + $pages_inactive + $pages_wired + $pages_compressed) * $page_size / 1073741824" | bc)
mem_total=$(sysctl -n hw.memsize | awk '{print $1/1073741824}')

# Get swap usage
swap_used=$(sysctl vm.swapusage | awk '{print $7}' | sed 's/M//')

# Convert swap to GB
swap_gb=$(echo "scale=1; $swap_used / 1024" | bc)

# Output format
printf "%.1fG/%.0fG" $mem_used $mem_total
if (( $(echo "$swap_gb > 0.1" | bc -l) )); then
    printf " SW:%.1fG" $swap_gb
fi
