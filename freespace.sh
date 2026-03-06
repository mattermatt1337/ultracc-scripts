#!/bin/bash

# ------------- Config --------------
MIN_FREE_PERCENT=5
# -----------------------------------

QUOTA_OUTPUT=$(quota -s 2>/dev/null | awk 'NR==3 {print $2, $4}')

if [ -z "$QUOTA_OUTPUT" ]; then
    echo "[freespace] Can't get freespace"
    exit 1
fi

USED_RAW=$(echo "$QUOTA_OUTPUT" | awk '{print $1}' | tr -d 'G*')
LIMIT_RAW=$(echo "$QUOTA_OUTPUT" | awk '{print $2}' | tr -d 'G*')

USED_GB=$(awk "BEGIN {printf \"%.0f\", $USED_RAW * 1.073741824}")
LIMIT_GB=$(awk "BEGIN {printf \"%.0f\", $LIMIT_RAW * 1.073741824}")
FREE_GB=$(awk "BEGIN {printf \"%.0f\", $LIMIT_GB - $USED_GB}")
FREE_PERCENT=$(awk "BEGIN {printf \"%d\", (($LIMIT_GB - $USED_GB) / $LIMIT_GB) * 100}")

echo "[freespace] Used: ${USED_GB} GB / ${LIMIT_GB} GB | Free: ${FREE_GB} GB (${FREE_PERCENT}%)"

if [ "$FREE_PERCENT" -lt "$MIN_FREE_PERCENT" ]; then
    echo "[freespace] STOP - Only ${FREE_PERCENT}% free storage (minimum: ${MIN_FREE_PERCENT}%)"
    exit 1
fi

echo "[freespace] OK - Enough storage"
exit 0
