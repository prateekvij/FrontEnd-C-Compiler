# FrontEnd-C-Compiler


The following is an implementation of front-end C compiler using flex and bison. The program takes a C-program as input and perform syntax parsing, semantic analysis and Intermediate Code Generation. The parser is based on LALR grammar.

If the input C program is valid, program output Symbol table along with intermediate code.


To compile the code, run
```bash 
$ make
```
To recompile. run
```
$ make clean
$ make
```

The program need bison and flex installed. You can install them by
```bash
$ sudo apt-get install bison
$ sudo apt-get install flex
```

The list of supported tokens is given in file "tokens". If you want to add or remove tokens, make changes in the file "tokens". Then, run
```bash
$ python generate_tokens.py
```
This will generate "tokens.h" which is used by the program.

To run the code, write the sample code to parse in file "input". Now run the command
```bash
$ ./c_parser < input
```

### About the code
1. **c_parser.y**: Primary file containing the grammer for parsing and semantic analysis.
2. **c_parser.l**: Contains regex and token_strings for converting strings to tokens.
3. **symtable.h**: Code for symbol table generation and maintainance. 
4. **tokens.h**: Contains tokens for flex parsing

### Examples

```c
int max(int a,int b){
	if ( a > b ){
		 return a;
	}
	return b;
}
int main(){
	
	int a, b;
	a = 2;
	b = 5;
	int c;
	if ( a > b) {
		return b;
		while( b > 0 ){
			c = c+1;
			b = b-1;
		}
	}
	return 0;
}
```

Output
```bash
Symbol Table
$global		0
	>>Name: $global
	>>Param count: 0
	>>Params : 
	>>Var : 
max	int	2
	>>Name: max
	>>Param count: 2
	>>Params : a(int)(1)  b(int)(1)  
	>>Var : 
main	int	0
	>>Name: main
	>>Param count: 0
	>>Params : 
	>>Var : a(int)(2)  simple b(int)(2)  simple c(int)(2)  simple 

0  func begin max
1  t1 = a > b
2  if (t1 == 0) goto 4
3  return a
4  return b
5  func end
6  func begin main
7  a = 2
8  b = 5
9  t2 = a > b
10  if (t2 == 0) goto 20
11  return b
12  t3 = b > 0
13  if (t3 == 0) goto 20
14  t4 = a * 3
15  t5 = c + t4
16  c = t5
17  t6 = b - 1
18  b = t6
19  goto 12
20  return 0
21  func end

```
