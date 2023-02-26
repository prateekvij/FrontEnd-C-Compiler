%{
	#include <bits/stdc++.h>

	using namespace std;
	#include "symtable.h"


	extern char* yytext;
	extern int yyleng;
	void yyerror(const char* s);
	int yylex(void);
	#define YYDEBUG 1
	// #define YYSTYPE container
	// extern YYSTYPE yylval;

	int next_quad = 0, temp_num = 0;
	vector<string> i_code;
	vector<string> tempList(10000); // stores type of each temp variable used for corresponing temp_num

	string newTemp(string); // feed type to this
	void genCode(string);
	void printThreeAddressCode();
	int increment(string s);
	vector<int> *makelist();
	void backpatch(vector<int> *list, int quad);
	void substitute(int quad_number, string replacent);

	map<string, int> sizes;

%}

%glr-parser
%define parse.error verbose

%start Start
%token IF ELSE WHILE DO FOR MAIN STRUCT RETURN DEFAULT CONST BREAK CONTINUE GOTO
%token VOID INT FLOAT CHAR
%token SEMICOLON COMMA LEFT_SQ_BRACKET RIGHT_SQ_BRACKET LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET LP RP
%token PLUS MINUS ASTERISK DIVIDE DOT DEREFERENCE AMP MODULO ASSIGN_OP AND_EXP OR_EXP NOT_EXP RIGHT_SHIFT LEFT_SHIFT AND_BIT OR_BIT
%token LT GT EQ LTE GTE
%token INTEGER CHARACTER STRING REAL ID
%token _THEN_ _ELSE_

%left OR_EXP
%left AND_EXP
%left EQ
%left LT GT LTE GTE
%left PLUS MINUS  
%left ASTERISK DIVIDE 
 
%right ASSIGN_OP

%nonassoc _THEN_
%nonassoc ELSE

%right "declaration" 
%right LP


%union {
  char* lex_val;
  struct Node *node;
}

%type <node> id_array L var_type res_id const expr asg func_call elist explist DIMLIST 
%type <node> stmt_list cond_stmt ifexp n m stmt scoped_stmt Decl funccall_stmt
%type <node> while_exp while_stmt array_elem dims lhs
%type <lex_val> INTEGER CHARACTER STRING REAL ID operator comparator
%type <lex_val> VOID INT FLOAT CHAR
%type <lex_val> PLUS MINUS DIVIDE ASTERISK LEFT_SHIFT  RIGHT_SHIFT AMP OR_BIT AND_BIT AND_EXP OR_EXP
%type <lex_val> LTE GTE EQ GT LT




%%

Start 		:	Decl Start{ }
			|	function Start{ }
			|
			;


Decl 		:	var_type L SEMICOLON {}
				{
					
					symtab->patch($1->attr["type"], $2->namelist, current_level );
				}
			;


L			:	id_array
				{
					$$ = new Node;
					$$->namelist = $1->namelist;
					// cout << "here2" <<endl;
				}

			|	L COMMA id_array
				{
					$$ = new Node;
					$$->namelist = new list<int>;
					*($$->namelist) = *($1->namelist);
					if (($3->namelist)->size())
					{
						int id_array_val = ($3->namelist)->front();
						($$->namelist)->push_back(id_array_val);
					}

				}
			;

