# Quotes all arguments into a single "shell" double-quoted string.
#
# NB: bash, when not in POSIX mode, will expand history using the !
#     character in double quoted strings.
#     This function will not escape ! characters because it would result in
#     incorrect results in POSIX shells.
#     e.g.: printf '%s\n' 'echo hello' 'x="!echo"' 'echo "$x"' | bash -i
#
# Usage:
#  - shdquot foo bar baz
#  - shdquot 'foo bar baz'

sed -e 's/["$`\]/\\&/g' -e '1s/^/"/' -e '$s/$/"/' <<EOF
$*
EOF
