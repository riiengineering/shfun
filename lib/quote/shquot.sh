sed -e "s/'/'\\\\''/g" -e "1s/^/'/" -e "\$s/\$/'/" <<EOF
$*
EOF
