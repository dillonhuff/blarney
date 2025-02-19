#!/bin/bash

# Run regression tests

EXAMPLES=(
  BasicRTL
  BitPat
  BitScan
  CPU
  Derive
  Factorial
  FIFO
  Interface
  MeanFilter
  Queue
  SourceSinkStream
  RAM
  Sorter
  UpDownCounter
  MasterSlave
  NoC
)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ -z "$BLARNEY_ROOT" ]; then
  echo Please set BLARNEY_ROOT environment variable
fi

for E in "${EXAMPLES[@]}"; do
  cd $BLARNEY_ROOT/Examples/$E
  make -s &> /dev/null
  if [ $? != 0 ]; then
    echo Failed to build $E
    exit -1
  fi
  for O in $(ls *.out); do
    TEST=$(basename $O .out)
    echo -ne "$TEST: "
    ./$TEST
    cd $TEST-Verilog
    make -s &> /dev/null
    ./top | head -n -1 > $TEST.got
    cd ..
    cmp -s $TEST.out $TEST-Verilog/$TEST.got
    if [ $? == 0 ]; then
      echo -e "${GREEN}Passed${NC}"
    else
      echo -e "${RED}Failed${NC}"
      exit -1
    fi
  done
done
