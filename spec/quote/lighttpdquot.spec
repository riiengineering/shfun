Describe 'quote/lighttpdquot'
  BS='\'
  CR=$(printf '\r.'); CR=${CR%?}
  LF=$(printf '\n.'); LF=${LF%?}
  HT=$(printf '\t.'); HT=${HT%?}

  EnableSandbox
  AllowExternalCommand sed

  EnableLeakDetector

  SetupCommandFromFile lighttpdquot lib/quote/lighttpdquot.sh

  It 'quotes an empty string'
    When run command lighttpdquot ''

    The status should be success
    The stdout should equal 'e""'
    The stderr should equal ''
  End

  It "quotes 'word'"
    When run command lighttpdquot 'word'

    The status should be success
    The stdout should equal 'e"word"'
    The stderr should equal ''
  End

  It "quotes 'hello world'"
    When run command lighttpdquot 'hello world'

    The status should be success
    The stdout should equal 'e"hello world"'
    The stderr should equal ''
  End

  It "leaves alone single quotes in a a string"
    When run command lighttpdquot "It's a string"

    The status should be success
    The stdout should equal 'e"It'\''s a string"'
    The stderr should equal ''
  End

  It "escapes double quotes in a string"
    When run command lighttpdquot 'This is "a value"'

    The status should be success
    The stdout should equal 'e"This is \"a value\""'
    The stderr should equal ''
  End

  It "escapes newlines"
    # use >1 LFs
    lfstr="line 1${LF}line 2${LF}line 3"

    When run command lighttpdquot "${lfstr}"

    The status should be success
    The stdout should equal 'e"line 1\nline 2\nline 3"'
    The stderr should equal ''
  End

  It "escapes carriage returns"
    # use >1 CRs to check if the sed command uses /g
    crstr="before${CR}mid${CR}after"

    When run command lighttpdquot "${crstr}"

    The status should be success
    The stdout should equal 'e"before\rmid\rafter"'
    The stderr should equal ''
  End

  It "escapes tabs"
    # use >1 tabs to check if the sed command uses /g
    htstr="col 1${HT}col 2${HT}col 3"

    When run command lighttpdquot "${htstr}"

    The status should be success
    The stdout should equal 'e"col 1\tcol 2\tcol 3"'
    The stderr should equal ''
  End

  It "escapes backslashes"
    # use >1 backslashes to check if the sed command uses /g
    bsstr="a${BS}b${BS}c"

    When run command lighttpdquot "${bsstr}"

    The status should be success
    The stdout should equal 'e"a\\b\\c"'
    The stderr should equal ''
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
      randstr=$(random_string $(($1)) '[:alnum:]')

      When run command lighttpdquot "${randstr}"

      The status should be success
      The stdout should equal "e\"${randstr}\""
      The stderr should equal ''
    End
  End
End
