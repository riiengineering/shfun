# Quotes all arguments into a single "shell" string.
#
# Usage:
#  - quote foo bar baz
#  - quote 'foo bar baz'

sed -e "s/'/'\\\\''/g" -e "1s/^/'/" -e "\$s/\$/'/" <<EOF
$*
EOF
