#!/bin/bash
set -e -x
DIST="duckuments-dist"
dest="dest"
out=$1
rm -rf ${dest}

mkdir -p ${dest}/

cp -R ${DIST}/* ${dest}

tar cvfz ${out} -C ${dest} .
