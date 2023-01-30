__strfc_c=$#
while test $((__strfc_c)) -gt 0
do
	case $1
	in
		(-[[:alnum:]]=*)
			set -- "$@" -e "$(
				sed <<-ARG \
					-e 's|[/\\&]|\\&|g' \
					-e 's|^\(.\)=\(.*\)$|s/@%\1@/\2/|'
				${1#-}
				ARG
			)"
			;;
		(*)
			printf 'error: invalid format specifier definition: %s\n' "$1" >&2
			exit 1
			;;
	esac

	shift 1
	: $((__strfc_c-=1))
done
unset __strfc_c

# explanation:
#  replace format specifiers with intermediate representation:
#   s/%[^ ]/@&@/g
#  replace literal percents from intermediate representation:
#   s/@%%@/%/g
#  remove unknown format specifiers:
#   s/@%.@//g
sed \
	-e 's/%[^ ]/@&@/g' \
	-e 's/@%%@/%/g' \
	"$@" \
	-e 's/@%.@//g'
