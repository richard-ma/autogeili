#!/usr/bin/env bash

readonly ROOT_DIR=$PWD/../..
readonly TMP_DIR=tmpDir
readonly RELEASE_DIR=autogeili

# 
# Remove older dirs
# -----------------
if [ -e $TMP_DIR ]; then
	rm -rf $TMP_DIR
fi

if [ -e $RELEASE_DIR ]; then
	rm -rf $RELEASE_DIR
fi

if [ -e autogeili$1.tar.gz ]; then
	rm autogeili$1.tar.gz
fi

# 
# Export codes
# -----------------
svn export $ROOT_DIR/ $TMP_DIR

# 
# Rename TMP_DIR
# -----------------
mv $TMP_DIR $RELEASE_DIR

#
# Remove Dev dirs
# -----------------
rm -rf $RELEASE_DIR/dev

# 
# Create package
# -----------------
tar -cf autogeili$1.tar autogeili/
gzip autogeili$1.tar

