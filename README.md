# CompilerDesign
### This repository consists of Compiler Design Assignment.

### Submitted By:
Pranjal Bankawat
Mahima M Nayak

### Steps to run the compiler:

  System Requirements
  macOS or windows with Cygwin
  
### Installation (mac):
  1. Open terminal
  2. Install brew if not there
  3. write command : brew install flex
  4. write command : brew install bison

### Setup:
  Clone the project
  
### Run:
  1. bison -y -d compiler.y
  2. flex compiler.l
  3. gcc y.tab.c lex.yy.c compiler.c -o compiler.exe
  4. ./compiler.exe

To clean the folder safely
  1. Copy content of clean
  2. paste on terminal where pwd should be same where all generated files are
  3. paste and run


