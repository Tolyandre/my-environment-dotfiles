#!/bin/bash

# https://brianchildress.co/named-parameters-in-bash/#:~:text=Shift%20is%20a%20built%2Din,the%20argument%20to%20their%20value.
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

   shift
done

# Clean up ignored changes before staging
# $clean is file being processed
if [ $clean ]
then
   stdinTemp=$(mktemp)
   trap "{ rm -f $stdinTemp; }" EXIT
   cat /dev/stdin> $stdinTemp

   fileFromHead=$(mktemp)
   trap "{ rm -f $fileFromHead; }" EXIT
   git show HEAD:$clean > $fileFromHead 2> /dev/null

   # handle error "fatal: invalid object name 'HEAD'" from `git show`
   # it occures when repository is just initialized
   if [ $? -ne 0 ]; then
      cat $stdinTemp
      exit
   fi

   attributes=()
   mapfile -t attributes < <(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print "-I\n"$3 }')

   #echo 'Clean filter is running (git-ignore-line)' >&2

   diff --unified=0 ${attributes[@]} \
      $fileFromHead $stdinTemp \
      | awk '{if($0 ~ /git-ignore-line/){sub(/^-/, "+", last); print last} else {print $0} {last=$0}}' \
      | patch $fileFromHead -o - --quiet --batch

fi

# Restore ignored changes on checkout
# $smudge is file being processed
if [ $smudge ]
then
   attributes=()
   mapfile -t attributes < <(git check-attr -a $smudge | awk '$2 ~ /ignore-regex\d*/ { print "-I\n"$3 }')

   if [ -f "$smudge" ]; then
      echo 'Smudge filter is running (git-ignore-line)' >&2

      diff --unified=0 -I 'git-ignore-line' ${attributes[@]} \
         $smudge /dev/stdin \
         | patch $smudge -o - --quiet --batch
   else
      echo smudge file does NOT exist >&2
      cat /dev/stdin
   fi

fi
