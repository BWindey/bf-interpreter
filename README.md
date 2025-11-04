# A Brainfuck interpreter
Nothing special, but at some point in your life you need to create one.

If you're looking for a LICENSE, there is none. Why do you want to include
this in your project? Don't you have better things to do?

## Recap of Brainfuck
There is a list of instructions, and an array of data with at least 30K entries,
initialised to `0`, and a data pointer into that array.

| Char | Operation |
|------|-----------|
| `>`  | Increment data pointer |
| `<`  | Decrement data pointer |
| `+`  | Increment value at data pointer |
| `-`  | Decrement value at data pointer |
| `.`  | Print byte at data pointer |
| `,`  | Read byte into data pointer |
| `[`  | If value data pointer is `0`, jump one instruction after matching closing `]` |
| `]`  | If value data pointer is not `0`, jump one instruction after matching opening `[` |


## Extensions
This interpreter accepts certain extensions to the normal language.

### Comments
To support other extensions, comments have to be well defined. This is achieved
by starting a comment with `#` and ending it with `#`. Everything beween those
hash-characters will be ignored.

Normal brainfuck would just ignore all characters that are not part of the
actual language, but because I added routines, you cannot write comments
anymore like you would in brainfuck. Thus the need for defining comments.


### Routines
Routines are created with the syntax `{[a-Z]+...}`, meaning that a routines
declaration begins with a `{` and ends with a `}`. It has a name with one
or more alphabetical letters and a body.

Routines are called by their name. Arguments are passed by the convention that
the function itself specifies, f.e. you could move the data pointer to a cell
specifying the amount of arguments, followed by that amount of cells with the
arguments.

Think of routines like assembly level functions: jumping to a label and
returning to a caller when done. Any arguments and return values have to be
specified manually.

Limitations:
- routines cannot be used before they're declared
- when a routine with the same prefix exists but shorter, the one with the
  longer name will never get called (when parsing first match is executed)
- routines cannot call themselves


#### Examples:
##### Sum of two numbers
```
{sumtwo[>+<-]>}+++>++++++<sumtwo.
```
-> outputs char `0x9`

##### Printing `Hello World`
```
{
    printhello                            # Define the printhello function #
    ++++++++++                            # Initialise helper counter      #
    [>+>+++>+++++++>++++++++++<<<<-]      # Initialise extra helper cells  #
    # Print #
    >>>++.>+.+++++++..+++.<<++.>+++++++++++++++.>.+++.------.--------.
    # Clear used cells so this routine can be reused #
    <<<[->--->-------->----------<<<]>-->-------<<<
}
printhello printhello printhello
```
-> outputs `Hello WorldHello WorldHello World`

##### Getting an ASCII letter
```
{
    ASCIIa
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}
{ ASCIIb ASCIIa+ }
{ ASCIIc ASCIIb+ }
{ ASCIId ASCIIc+ }
{ ASCIIe ASCIId+ }
{ ASCIIf ASCIIe+ }
{ ASCIIg ASCIIf+ }
{ ASCIIh ASCIIg+ }
{ ASCIIi ASCIIh+ }
{ ASCIIj ASCIIi+ }
{ ASCIIk ASCIIj+ }
{ ASCIIl ASCIIk+ }
{ ASCIIm ASCIIl+ }
{ ASCIIn ASCIIm+ }
{ ASCIIo ASCIIn+ }
{ ASCIIp ASCIIo+ }
{ ASCIIq ASCIIp+ }
{ ASCIIr ASCIIq+ }
{ ASCIIs ASCIIr+ }
{ ASCIIt ASCIIs+ }
{ ASCIIu ASCIIt+ }
{ ASCIIv ASCIIu+ }
{ ASCIIw ASCIIv+ }
{ ASCIIx ASCIIw+ }
{ ASCIIy ASCIIx+ }
{ ASCIIz ASCIIy+ }
ASCIIh.>ASCIIe.>ASCIIl..>ASCIIo.
```
-> outputs `hello`

Notice that a good routine leaves the data-array clean for reuse.
