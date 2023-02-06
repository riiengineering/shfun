# Convert arguments to a POSIX BRE-compatible form, i.e. escape special
# characters (incl. / delimiter)
sed -e 's:[].^$*/\[]:\\&:g' <<EOF
$*
EOF
