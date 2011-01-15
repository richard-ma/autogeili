#!/usr/bin/evn bash

readonly TMP_DIR=tmpDir
readonly RELEASE_DIR=autogeili

# 
# Remove older dirs
# -----------------
if [ -d $TMP_DIR ]; then
	rm -rf $TMP_DIR
fi

# 
# Create temp dir
# -----------------
mkdir -p $TMP_DIR