id_array	:	ID DIMLIST
				{
					// cout << "here3" <<endl;
					$$ = new Node;
				 	$$->attr["name"] = $1;
				 	string name = $1;
				 	// int a;
				 	bool found;
				 	int var_ptr = symtab->search_var(name, active_func_ptr, current_level, &found);
				 	int var_level = -1;
				 	if (found)
				 	{
				 		var_level = symtab->func_name_table[active_func_ptr].loc_varlist_ptr[var_ptr].level;
				 		// cout << "level: "<<var_level << " " << current_level << endl;
				 	}
				 	$$->namelist = new list<int>;
				 	if (found && var_level == current_level)
				 	{
				 		cout << "Error: Redeclaration of variable within the same scope " << name <<endl;
				 	}
				 	else if (current_level == 2)
				 	{
				 		int  param_ptr = symtab->search_param(name, &found, active_func_ptr);
				 		if (found)
				 		{
				 			cout << "Error: Variable "<< name << " already declared as a parameter" << endl;
				 		}
				 		else{
				 			string var_tag = "simple";
				 			if($2->attr_list["dimlist"]->size()){
				 				var_tag = "array";
				 			}
					 		int sym_ptr = symtab->add_var(active_func_ptr,name,"",current_level, var_tag, $2->attr_list["dimlist"]);
					 		($$->namelist)->push_back(sym_ptr);
				 		}
				 	}
				 	else{
				 		string var_tag = "simple";
			 			if($2->attr_list["dimlist"]->size()){
			 				var_tag = "array";
			 			}
				 		int sym_ptr = symtab->add_var(active_func_ptr,name,"",current_level, var_tag, $2->attr_list["dimlist"]);
				 		($$->namelist)->push_back(sym_ptr);
				 	}

				}
			;


DIMLIST		:	DIMLIST LEFT_SQ_BRACKET INTEGER RIGHT_SQ_BRACKET
				{
					$1->attr_list["dimlist"]->push_back(stoi($3));
					$$->attr_list["dimlist"] = $1->attr_list["dimlist"];

				}
			|
				{
					$$ = new Node;
					$$->attr_list["dimlist"] = makelist();
				}
			;


function	:	func_head LEFT_CURLY_BRACKET body RIGHT_CURLY_BRACKET
				{
					active_func_ptr = curr_func_stack.top(); // suggest global, gadbad
					current_level = 0;
					curr_func_stack.pop();					
					genCode("func end");
				}
			;

func_head	:	res_id LP paramlist RP { current_level = 2;}
			;

res_id		:	var_type ID 
				{
					string type = $1->attr["type"];
					string name = $2;
					bool found;
					int a;
					symtab->search_func(name,&found);
					if (found)
						cout << "Error: Function " << name << " already declared" << endl;
					else{
						active_func_ptr = symtab->add_function(name,type);
						current_level = 1;
						curr_func_stack.push(active_func_ptr);	
					}
					genCode("func begin " + name);
		
				}
			|	VOID ID
				{
					string type = "void";
					string name = $2;
					bool found;
					symtab->search_func(name,&found);
					if (found)
						cout << "Error: Function " << name << " already declared" << endl;
					else{
						active_func_ptr = symtab->add_function(name,type);
						current_level = 1;
						curr_func_stack.push(active_func_ptr);	
					}
					genCode("func begin " + name);
				}
			|	var_type MAIN
				{
					string type = $1->attr["type"];
					string name = "main";
					bool found;
					symtab->search_func(name,&found);
					if (found)
						cout << "Error: Function " << name << " already declared" << endl;
					else{
						active_func_ptr = symtab->add_function(name,type);
						current_level = 1;
						curr_func_stack.push(active_func_ptr);

					}
					genCode("func begin " + name);
				}
			|	VOID MAIN
				{
					string type = "void";
					string name = "main";
					bool found;
					symtab->search_func(name,&found);
					if (found)
						cout << "Error: Function " << name << " already declared" << endl;
					else{
						active_func_ptr = symtab->add_function(name,type);
						current_level = 1;
						curr_func_stack.push(active_func_ptr);
					}
					genCode("func begin " + name);
				}
			;

paramlist	:	params {}
			| 	{}
			;

params 		:	params COMMA param { }
			|	param {}
			;

param 		:	var_type ID
				{
					string type = $1->attr["type"];
					string name = $2;
					bool found;
					symtab->search_param(name, &found, active_func_ptr);
					if (found)
						cout << "Error: Param " << name << " already in use" << endl;
					else{
						symtab->add_param(active_func_ptr, name,type);
					}
				}
			;



