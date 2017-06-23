#!/bin/sh
if [ -e outfile.txt ]
then
    rm outfile.txt
fi
./toupper infile.txt outfile.txt
if [ -e outfile.txt ]
then
    echo ""
    echo "Results:"
    echo "-------------------"
    cat outfile.txt
fi
