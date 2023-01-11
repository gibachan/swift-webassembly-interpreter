#!/bin/bash -eu
rm -rf ../Tests/Spec/Resources/build
mkdir ../Tests/Spec/Resources/build
cp ./core/*.wast ../Tests/Spec/Resources/build

for file in $(ls ../Tests/Spec/Resources/build); do
  wast2json ../Tests/Spec/Resources/build/$file -o ../Tests/Spec/Resources/build/$file.json
done