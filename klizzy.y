%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include "stdbool.h"
#include <set>
#include <map>

extern char* yytext;
extern int LINES;

int tempVarCount = 0;
int labelCount = 0;
std::map<std::string, std::string> symTable;
std::map<std::string, std::string> functions;
std::set<std::string> reserved = {"main", "i", "in", "out", "kill", "if", "ow", "send", "func", "until",
                                  "and", "or", "not"};
std::map<std::string, int> arraySizes;
int yyerror(std::string);
bool isReserver(std::string);
void kError(std::string, std::string);
template <typename T>
std::string to_string(T);
void addArray(std::string, int);
void isValidArray(std::string, int);
bool isFunction(std::string);
void addFunction(std::string, std::string);
bool isSymbol(std::string);
void addSymbol(std::string, std::string);
std::string makeTempVar();
std::string newLabel();
char* cStr(std::string);
int yylex();

%}

%define parse.error verbose

%union {

    int intval;
    char* strval;
    char* str;

    struct CodeNode {
        char* code;
        char* name;
        int Count;
    } node;
}

/* declare tokens */
%token<str> INTEGER
%token<str> IN
%token<str> OUT
%token<str> KILL
%token<str> IF
%token<str> OTHERWISE
%token<str> SEND
%token<str> FUNCTION
%token<str> UNTIL
%token<strval> IDENT
%token<strval> NUMBER
%token<str> L_SQUARE_BRACKET
%token<str> R_SQUARE_BRACKET
%token<str> SEMICOLON
%token<str> EQUAL
%token<str> PLUS
%token<str> MINUS
%token<str> MULT
%token<str> DIV
%token<str> BOOL_EQUAL
%token<str> BOOL_GREATER
%token<str> BOOL_LESSER
%token<str> BOOL_NOTEQUAL
%token<str> R_SQUIG
%token<str> L_SQUIG
%token<str> L_PAREN
%token<str> R_PAREN
%token<str> LINE_COMMENT
%token<str> BLOCK_COMMENT
%token<str> NEWLINE
%token<str> COMMA
%token<str> AND
%token<str> OR
%token<str> NOT


%type<node> Program
%type<node> Term
%type<node> Var
%type<node> ArrayCreate
%type<node> ArrayAccess
%type<node> Assign
%type<node> Out
%type<node> Multiply
%type<node> Expression
%type<node> Compare
%type<node> BoolExpression
%type<node> Function
%type<node> FunctionCall
%type<node> Statement
%type<node> Statements
%type<node> If-Block
%type<node> Until
%type<node> CreateFunctionArgs
%type<node> CreateFunctionCall
%type<node> In
%type<node> Ignore
%type<node> Type
%%

Start: Program {
    if (!isFunction("main")) {
        kError("Start", "no 'main' function could be found.");
    }

    std::string code = "";

    for (const auto& [key, value] : functions) {
        code += std::string(value) + "\n";
    }
    

    FILE *outFile;
    outFile = fopen("./klizzy.mil", "w+");
    fputs(cStr(code), outFile);
    fclose(outFile);
}

Program: {
    $$.name = cStr("");
    $$.code = cStr("");
}
| Ignore Program {
    $$.code = $2.code;
    $$.name = cStr("");
}
| Statements Program {
    std::string code = "";
    code.append($2.code);
    code.append($1.code);
    $$.code = cStr(code);
    $$.name = cStr("");
}
;

Ignore: LINE_COMMENT {
    $$.name = cStr("");
    $$.code = cStr("");
}
 | BLOCK_COMMENT {
    $$.name = cStr("");
    $$.code = cStr("");
}
 | NEWLINE {
    $$.name = cStr("");
    $$.code = cStr("");
}
;

Term: NUMBER {
    std::string temp = makeTempVar();
    std::string code = "";
    code += ". " + temp + "\n";
    code += "= " + temp  + ", " + std::string($1) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);
}
| IDENT {
    $$.code = cStr("");
    $$.name = $1;
}
| ArrayAccess {
    $$ = $1;
}
| FunctionCall {
    $$ = $1;
}
;

Type: INTEGER {
    $$.name = cStr("");
    $$.code = cStr("");
}
;

Var: Type IDENT {
    $$.code = cStr(". " + std::string($2) + "\n");
    $$.name = cStr(std::string($2));
    addSymbol(std::string($2), "Integer");
}
;

ArrayCreate: Type L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET IDENT {
    $$.code = cStr(".[] " + std::string($5) + ", " + std::string($3) + "\n");
    $$.name = cStr("");
    addArray(std::string($5), atoi($3));
}
;

