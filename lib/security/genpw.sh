# Generates a password with secure input from /dev/random
#
# Usage: pwgen [length] [allowed characters]
#
# Examples:
#
#   pwgen
#      use defaults
#   pwgen 16
#      generate a 16 characters long password
#   pwgen 20 '[:alnum:]'
#      use only alphanumeric characters to create a 20 characters long password

{
	LC_ALL=C \
	tr -d -c "${2:-[:alnum:].,/?!$%^&*()=+_-}" \
	| dd bs=1 count="${1:-32}"
} </dev/random 2>/dev/null
