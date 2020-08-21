#!/bin/bash

# https://brianchildress.co/named-parameters-in-bash/#:~:text=Shift%20is%20a%20built%2Din,the%20argument%20to%20their%20value.
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

   shift
done

if [ $clean ]
then
   tmpfile=$(mktemp)
   trap "{ rm -f $tmpfile; }" EXIT

   attributes=$(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print $3 }')

   git show HEAD:$clean > $tmpfile

   diff --unified=0 -I 'git-ignore-line' \
      <(grep -vE -f <(echo "$attributes") -- $tmpfile) \
      <(grep -vE -f <(echo "$attributes") -- $clean) |\
      patch $tmpfile -o - --quiet --batch

fi
