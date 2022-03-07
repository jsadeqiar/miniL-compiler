    /* cs152-miniL phase3-part1 */
%{
#include <stdio.h>
#include <iostream>
#include <string>
#include <string.h>

int yylex(void);
void yyerror(const char* msg);
std::string makeTemp();
std::string makeLabel();
//bool find(std::string &value);
#define YY_NO_UNPUT

enum Type { Integer, Array };
struct CodeNode
{
  std::string code;
  std::string name;

  bool array = false;
  bool breakCheck = false;
};

extern int row;
extern int col;

bool subFlag = false;
bool addFlag = false;
bool mulFlag = false;
bool divFlag = false;
bool modFlag = false;
bool isArray = false;
bool mainCheck = false;
bool bC = false;

static int i = 1;
std::string dec_string = "";
std::string stmt_string = "";
std::string func_string = "";
std::string endLoop;



%}

%union{
  /* put your types here */
  int       int_val;
  char*     str_val;
  struct CodeNode* codeNode;
}

%error-verbose
%locations

/* start program */
%start PROGRAM
%token <int_val> NUMBER
%token <str_val> IDENTIFIER
%token FUNCTION
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token BEGINLOOP
%token ENDLOOP
%token CONTINUE
%token BREAK
%token READ
%token WRITE
%token NOT
%token TRUE
%token FALSE
%token RETURN
%token SUB
%token ADD
%token MULT
%token DIV
%token MOD
%token EQ
%token NEQ
%token LT
%token GT
%token LTE
%token GTE
%token SEMICOLON
%token COLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token ASSIGN

%type<codeNode> PROGRAM FUNCTIONS_L FUNCTIONS DECLARATION_L DECLARATION
%type<codeNode> STATEMENT_L STATEMENT BOOL_EXP NOT_L COMP EXPRESSION ADDSUBEXP
%type<codeNode> MULT_EXPR MULTDIVEXP TERM EXPRESSION_L VAR



%% 
/* write your rules here */
PROGRAM:        FUNCTIONS_L
                {
                  if(!mainCheck)
                  {
                    std::string error;
                    error += std::string("Function 'main' not defined!");
                    yyerror(error.c_str());
                  }
                  else
                    std::cout << $1->code;
                }
                ;

FUNCTIONS_L:    FUNCTIONS FUNCTIONS_L
                {
                  func_string.insert(0, $1->code);
                  CodeNode *node = new CodeNode;
                  node->name = "";
                  node->code = func_string;

                  
                  $$ = node;
                }
                |  /* epsilon */
                  {
                    $$ = new CodeNode;
                  }
                ;

FUNCTIONS:      FUNCTION IDENTIFIER SEMICOLON BEGIN_PARAMS DECLARATION_L END_PARAMS BEGIN_LOCALS DECLARATION_L END_LOCALS BEGIN_BODY STATEMENT_L END_BODY
                {
                  CodeNode *node = new CodeNode;
                  node->name = $2;
                  if($2 == std::string("main"))
                    mainCheck = true;
                  node->code = std::string("func ") + $2 + std::string("\n");
                  node->code += $5->code + $8->code + $11->code + std::string("endfunc");
                  $$ = node;
                }
                ;

DECLARATION_L:  DECLARATION SEMICOLON DECLARATION_L
                {
                  dec_string.insert(0, $1->code + std::string("\n"));
                  CodeNode *node = new CodeNode;
                  node->name = "";
                  node->code = dec_string;
                  $$ = node;
                }
                | /* epsilon */
                  {
                    dec_string = "";
                    $$ = new CodeNode;
                  }
                ;

DECLARATION:    IDENTIFIER COLON INTEGER
                {
                  CodeNode *node = new CodeNode;
                  node->name = "";
                  node->code = std::string(". ") + $1;
                  $$ = node;
                }
                | IDENTIFIER COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
                  {
                    CodeNode *node = new CodeNode;
                    node->name = "";
                    node->code = std::string(".[] ") + $1 + std::string(", ") + std::to_string($5);
                    $$ = node;
                  }
                ;

