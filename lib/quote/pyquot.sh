# Quotes all arguments into a single Python string.
#
# Usage:
#  - pyquot foo bar baz
#  - pyquot 'foo bar baz'

sed -e 's/[\"]/\\&/g' -e '1s/^/"/' -e '$s/$/"/' <<EOF
$*
EOF
