#!/bin/sh

set -e

PACKAGES=$1
TITLE=$2

mkdir -p _build/apidoc

ocamlfind ocamldoc -html -d _build/apidoc/ \
          -package $PACKAGES  \
          -thread  -charset UTF-8 -t "$TITLE: API Docs" -keep-code -colorize-code \
          -sort \
          -I _build/src/lib/ \
          src/*/*.mli src/*/*.ml

INPUT= \
     INDEX=README.md \
     TITLE_PREFIX="$TITLE: " \
     API=_build/apidoc/ \
     OUTPUT_DIR=_build/doc/ \
     oredoc
