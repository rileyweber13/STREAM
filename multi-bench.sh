#!/bin/bash

BYTES_PER_ELEMENT=8
SPACE_BETWEEN_RUNS=10

# num iters and sizes

#                   L1         L2      L3       RAM
#                ~16kb      ~80kb   1.6Mb      80Mb
test_sizes=(      2000      10000  200000  10000000)

# Num iters are tuned to be about 15s per test on my machine, where possible.
# Running with more than 250,000 iterations causes segfault
ntimes=(        250000     250000   22000       300)

if [ "$1" == "-v" ]; then
  echo "Running in verbose mode."
else 
  echo "Running with short output, pass '-v' as first parameter to enable" \
       "higher verbosity."
fi

for i in $(seq 0 $((${#test_sizes[@]} - 1)) ); do
  # print info about this iteration
  echo "=========================================================="
  echo "  Compiling and running stream benchmark with the"
  echo "  following parameters:"
  echo "    num iter:            ${ntimes[$i]}"
  echo "    array size (items):  ${test_sizes[$i]}"
  echo "    array size (bytes): ~$(( ${test_sizes[$i]} * $BYTES_PER_ELEMENT \
                                     * 1000 / 1024))"
  if [ "$1" == "-v" ]; then
    echo "    i:             $i"
    echo "    ntimes[i]:     ${ntimes[$i]}"
    echo "    test_sizes[i]: ${test_sizes[$i]}"
  fi
  echo "=========================================================="

  # compile
  compile_command="gcc -O2 -fopenmp -DNTIMES=${ntimes[$i]} \
    -DSTREAM_ARRAY_SIZE=${test_sizes[$i]} stream.c \
    -o stream_c.${test_sizes[$i]}"
  echo "compiling with command \"$compile_command\""
  $compile_command

  # run
  run_command="./stream_c.${test_sizes[$i]}"
  echo "running with command \"$run_command\""
  if [ "$1" == "-v" ]; then
    /usr/bin/time -f "Runtime: %E" $run_command
  else
    /usr/bin/time -f "Runtime: %E" $run_command | grep Function -B 1 -A 7
  fi

  if [ "$1" == "-v" ]; then
    # add space between iterations
    for j in $(seq $SPACE_BETWEEN_RUNS); do echo; done
  else
    echo; echo
  fi
done

