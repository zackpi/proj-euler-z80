#!/bin/sh

echo "Ti-8x z80 ASM Project Euler programs"
echo "Copyright 2019 Zachary Pitcher"
echo ""

PROB="1"
DEBUG="false"

while getopts 'p:d' flag; do
	case "${flag}" in
		p) PROB="${OPTARG}" ;;
		d) DEBUG="true" ;;
	esac
done

# parse problem argument as a number
case $PROB in
    ''|*[!0-9]*) echo "Problem argument must be a number"; exit ;;
    *) PROG=$(printf "prob%03d" $PROB); CALCNAME=$(printf "PROB%03d" $PROB) ;;
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

# build a hex binary and create a code listing
ASM_FLAGS="-T -S -I $INC_DIR"
MAIN_FILE=$CODE_DIR/$PROG.z80
BIN_FILE=$BIN_DIR/$PROG.bin
LST_FILE=$LST_DIR/$PROG.lst

echo "Building $PROG:"
echo "Assembling Hex Binary File..."
echo "spasm $ASM_FLAGS $MAIN_FILE $BIN_FILE"
spasm $ASM_FLAGS $MAIN_FILE $BIN_FILE
mv $BIN_DIR/$PROG.lst $LST_FILE
echo ""

# convert binary into a ti calculator program
XP8_FILE=$XP8_DIR/$PROG.8xp

echo "Formatting .8xp Program File..."
echo "python3 $UTIL_DIR/bin_to_8xp.py --oncalcname $CALCNAME $BIN_FILE $XP8_FILE"
python3 $UTIL_DIR/bin_to_8xp.py --oncalcname $CALCNAME $BIN_FILE $XP8_FILE
echo ""

# Run the program on an emulator
ROM_FILE=$ROM_DIR/ti84se.rom
MACRO_FILE=$MACRO_DIR/runasm.macro

echo "Running $PROG.8xp on emulator..."

if [ $DEBUG != "true" ]; then
	tilem2 -r $ROM_FILE -p $MACRO_FILE $XP8_FILE 2> /dev/null
else
	tilem2 -r $ROM_FILE -p $MACRO_FILE $XP8_FILE -d & 2> /dev/null

	sleep .5
	echo "Running debugger and breaking at usermem..."
	xdotool key Tab Shift+Tab Menu 
	sleep .05
	xdotool key Down Down Return 
	sleep .05
	xdotool key 9 D 9 5 Return 
	sleep .05
	xdotool key Menu Down Return 
	sleep .05
	xdotool key Shift+Tab Left Left Left Return
	wait
fi

echo "Done."