body		:	stmt_list
				{
					current_level ++;
					if (!symtab->func_name_table[active_func_ptr].returned && symtab->func_name_table[active_func_ptr].result_type != "void") {
						cout << "Error: Function " << symtab->func_name_table[active_func_ptr].name << " does not have a return statement." << endl;
					}
				}
			|
			;
stmt_list	:	stmt_list stmt
			|	stmt 
				{
					$$ = new Node;	
					$$->attr_list["next"] = $1->attr_list["next"];
				}
			;

stmt 		:	Decl
				{
					$$ = new Node;
					$$->attr_list["next"] = makelist();
					// $$->attr_list["next"] = 
				}
			|	funccall_stmt
			|	asg
				{
					// changes required here !!
					$$ = new Node;	
					$$->attr_list["next"] = makelist();
					// genCode("Assignment");
					// backpatch($$->attr["next"],next_quad);

				}

			|	cond_stmt 
				{
					$$ = new Node;	
					$$->attr_list["next"] = $1->attr_list["next"];
					backpatch($$->attr_list["next"], next_quad);
				}
			|   while_stmt
				{
					$$ = new Node;	
					$$->attr_list["next"] = $1->attr_list["next"];
					backpatch($$->attr_list["next"], next_quad);

				}
			|	return_stmt
				{
					$$ = new Node;
					$$->attr_list["next"] = makelist();
				}
			|	scoped_stmt
				{
					$$ = new Node;	
					$$->attr_list["next"] = $1->attr_list["next"];
					// backpatch($1->attr_list["next"], next_quad);
				}

			;

scoped_stmt : 	nest_begin stmt_list nest_end
				{
					$$ = new Node;
					$$->attr_list["next"] = $2->attr_list["next"];
				}
			;

nest_begin 	:	LEFT_CURLY_BRACKET
				{
					current_level++;
				}
			;

nest_end	:	RIGHT_CURLY_BRACKET
				{
					current_level--;
				}
			;

asg 		:	lhs ASSIGN_OP expr SEMICOLON
				{
					string type = $1->attr["type"];

					if (type != $3->attr["type"]) {
						cout << "Error: Type mismatch, type of " << $1 << " does not match type of RHS." << endl;
					} else {
						genCode($1->attr["tempname"]+" = "+$3->attr["tempname"]);
					}
					
				}
			;

lhs 		:	ID
				{
					$$ = new Node;
					bool found_var = false, found_param = false;

					int vnptr = symtab->search_var($1, active_func_ptr, current_level, &found_var);
					int pnptr = symtab->search_param($1, &found_param, active_func_ptr);
					if (!found_var && !found_param) {
						cout << "Error: Variable " << $1 << " not declaredd in this scope." << endl;
					} else {
						string type = "";
						if (vnptr != -1) {
							type = symtab->func_name_table[active_func_ptr].loc_varlist_ptr[vnptr].type;
						} else {
							type = symtab->func_name_table[active_func_ptr].paramlist_ptr[pnptr].type;
						}

						$$->attr["type"] = type;
						$$->attr["tempname"] = $1;
					}
				}
			|	array_elem	{$$ = $1;}
			;

funccall_stmt	:	func_call SEMICOLON
					{
						// active_func_ptr = curr_func_stack.top();
						curr_func_stack.pop();
						call_name_ptr = curr_func_stack.top();
					}
				;

func_call	:	ID LP explist RP 
				{
					$$ = new Node;
					$$->attr["type"] = "ERROR";
					string name = $1;
					bool found = false;
					int fnptr = symtab->search_func(name, &found);
					

					if(!found) {
						cout << "Function " << name << " not declared." << endl;
						call_name_ptr = 0;
					} else {
						string type = symtab->func_name_table[fnptr].result_type;
					 	$$->attr["type"] = type;
					 	int num_params = symtab->func_name_table[fnptr].num_params;
					 	if (num_params != stoi($3->attr["pno"]))
					 	{
					 		cout << "Mismatch in number of parameters of function "<<name<<endl;
					 	}
					 	else{
					 		call_name_ptr = active_func_ptr;
							curr_func_stack.push(active_func_ptr);

							string result_var = newTemp(type);

							$$->attr["tempname"] = result_var;

							genCode("refparam " + result_var);
							genCode("call " + name + ", " + to_string(num_params + 1));
							curr_func_stack.push(active_func_ptr);
					 	}
							active_func_ptr = fnptr;
					}
				}
			;

