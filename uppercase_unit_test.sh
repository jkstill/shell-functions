#!/bin/bash

DEBUG=0
FUNCTIONS_FILE=$HOME/scripts/functions.sh; export FUNCTIONS_FILE
. $FUNCTIONS_FILE

WORD=$(upperCase 'this is a test')
echo UPPER: $WORD

WORD=$(lowerCase $WORD)
echo LOWER: $WORD

WORD=$(upperCase $WORD)
echo UPPER: $WORD

