#!/bin/bash

swepo_base=~/.swepo

mkdir -p "$swepo_base/bin"
cp -a swepo.sh "$swepo_base/bin/swepo"
cp completion.sh "$swepo_base/"

file=~/.swepo.sh
touch $file
cat > $file << EOF
if [[ ! "\$PATH" == *$swepo_base/bin* ]]; then
  export PATH="\$PATH:$swepo_base/bin"
fi

source $swepo_base/completion.sh
EOF

file=~/.bashrc
echo >> "$file"
echo "[ -f ~/.swepo.sh ] && source ~/.swepo.sh" >> "$file"