ArrayAccess: IDENT L_SQUARE_BRACKET Expression R_SQUARE_BRACKET {
    std::string temp = makeTempVar();
    std::string code = "";
    code += $3.code;
    code += ". " + temp + "\n";
    code += "=[] " + temp + ", " + std::string($1) + ", " + std::string($3.name) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);

    //isValidArray(std::string($1), atoi($3));
}
;

Assign: IDENT L_SQUARE_BRACKET Expression R_SQUARE_BRACKET EQUAL Expression {
    std::string code = "";
    code += std::string($6.code);
    code += $3.code;
    code += "[]= " + std::string($1) + ", " + std::string($3.name) + ", " + std::string($6.name) + "\n";
    $$.name = cStr("");
    $$.code = cStr(code);

    //isValidArray(std::string($1), atoi($3));
}
 | Var EQUAL Expression {
    std::string code = "";
    code += std::string($1.code);
    code += std::string($3.code);
    code += "= " + std::string($1.name) + ", " + std::string($3.name) + "\n";
    $$.name = cStr("");
    $$.code = cStr(code);
 }
 | IDENT EQUAL Expression {
    std::string code = "";
    code += std::string($3.code);
    code += "= " + std::string($1) + ", " + std::string($3.name) + "\n";
    $$.name = cStr("");
    $$.code = cStr(code);

    if (!isSymbol(std::string($1))) {
        kError("Assign", "Identifier '" + std::string($1) + "' has not been declared.");
    }
 }
;

In: IN L_PAREN Term R_PAREN  {
    std::string code = "";
    code += std::string($3.code);
    code += ".< " + std::string($3.name) + "\n";
    $$.name = cStr("");
    $$.code = cStr(code);

    if (!isSymbol(std::string($3.name))) {
        kError("In", "Identifier '" + std::string($3.name) + "' has not been declared.");
    }
}
;

Out: OUT L_PAREN Term R_PAREN {
    std::string code = "";
    code.append($3.code);
    code.append(std::string(".> "));
    code.append($3.name);
    code.append(std::string("\n"));
    $$.name = cStr("");
    $$.code = cStr(code);

    if (!isSymbol(std::string($3.name))) {
        kError("Out", "Identifier '" + std::string($3.name) + "' has not been declared.");
    }
}
;

Multiply: Term {
    $$ = $1;
}
| Term MULT Multiply {
    std::string temp = makeTempVar();
    std::string code = "";
    
    code += std::string($1.code) + std::string($3.code);
    code += ". " + temp + "\n";
    code += "* " + temp + ", " + std::string($1.name) + ", " + std::string($3.name) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);
}
| Term DIV Multiply {
    std::string temp = makeTempVar();
    std::string code = "";
    
    code += std::string($1.code) + std::string($3.code);
    code += ". " + temp + "\n";
    code += "/ " + temp + ", " + std::string($1.name) + ", " + std::string($3.name) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);
}
;

Expression: Multiply {
    $$ = $1;
}
 | L_PAREN Expression R_PAREN {
    $$ = $2;
 }
 | Expression PLUS Expression {
    std::string temp = makeTempVar();
    std::string code = "";

    code += std::string($1.code) + std::string($3.code);
    code += ". " + temp + "\n";
    code += "+ " + temp + ", " + std::string($1.name) + ", " + std::string($3.name) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);

    if (!isSymbol(std::string($1.name))) {
        kError("Expression","Identifier '" + std::string($1.name) + "' is not declared.");
    }
    if (!isSymbol(std::string($3.name))) {
        kError("Expression","Identifier '" + std::string($3.name) + "' is not declared.");
    }
     
 }
 | Expression MINUS Expression {
    std::string temp = makeTempVar();
    std::string code = "";
    code = std::string($1.code) + std::string($3.code);
    code += ". " + temp + "\n";
    code += "- " + temp + ", " + std::string($1.name) + ", " + std::string($3.name) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);

    if (!isSymbol(std::string($1.name))) {
        kError("Expression","Identifier '" + std::string($1.name) + "' is not declared.");
    }
    if (!isSymbol(std::string($3.name))) {
        kError("Expression","Identifier '" + std::string($3.name) + "' is not declared.");
    }
     
}
;

Compare: BOOL_EQUAL {
    $$.code = cStr("==");
    $$.name = cStr("");
}
 | BOOL_GREATER {
    $$.code = cStr(">");
    $$.name = cStr("");
}
 | BOOL_LESSER {
    $$.code = cStr("<");
    $$.name = cStr("");
}
 | BOOL_NOTEQUAL {
    $$.code = cStr("!=");
    $$.name = cStr("");
}
;
 
