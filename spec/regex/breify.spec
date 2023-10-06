Describe 'regex/breify'
  EnableSandbox
  AllowExternalCommand sed

  EnableLeakDetector

  SetupCommandFromFile breify lib/regex/breify.sh

  It "'hello world'"
    When run command breify 'hello world'

    The status should be success
    The stdout should equal 'hello world'
    The stderr should equal ''
  End

  It 'greps the breify()ed input'
    input='The result of [1.41^(2*3)] is 7.85...'

    _bre=$(breify "${input}")

    Data
    #|The result of [1a41^(2*3)] is 7.85...
    #|The result of [1.41^(2*3)] is 7.85abc
    #|The result of [1.41^(2*3)] is 7x85...
    #|The result of [1.41^(222223)] is 7.85...
    #|The result of * is 7x85abc
    #|The result of 4 is 7.85...
    End

    When run @grep -x -e "${_bre}"

    The status should equal 1
  End
End
