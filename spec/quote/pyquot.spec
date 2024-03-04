Describe 'quote/pyquot'
  EnableSandbox
  AllowExternalCommand sed

  EnableLeakDetector

  SetupCommandFromFile pyquot lib/quote/pyquot.sh


  # Check if a Python interpreter is available
  { @python -c 'import sys; sys.exit(0)' >/dev/null 2>&1; } \
  && __have_python=1 || __have_python=0
  have_python() {
    return $((! __have_python))
  }
  skip_python() {
    return $((__have_python))
  }

  eval_quoted_string() {
    # the version using the ast module requires at least Python 2.6.
    # an unsafe(!!) version for older versions is provided commented
    have_python &&
    @python -c 'import ast, sys; print(ast.literal_eval(sys.argv[1]))' "$1"
    #@python -c 'import sys; print(eval(sys.argv[1]))' "$1"
  }


  It 'quotes an empty string'
    When run command pyquot ''

    The status should be success
    The output should equal '""'
    The error should equal ''
  End

  It "quotes 'word'"
    When run command pyquot 'word'

    The status should be success
    The output should equal '"word"'
    The error should equal ''
  End

  It "quotes 'hello world'"
    When run command pyquot 'hello world'

    The status should be success
    The output should equal '"hello world"'
    The error should equal ''
  End

  Context  # IFS
    Parameters:value ' ' '.' '-' '_' '/'

    It "concatenates multiple arguments with IFS '$1'"
      Skip  # FIXME
      Skip if 'no Python interpreter available' skip_python

      old_IFS=$IFS
      IFS=$1
      When run command pyquot hello world
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

      When run command pyquot "$(@printf "${format}" "$1")"

      The status should be success
      The stdout should equal "\"$(@printf "${format}" "$1" | sed 's/"/\\"/g')\""
      The stderr should equal ''
    End

    It "quotes strings containing single quotes (property test)"
      format="a string which contains a single quote '%s' in the middle."

      When run command pyquot "$(@printf "${format}" "$1")"

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

    It "eval of quoted string in Python produces input (property test)"
      Skip if 'no Python interpreter available' skip_python

      When run command pyquot "$1"

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
      When run command pyquot "$(random_string $(($1)) '[:alnum:][:space:]')"

      The status should be success
      # TODO: better check
      The stdout should not equal ''
    End
  End
End
