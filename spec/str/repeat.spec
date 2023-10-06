Describe 'str/repeat'
  EnableSandbox
  AllowExternalCommand printf

  SetupCommandFromFile str_repeat lib/str/repeat.sh

  It 'repeats an empty string'
    When run command str_repeat 10 ''

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It "does zero repetitions of an empty string"
    When run command str_repeat 0 ''

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It "does zero repetitions of an arbitrary string"
    When run command str_repeat 0 "$(random_string)"

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  Context  # repeat white space
    Parameters:value ' ' '  ' '	'

    It "repeats whitespace '$1'"
      When run command str_repeat 3 "$1"

      The status should be success
      The stdout should equal "$1$1$1"
      The stderr should equal ''
    End
  End

  It 'repeats an arbitrary string'
    str=$(random_string)
    When run command str_repeat 5 "${str}"

    The status should be success
    The stdout should equal "${str}${str}${str}${str}${str}"
    The stderr should equal ''
  End
End
