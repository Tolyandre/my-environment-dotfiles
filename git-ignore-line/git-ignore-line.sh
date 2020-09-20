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
   #attributes=$(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print "-I \x27"$3"\x27" }')
   my_array=()
   mapfile -t my_array < <(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print "-I\n"$3 }')

   git show HEAD:$clean > $tmpfile

   #echo $attributes >&2

   # if repository is just initialized, handle error "fatal: invalid object name 'HEAD'"
   if [ $? -ne 0 ]; then
      cat /dev/stdin
      exit
   fi

      #<(grep -vE -f <(echo "$attributes") -- $tmpfile) \
      #<(grep -vE -f <(echo "$attributes") -- /dev/stdin) \
   #diff --unified=0 -I 'git-ignore-line' $attributes \
   diff --unified=0 ${my_array[@]} -I 'git-ignore-line' \
      $tmpfile /dev/stdin \
      | awk '{if($0 ~ /git-ignore-line/){sub(/^-/, "+", last); print last} else {print $0} {last=$0}}' \
      | patch $tmpfile -o - --quiet --batch
fi

# Restore ignored changes on checkout
if [ $smudge ]
then
   echo Smudge message >&2

   tmpfile=$(mktemp)
   trap "{ rm -f $tmpfile; }" EXIT

   #attributes=$(git check-attr -a $smudge | awk '$2 ~ /ignore-regex\d*/ { print $3 }')
   #attributes=$(git check-attr -a $smudge | awk '$2 ~ /ignore-regex\d*/ { print "-I \x27"$3"\x27" }')
   my_array=()
   mapfile -t my_array < <(git check-attr -a $smudge | awk '$2 ~ /ignore-regex\d*/ { print "-I\n"$3 }')

   git show HEAD:$smudge > $tmpfile

   cat $smudge >&2
   ls >&2

   if [ -f "$smudge" ]; then
      echo smudge file exists >&2
         #<(grep -vE -f <(echo "$attributes") -- /dev/stdin) \
         #<(grep -vE -f <(echo "$attributes") -- $smudge) \
      diff --unified=0 -I 'git-ignore-line' ${my_array[@]} \
         $smudge /dev/stdin \
         | patch $smudge -o - --quiet --batch
   else
      echo smudge file does NOT exist >&2
      cat /dev/stdin
   fi

fi
