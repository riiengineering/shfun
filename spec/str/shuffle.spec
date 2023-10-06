Describe 'str/shuffle'
  EnableSandbox
  AllowExternalCommand awk
  AllowExternalCommand date

  EnableLeakDetector

  SetupCommandFromFile strshuffle lib/str/shuffle.sh

  sorted_output() {
    @printf '%s' "$1" | @sort
  }

  It 'shuffles empty input'
    Data ''

    When run command strshuffle

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It 'shuffles repeated lines'
    input=$(awk 'BEGIN { for (i = 1; i <= 100; ++i) print "foo" }')

    Data "${input}"

    When run command strshuffle

    The status should be success
    The stdout should equal "${input}"
    The stderr should equal ''
  End

  It 'shuffles random lines'
    input=$(
      LC_ALL=C @tr -d -c '[:alnum:] \n' </dev/urandom 2>&- \
      | awk '1; NR==100{exit}' \
      | @sort)

    Data "${input}"

    When run command strshuffle

    The status should be success
    The stdout should not equal "${input}"
    The result of function sorted_output should equal "${input}"
  End
End
