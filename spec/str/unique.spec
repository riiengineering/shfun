Describe 'str/unique'
  EnableSandbox
  AllowExternalCommand awk

  EnableLeakDetector

  SetupCommandFromFile unique lib/str/unique.sh

  NL='
'

  It 'works with no input'
    Data ''

    When run command unique

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It 'works with unique lines'
    Data
    #|foo
    #|bar
    #|baz
    End

    When run command unique

    The status should be success
    The lines of stdout should equal 3
    The line 1 of stdout should equal 'foo'
    The line 2 of stdout should equal 'bar'
    The line 3 of stdout should equal 'baz'
    The stderr should equal ''
  End

  It 'removes repeated lines'
    # generate input
    for _l in pledari glossari parola floscla lieu persuna famiglia programmar
    do
      input=${input}${NL}${_l}
      while test $(random_short) -ge 20000
      do
        input=${input}${NL}${_l}
      done

      expected=${expected}${NL}${_l}
    done

    Data "${input}"

    When run command unique

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'collapses empty lines'
    Data
    #|foo
    #|
    #|
    #|
    #|bar
    #|
    #|
    #|baz
    #|
    #|
    #|
    End

    When run command unique

    The status should be success
    The lines of stdout should equal 4
    The line 1 of stdout should equal 'foo'
    The line 2 of stdout should equal ''
    The line 3 of stdout should equal 'bar'
    The line 4 of stdout should equal 'baz'
    The stderr should equal ''
  End
End
