#!/usr/bin/env bats

function teardown {
  git reset initialCommit --hard
  git checkout .
}

@test "When file is modified and no git attributes, git shows file as modified" {
  cp testfile1.modified.txt testfile1.txt
  git add testfile1.txt
  result=$(echo $(git status --porcelain -- testfile1.txt))
  echo "result is $result"
  [ "$result" = "M testfile1.txt" ]
}

@test "When ignored lines is modified, git shows file as not modified" {
  cp testfile2.modified.txt testfile2.txt
  git add testfile2.txt
  result=$(echo $(git status --porcelain -- testfile2.txt))
  echo "result is $result"
  git diff --cached -- testfile2.txt
  
  [ "$result" = "" ]
}

@test "On commit all but ignored lines are saved" {
  cp testfile3.modified.txt testfile3.txt
  git add testfile3.txt
  git commit -m"test 3"

  diff -u testfile3.expected.txt <(git show HEAD:testfile3.txt)
  [ $? -eq 0 ]
}

@test "Checkout only overrides not ignored changes" {
 # skip 'smudge script is no working. Git deletes $smudge file before running a filter'
  cp testfile4.modified.txt testfile4.txt
 
  git checkout HEAD

  diff -u testfile4.txt testfile4.expected.txt
  [  $? -eq 0 ]

  result=$(echo $(git status --porcelain -- testfile4.txt))
  [ "$result" = "" ]
}