STATEMENT_L:    STATEMENT SEMICOLON STATEMENT_L
                {
                  stmt_string.insert(0, $1->code +  std::string("\n"));
                  CodeNode *node = new CodeNode;
                  node->name = "";
                  node->code = stmt_string;
                  if($1->breakCheck == true || $3->breakCheck == true)
                    {
                      node->breakCheck = true;
                      //std::cout << $1->code << std::string(" ") + std::to_string(node->breakCheck) << std::endl;
                    }                    
                  $$ = node;
                  
                }
                | STATEMENT SEMICOLON
                  {
                    stmt_string.insert(0, $1->code + std::string("\n"));
                    CodeNode *node = new CodeNode;
                    node->name = "";
                    node->code += std::string($1->code) + std::string("\n");

                    if($1->breakCheck == true)
                    {
                      node->breakCheck = true;
                      //std::cout << $1->code << std::string(" ") + std::to_string(node->breakCheck) << std::endl;
                    }                    
                    $$ = node;
                    
                    //stmt_string.clear(); IDK
                    
                  }
                ;

STATEMENT:      VAR ASSIGN EXPRESSION
                {
                  if($1->array)
                  {
                    CodeNode *node = new CodeNode;
                    std::string var_name = $1->name;
                    node->code = $3->code;

                    node->code += std::string("[]= ") + var_name + std::string(", ") + $3->name;
                    $$ = node;
                  }
                  else{
                  CodeNode *node = new CodeNode;
                  std::string var_name = $1->name;
                  node->code = $3->code;
                  node->code += std::string("= ") + var_name + std::string(", ") + $3->name;
                  $$ = node;
                  }
                }
                | IF BOOL_EXP THEN STATEMENT_L ENDIF
                  {
                    CodeNode *node = new CodeNode;
                    std::string trueL = makeLabel();
                    std::string endif = makeLabel();

                    node->code += $2->code + std::string("\n");
                    node->code += std::string("?:= ") + trueL + std::string(", ") + $2->name + std::string("\n");
                    node->code += std::string(":= ") + endif + std::string("\n");
                    node->code += std::string(": ") + trueL + std::string("\n");
                    node->code += $4->code;
                    stmt_string = ""; // erase stmt_string buffer once appended to this node to avoid duplicate.
                    node->code += std::string(": ") + endif ;
                    $$ = node;
                  }
                | IF BOOL_EXP THEN STATEMENT_L ELSE STATEMENT_L ENDIF
                  {
                    CodeNode *node = new CodeNode;
                    //std::string temp = makeTemp();
                    std::string trueL = makeLabel();
                    std::string falseL = makeLabel();
                    std::string endif = makeLabel();

                    node->code += $2->code + std::string("\n");
                    node->code += std::string("?:= ") + trueL + std::string(", ") + $2->name + std::string("\n");
                    node->code += std::string(":= ") + falseL + std::string("\n");
                    node->code += std::string(": ") + trueL + std::string("\n");
                    node->code += $4->code;
                    node->code += std::string(":= ") + endif + std::string("\n");
                    node->code += std::string(": ") + falseL + std::string("\n");
                    node->code += $6->code;
                    node->code += std::string(": ") + endif;
                    $$ = node;
                  }
                | WHILE BOOL_EXP BEGINLOOP STATEMENT_L ENDLOOP
                  {
                    CodeNode *node = new CodeNode;
                    std::string startL = makeLabel();
                    std::string endL;
                    
                    if(bC == false)
                    {
                      endL = makeLabel();
                    }
                    else{
                      endL = endLoop;
                      bC = false;
                    }
                    std::string innerL = makeLabel();

                    node->code += std::string(": ") + startL + std::string("\n");
                    node->code += $2->code + std::string("\n");
                    node->code += std::string("?:= ") + innerL + std::string(", ") + $2->name + std::string("\n");
                    node->code += std::string(":= ") + endL + std::string("\n"); //if bool_exp name is false, go down to this label and exit loop.
                    node->code += std::string(": ") + innerL + std::string("\n");
                    node->code += $4->code;
                    stmt_string = ""; // erase stmt_string buffer once appended to this node to avoid duplicate.
                    node->code += std::string(":= ") + startL + std::string("\n");
                    node->code += std::string(": ") + endL;
                    $$ = node;
                  }
                | DO BEGINLOOP STATEMENT_L ENDLOOP WHILE BOOL_EXP
                  {
                    CodeNode *node = new CodeNode;
                    std::string startL = makeLabel();
                    std::string endL;
                    
                    if(bC == false)
                    {
                      endL = makeLabel();
                    }
                    else{
                      endL = endLoop;
                      bC = false;
                    }
                    std::string innerL = makeLabel();

                    node->code += std::string(": ") + startL + std::string("\n");
                    node->code += $6->code + std::string("\n");
                    node->code += std::string("?:= ") + innerL + std::string(", ") + $6->name + std::string("\n");
                    node->code += std::string(":= ") + endL + std::string("\n"); //if bool_exp name is false, go down to this label and exit loop.
                    node->code += std::string(": ") + innerL + std::string("\n");
                    node->code += $3->code;
                    stmt_string = ""; // erase stmt_string buffer once appended to this node to avoid duplicate.
                    node->code += std::string(":= ") + startL + std::string("\n");
                    node->code += std::string(": ") + endL;
                    $$ = node;
                  }
                | READ VAR
                  {

                  }
                | WRITE VAR
                  {
                   if($2->array == true)
                    {
                    std::string temp = makeTemp();
                    CodeNode *node = new CodeNode;
                    std::string var_name = $2->name;
                    node->code = $2->code;
                    node->code += std::string(". ") + temp + std::string("\n");
                    node->code += std::string("=[] ") + temp + std::string(", ") + var_name + std::string("\n");
                    node->code += std::string(".> ") + temp;
                    $$ = node;
                    } 
                    else{
                    CodeNode *node = new CodeNode;
                    node->code = $2->code;
                    node->code += std::string(".> ") + $2->name;
                    $$ = node;
                    }
                  }
                | CONTINUE
                  {
                    CodeNode *node = new CodeNode;
                    std::string tempL = makeLabel();
                    endLoop = tempL;
                    node->code += std::string(":= ") + tempL;
                    node->breakCheck = true;
                    bC = true;
                    $$ = node;
                  }
                | BREAK
                  {
                    CodeNode *node = new CodeNode;
                    std::string tempL = makeLabel();
                    endLoop = tempL;
                    node->code += std::string(":= ") + tempL;
                    node->breakCheck = true;
                    bC = true;
                    $$ = node;
                  }
                | RETURN EXPRESSION
                  {
                    CodeNode *node = new CodeNode;
                    node->name = $2->name;
                    node->code = $2->code;
                    node->code += std::string("ret ") + $2->name;
                    $$ = node;
                  }
                ; 


