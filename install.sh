#!/bin/sh
curl -L -o ~/Desktop/Ring.zip "https://github.com/leavez/Ring/archive/master.zip"
unzip -q -o ~/Desktop/Ring.zip -d ~/Desktop/Ring2
mv ~/Desktop/Ring2/Ring-master ~/Desktop/Ring
rm -rf ~/Desktop/Ring2
rm ~/Desktop/Ring.zip
echo "Script Downloaded"
ruby ~/Desktop/Ring/do.rb
