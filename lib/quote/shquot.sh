# Quotes all arguments into a single "shell" string.
#
# Usage:
#  - shquot foo bar baz
#  - shquot 'foo bar baz'

sed -e "s/'/'\\\\''/g" -e "1s/^/'/" -e "\$s/\$/'/" <<EOF
$*
EOF
