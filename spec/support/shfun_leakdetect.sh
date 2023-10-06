EnableLeakDetector() {
	leakdir=${SHELLSPEC_WORKDIR:?}/leakdetector
	@mkdir "${leakdir:?}" && export leakdir

	shellspec_before_call '_LeakBeforeCallHook'
	shellspec_after_call  '_LeakAfterCallHook'
	shellspec_before  '_LeakBeforeHook'
	shellspec_after   '_LeakAfterHook'
}

LeakAllowVariable() {
	LEAK_ALLOWED_VARIABLES=${LEAK_ALLOWED_VARIABLES-}${LEAK_ALLOWED_VARIABLES:+,}$1
	export LEAK_ALLOWED_VARIABLES
}

_LeakDumpVariables() {
	if test -n "${ZSH_VERSION+zsh}"
	then
		typeset
	else
		set
	fi \
	| _LeakFilterVariables
}

_LeakFilterVariables() {
	@awk -v allow="${LEAK_ALLOWED_VARIABLES-}" '
	BEGIN {
		split(allow, ignore, ",")
		i = length(ignore)

		ignore[++i] = "_"

		ignore[++i] = "FUNCNAME"
		ignore[++i] = "PPID"
		ignore[++i] = "RANDOM"
		ignore[++i] = "SECONDS"
		ignore[++i] = "SHLVL"

		# ShellSpec
		ignore[++i] = "SHELLSPEC_[A-Za-z0-9_]+"
		ignore[++i] = "shellspec_output_raw"
		ignore[++i] = "__extcmd_path"

		# bash
		ignore[++i] = "BASH_[A-Z_]+"
		ignore[++i] = "PIPESTATUS"

		# ksh
		ignore[++i] = "_AST_FEATURES"

		# mksh
		ignore[++i] = "KSH_MATCH"
		ignore[++i] = "BASHPID"
		ignore[++i] = "EPOCHREALTIME"
		ignore[++i] = "PIPESTATUS\\[.+\\]"

		# zsh
		ignore[++i] = "ZSH_[A-Z_]+"
		ignore[++i] = "zsh_[a-z_]+"
		ignore[++i] = "LINENO"
		ignore[++i] = "TTYIDLE"
		ignore[++i] = "pipestatus"
		ignore[++i] = "ARGC"
		ignore[++i] = "argv"
		ignore[++i] = "@"
		ignore[++i] = "'\''[#*?$]'\''"

		# shfun
		ignore[++i] = "LEAK_[A-Z_]+"
	}

	!cont {
		vname = substr($0, 1, index($0, "=")-1)

		if (substr($0, length(vname)+2) ~ /^'\''(.*[^'\''])*$/) {
			cont = "'\''"
		} else if (substr($0, length(vname)+2) ~ /^\((.*[^)])*$/) {
			cont = "("
		} else {
			cont = 0
		}

		keep = (!!vname)

		for (k in ignore) {
			if (vname ~ ("^" ignore[k] "$")) {
				keep = 0
				break
			}
		}
	}

	cont == "'\''" && /(^|[^\\])'\''$/ { cont = 0 }
	cont == "(" && /(^|[^\\])\)$/ { cont = 0 }

	keep
	'
}

_LeakAssert() {
	if ! {
		test -s "${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.before" \
		&& test -s "${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.after"
	}
	then
		return 0
	fi

	# This is a bit ugly, but it’ll have to do for now :-)
	@diff -U0 \
		"${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.before" \
		"${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.after" \
	| @awk '
	  NR < 3 && (/^+++ / || /^--- /) { next }
	  /^@@ .* @@$/ { next }

	  /^[+-]/ {
		  if (!_hdr) {
			  print "The variables have been modified:"
		  }

		  print
	  }
	  ' >&2
}

_LeakBeforeHook() {
	LEAK_DUMPFILE="${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}"
	export LEAK_DUMPFILE
}
_LeakBeforeCallHook() {
	_LeakDumpVariables >"${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.before"
}

_LeakAfterCallHook() {
	_LeakDumpVariables >"${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.after"
	_LeakAssert
}

_LeakAfterHook() {
	if test -s "${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.cmdenter" \
		&& test -s "${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.cmdexit"
	then
		_LeakFilterVariables \
		<"${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.cmdenter" \
		>"${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.before"
		_LeakFilterVariables \
		<"${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.cmdexit" \
		>"${leakdir:?}/${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}.after"
	fi

	_LeakAssert
}
