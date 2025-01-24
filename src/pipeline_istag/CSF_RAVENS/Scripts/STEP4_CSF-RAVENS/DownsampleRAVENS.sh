#! /bin/bash

inImg=$1
outImg=$2

if [ -z $inImg ] || [ -z $outImg ]; then
    echo "Usage: $0 [inimg] [outimg]"
    exit 1
fi

if [ ! -e $outImg ]; then
    if [ -e $inImg ]; then
        cmd="3dresample -dxyz 2 2 2 -rmode Cu -prefix $outImg -inset $inImg"
        echo "About to run: $cmd"
        $cmd
    else
        echo "Skip img, in missing "
    fi
else
    echo "Skip img, out exists "
fi

