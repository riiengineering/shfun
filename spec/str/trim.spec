Describe 'str/trim'
  EnableSandbox
  AllowExternalCommand cat  # XXX: check if cat(1) could be removed
  AllowExternalCommand printf  # XXX: check if printf could be removed
  AllowExternalCommand sed

  SetupCommandFromFile strtrim lib/str/trim.sh

  It 'reads from stdin if no arguments are passed'
    Data 'hello world'

    When run command strtrim

    The status should be success
    The stdout should equal 'hello world'
    The stderr should equal ''
  End

  It 'trims an empty string'
    When run command strtrim ''

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It "trims 'hello world'"
    When run command strtrim 'hello world'

    The status should be success
    The stdout should equal 'hello world'
    The stderr should equal ''
  End

  Context  # prefixes / suffixes
    Parameters:value ' ' '  ' '	'

    It "trims the prefix '$1'"
      When run command strtrim "$1hello world"

      The status should be success
      The stdout should equal 'hello world'
      The stderr should equal ''
    End

    It "trims the suffix '$1'"
      When run command strtrim "hello world$1"

      The status should be success
      The stdout should equal 'hello world'
      The stderr should equal ''
    End

    It "trims the prefix and suffix '$1'"
      When run command strtrim "$1hello world$1"

      The status should be success
      The stdout should equal 'hello world'
      The stderr should equal ''
    End
  End

  It 'removes empty lines'
    Data
    #|lorem
    #|
    #|
    #|ipsum
    #|
    End

    When run command strtrim

    The status should be success
    The stdout should equal 'lorem
ipsum'
    The stderr should equal ''
  End

  It 'removes whitespace-only lines'
    Data:expand
    #|lorem
    #|$(echo ' ')
    #|$(echo '  ')
    #|ipsum
    #|$(echo ' 	')
    End

    When run command strtrim

    The status should be success
    The stdout should equal 'lorem
ipsum'
    The stderr should equal ''
  End


End