BOOL_EXP:       NOT_L EXPRESSION COMP EXPRESSION
                {
                  std::string temp = makeTemp();
                  CodeNode *node = new CodeNode;
                  node->code += std::string(". ") + temp + std::string("\n");
                  node->code += $3->name + std::string(" ") + temp + std::string(", ") + $2->name + std::string(", ") + $4->name;
                  node->name = temp;
                  $$ = node;
                }
                ;

NOT_L:          NOT NOT_L
                {

                }
                | /* epsilon */
                  {

                  }
                ;

COMP:           EQ
                {
                  CodeNode *node = new CodeNode;
                  node->code = "";
                  node->name = "==";
                  $$ = node;
                }
                | NEQ
                  {
                    CodeNode *node = new CodeNode;
                    node->code = "";
                    node->name = "!=";
                    $$ = node;
                  }
                | LT
                  {
                    CodeNode *node = new CodeNode;
                    node->code = "";
                    node->name = "<";
                    $$ = node;
                  }
                | GT
                  {
                    CodeNode *node = new CodeNode;
                    node->code = "";
                    node->name = ">";
                    $$ = node;
                  }
                | LTE
                  {
                    CodeNode *node = new CodeNode;
                    node->code = "";
                    node->name = "<=";
                    $$ = node;
                  }
                | GTE
                  {
                    CodeNode *node = new CodeNode;
                    node->code = "";
                    node->name = ">=";
                    $$ = node;
                  }
                ;

EXPRESSION:     MULT_EXPR ADDSUBEXP
                {
                  CodeNode *node = new CodeNode;
                  std::string temp = makeTemp();
                  node->name = temp;
                  node->code = $1->code + $2->code;
                  if(addFlag)
                  {
                    if($1->array == true || $2->array == true)
                    {
                      std::string temp2 = makeTemp();
                      node->code += std::string(". ") + temp2 + std::string("\n");
                      node->code += std::string("=[] ") + temp2 + std::string(", ") + $1->name + std::string("\n");
                      
                      node->name = temp;
                      node->code += std::string(". ") + temp + std::string("\n");
                      node->code += std::string("+ ") + temp + std::string(", ") + temp2 + std::string(", ") + $2->name + std::string("\n");
                      addFlag = false;
                      node->array = true;
                      
                    }
                    else
                    {
                      addFlag = false;
                      node->code += std::string(". ") + temp + std::string("\n");
                      node->code += std::string("+ ") + temp + std::string(", ") + $1->name + std::string(", ") + $2->name + std::string("\n");
                    }
                  }
                  else if(subFlag)
                  {
                    if($1->array == true || $2->array == true)
                    {
                      std::string temp2 = makeTemp();
                      node->code += std::string(". ") + temp2 + std::string("\n");
                      node->code += std::string("=[] ") + temp2 + std::string(", ") + $1->name + std::string("\n");
                      
                      node->name = temp;
                      node->code += std::string(". ") + temp + std::string("\n");
                      node->code += std::string("+ ") + temp + std::string(", ") + temp2 + std::string(", ") + $2->name + std::string("\n");
                      subFlag = false;
                      node->array = true;
                    }
                    else
                    {
                    subFlag = false;
                    node->code += std::string(". ") + temp + std::string("\n");
                    node->code += std::string("- ") + temp + std::string(", ") + $1->name + std::string(", ") + $2->name + std::string("\n");
                    }
                  }
                  else
                  {
                    node->name = $1->name;
                  }
                  $$ = node;
                }
                ;