BoolExpression: NUMBER {
    std::string temp = makeTempVar();
    std::string code = "";
    
    code += ". " + temp + "\n";
    code += "= " + temp + ", " + std::string($1) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);
}
| IDENT {
    $$.code = cStr("");
    $$.name = cStr(std::string($1));
    if (!isSymbol(std::string($1))) {
        kError("BoolExpression", "Identifier '" + std::string($1) + "' is not declared.");
    }
}
| ArrayAccess {
    $$ = $1;
}
 | L_PAREN BoolExpression R_PAREN {
    $$ = $2;
 }
 | NOT BoolExpression {
    std::string temp = makeTempVar();
    std::string code = "";
    
    code += std::string($2.code);
    code += ". " + temp + "\n";
    code += "! " + temp + ", " + std::string($2.name) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);
 }
 | BoolExpression Compare BoolExpression {
    std::string temp = makeTempVar();
    std::string code = "";
    
    code += std::string($1.code) + std::string($3.code);
    code += ". " + temp + "\n";
    code += std::string($2.code) + " " + temp + ", " + std::string($1.name) + ", " + std::string($3.name) + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);
 }
 ;

If-Block: IF L_PAREN BoolExpression R_PAREN L_SQUIG Statements R_SQUIG {
    std::string L1 = newLabel();
    std::string L2 = newLabel();
    std::string code = "";

    code += std::string($3.code);
    code += "?:= " + L1 + ", " + std::string($3.name) + "\n";
    code += ":= " + L2 + "\n";
    code += ": " + L1 + "\n";
    code += std::string($6.code);
    code += ": " + L2 + "\n";

    $$.name = cStr("");
    $$.code = cStr(code);
}
 | IF L_PAREN BoolExpression R_PAREN L_SQUIG Statements R_SQUIG OTHERWISE L_SQUIG Statements R_SQUIG {
    std::string L1 = newLabel();
    std::string L2 = newLabel();
    std::string L3 = newLabel();
    std::string code = "";

    code += std::string($3.code);
    code += "?:= " + L1 + ", " + std::string($3.name) + "\n";
    code += ":= " + L2 + "\n";
    code += ": " + L1 + "\n";
    code += std::string($6.code);
    code += ":= " + L3 + "\n";
    code += ": " + L2 + "\n";
    code += std::string($10.code);
    code += ": " + L3 + "\n";

    $$.name = cStr("");
    $$.code = cStr(code);
 }
;

Until: UNTIL L_PAREN BoolExpression R_PAREN L_SQUIG Statements R_SQUIG {
    std::string L1 = newLabel();
    std::string L2 = newLabel();
    std::string temp = makeTempVar();
    std::string code = "";

    code += ": " + L1 + "\n";
    code += std::string($3.code);
    code += ". " + temp + "\n";
    code += "! " + temp + ", " + std::string($3.name) + "\n";
    code += "?:= " + L2 + ", " + temp + "\n";
    code += std::string($6.code);
    code += ":= " + L1 + "\n";
    code += ": " + L2 + "\n";

    $$.code = cStr(code);
    $$.name = cStr("");
}
;

CreateFunctionArgs: {
    $$.code = cStr("");
    $$.name = cStr("");
}
| Type IDENT {
    $$.Count = 0;
    std::string code = "";
    code += ". " + std::string($2) + "\n";
    code += "= " + std::string($2) + ", $" + "0\n";
    $$.name = cStr("");
    $$.code = cStr(code);

    addSymbol(std::string($2), "Integer");
}
| CreateFunctionArgs COMMA Type IDENT {
    $$.Count = $1.Count + 1;
    std::string code = "";
    code += ". " + std::string($4) + "\n";
    code += $1.code;
    code += "= " + std::string($4) + ", $" + to_string($$.Count) + "\n";
    $$.name = cStr("");
    $$.code = cStr(code);

    addSymbol(std::string($4), "Integer");
}
;

Function: Type FUNCTION IDENT L_PAREN CreateFunctionArgs R_PAREN L_SQUIG Statements R_SQUIG {
    std::string code = "";
    code += "func " + std::string($3) + "\n";
    code += std::string($5.code);
    code += std::string($8.code);
    code += "endfunc\n";
    
    addSymbol(std::string($3), "Function");
    addFunction(std::string($3), code);
}
;

