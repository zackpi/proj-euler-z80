# Ti8X z80 ASM Project Euler Programs
### by zackpi

## SPASM-ng Documentation
### Directives
#### db (byte), dw (word), dl (long)
Place bytes, words, or longs (double-words) into code memory at the current location. The `.byte`, `.word`, and `.long` directives are aliases for `.db`, `.dw`, and `.dl`, respectively.

```
.db	3, $F5, 17 
.db "null-terminated string",0
.byte 3, $F5, 17	; same thing

.dw 65535, $C0DE
.word 65535, $C0DE	; same thing

.dl $DEADBEEF
.long $DEADBEEF	; same thing
```

#### nolist, list
These determine what portions of the code should be included in a listing file, which is intended to allow you to compare assembly to bytecode. Usually put `.nolist` before includes and defines and `.list` before the code segment

```
.nolist
#include "file.inc"
#define VALUE

.list
	ret
```

#### org
This tells the assembler to set the program counter to the two-byte address passed as its argument. The actual address that labels correspond to are all calculated based on the value in PC. It should also be used at the beginning of the program to tell the assembler where in memory the code will be loaded and executed from ($9D93 for Ti calculators). Can also be used to leave space between code blocks in a larger program

```
.org $9D93		; PC <- $9D93
```

#### fill, block
Fills a region of memory starting at the current value of PC with a constant value, and increments PC to start at the next byte after the fill block. The first argument specifies the number of bytes to fill. The optional second argument specifies the value to fill with. If no second argument is given the region is filled with 0. The `.fill` and `.block` directives are aliases for each other, so they do the exact same thing.

```
.fill 256, $AB	; fills 256 bytes with $AB
.fill 10		; fills 10 bytes with 0

.block 256, $AB
.block 10		; the same thing
```

#### addinstr

#### echo

#### error

#### equ

#### show

#### option

#### seek

#### assume