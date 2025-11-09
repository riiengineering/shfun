Describe 'quote/shdquot'
  EnableSandbox
  AllowExternalCommand sed

  EnableLeakDetector

  SetupCommandFromFile shdquot lib/quote/shdquot.sh

  eval_quoted_string() {
    eval "@printf '%s' $1"
  }


  It 'quotes an empty string'
    When run command shdquot ''

    The status should be success
    The output should equal '""'
    The error should equal ''
  End

  It "quotes 'word'"
    When run command shdquot 'word'

    The status should be success
    The output should equal '"word"'
    The error should equal ''
  End

  It "quotes 'hello world'"
    When run command shdquot 'hello world'

    The status should be success
    The output should equal '"hello world"'
    The error should equal ''
  End

  Context  # IFS
    Parameters:value ' ' '.' '-' '_' '/'

    It "concatenates multiple arguments with IFS '$1'"
      Skip  # FIXME

      old_IFS=$IFS
      IFS=$1
      When run command shdquot hello world
      IFS=$old_IFS

      The status should be successful
      The result of function eval_quoted_string should equal "hello$1world"
    End
  End

  Context  # double quotes
    Parameters:dynamic
      iterations=5

      while test $((iterations-=1)) -ge 0
      do
        %data "$(random_string 32 '[:alnum:][:blank:]')"
      done
    End

    It "quotes strings containing double quotes (property test)"
      format='a string which contains a double quote "%s" in the middle.'

      When run command shdquot "$(@printf "${format}" "$1")"

      The status should be success
      The stdout should equal "\"$(@printf "${format}" "$1" | sed 's/"/\\"/g')\""
      The stderr should equal ''
    End

    It "quotes strings containing single quotes (property test)"
      format="a string which contains a single quote '%s' in the middle."

      When run command shdquot "$(@printf "${format}" "$1")"

      The status should be success
      The stdout should equal "\"$(@printf "${format}" "$1")\""
      The stderr should equal ''
    End
  End

  Context  # test eval
    Parameters:dynamic
      iterations=5

      while test $((iterations-=1)) -ge 0
      do
        %data $(random_string)
      done
    End

    It "eval of quoted string in shell produces input (property test)"
      When run command shdquot "$1"

      The status should be success
      The result of function eval_quoted_string should equal "$1"
      The stderr should equal ''
    End
  End

  Context  # long strings
    Parameters:dynamic
      l=2048

      while test $((l*=2)) -le 100000
      do
        %data $l "$(random_string $((l)) '[:alnum:][:space:]')"
      done
    End

    It "quotes a $1 bytes long string"
      When run command shdquot "$2"

      The status should be success
      The result of function eval_quoted_string should equal "$2"
    End
  End
End
