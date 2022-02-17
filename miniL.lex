   /* cs152-miniL phase1 */
   
%{   
   /* write your C code here for definitions of variables and including headers */
   #include "miniL-parser.hpp"
   int col = 1, row = 1;
%}

%%

"function"     {col += yyleng; return FUNCTION;}
"beginparams"  {col += yyleng; return BEGIN_PARAMS;}
"endparams"    {col += yyleng; return END_PARAMS;}
"beginlocals"  {col += yyleng; return BEGIN_LOCALS;}
"endlocals"    {col += yyleng; return END_LOCALS;}
"beginbody"    {col += yyleng; return BEGIN_BODY;}
"endbody"      {col += yyleng; return END_BODY;}
"integer"      {col += yyleng; return INTEGER;}
"array"        {col += yyleng; return ARRAY;}
"of"           {col += yyleng; return OF;}
"if"           {col += yyleng; return IF;}
"then"         {col += yyleng; return THEN;}
"endif"        {col += yyleng; return ENDIF;}
"else"         {col += yyleng; return ELSE;}
"while"        {col += yyleng; return WHILE;}
"do"           {col += yyleng; return DO;}
"beginloop"    {col += yyleng; return BEGINLOOP;}
"endloop"      {col += yyleng; return ENDLOOP;}
"continue"     {col += yyleng; return CONTINUE;}
"break"        {col += yyleng; return BREAK;}
"read"         {col += yyleng; return READ;}
"write"        {col += yyleng; return WRITE;}
"not"          {col += yyleng; return NOT;}
"true"         {col += yyleng; return TRUE;}
"false"        {col += yyleng; return FALSE;}
"return"       {col += yyleng; return RETURN;}

"-"            {col += yyleng; return SUB;}
"+"            {col += yyleng; return ADD;}
"*"            {col += yyleng; return MULT;}
"/"            {col += yyleng; return DIV;}
"%"            {col += yyleng; return MOD;}

"=="           {col += yyleng; return EQ;}
"<>"           {col += yyleng; return NEQ;}
"<"            {col += yyleng; return LT;}
">"            {col += yyleng; return GT;}
"<="           {col += yyleng; return LTE;}
">="           {col += yyleng; return GTE;}

\#\#.*                          {row++; col = 1;}
[0-9]+                        {yylval.int_val = atoi(yytext); col += yyleng; return NUMBER;}
[0-9]+[A-Za-z0-9_]*           {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", row, col, yytext);}
[A-Za-z0-9_]*\_               {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", row, col, yytext);}
\_[A-Za-z0-9_]*               {printf("Error at line %d, column %d: identifier \"%s\" cannot start with an underscore\n", row, col, yytext);}
[A-Za-z]+[A-Za-z0-9_]*        {yylval.str_val = strdup(yytext); col += yyleng; return IDENTIFIER;}

";"            {col += yyleng; return SEMICOLON;}
":"            {col += yyleng; return COLON;}
","            {col += yyleng; return COMMA;}
"("            {col += yyleng; return L_PAREN;}
")"            {col += yyleng; return R_PAREN;}
"["            {col += yyleng; return L_SQUARE_BRACKET;}
"]"            {col += yyleng; return R_SQUARE_BRACKET;}
":="           {col += yyleng; return ASSIGN;}
"\n"           {row++; col = 1;}
" "            {col++;}
"\t"           {col++;}
.              {printf("ERROR: Unrecognized Character\n"); exit(1);}


%%
	/* C functions used in lexer */

int main(int argc, char **argv) {
  if(argc > 1)
   {
      yyin = fopen(argv[1], "r");
   }
   else 
      yyin = stdin;
  yyparse();
  fclose(yyin);
  return 0;
}