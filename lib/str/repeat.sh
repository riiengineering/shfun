while case $(($1)) in (0) ! : ;; esac
do
	printf '%s' "$2"
	set -- $(($1 - 1)) "$2"
done
printf '\n'
