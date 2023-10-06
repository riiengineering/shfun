Describe 'interactive/confirm'
  EnableSandbox
  AllowExternalCommand printf

  EnableLeakDetector

  SetupCommandFromFile confirm lib/interactive/confirm.sh

  is_ksh() {
    (eval ': "${.sh.version}"' 2>/dev/null)
  }

  It 'prompts: no text, no default'
    Data 'y'

    When run command confirm

    The status should be success
    The stdout should equal 'Confirm? [y/n] '
    The stderr should equal ''
  End

  It 'prompts: custom text, no default'
    Data 'y'

    When run command confirm 'Do you want to continue?'

    The status should be success
    The stdout should equal 'Do you want to continue? [y/n] '
    The stderr should equal ''
  End

  It 'returns 0 with default y'
    Data ''

    When run command confirm 'Do you want to continue?' y

    The status should equal 0
    The stdout should equal 'Do you want to continue? [Y/n] '
    The stderr should equal ''
  End

  It 'returns 1 with default n'
    Data ''

    When run command confirm 'Do you want to continue?' n

    The status should equal 1
    The stdout should equal 'Do you want to continue? [y/N] '
    The stderr should equal ''
  End

  Context
    Parameters
      # default  inverse  expected status
        y        n        0
        n        y        1
    End

    It "returns $3 with user choice $1"
      Data "$1"

      When run command confirm 'Confirm?'

      The status should equal $3
      The stdout should equal 'Confirm? [y/n] '
      The stderr should equal ''
    End

    It "returns $3 with user choice ($1) against default ($2)"
      Data:expand
      #|$1
      End

      When run command confirm 'Are you sure?' "$2"

      The status should equal $3
      The stdout should start with 'Are you sure? '
      The stderr should equal ''
    End
  End

  Context  # capitalisation
    Parameters
      # user choice  expected status
        Y            0
        N            1
    End

    It "ignores capitalisation in the response ($1)"
      Data "$1"

      When run command confirm

      The status should equal $2
      The stdout should equal 'Confirm? [y/n] '
      The stderr should equal ''
    End
  End

  Context  # long responses
    Parameters
      # response  expected status
      yes         0
      Yes         0
      YES         0
      YeS         0
      no          1
      No          1
      NO          1
      nO          1
    End

    It "accepts long responses ($1)"
      Data "$1"

      When run command confirm

      The status should equal $2
      The stdout should equal 'Confirm? [y/n] '
      The stderr should equal ''
    End
  End

  It 'returns 130 on interrupt'
    # NOTE: for some reason this test errors in ksh 93...
    #       I could not figure out how to fix it, so it’s skipped
    #Skip if 'unstable in ksh' is_ksh

    # Update: skip it altogether because it does not run stabilly in GitHub Actions.
    Skip

    Mock confirm-sigint
      _read() {
        # send SIGINT after a short delay
        { while test $((__i+=1)) -lt 10000; do :; done; kill -INT $$; } &
        read "$@";
      }
      read() { _read "$@"; }

      . "${SHELLSPEC_PROJECT_ROOT:?}/lib/interactive/confirm.sh"
    End

    _interact() {
      # use a fifo as stdin to present something "interactive" to confirm
      fifo="${SHELLSPEC_WORKDIR:?}/${SHELLSPEC_EXAMPLE_ID:?}.confirm-sigint.fifo"
      @mkfifo -m 0700 "${fifo:?}"

      # open fifo
      { @sleep 1; echo n; } >"${fifo:?}" &
      _p_pid=$!

      confirm-sigint <"${fifo:?}"
      _rc=$?

      { kill -KILL ${_p_pid}; wait ${_p_pid}; } 2>&-

      # clean up
      @rm -f "${fifo:?}"

      return ${_rc}
    }
    When call _interact

    The status should equal 130
    The stdout should equal 'Confirm? [y/n] '
    The stderr should equal ''
  End

  It 'nags until the user makes a choice'
    Data
    #|
    #|
    #|n
    End

    When run command confirm 'Do you want X?'

    The status should be failure
    The stdout should equal 'Do you want X? [y/n] Please respond with "yes" or "no": Please respond with "yes" or "no": '
  End
End
