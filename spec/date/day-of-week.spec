Describe 'date/day-of-week'
  EnableSandbox

  EnableLeakDetector

  SetupCommandFromFile day-of-week lib/date/day-of-week.sh

  # check if GNU date(1) is available
  case $(@gdate --version 2>/dev/null)
  in
    (*'GNU coreutils'*)
      __have_gdate=1 ;;
    (*)
      __have_gdate=0 ;;
  esac
  have_gdate() {
    return $((! __have_gdate))
  }
  skip_gdate() {
    return $((__have_gdate))
  }

  # check if this shell has $RANDOM
  have_random_var() {
    case ${RANDOM-} in ('') ! : ;; esac
  }


  Context  # static test values
    Parameters
      # year mon day    expected day-of-week
        1970   1   1    4
        1900   1   1    1
        1900   2  28    3
        1900   2  29    4  # NOTE: this is an invalid date
        1900   3   1    4
        2000   1   1    6
        2000   2  28    1
        2000   2  29    2
        2000   3   1    3
        2020   3   1    0
        2024   2   1    4
        2024   2  28    3
        2024   2  29    4
        2024   3   1    5
    End

    It "calculates the day of week for $(@printf '%04u-%02u-%02u' $1 $2 $3)"
      When run command day-of-week $1 $2 $3

      The status should equal 0
      The stdout should equal "$4"
      The stderr should equal ''
    End
  End

  It 'supports parameters with leading 0s'
    When run command day-of-week 1970 01 01

    The status should be success
    The output should equal 4
    The error should equal ''
  End

  Context  # dynamic test values
    Parameters:dynamic
      n=10

      if case ${RANDOM-} in ('') ! : ;; esac
      then
        while test $((n-=1)) -ge 0
        do
          Y=$(( 1600 + (RANDOM % 1000) ))
          m=$(( 1 + (RANDOM % 12) ))
          case ${m}
          in
            (2)
              d=$(( 1 + (RANDOM % (28 + (0==(Y % 4)&&(0!=(Y % 100)||0==(Y % 400))))) )) ;;
            (1|3|5|7|8|10|12)
              d=$(( 1 + (RANDOM % 31) )) ;;
            (*)
              d=$(( 1 + (RANDOM % 30) )) ;;
          esac
            %data $Y $m $d
        done
      else
        :  # skip: cannot generate random dates
      fi
    End

    gdate_check_dow() {
      test "${gdate_check_dow}" -eq $(($(TZ=GMT0 @gdate --date="$1" +%u) % 7))
    }

    It "calculates the day of week for $(@printf '%04u-%02u-%02u' $1 $2 $3) (property test)"
      Skip if 'date(1) is not GNU date' skip_gdate

      When run command day-of-week $1 $2 $3

      The status should equal 0
      # NOTE: must check using function to call @gdate only if it is available
      The stdout should satisfy gdate_check_dow "$(@printf '%04u-%02u-%02u' $1 $2 $3)"
      The stderr should equal ''
    End
  End
End
