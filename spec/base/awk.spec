Describe '(awk)'
  It 'space is in [:print:]'
    When run command awk 'BEGIN { exit (" " ~ /[[:print:]]/) }'

    The status should equal 1
  End

  It 'tab is not in [:print:]'
    When run command awk 'BEGIN { exit ("	" ~ /[[:print:]]/) }'

    The status should equal 0
  End

  It 'newline is not in [:print:]'
    When run command awk 'BEGIN { exit ("\n" ~ /[[:print:]]/) }'

    The status should equal 0
  End
End
