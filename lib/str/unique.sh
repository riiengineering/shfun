# removes duplicate lines (without sorting input lines)
awk '!x[$0]++'