explist		:	elist 
				{
					$$ = new Node;
					$$->attr["pno"] = $1->attr["pno"];
				}
			| 	{
					$$ = new Node;
					$$->attr["pno"] = "0";
				}
			;

elist 		:	elist COMMA expr
				{
					int newVal = increment($1->attr["pno"]);
					$$ = new Node;
					$$->attr["pno"] = to_string(newVal);
					bool ok;
					symtab->check_param_type(curr_func_stack.top(), newVal, $3->attr["type"], ok);
					if(!ok) 
						cout << "Parameter type mismatch in declaration and call.";	
					else
						genCode("param expr.result");
				}
				
			|	expr
				{
					$$ = new Node;
					$$->attr["pno"] = "1";
					bool ok;
					symtab->check_param_type(curr_func_stack.top(), 1, $1->attr["type"], ok);
					if(!ok) 
						cout << "Parameter type mismatch in declaration and call.";	
					else
						genCode("param expr.result");
				}



expr		:	const							{$$ = $1;}
			|	array_elem						{$$ = $1;}
			|	ID
				{
					$$ = new Node;
					$$->attr["type"] = "ERROR";
					bool found_var = false, found_param = false;
					int vnptr = symtab->search_var($1, active_func_ptr, current_level, &found_var);
					int pnptr = symtab->search_param($1, &found_param, active_func_ptr);
					if (!found_var && !found_param) {
						cout << "Error: Variable " << $1 << " not declared in this scope." << endl;
					} else {
						if (vnptr != -1) {
							$$->attr["type"] = symtab->func_name_table[active_func_ptr].loc_varlist_ptr[vnptr].type;
							$$->attr["name"] = symtab->func_name_table[active_func_ptr].loc_varlist_ptr[vnptr].name;
							$$->attr["tempname"] = $$->attr["name"];
						} else {
							$$->attr["type"] = symtab->func_name_table[active_func_ptr].paramlist_ptr[pnptr].type;
							$$->attr["name"] = symtab->func_name_table[active_func_ptr].paramlist_ptr[pnptr].name;
							$$->attr["tempname"] = $$->attr["name"];
						}
					}
				}
			|	LP expr	RP					{$$ = $2;}
			|	func_call
				{
					$$ = $1;
				}
			|	const operator expr
				{
					$$ = new Node;
					$$->attr["type"] = "ERROR";
					if ($1->attr["type"] != $3->attr["type"]) {
						cout << "Error: Type mismatch for operator " << $1 << endl;
					}
					else{
						$$->attr["type"] = $1->attr["type"];
						$$->attr["tempname"] = newTemp($1->attr["type"]);
						genCode($$->attr["tempname"] + " = " + $1->attr["tempname"] + " " + $2 + " " + $3->attr["tempname"]);
					}
				}
			|	ID operator expr
				{
					$$ = new Node;
					$$->attr["type"] = "ERROR";

					bool found_var = false, found_param = false;
					int vnptr = symtab->search_var($1, active_func_ptr, current_level, &found_var);
					int pnptr = symtab->search_param($1, &found_param, active_func_ptr);
					if (!found_var && !found_param) {
						cout << "Error: Variable " << $1 << " not declared in this scope." << endl;
					} else {
						if (vnptr != -1 && symtab->func_name_table[active_func_ptr].loc_varlist_ptr[vnptr].type != $3->attr["type"]) {
							cout << "Error: Type mismatch for operator " << $1 << endl;
						} else if (pnptr != -1 && symtab->func_name_table[active_func_ptr].paramlist_ptr[pnptr].type != $3->attr["type"] ) {
							cout << "Error: Type mismatch for operator " << $1 << endl;
						}
						else{
							$$->attr["type"] = $3->attr["type"];
							$$->attr["tempname"] = newTemp($3->attr["type"]);
							genCode($$->attr["tempname"] + " = " + $1 + " " + $2 + " " + $3->attr["tempname"]);
						}
					}
				}
			|	func_call operator expr
				{
					$$ = new Node;
					$$->attr["type"] = "ERROR";
					if ($1->attr["type"] != $3->attr["type"]) {
						cout << "Error: Type mismatch for operator " << $1 << endl;
					}
					else{
						$$->attr["type"] = $1->attr["type"];
						$$->attr["tempname"] = newTemp($1->attr["type"]);
						genCode($$->attr["tempname"] + " = " + $1->attr["tempname"] + " " + $2 + " " + $3->attr["tempname"]);
					}
				}
			|	expr comparator expr
				{
					$$ = new Node;
					$$->attr["type"] = "ERROR";
					if ($1->attr["type"] != $3->attr["type"]) {
						cout << "Error: Type mismatch for comparator " << $1 << endl;
					}
					else{
						$$->attr["type"] = "int";
						$$->attr["tempname"] = newTemp($$->attr["type"]);
						genCode($$->attr["tempname"] + " = " + $1->attr["tempname"] + " " + $2 + " " + $3->attr["tempname"]);
					}
				}
			;


