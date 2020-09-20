#!/usr/bin/env bats

function teardown {
  git reset
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

@test "Checkout only overrides not ignored changes" {
  cp testfile3.modified.txt testfile3.txt
 
  git checkout HEAD
  diff -u testfile3.txt testfile3.expected.txt

  result=$(echo $(git status --porcelain -- testfile3.txt))
  [ "$result" = "" ]
}