ADDSUBEXP:       ADD MULT_EXPR ADDSUBEXP
                 {
                   CodeNode *node = new CodeNode;
                   std::string temp = makeTemp();
                   node->name = temp;
                   node->code = $2->code + $3->code;
                   node->code += std::string(". ") +  temp + std::string("\n");
                   node->code += std::string("= ") + temp + std::string(", ") + $2->name + std::string("\n");
                   addFlag = true;
                   $$ = node;

                 }
                 | SUB MULT_EXPR ADDSUBEXP
                   {
                     CodeNode *node = new CodeNode;
                      std::string temp = makeTemp();
                      node->name = temp;
                      node->code = $2->code + $3->code;
                      node->code += std::string(". ") +  temp + std::string("\n");
                      node->code += std::string("= ") + temp + std::string(", ") + $2->name + std::string("\n");
                      subFlag = true;
                      $$ = node;
                   }
                 | /* epsilon */
                  {
                    $$ = new CodeNode;
                  }
                 ;

MULT_EXPR:      TERM MULTDIVEXP
                {
                  CodeNode *node = new CodeNode;
                  std::string temp = makeTemp();
                  node->name = temp;
                  node->code = $1->code + $2->code;
                  if(mulFlag)
                  {
                    if($1->array == true || $2->array == true)
                    {
                      std::string temp2 = makeTemp();
                      node->code += std::string(". ") + temp2 + std::string("\n");
                      node->code += std::string("=[] ") + temp2 + std::string(", ") + $1->name + std::string("\n");
                      
                      node->code += std::string(". ") + temp + std::string("\n");
                      node->code += std::string("* ") + temp + std::string(", ") + temp2 + std::string(", ") + $2->name + std::string("\n");
                      mulFlag = false;
                      node->array = true;
                    }
                    else
                    {
                      mulFlag = false;
                      node->code += std::string(". ") + temp + std::string("\n");
                      node->code += std::string("* ") + temp + std::string(", ") + $1->name + std::string(", ") + $2->name + std::string("\n");
                    }
                  }
                  else if(divFlag)
                  {
                    if($1->array == true || $2->array == true)
                    {
                      std::string temp2 = makeTemp();
                      node->code += std::string(". ") + temp2 + std::string("\n");
                      node->code += std::string("=[] ") + temp2 + std::string(", ") + $1->name + std::string("\n");
                      
                      node->code += std::string(". ") + temp + std::string("\n");
                      node->code += std::string("/ ") + temp + std::string(", ") + temp2 + std::string(", ") + $2->name + std::string("\n");
                      divFlag = false;
                      node->array = true;
                    }
                    else
                    {
                    divFlag = false;
                    node->code += std::string(". ") + temp + std::string("\n");
                    node->code += std::string("/ ") + temp + std::string(", ") + $1->name + std::string(", ") + $2->name + std::string("\n");
                    }
                  }
                  else if(modFlag)
                  {
                    if($1->array == true || $2->array == true)
                    {
                      std::string temp2 = makeTemp();
                      node->code += std::string(". ") + temp2 + std::string("\n");
                      node->code += std::string("=[] ") + temp2 + std::string(", ") + $1->name + std::string("\n");
                      
                      node->code += std::string(". ") + temp + std::string("\n");
                      node->code += std::string("/ ") + temp + std::string(", ") + temp2 + std::string(", ") + $2->name + std::string("\n");
                      modFlag = false;
                      node->array = true;
                    }
                    else
                    {
                    modFlag = false;
                    node->code += std::string(". ") + temp + std::string("\n");
                    node->code += std::string("% ") + temp + std::string(", ") + $1->name + std::string(", ") + $2->name + std::string("\n");
                    }
                  }
                  else
                  {
                    node->name = $1->name;
                    if($1->array)
                      node->array = true;
                    $$ = node;
                  }
                  if($1->array)
                      node->array = true;
                  $$ = node;
                }
                ;