const 		:	INTEGER				{$$ = new Node; $$->attr["type"] = "int"; $$->attr["value"] = $1; $$->attr["tempname"] = $1;}
			|	REAL				{$$ = new Node; $$->attr["type"] = "float"; $$->attr["value"] = $1; $$->attr["tempname"] = $1;}
			|	CHARACTER			{$$ = new Node; $$->attr["type"] = "char"; $$->attr["value"] = $1; $$->attr["tempname"] = $1;}
			;


comparator	:	LTE			{$$ =$1;}
			|	GTE			{$$ =$1;}
			|	EQ			{$$ =$1;}
			|	GT			{$$ =$1;}
			|	LT			{$$ =$1;}
			;

operator 	:	ASTERISK			{$$ = $1;}
			|	PLUS				{$$ = $1;}
			|	MINUS				{$$ = $1;}
			|	DIVIDE				{$$ = $1;}
			|	LEFT_SHIFT 			{$$ = $1;}
			|	RIGHT_SHIFT 		{$$ = $1;}
			|	AMP					{$$ = $1;}
			|	OR_BIT				{$$ = $1;}
			|	AND_BIT				{$$ = $1;}
			|	AND_EXP				{$$ = $1;}
			|	OR_EXP				{$$ = $1;}
			;


cond_stmt	:	ifexp stmt n ELSE m stmt 
				{
					$$ = new Node;
					backpatch($1->attr_list["falselist"], stoi($5->attr["quad"]));
					vector<int> *v = $2->attr_list["next"];
					v->insert(v->end(), $6->attr_list["next"]->begin(), $6->attr_list["next"]->end());
					v->insert(v->end(), $3->attr_list["next"]->begin(), $3->attr_list["next"]->end());

					$$->attr_list["next"] = v;
				}	
			|	ifexp stmt p %prec _THEN_
				{
					$$ = new Node;
					vector<int> *v = $2->attr_list["next"];
					v->insert(v->end(), $1->attr_list["falselist"]->begin(), $1->attr_list["falselist"]->end());

					$$->attr_list["next"] = v;
				}

			
			;

ifexp		:	IF LP expr RP
				{
					$$ = new Node;
					$$->attr_list["falselist"] = makelist();
					$$->attr_list["falselist"]->push_back(next_quad);
					genCode("if ("+$3->attr["tempname"]+" == 0) goto _");
				}

			;

