#!/bin/sh

echo "Ti-8x z80 ASM Project Euler programs"
echo "Copyright 2019 Zachary Pitcher"
echo ""

# parse first argument from command line as the problem to be built
case $1 in
    ''|*[!0-9]*) echo "Choose a problem to build by specifying a first argument"; exit ;;
    *) PROB=$1; PROG=$(printf "prob%03d" $PROB) ;;
esac

# parent directories
SRC_DIR="src"
BUILD_DIR="build"
UTIL_DIR="util"
EMU_DIR="emu"

# leaf directories
INC_DIR=$SRC_DIR/inc
CODE_DIR=$SRC_DIR/z80
LST_DIR=$BUILD_DIR/lst
BIN_DIR=$BUILD_DIR/bin
XP8_DIR=$BUILD_DIR/8xp
ROM_DIR=$EMU_DIR/rom
MACRO_DIR=$EMU_DIR/macro

# make sure that the directory tree is built
mkdir -p $INC_DIR $CODE_DIR $LST_DIR $BIN_DIR $XP8_DIR $ROM_DIR $MACRO_DIR

ASM_FLAGS="-T -I $INC_DIR"
MAIN_FILE=$CODE_DIR/$PROG.z80
BIN_FILE=$BIN_DIR/$PROG.bin
LST_FILE=$LST_DIR/$PROG.lst

echo "Building $PROG:"
echo "Assembling..."
echo "spasm $ASM_FLAGS $MAIN_FILE $BIN_FILE"
spasm $ASM_FLAGS $MAIN_FILE $BIN_FILE
mv $BIN_DIR/$PROG.lst $LST_FILE
echo ""

# convert binary to ti calculator program format
XP8_FILE=$XP8_DIR/$PROG.8xp

echo "Formatting $PROG.bin to .8xp..."
echo "python3 $UTIL_DIR/bin_to_8xp.py $BIN_FILE $XP8_FILE"
python3 $UTIL_DIR/bin_to_8xp.py $BIN_FILE $XP8_FILE
echo ""

# Run the program on an emulator
ROM_FILE=$ROM_DIR/ti84se.rom
MACRO_FILE=$MACRO_DIR/runasm.macro

echo "Running $PROG.8xp on emulator..."
echo ""
tilem2 -r $ROM_FILE -p $MACRO_FILE $XP8_FILE
