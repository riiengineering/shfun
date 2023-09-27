Describe 'format/strfc'
  EnableSandbox
  AllowExternalCommand printf
  AllowExternalCommand sed

  SetupCommandFromFile strfc lib/format/strfc.sh

  It 'accepts an empty string'
    Data ''

    When run command strfc

    The status should be success
    The output should equal ''
    The error should equal ''
  End

  It 'makes a single replacement'
    Data '%t'

    When run command strfc -t=test

    The status should be success
    The output should equal 'test'
    The error should equal ''
  End

  It 'generates an error when an invalid format specifier is used'
    Data 'this is an invalid format specifier: %x'

    When run command strfc

    # XXX: is this the right behaviour??
    The status should be success
    The output should equal 'this is an invalid format specifier: '
    The error should equal ''
  End

  Context  # special characters
    It 'supports special characters (backslash)'
      x_value='abc\def'

      Data '%x'

      When run command strfc -x="${x_value}"

      The status should be success
      The output should equal "${x_value}"
      End

    Parameters:dynamic
      iterations=5

      while test $((iterations-=1)) -ge 0
      do
        %data "$(random_string 32)"
      done
    End

    It "supports special characters ($1)"
      Data
      #|a string with %c format specifiers: a simple one (%s) and a complex one (%x).
      End

      c_value='multiple'
      s_value='hello world'
      x_value=$1

      When run command strfc -c="${c_value}" -s="${s_value}" -x="${x_value}"
      The status should be success
      The output should equal "a string with ${c_value} format specifiers: a simple one (${s_value}) and a complex one (${x_value})."
      The error should equal ''
    End
  End
End
