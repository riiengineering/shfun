# Like POSIX getopts(1) but for GNU-style long options.
# Usage: geteopts_long optstring name arg...
#
# unlike GNU getopt_long() this function does not rearrange arguments so that
# all options are before positional arguments.
#
# e.g. getopts_long 'no-value,required-value:,optional-value?' _opt "$@"
#
# This function updates the global variables ${name}, OPTIND_LONG, OPTARG_LONG.
# The _LONG suffix is added for shells which don’t behave nicely when the
# standard OPTIND and OPTARG variables are re-used (hello, Zsh).


: ${OPTIND_LONG:=1}

unset -v OPTARG_LONG

case $#
in
(0|1)
	# invalid usage of getopts_long (needs at least two arguments)
	return 1
	;;
(*)
	# shift off all already processed arguments and save getopts_long arguments
	set -- "$@" "${1?}" "${2:?}"
	shift $((2 + OPTIND_LONG-1))

	# save one or two (option + OPTARG) arguments and shift off rest of ARGV
	case $#
	in
	(2)
		# no args (left)
		read -r "$2" <<-EOF
		EOF
		return 255  # -1
		;;
	(3)
		# only one argument left
		set -- "$@" "$1"
		shift $(($# - 3))
		;;
	(*)
		# more than one argument left
		set -- "$@" "$1" "$2"
		shift $(($# - 4))
		;;
	esac
esac

case $3
in
(--?*)
	# long option
	__optstring=${1#:}
	while :
	do
		# process component of __optstring
		case $3
		in
			(--${__optstring%%[:?,]*}=*)
				# option + value
				case ${__optstring%%,*}
				in
					(*':'|*'?')
						# has value
						read -r "$2" <<-EOF
						${__optstring%%[:?,]*}
						EOF
						OPTARG_LONG=${3#--${__optstring%%[:?,]*}=}
						: $((OPTIND_LONG+=1))
						;;
					(*)
						read -r "$2" <<-EOF
						?
						EOF
						case ${1}
						in
							(':'*)
								read -r "$2" <<-EOF
								?
								EOF
								OPTARG_LONG=${3%%=*}
								OPTARG_LONG=${OPTARG_LONG#--}
								;;
							(*)
								echo "option \`--${__optstring%%[:?,]*}' doesn't allow an argument" >&2
								;;
						esac
						: $((OPTIND_LONG+=1))
						;;
				esac

				break
				;;
			(--${__optstring%%[:?,]*})
				read -r "$2" <<-EOF
				${__optstring%%[:?,]*}
				EOF
				: $((OPTIND_LONG+=1))

				# option (value maybe in next argument)
				case ${__optstring%%,*}
				in
					(*':')
						case ${4+hasv}
						in
							(hasv)
								OPTARG_LONG=$4
								: $((OPTIND_LONG+=1))
								;;
							(*)
								case ${1}
								in
									(':'*)
										read -r "$2" <<-EOF
										:
										EOF
										OPTARG_LONG=${__optstring%%:*}
										;;
									(*)
										read -r "$2" <<-EOF
										?
										EOF
										echo "option \`$3' requires an argument" >&2
										;;
								esac

								break
								;;
						esac
						;;
					(*)
						# ignore possible arguments, as getopt_long(3) does
						;;
				esac

				break
				;;
		esac

		# strip first component from optstring if no match
		case ${__optstring}
		in
			(*,*)
				# next
				__optstring=${__optstring#*,}
				;;
			(*)
				read -r "$2" <<-EOF
				?
				EOF
				: $((OPTIND_LONG+=1))

				case ${1}
				in
					(':'*)
						OPTARG_LONG=${3%%=*}
						OPTARG_LONG=${OPTARG_LONG#--}
						;;
					(*)
						echo "unrecognized option \`$3'" >&2
						;;
				esac

				break
				;;
		esac
	done
	unset -v __optstring
	;;
(--)
	# skip -- and terminate option list
	read -r "$2" <<-EOF
	EOF
	: $((OPTIND_LONG+=1))
	return 255  # -1
	;;
(*)
	# positional argument
	read -r "$2" <<-EOF
	EOF
	return 255  # -1
	;;
esac

return 0
