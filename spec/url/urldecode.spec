Describe 'url/urldecode'
  EnableSandbox
  AllowExternalCommand awk

  EnableLeakDetector

  SetupCommandFromFile urldecode lib/url/urldecode.sh

  It 'decodes an empty string'
    When run command urldecode ''

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It "decodes 'word'"
    When run command urldecode 'word'

    The status should be success
    The stdout should equal 'word'
    The stderr should equal ''
  End

  It "decodes 'hello world'"
    When run command urldecode 'hello%20world'

    The status should be success
    The stdout should equal 'hello world'
    The stderr should equal ''
  End

  It 'accepts lower-case percent-encoding'
    When run command urldecode '%2f'

    The status should be success
    The stdout should equal '/'
    The stderr should equal ''
  End

  It 'accepts upper-case percent-encoding'
    When run command urldecode '%2F'

    The status should be success
    The stdout should equal '/'
    The stderr should equal ''
  End

  It 'accepts mixed-case percent-encoding'
    When run command urldecode '%2F%C3%bC%2f'

    The status should be success
    The stdout should equal '/ü/'
    The stderr should equal ''
  End

  It 'supports RFC 3986 reserved characters'
    input='%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D'
    expected='!#$&'\''()*+,/:;=?@[]'

    When run command urldecode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'supports RFC 3986 unreserved characters'
    input='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~'
    expected=${input:?}

    When run command urldecode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'supports multi-line strings (LF)'
    input='this%20string%20consists%20of%0Amultiple%20lines.'
    expected=$(@printf 'this string consists of\nmultiple lines.')

    When run command urldecode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'supports multi-line strings (CRLF)'
    input='this%20string%20consists%20of%0D%0Amultiple%20lines.'
    expected=$(@printf 'this string consists of\r\nmultiple lines.')

    When run command urldecode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'supports multi-byte UTF-8 characters (€)'
    When run command urldecode '%E2%82%AC'

    The status should be success
    The stdout should equal '€'
    The stderr should equal ''
  End

  # source: https://en.wikipedia.org/wiki/URL_encoding#Character_data
  It 'supports Japanese UTF-8 characters (円)'
    When run command urldecode '%E5%86%86'

    The status should be success
    The stdout should equal '円'
    The stderr should equal ''
  End
End

Describe 'url/url{de,en}ecode'
  EnableSandbox
  AllowExternalCommand awk

  SetupCommandFromFile urldecode lib/url/urldecode.sh
  SetupCommandFromFile urlencode lib/url/urlencode.sh

  Parameters:dynamic
    iterations=5

    while test $((iterations-=1)) -ge 0
    do
      %data "$(random_string)"
    done
  End

  It "round-trips '$1'"
    _roundtrip() {
      urldecode "$(urlencode "$1")"
    }

    When call _roundtrip "$1"

    The status should be success
    The stdout should equal "$1"
    The stderr should equal ''
  End
End
