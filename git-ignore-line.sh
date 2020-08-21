#!/bin/bash

# https://brianchildress.co/named-parameters-in-bash/#:~:text=Shift%20is%20a%20built%2Din,the%20argument%20to%20their%20value.
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

   shift
done

# Clean up ignored changes before staging to commit
if [ $clean ]
then
   tmpfile=$(mktemp)
   trap "{ rm -f $tmpfile; }" EXIT

   attributes=$(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print $3 }')

   git show HEAD:$clean > $tmpfile

   diff --unified=0 -I 'git-ignore-line' \
      <(grep -vE -f <(echo "$attributes") -- $tmpfile) \
      <(grep -vE -f <(echo "$attributes") -- /dev/stdin) |\
      patch $tmpfile -o - --quiet --batch
fi

# Restore ignored changes on checkout
if [ $smudge ]
then

   tmpfile=$(mktemp)
   trap "{ rm -f $tmpfile; }" EXIT

   attributes=$(git check-attr -a $smudge | awk '$2 ~ /ignore-regex\d*/ { print $3 }')

   git show HEAD:$smudge > $tmpfile

   diff --unified=0 -I 'git-ignore-line' \
      <(grep -vE -f <(echo "$attributes") -- /dev/stdin) \
      <(grep -vE -f <(echo "$attributes") -- $smudge) |\
      patch $smudge -o - --quiet --batch
fi