CreateFunctionCall: Term {
    std::string code = "";
    code +=  std::string($1.code);
    code += "param " + std::string($1.name) + "\n";
    $$.name = cStr("");
    $$.code = cStr(code);
}
| Term COMMA CreateFunctionCall  {
    std::string code = "";
    code += std::string($1.code);
    code += "param " + std::string($1.name) + "\n";
    code +=  std::string($3.code);
    $$.name = cStr("");
    $$.code = cStr(code);
 }
;

FunctionCall: IDENT L_PAREN CreateFunctionCall R_PAREN {
    std::string temp = makeTempVar();
    std::string code = "";
    
    code = std::string($3.code);
    code += ". " + temp + "\n";
    code += "call " + std::string($1) + ", " + temp + "\n";
    $$.name = cStr(temp);
    $$.code = cStr(code);

    if (!isFunction(std::string($1))) {
        kError("FunctionCall", "Function '" + std::string($1) + "' is not declared.");
    }
}
;

Statement: Assign {
    $$ = $1;
}
| If-Block {
    $$ = $1;
}
| ArrayCreate {
    $$ = $1;
}
| Function {
    $$ = $1;
}
| FunctionCall {
    $$ = $1;
}
| KILL {
    $$.name = cStr("");
    $$.code = cStr("");
}
| Until {
    $$ = $1;
}
| SEND Term {
    std::string code = "";
    code += std::string($2.code);
    code += "ret ";
    code += std::string($2.name);
    code += "\n";

    $$.name = cStr("");
    $$.code = cStr(code);
}
| In {
    $$ = $1;
}
| Out {
    $$ = $1;
}
| Var {
    $$ = $1;
}
| {
    $$.name = cStr("");
    $$.code = cStr("");
}
;

Statements: {
    $$.name = cStr("");
    $$.code = cStr("");
}
 | Statement SEMICOLON Statements {    
    std::string code = "";
    code += $1.code;
    code += $3.code;
    $$.name = cStr("");
    $$.code = cStr(code);
}
;

%%

int main(int argc, char **argv)
{
    yyparse();
    return 0;
}

void kError(std::string src, std::string msg) {
    yyerror(src + " [Line " + to_string(LINES) + "]: " + msg);
}

int yyerror(std::string s)
{
  fprintf(stderr, "error: %s\n", cStr(s));
  std::exit(1);
  return 1;
}

template <typename T>
std::string to_string(T input) {
    return std::__cxx11::to_string(input);
}

void isValidArray(std::string ident, int index) {
    if(!isSymbol(ident)) {
        kError("isValidArray()", "Identifier '" + ident + "' is used before it was initialized.");
    }
    else if(symTable[ident] != "Array") {
        kError("isValidArray()", "Identifier '" + ident + "' is not of type 'Array'.");
    }
    else if(!(index >= 0 && index < arraySizes[ident])) {
        kError("isValidArray()", "Array out of bounds. Size was " + to_string(arraySizes[ident]) + ". Index was " + to_string(index) + ".");
    }
}

void addArray(std::string ident, int size) {
    if(size < 1) {
        kError("addArray()", "Array size must be greater than 0.");
    }
    addSymbol(ident, "Array");
    arraySizes[ident] = size;
}

bool isReserved(std::string input) {
    return reserved.find(input) != reserved.end();
}

bool isFunction(std::string input) {
    return functions.find(input) != functions.end();
}

void addFunction(std::string ident, std::string defition) {
    if (isFunction(ident)) {
        kError("addFunction()", "Identifier '" + ident + "' has already been declared.");
    }
    functions[ident] = defition;
}


bool isSymbol(std::string input) {
    return symTable.find(input) != symTable.end();
}

void addSymbol(std::string ident, std::string type) {
    if (isSymbol(ident)) {
        kError("addSymbol()", "Identifier '" + ident + "' has already been declared.");
    }
    if (isReserved(ident) && type != "Function") {
        kError("addSymbol()", "Identifier '" + ident + "' is a reserved keyword.");
    }
    symTable[ident] = type;
}

std::string makeTempVar() {
    std::string respondWith = "__temp_" + std::__cxx11::to_string(tempVarCount);
    if (isSymbol(respondWith)) {
        kError("makeTempVar()", "Identifier '" + respondWith + "' has already been declared.");
    }
    tempVarCount++;
    addSymbol(respondWith, "TempVar");
    return respondWith;
}

std::string newLabel() {
    std::string respondWith = "L" + std::__cxx11::to_string(labelCount);    
    if (isSymbol(respondWith)) {
        kError("newLabel()", "Identifier '" + respondWith + "' has already been declared.");
    }
    labelCount++;
    addSymbol(respondWith, "Label");
    return respondWith;
}

char* cStr(std::string input) {
    return strdup(input.c_str());
}