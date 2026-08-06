#! /usr/bin/bash

for f in *.jpg; do 
   cjxl "$f" "${f%.jpg}.jxl"; 
done
