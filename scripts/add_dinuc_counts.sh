#!/bin/bash

matrix=$1
counts=$2

cat $matrix <(cat "dinuc" <(grep -f <(head -n1 $matrix | tr "\t" "\n") $counts | cut -f2) | tr "\n" "\t")