#!/usr/bin/env bats

@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}

@test "When file is modified, git shows file as modified" {
  cp testfile.modified.xml testfile1.xml
  git add testfile2.xml
  result=$(echo $(git status --porcelain -- testfile1.xml))
  echo "result is $result"
  [ "$result" = "M testfile1.xml" ]
}

@test "When ignored line is modified, git shows file as not modified" {
  cp testfile.modified.xml testfile2.xml
  git add testfile2.xml
  result=$(echo $(git status --porcelain -- testfile2.xml))
  echo "result is $result"
  git diff --cached -- testfile2.xml
  
  [ "$result" = "" ]
}