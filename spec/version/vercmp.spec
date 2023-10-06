Describe 'version/vercmp'
  EnableSandbox
  AllowExternalCommand sort

  EnableLeakDetector

  SetupCommandFromFile vercmp lib/version/vercmp.sh

  It 'supports no arguments'
    When run command vercmp

    The status should equal 0
    The stdout should equal ''
    The stderr should equal ''
  End

  It 'supports one argument'
    When run command vercmp 1.0

    The status should equal 0
    The stdout should equal ''
    The stderr should equal ''
  End

  It 'supports two arguments'
    When run command vercmp 2.0 1.2

    The status should equal 1
    The stdout should equal ''
    The stderr should equal ''
  End

  It 'ignores zero padding'
    When run command vercmp 1.1 1.01

    The status should equal 0
    The stdout should equal ''
    The stderr should equal ''
  End

  It 'compares up to 6 hierarchy levels'
    When run command vercmp 1.0.0.0.0.1 1.0.0.0.0.0

    The status should equal 1
    The stdout should equal ''
    The stderr should equal ''
  End

  Context  # same versions
    Parameters:value 1.0 1 1.0.0 1.00

    It "compares the same version ($1 == 1.0)"
      When run command vercmp "$1" 1.0

      The status should equal 0
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context  # greater versions
    Parameters:value 2.01 2.1 2.0.1 2.0.0.1 3 3.0 3.00 3.00.4

    It "compares greater versions ($1 > 2.0)"
      When run command vercmp "$1" 2.0

      The status should equal 1
      The stdout should equal ''
      The stderr should equal ''
    End
  End

  Context  # smaller versions
    Parameters:value 2.01 2.1 2.0.1 2.0.0.1 2.999999 1.0 1.99 1.87

    It "compares smaller versions ($1 < 3.0)"
      When run command vercmp "$1" 3.0

      The status should equal 255
      The stdout should equal ''
      The stderr should equal ''
    End
  End
End