MULTDIVEXP:      MULT TERM MULTDIVEXP
                 {
                   CodeNode *node = new CodeNode;
                   std::string temp = makeTemp();
                   node->name = temp;
                   node->code = $2->code + $3->code;
                   node->code += std::string(". ") +  temp + std::string("\n");
                   node->code += std::string("= ") + temp + std::string(", ") + $2->name + std::string("\n");
                   mulFlag = true;
                   $$ = node;
                 }
                 | DIV TERM MULTDIVEXP
                   {
                    CodeNode *node = new CodeNode;
                    std::string temp = makeTemp();
                    node->name = temp;
                    node->code = $2->code + $3->code;
                    node->code += std::string(". ") +  temp + std::string("\n");
                    node->code += std::string("= ") + temp + std::string(", ") + $2->name + std::string("\n");
                    divFlag = true;
                    $$ = node; 
                   }
                 | MOD TERM MULTDIVEXP
                   {
                     CodeNode *node = new CodeNode;
                     std::string temp = makeTemp();
                     node->name = temp;
                     node->code = $2->code + $3->code;
                     node->code += std::string(". ") +  temp + std::string("\n");
                     node->code += std::string("= ") + temp + std::string(", ") + $2->name + std::string("\n");
                     modFlag = true;
                     $$ = node; 
                   }
                 | /* epsilon */
                   {
                     $$ = new CodeNode;
                   }
                 ;

TERM:           VAR
                {
                  CodeNode *node = new CodeNode;
                  node->code = $1->code;
                  node->name = $1->name;
                  if($1->array)
                    node->array = true;
                  //std::string error;
                  //if(!find(node->name, Integer, error))
                    //yyerror(error.c_str());
                  $$ = node;
                }
                | NUMBER
                  {
                    CodeNode *node = new CodeNode;
                    node->code = "";
                    node->name = std::to_string($1);
                    
                    $$ = node;
                  }
                | L_PAREN EXPRESSION R_PAREN
                  {
                    CodeNode *node = new CodeNode;
                    std::string temp = makeTemp();
                    node->name = $2->name;
                    node->code = $2->code;
                    $$ = node;
                    //maybe
                  }
                | IDENTIFIER L_PAREN EXPRESSION_L R_PAREN
                  {
                    CodeNode *node = new CodeNode;
                    std::string temp = makeTemp();
                    node->name = temp;
                    node->code = $3->code;
                    node->code += std::string("call ") +  $1 + std::string(", ") + temp + std::string("\n");
                    $$ = node;
                  }
                ;

EXPRESSION_L:   EXPRESSION COMMA EXPRESSION_L 
                {
                  CodeNode *node = new CodeNode;
                  node->name = $1->name;
                  node->code = $1->code;
                  node->code += std::string("param ") + $1->name + std::string("\n");
                  $$ = node;
                }
                | EXPRESSION
                  {
                    CodeNode *node = new CodeNode;
                    node->name = $1->name;
                    node->code = $1->code;
                    node->code += std::string("param ") + $1->name + std::string("\n");
                    $$ = node;
                  }
                | /* epsilon */
                  {
                    $$ = new CodeNode;
                  }
                ;

VAR:            IDENTIFIER
                {
                  CodeNode *node = new CodeNode;
                  node->code = "";
                  node->name = std::string($1);
                  //std::string error;
                  //if(!find(node->name, Integer, error))
                    //yyerror(error.c_str());
                  $$ = node;
                }
                | IDENTIFIER L_SQUARE_BRACKET EXPRESSION R_SQUARE_BRACKET
                  {
                    CodeNode *node = new CodeNode;
                    node->code = $3->code;
                    node->name = std::string($1) + std::string(", ") + $3->name;
                    node->array = true;
                    $$ = node;
                  }
                ;


%% 

std::string makeTemp()
{
  static int count = 0;
  return "_temp" + std::to_string(count++);
}

std::string makeLabel()
{
  static int count = 0;
  return "label_" + std::to_string(count++);
}



/*
enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;


Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}
*/

void yyerror(const char *msg) {
    /* implement your error handling */
    printf("Error at line %d, column %d: %s\n", row, col, msg);
}