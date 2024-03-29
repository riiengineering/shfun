__strfc_c=$#
while case $((__strfc_c)) in (0) ! : ;; esac
do
	case $1
	in
		(-[0-9A-Za-z]=*)
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

	shift
	: $((__strfc_c-=1))
done
unset -v __strfc_c

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