n 			:
				{
					$$ = new Node;
					$$->attr_list["next"] = makelist();
					$$->attr_list["next"]->push_back(next_quad);
					
					genCode("goto _");
				}
			;

m 			:	{
					$$ = new Node;
					$$->attr["quad"] = to_string(next_quad);
				
				}
			;
 p 			:	
 			;

while_stmt	:	while_exp stmt
				{
					$$ = new Node;
					$$->attr_list["next"] = $1->attr_list["falselist"];
					string while_begin = $1->attr["begin"];
					backpatch($2->attr_list["next"], stoi(while_begin));
					genCode("goto " + while_begin);
				}
			;

while_exp	:	WHILE m LP expr RP
				{
					$$ = new Node;
					$$->attr["begin"] = $2->attr["quad"];
					$$->attr_list["falselist"] = makelist();
					$$->attr_list["falselist"]->push_back(next_quad);
					genCode("if ("+$4->attr["tempname"]+" == 0) goto _");
				}


return_stmt	:	RETURN expr SEMICOLON
			{
				string ret_type = symtab->func_name_table[active_func_ptr].result_type;
				if (ret_type != $2->attr["type"]) {
					cout << "Error: Type mismatch: returned value does not match expected return value in " << symtab->func_name_table[active_func_ptr].name<<endl;
				} else {
					genCode("return "+$2->attr["tempname"]);
					symtab->func_name_table[active_func_ptr].returned = true;
				}
			}
			|	RETURN SEMICOLON
			{
				string ret_type = symtab->func_name_table[active_func_ptr].result_type;
				if (ret_type != "void") {
					cout << "Function " << symtab->func_name_table[active_func_ptr].name <<" should not return any values." <<endl;
				} else {
					genCode("return");
					symtab->func_name_table[active_func_ptr].returned = true;
				}
			}
			;

var_type 	:	INT
			{	
				$$ = new Node();
				$$->attr["type"] = $1;
			}
			|	FLOAT
			{
				$$ = new Node();
				$$->attr["type"] = $1;
			}
			|	CHAR
			{
				$$ = new Node();
				$$->attr["type"] = $1;
			}
			;

array_elem	:	ID dims
				{
					// check if Id exist
					// check if dims doesnt have tempname as error
					$$ = new Node;
					$$->attr["type"] = "ERROR";
					$$->attr["tempname"] = "ERROR";
					bool found_var = false, found_param = false;
					int vnptr = symtab->search_var($1, active_func_ptr, current_level, &found_var);
					int pnptr = symtab->search_param($1, &found_param, active_func_ptr);
					if (!found_var && !found_param) {
						cout << "Error: Variable " << $1 << " not declared in this scope." << endl;
					} else {
						vector<int>* dim_list;
						if (vnptr != -1) {
							$$->attr["type"] = symtab->func_name_table[active_func_ptr].loc_varlist_ptr[vnptr].type;
							dim_list = symtab->func_name_table[active_func_ptr].loc_varlist_ptr[vnptr].dimlist_ptr;
						} else if (pnptr != -1  ) {
							$$->attr["type"] = symtab->func_name_table[active_func_ptr].paramlist_ptr[pnptr].type;
							dim_list = symtab->func_name_table[active_func_ptr].paramlist_ptr[pnptr].dimlist_ptr;
						}

						if ($2->attr["tempname"] != "ERROR")
						{
							string addr_str = newTemp($$->attr["type"]+"*");
							genCode(addr_str+" = addr("+$1+")");

							$$->attr["tempname"] = newTemp($$->attr["type"]);
							genCode($$->attr["tempname"]+" = "+addr_str+"["+$2->attr["tempname"]+"]");
							string type = $$->attr["type"];
							backpatch($2->attr_list["type_offset"],sizes[type]);
							for (int i = 0; i < dim_list->size(); ++i)
							{
								if (i < $2->attr_list["dim_offset"]->size())
								{
									string replacent = to_string((*dim_list)[i]);
									int quad_number = (*($2->attr_list["dim_offset"]))[i];
									substitute(quad_number,replacent);
								}
									
							}
						}


					}
					 
				}
			;

