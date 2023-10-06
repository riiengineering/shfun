Describe 'security/genpw'
  EnableSandbox
  AllowExternalCommand dd
  AllowExternalCommand tr

  SetupCommandFromFile genpw lib/security/genpw.sh

  # prepare and clean up temporary directory for password cache
  BeforeAll  'pwfildir=${SHELLSPEC_WORKDIR:?}/pwcache; @mkdir "${pwfildir:?}" && export pwfildir'
  BeforeEach 'export pwfilnam=${SHELLSPEC_EXAMPLE_ID:?}-${SHELLSPEC_EXAMPLE_NO:?}'
  AfterAll '@rm -R "${pwfildir:?}"'

  zsh_no_nomatch_error() { set +o nomatch; }
  password_is_unique() (
    ${ZSH_VERSION+zsh_no_nomatch_error}

    for __f in "${pwfildir:?}"/*
    do
      @test -f "${__f}" || continue
      if @printf '%s' "$1" | @cmp -s "${__f}" -
      then
        return 1
      fi
    done

    @printf '%s' "$1" >>"${pwfildir:?}/${pwfilnam:?}"
    return 0
  )

  check_pw_unique() {
    if password_is_unique "$1"
    then
      echo 'unique'
    else
      echo 'reused'
    fi
  }

  str_repeat() {
    # lib/str/repeat.sh
    while case $(($1)) in (0) ! :;; esac
    do
      @printf '%s' "$2"
      set -- $(($1 - 1)) "$2"
    done
    @printf '\n'
  }

  It 'generates a password without any parameters'
    When run command genpw

    The status should be success
    The stdout should not equal ''
    The stderr should equal ''
  End

  Context  # parameters
    Parameters
      32 '[:alnum:]'
       8 '[:lower:]'
      16 '[:print:]'
      16 '0-9a-f'
      12 '01'
      16 'abcdef'
      512 '[:print:]'
    End

    It "can have a length specified ($1)"
      When run command genpw $(($1))

      The status should be success
      The length of stdout should equal $1
      The stderr should equal ''
    End

    It "can have a character set specified ($1-long $2)"
      When run command genpw $(($1)) "$2"

      The status should be success
      The length of stdout should equal $1
      The stdout should match pattern "$(str_repeat $1 "[$2]")"
      The result of function check_pw_unique should equal 'unique'
      The stderr should equal ''
    End
  End

  Context  # random
    Parameters:value 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19

    It 'generates a random password (property test)'
      pw_len=32

      _check() {
        # $1: stdout, $2: stderr, $3: status
        @printf 'status: %u, #stdout: %u, #stderr: %u, pw %s\n' \
          $3 ${#1} ${#2} "$(check_pw_unique "$1")"
      }

      When run command genpw $((pw_len))

      The result of function _check should equal "status: 0, #stdout: $((pw_len)), #stderr: 0, pw unique"
    End
  End
End
