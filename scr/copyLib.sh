#! /usr/bin/bash
# example: ./copyLib.sh proj.c lib.c rock.root

tgtStartLn=$(sed -n "/^\/\/##$3/{=;q}" $1)
if [ -z "$tgtStartLn" ]; then
   echo "Target (this project) start line not found!"
   exit
fi
tgtEndLn=$(sed -n "$tgtStartLn,$ {/^\/\/##end/{=;q}}" $1)
if [ -z "$tgtEndLn" ]; then
   echo "Target (this project) end line not found!"
   exit
fi

srcStartLn=$(sed -n "/^\/\/##$3/{=;q}" $2)
if [ -z "$srcStartLn" ]; then
   echo "Source (library) start line not found!"
   exit
fi
srcEndLn=$(sed -n "$srcStartLn,$ {/^\/\/##end/{=;q}}" $2)
if [ -z "$srcEndLn" ]; then
   echo "Source (library) start line not found!"
   exit
fi

tempFile=$(mktemp)
trap "rm $tempFile" EXIT

sed -n "1,${tgtStartLn}p" $1 >> tempFile
sed -n "$((srcStartLn + 1)),$((srcEndLn - 1))p" $2 >> tempFile
sed -n "$tgtEndLn,\$p" $1 >> tempFile
mv tempFile $1
