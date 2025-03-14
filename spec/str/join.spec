Describe 'str/join'
  EnableSandbox
  AllowExternalCommand printf

  EnableLeakDetector

  SetupCommandFromFile strjoin lib/str/join.sh

  It 'joins without arguments'
    When run command strjoin

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It 'joins without fields'
    When run command strjoin ,

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It 'joins with an empty separator'
    When run command strjoin '' a b c

    The status should be success
    The stdout should equal 'abc'
    The stderr should equal ''
  End

  It "joins 'hello', 'world', with ' '"
    When run command strjoin ' ' hello world

    The status should be success
    The stdout should equal 'hello world'
    The stderr should equal ''
  End

  It "joins 'foo', 'bar', 'baz' with ', '"
    When run command strjoin ', ' foo bar baz

    The status should be success
    The stdout should equal 'foo, bar, baz'
    The stderr should equal ''
  End

  It "joins empty fields"
    When run command strjoin @ foo '' baz

    The status should be success
    The stdout should equal 'foo@@baz'
    The stderr should equal ''
  End
End
