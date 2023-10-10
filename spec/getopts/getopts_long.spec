Describe 'getopts/getopts_long'
  EnableSandbox

  EnableLeakDetector
  LeakAllowVariable OPTARG_LONG
  LeakAllowVariable OPTIND_LONG
  LeakAllowVariable _opt

  SetupFunctionFromFile getopts_long lib/getopts/getopts_long.sh

  SPECDIR=${SHELLSPEC_SPECFILE%/*}
  if have_cc
  then
    SetupCHelper proc_options_c "${SPECDIR:?}/proc_options.c"
  fi

  proc_options() {
    __proc_options_optstring=$1
    shift

    while getopts_long "${__proc_options_optstring}" _opt "$@"
    do
      case ${_opt}
      in
        ('?')
          echo
          ;;
        (*)
          echo "${_opt}${OPTARG_LONG:+=}${OPTARG_LONG-}"
          ;;
      esac
    done
    unset -v __proc_options_optstring

    shift $((OPTIND_LONG-1))

    case $#
    in
      (0) ;;
      (*)
        echo
        echo "$@"
        ;;
    esac
  }

  Context  # getopts_long_test.c
    It 'reports end of options with an empty optstring and no arguments'
      When call getopts_long '' _opt

      The status should equal 255
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should be defined
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 1
    End

    It 'reports end of options when no options are passed'
      When call getopts_long 'foo' _opt

      The status should equal 255
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should be defined
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 1
    End

    It 'prints an error when unsupported options are passed'
      When call getopts_long 'foo,bar,baz' _opt --illegal

      The status should be success
      The stdout should equal ''
      The stderr should equal 'unrecognized option '\''--illegal'\'''

      The variable _opt should equal '?'
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 2
    End

    It 'returns an unsupported option in OPTARG_LONG if the optstring starts with :'
      When call getopts_long ':foo,bar,baz' _opt --illegal

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal '?'
      The variable OPTARG_LONG should equal 'illegal'
      The variable OPTIND_LONG should equal 2
    End

    It 'extracts a required argument in next ARGV'
      When call getopts_long 'required:' _opt --required foo

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'required'
      The variable OPTARG_LONG should equal 'foo'
      The variable OPTIND_LONG should equal 3
    End

    It 'extracts a required argument in next ARGV starting with -'
      When call getopts_long 'required:' _opt '--required' '-not-an-option'

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'required'
      The variable OPTARG_LONG should equal '-not-an-option'
      The variable OPTIND_LONG should equal 3
    End

    It 'extracts a required argument in next ARGV starting with --'
      When call getopts_long 'required:' _opt '--required' '--not-an-option'

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'required'
      The variable OPTARG_LONG should equal '--not-an-option'
      The variable OPTIND_LONG should equal 3
    End

    It 'extracts required arguments after ='
      When call getopts_long 'required:' _opt --required=foo

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'required'
      The variable OPTARG_LONG should equal 'foo'
      The variable OPTIND_LONG should equal 2
    End

    It 'prints an error if a required argument is missing'
      When call getopts_long 'required:' _opt --required

      The status should be success
      The stdout should equal ''
      The stderr should equal 'option '\''--required'\'' requires an argument'

      The variable _opt should equal '?'
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 2
    End

    It 'returns the option in OPTARG_LONG if a required argument is omitted and the optstring starts with :'
      When call getopts_long ':required:' _opt --required

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal ':'
      The variable OPTARG_LONG should equal 'required'
      The variable OPTIND_LONG should equal 2
    End

    It 'accepts empty arguments'
      When call getopts_long 'required:' _opt --required ''

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'required'
      The variable OPTARG_LONG should equal ''
      The variable OPTIND_LONG should equal 3
    End

    It 'ignores optional arguments in next ARGV'
      When call getopts_long 'optional?' _opt --optional foo

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'optional'
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 2
    End

    It 'extracts optional arguments after ='
      When call getopts_long 'optional?' _opt --optional=foo

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'optional'
      The variable OPTARG_LONG should equal 'foo'
      The variable OPTIND_LONG should equal 2
    End

    It 'sets OPTARG_LONG if an empty argument is passed after ='
      OPTARG_LONG='something'
      When call getopts_long 'optional?' _opt --optional=

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'optional'
      The variable OPTARG_LONG should equal ''
      The variable OPTIND_LONG should equal 2
    End

    It 'unsets OPTARG_LONG if no optional argument is passed'
      OPTARG_LONG='something'
      When call getopts_long 'optional?' _opt --optional

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'optional'
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 2
    End

    It 'prints an error if an unexpected argument is passed for a flag option (after =)'
      OPTARG_LONG='something'
      When call getopts_long 'flag' _opt --flag=2

      The status should be success
      The stdout should equal ''
      The stderr should equal 'option '\''--flag'\'' doesn'\''t allow an argument'

      The variable _opt should equal '?'
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 2
    End

    It 'handles an unexpected argument passed after a flag= option (optstring leading :)'
      When call getopts_long ':flag' _opt --flag=2

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal '?'
      The variable OPTARG_LONG should equal 'flag'
      The variable OPTIND_LONG should equal 2
    End

    It 'ignores an argument passed after a flag in the next ARGV'
      When call getopts_long 'flag' _opt --flag 2

      The status should be success
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should equal 'flag'
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 2
    End

    It 'reports end of options when reaching a positional argument'
      OPTIND_LONG=2
      When call getopts_long 'flag' _opt --flag 2

      The status should equal 255
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should be defined
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 2
    End

    It 'respects --'
      OPTIND_LONG=2
      When call getopts_long 'flag1,flag2,flag3' _opt --flag1 -- --flag3

      The status should equal 255
      The stdout should equal ''
      The stderr should equal ''

      The variable _opt should be defined
      The variable OPTARG_LONG should be undefined
      The variable OPTIND_LONG should equal 3
    End
  End

  Context  # proc_options
    It 'processes multiple arguments'
      When call proc_options 'required:,optional?,flag' --required foo --flag

      The stdout should equal 'required=foo
flag'
    End

    It 'processes multiple arguments (including positional arguments)'
      When call proc_options 'required:,optional?,flag' --required foo --optional=42 --flag

      The stdout should equal 'required=foo
optional=42
flag'
    End
  End

  Context  # proc_options (compare with proc_options.c)
    Parameters
      'required:'                   --required foo --required=bar --required baz
      'optional?'                   --optional=42 --optional
      'flag1,flag2,flag3'           --flag1 --flag3
      'required:,optional?,flag'    --required foo --optional=42 --flag
      ''                            1 2 3
      ':foo,bar,baz'                --invalid
    End

    It "compare long options processing against getopt_long(3): $@"
      Skip if 'no C compiler available' skip_c

      When call proc_options "$@"

      The stdout should equal "$(proc_options_c "$@")"
    End
  End
End