dims 		:	LEFT_SQ_BRACKET expr RIGHT_SQ_BRACKET
				{
					$$ = new Node;
					$$->attr_list["type_offset"] = makelist();
					$$->attr_list["dim_offset"] = makelist();
					if ($2->attr["type"]!="int")
					{
						cout << "Error: Dimension should be an integer" << endl;
						$$->attr["tempname"] = "ERROR";
					}
					else{
						$$->attr["tempname"] = newTemp($2->attr["type"]);
						$$->attr_list["type_offset"]->push_back(next_quad);
						genCode($$->attr["tempname"] + " = " +$2->attr["tempname"]+" * _");


					}
				}
			|	dims LEFT_SQ_BRACKET expr RIGHT_SQ_BRACKET
				{
					$$ = new Node;
					if ($3->attr["type"]!="int" && $1->attr["tempname"]!="ERROR")
					{
						cout << "Error: Dimension should be an integer" << endl;
						$$->attr["tempname"] = "ERROR";
					}
					else{
						$$->attr_list["type_offset"] = $1->attr_list["type_offset"];
						$$->attr_list["dim_offset"] = $1->attr_list["dim_offset"];
						$$->attr["tempname"] = newTemp($3->attr["type"]);
						string offset1 = newTemp("int");
						string offset2 = newTemp("int");
						$$->attr_list["dim_offset"]->push_back(next_quad);
						genCode(offset1+" = "+$1->attr["tempname"]+" * _");
						$$->attr_list["type_offset"]->push_back(next_quad);
						genCode(offset2+" = "+$3->attr["tempname"]+" * _");
						genCode($$->attr["tempname"] + " = " +offset1+" + "+offset2);
					}
				}
			;


%%

int main() {
	sizes["int"] = 4;
	sizes["char"] = 1;
	sizes["float"] = 8;
	int global = symtab->add_function("$global","");
	curr_func_stack.push(global); // stores call 
	yyparse();
	symtab->print_symTable();
	// int f = symtab->insert_function("f1","int");
	// // symtab->insert_function("f2","string");
	// symtab->add_param(f,"p0.1", "int");
	// symtab->add_var(f,"v0.1","int",2);
	// symtab->add_var(f,"v0.2","int",2);
	// active_func_ptr = f;
	// // symtab->print_symTable();
	// symtab->print_funcTable(f);
	// list<int> var_list (1,1);
	// var_list.push_back(0);
	// symtab->patch("float",&var_list);
	// symtab->print_funcTable(global);
	// symtab->print_funcTable(1);
	printThreeAddressCode();
	// while(!curr_func_stack.empty()) {
	// 	cout << curr_func_stack.top() << endl;
	// 	curr_func_stack.pop();
	// }
	return 0;
}


void yyerror (const char *s) {fprintf (stderr, "%s\n\n", s);}

string newTemp(string type) {	
	tempList[temp_num++] = type;
	return "t" + to_string(temp_num);
}

void genCode(string s) {
	i_code.push_back(s);
	next_quad++;
}

void printThreeAddressCode() {
	int i = 0;
	for(auto it = i_code.begin(); it != i_code.end(); it++,i++) {
		cout << to_string(i) << "  " << *it << endl;
	}
}

int increment(string s) {
	return stoi(s) + 1;
}

vector<int>* makelist(){
	return new vector<int>;
}

void backpatch(vector<int> *list, int quad){
	for (auto it = list->begin(); it!=list->end(); it++)
	{
		int index = 0;
		index = i_code[*it].find("_", index);
     	if (index == string::npos) continue;
     	i_code[*it].replace(index,1,to_string(quad));
    }
}

void substitute(int quad_number, string replacent){
	int index = 0;
	index = i_code[quad_number].find("_", index);
 	if (index == string::npos) return;
 	i_code[quad_number].replace(index,1,replacent);
 	return;
}
