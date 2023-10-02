Describe 'email/qpencode'
  EnableSandbox
  AllowExternalCommand awk

  SetupCommandFromFile qpencode lib/email/qpencode.sh

  It 'encodes an empty string'
    When run command qpencode ''

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It "encodes 'word'"
    When run command qpencode 'word'

    The status should be success
    The stdout should equal 'word'
    The stderr should equal ''
  End

  It "encodes 'hello world'"
    When run command qpencode 'hello world'

    The status should be success
    The stdout should equal 'hello world'
    The stderr should equal ''
  End

  It 'encodes ='
    When run command qpencode '='

    The status should be success
    The stdout should equal '=3D'
    The stderr should equal ''
  End

  It 'preserves line breaks (LF)'
    input=$(@printf 'this string consists of\nmultiple lines.')
    expected=$(@printf 'this string consists of\nmultiple lines.')

    When run command qpencode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'preserves line breaks (CRLF)'
    input=$(@printf 'this string consists of\r\nmultiple lines.')
    expected=$(@printf 'this string consists of=0D\nmultiple lines.')

    When run command qpencode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'encodes spaces at EOL'
    input=$(@printf 'this line ends in a space \nso the space needs to be encoded')
    expected=$(@printf 'this line ends in a space=20\nso the space needs to be encoded')

    When run command qpencode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'encodes tabs at EOL'
    input=$(@printf 'this line ends in a tab\t\nso the tab needs to be encoded')
    expected=$(@printf 'this line ends in a tab=09\nso the tab needs to be encoded')

    When run command qpencode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'wraps long lines with soft line breaks'
    input='This is a very long line which needs to be broken up into three separate lines with a soft line break to make it fit the 76 character line length limit imposed by Quoted-Printable encoded text.'

    When run command qpencode "${input}"

    The status should be success
    The lines of stdout should equal 3
    The line 1 of stdout should end with '='
    The line 2 of stdout should end with '='
    The line 3 of stdout should not end with '='
    The stderr should equal ''
  End

  It 'supports multi-byte UTF-8 characters (€)'
    When run command qpencode '€'

    The status should be success
    The stdout should equal '=E2=82=AC'
    The stderr should equal ''
  End

  # source: https://en.wikipedia.org/wiki/URL_encoding#Character_data
  It 'supports Japanese UTF-8 characters (円)'
    When run command qpencode '円'

    The status should be success
    The stdout should equal '=E5=86=86'
    The stderr should equal ''
  End
End
