#!/bin/bash

matrix=$1
matlab=$2

cat $matlab <(tail -n1 $matrix | cut -d" " -f2- )