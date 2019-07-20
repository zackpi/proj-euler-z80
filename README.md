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

#### end
Specifies the end of the source code. Can be used to place a text segment at the end for documentation or an appendix. ~~Everything else after the `.end` directive will be ignored.~~ This should be the functionality of `.end` but as of the latest version of SPASM-ng it ignores the directive completely. Good practice to leave it in to 

```
.org $9D93
	ret
.end

.db "this shouldn't get assembled", 0
.db "but it does as of current version :(", 0
```

#### addinstr
Creates a new opcode and takes the following parameters:

```
.addinstr mnemonic args instr_data size [class extended end_data] 
```

* `mnemonic` is a word like "add" that indicates what the instruction does.
* `args` is a comma-separated list of the arguments 
* `instr_data` is the hex code that the opcode assembles to (For `ret` this would be `C9`)
* `size` is the total size that the opcode takes up in memory (can be any number > `instr_data`+`end_data`)
* `class` and `extended` are not used and can be omitted unless you want to specify `end_data`
* `end_data` is a single hex byte that will be placed after `instr_data` in the assembled bytecode

SPASM's `.addinstr` code supports `instr_data` up to 8 bytes in size, but due to a conflict with SPASM's pass-one parser, literals of size greater than 4 bytes are not possible so the instr_data field is limited to 4 bytes. However, as shown in the example below, 5 bytes are possible by specifying the single-byte `end_data` to be placed after a max-length `instr_data` segment.

```
.addinstr swap A,B A8A8A8 3
.addinstr supret "" C9C9C9C9 5 cls ext C9

.list
	swap A,B
	supret
```

The above code produces the following listing:

```
1 00:0000 -  -  -  -  .addinstr swap A,B A8A8A8 3
2 00:0000 -  -  -  -  .addinstr supret "" C9C9C9C9 5 cls ext C9
3 00:0000 -  -  -  -  
4 00:0000 -  -  -  -  .list
5 00:0000 A8 A8 A8 -  	swap A,B
6 00:0004 C9 C9 C9 C9 
          C9 -  -  -  	supret
```

Here are some useful instructions:

```
.addinstr swap A,B A8A8A8 3		; ```[XOR Swap Algorithm](https://en.wikipedia.org/wiki/XOR_swap_algorithm)```
.addinstr swap A,C A9A9A9 3
.addinstr swap A,D AAAAAA 3
.addinstr swap A,E ABABAB 3
.addinstr swap A,H ACACAC 3
.addinstr swap A,L ADADAD 3
.addinstr clr A AF 1			; A xor A = 0
```

They're saved in a file called [*extops.inc*](src/inc/extops.inc) which you can include in your code and use like so:

```
#include "extops.inc"
.org 0
	clr A						; not in the standard opcode set
	ret
```

#### echo
Print a value or string to a file or stderr during assembly.

```
.echo "Writing to stderr"
.echo > rel/path "Writing to this file"
.echo >> rel/path "Appending to this file"
```

#### error
Print a value or string to a file or stderr during assembly.

```
.error "err_string"
```

#### equ
Create an equate for a constant value. Each place in the source code where `ALIAS` is found, the constant value is substituted. Equates can be used in expressions, and likewise, expressions can be used as the constant value for an alias as long as the value is predetermined at assembly.

```
ALIAS 	.equ 64
PLUS1 	.equ 1+ALIAS
	ld A, PLUS1
```

#### show
Shows the string value of a define, so no text replacement is performed before printing the value (see `apple` below). Does not work with equates.

```
#define	progStart	$9D95
#define apple progStart-2
.show apple
```

The above code produces `APPLE: progStart-2` in the command line during assembly.

#### option
Create multiple defines in one line. Each `name=expr` pair will create a define with `__name` evaluating to `expr`. Several pairs can be chained together.

```
.option apple=56,orange=tacos,bagel="flamingo"
.show __apple
.show __orange
.show __flamingo
```

The above code produces the following during assembly:

```
__APPLE: 56
__ORANGE: tacos
__BAGEL: "flamingo"
```

#### seek
Moves the program counter to the specified 2-byte absolute address. Also moves the `out_ptr` which controls where the file ends to the value specified, so without the last line below, the program would end after `$9E20`, but with it the program ends at `$9E40` as intended.

```
.list
.org $9E00
.block 64,1
.seek $9E20		; place PC into center of .block segment
.db $FF
.seek $9E40		; sets the end of the program properly
```

Make sure to read carefully when looking at the listing file, since the addresses at the left are not always in order when using `.seek`. Check the addresses of lines 4 and 5.

```
1 00:0000 -  -  -  -  .list
2 00:0000 -  -  -  -  .org $9E00
3 00:9E00 01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 
          01 01 01 01 .block 64,1
4 ```**00:9E40**``` -  -  -  -  .seek $9E20
5 ```**00:9E20**``` FF -  -  -  .db $FF
6 00:9E21 -  -  -  -  .seek $9E40
```

However, a `hexdump` of the assembled binary shows that the operation was indeed performed properly--that is, an `$ff` appears in the middle of the `.block` segment.

```
00000000  01 01 01 01 01 01 01 01  01 01 01 01 01 01 01 01
00000010  01 01 01 01 01 01 01 01  01 01 01 01 01 01 01 01
00000020  ```**ff**``` 01 01 01 01 01 01 01  01 01 01 01 01 01 01 01
00000030  01 01 01 01 01 01 01 01  01 01 01 01 01 01 01 01
```

#### assume
Does nothing in the most recent version of SPASM. But if it did it would take arguments in this format:

```
.assume name=value
```