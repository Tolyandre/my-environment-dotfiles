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
   #git show HEAD:$clean
   #cat $clean

   tmpfile=$(mktemp)
   trap "{ rm -f $tmpfile; }" EXIT

   git show HEAD:$clean > $tmpfile

   diff --unified=0 \
   <(grep -vE -f <(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print $3 }') -- $tmpfile) \
   <(grep -vE -f <(git check-attr -a $clean | awk '$2 ~ /ignore-regex\d*/ { print $3 }') -- $clean) |\
      patch $tmpfile -o - --quiet --batch


   #  git show HEAD:$clean |\
   #     grep -vE "$ignoreRegex" |\
   #     diff --unified -I 'ConWnd XXX' <(grep -vE "$ignoreRegex" $clean) - |\
   #     patch $clean -o - --quiet --batch
fi

# echo "$pwd I am git-ignore-line" $@
# echo $((1 + RANDOM % 10))