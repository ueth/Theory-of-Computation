## Project Description

The goal of this project is to design and implement the initial stages of a compiler for an imaginary programming language called "Kappa". The project is part of the "PLI402 – Theory of Computation” course, aimed at deepening the understanding of the use and application of theoretical tools, such as regular expressions and context-free grammars, for the problem of compiling programming languages.

In this project, we create a source-to-source compiler (also known as a trans-compiler or transpiler). This type of compiler takes the source code of a program in one programming language and produces equivalent source code in another programming language. In our case, the input source code will be written in the fictional programming language Kappa, and the generated code will be in the C programming language.

The tools used for the implementation are Flex and Bison, which are both available as free software. The programming language used for the compiler is C.

The project consists of two parts:
* Implementing a lexical analyzer for the Kappa language using Flex.
* Implementing a syntax analyzer for the Kappa language using Bison.
    * The Bison actions will be used to convert Kappa code into C code.

## Getting Started

1. Install Bison and Flex on your machine if you have not done so.

2. Clone the repository to your local machine.

3. Navigate to the project directory.

4. Run `make` to build the compiler. This will create a binary file called 'compiler'.

## Testing

To test the compiler, I have provided two Kappa code files, `correct1.ka` and `correct2.ka`.

Run `make test` to compile these Kappa files into C programs (`correct1.c` and `correct2.c`), and then compile these C programs into executable files (`correct1` and `correct2`).

## Cleaning Up

Run `make clean` to remove generated files.

## Future Work

This project currently only implements the initial stages of the Kappa compiler. Future work includes completing the compiler and implementing error handling and optimization strategies.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## GCC Version

gcc (Ubuntu 11.3.0-1ubuntu1~22.04) 11.3.0
