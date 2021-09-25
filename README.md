# IOListTest

Quick experiment to look into splitting of iodata as a list-based operation instead of 
using binary splitting and concatenation. Provides a function that takes an iodata
and a length, and returns an iodata consisting of the first length bytes of the input,
along with the remainder (both as iodata). 

As written this is currently much slower than binary splits & concatenations, I
believe because the latter is written in C (but also maybe because my implementation 
isn't very good. It's just an afternoon lark at this point).
