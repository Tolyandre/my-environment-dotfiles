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
   echo Clean message >&2

   tmpfile=$(mktemp)
   trap "{ rm -f $tmpfile; }" EXIT

   # attributes=$(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print $3 }')
   attributes=$(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print "-I \x27"$3"\x27" }')

   git show HEAD:$clean > $tmpfile

   # if repository is just initialized, handle error "fatal: invalid object name 'HEAD'"
   if [ $? -ne 0 ]; then
      cat /dev/stdin
      exit
   fi

      #<(grep -vE -f <(echo "$attributes") -- $tmpfile) \
      #<(grep -vE -f <(echo "$attributes") -- /dev/stdin) \
   diff --unified=0 -I 'git-ignore-line' $attributes \
      $tmpfile /dev/stdin \
      | patch $tmpfile -o - --quiet --batch
fi

# Restore ignored changes on checkout
if [ $smudge ]
then
   echo Smudge message >&2

   tmpfile=$(mktemp)
   trap "{ rm -f $tmpfile; }" EXIT

   #attributes=$(git check-attr -a $smudge | awk '$2 ~ /ignore-regex\d*/ { print $3 }')
   attributes=$(git check-attr -a $smudge | awk '$2 ~ /ignore-regex\d*/ { print "-I \x27"$3"\x27" }')

   git show HEAD:$smudge > $tmpfile

   if [ -f "$smudge" ]; then
         #<(grep -vE -f <(echo "$attributes") -- /dev/stdin) \
   #<(grep -vE -f <(echo "$attributes") -- $smudge) \
      diff --unified=0 -I 'git-ignore-line' $attributes \
         $smudge /dev/stdin \
         | patch $smudge -o - --quiet --batch
   else
      cat /dev/stdin
   fi

fi
