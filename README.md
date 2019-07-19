# Ti8X z80 ASM Project Euler Programs
### by zackpi

## SPASM-ng Documentation
### Directives
#### db, dw, dl
Place bytes, words, or double-words into code memory at the current location.

```assembly
.db	3, $F5, 17 
.db "zero-terminated string", 0
.dw 65535, $C0DE
.dl $DEADBEEF
```

#### nolist, list
These determine what portions of the code should be included in a listing file, which is intended to allow you to compare assembly to bytecode. Usually put .nolist before includes and defines and .list before the code segment

```assembly
.nolist
#include "file.inc"
#define VALUE

.list
; code
```

#### org
This tells the assembler where in memory the code should be written and executed from. Can also be used to leave space between code blocks in a larger program

```assembly
.org 
```