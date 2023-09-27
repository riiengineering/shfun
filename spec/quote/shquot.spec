Describe 'quote/shquot'
  EnableSandbox
  AllowExternalCommand sed

  SetupCommandFromFile shquot lib/quote/shquot.sh

  # ARG_MAX=$(getconf ARG_MAX 2>/dev/null)
  # test $((ARG_MAX)) -gt 0 || ARG_MAX=$((64 * 1024))

  # # some space for the environment
  # STRING_MAX_LEN=$((ARG_MAX - 8192))

  eval_quoted_string() {
    eval "@printf '%s' $1";
  }


  It 'quotes an empty string'
    When run command shquot ''

    The status should be success
    The output should equal "''"
    The error should equal ''
  End

  It "quotes 'word'"
    When run command shquot 'word'

    The status should be success
    The output should equal "'word'"
    The error should equal ''
  End

  It "quotes 'hello world'"
    When run command shquot 'hello world'

    The status should be success
    The output should equal "'hello world'"
    The error should equal ''
  End

  Context  # IFS
    Parameters:value ' ' '.' '-' '_' '/'

    It "concatenates multiple arguments with IFS '$1'"
      Skip  # FIXME

      old_IFS=$IFS
      IFS=$1
      When run command shquot hello world
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

      When run command shquot "$(@printf "${format}" "$1")"

      The status should be success
      The stdout should equal "$(@printf "'${format}'" "$1")"
      The stderr should equal ''
    End

    It "quotes strings containing single quotes (property test)"
      format="a string which contains a double quote '%s' in the middle."

      When run command shquot "$(@printf "${format}" "$1")"

      The status should be success
      The stdout should equal "'$(@printf "${format}" "$1" | sed "s/'/'\\\\''/g")'"
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
      When run command shquot "$1"

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
        %data $l
      done
    End

    It "quotes a $1 bytes long string"
      When run command shquot "$(random_string $(($1)) '[:alnum:][:space:]')"

      The status should be success
      # TODO: better check
      The stdout should not equal ''
    End
  End
End
