Describe 'url/urlencode'
  EnableSandbox
  AllowExternalCommand awk

  EnableLeakDetector

  SetupCommandFromFile urlencode lib/url/urlencode.sh

  It 'encodes an empty string'
    When run command urlencode ''

    The status should be success
    The stdout should equal ''
    The stderr should equal ''
  End

  It "encodes 'word'"
    When run command urlencode 'word'

    The status should be success
    The stdout should equal 'word'
    The stderr should equal ''
  End

  It "encodes 'hello world'"
    When run command urlencode 'hello world'

    The status should be success
    The stdout should equal 'hello%20world'
    The stderr should equal ''
  End

  It 'capitalises percent-encoding'
    When run command urlencode '/'

    The status should be success
    The stdout should equal '%2F'
    The stderr should equal ''
  End

  It 'supports RFC 3986 reserved characters'
    input='!#$&'\''()*+,/:;=?@[]'
    expected='%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D'

    When run command urlencode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'supports RFC 3986 unreserved characters'
    input='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~'
    expected=${input:?}

    When run command urlencode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'supports multi-line strings (LF)'
    input=$(@printf 'this string consists of\nmultiple lines.')
    expected='this%20string%20consists%20of%0Amultiple%20lines.'

    When run command urlencode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'supports multi-line strings (CRLF)'
    input=$(@printf 'this string consists of\r\nmultiple lines.')
    expected='this%20string%20consists%20of%0D%0Amultiple%20lines.'

    When run command urlencode "${input}"

    The status should be success
    The stdout should equal "${expected}"
    The stderr should equal ''
  End

  It 'supports multi-byte UTF-8 characters (€)'
    When run command urlencode '€'

    The status should be success
    The stdout should equal '%E2%82%AC'
    The stderr should equal ''
  End

  # source: https://en.wikipedia.org/wiki/URL_encoding#Character_data
  It 'supports Japanese UTF-8 characters (円)'
    When run command urlencode '円'

    The status should be success
    The stdout should equal '%E5%86%86'
    The stderr should equal ''
  End
End
