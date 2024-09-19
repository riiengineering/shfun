Describe 'fs/mode2octal'
  EnableSandbox

  SetupCommandFromFile mode2octal lib/fs/mode2octal.awk

  modes_txt=${SHELLSPEC_SPECFILE%/*}/modes.txt

  make_random_subset() {
    rand_modes_txt="${SHELLSPEC_WORKDIR:?}/rand_modes.txt"
    pick_random_lines 10% "${modes_txt}" >"${rand_modes_txt}"
  }
  BeforeAll 'make_random_subset'

  It "converts plain mode strings to the correct octal values"

    test_func() {
      @awk -F'\t' '{ print $2 }' <"${rand_modes_txt}" \
      | mode2octal
    }

    When call test_func

    check_output() {
      exec 7<"${rand_modes_txt}"

      while read -r _oct_is
      do
        read -r _oct_should _string <&7

        test "${_oct_is}" = "${_oct_should}" || {
          printf 'mode string %s was converted to %s (but expected %s)\n' \
                 "${_string}" "${_oct_is}" "${_oct_should}"
        }
      done <<EOF
$1
EOF

      exec 7>&-
    }

    The status should be success
    The result of function check_output should equal ''
    The stderr should equal ''
  End


  It "converts ls(1) long output to the correct octal values"

    test_func() {
      @awk -F'\t' '{ printf "%s 1 nobody nogroup 0 Jan  1  1970 %s"ORS, $2, $1 }' <"${rand_modes_txt}" \
      | mode2octal
    }

    When call test_func

    check_output() {
      exec 7<"${rand_modes_txt}"

      while read -r _oct_is
      do
        read -r _oct_should _string <&7

        test "${_oct_is}" = "${_oct_should}" || {
          printf 'mode string %s was converted to %s (but expected %s)\n' \
                 "${_string}" "${_oct_is}" "${_oct_should}"
        }
      done <<EOF
$1
EOF

      exec 7>&-
    }

    The status should be success
    The result of function check_output should equal ''
    The stderr should equal ''
  End
End
