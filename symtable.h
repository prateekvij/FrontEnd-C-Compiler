class VarNameRecord {
public:
	string name, type, var_tag;
	int level;
	vector<int>* dimlist_ptr;
};

class FuncNameRecord {
public:
	string name, result_type; 
	vector<VarNameRecord> paramlist_ptr, loc_varlist_ptr;
	int num_params;
	bool returned;
};

class SymTable {
public:
	vector<FuncNameRecord> func_name_table;
	int search_func(string n, bool* found);
	int search_param(string p, bool* found, int fnptr);
	int search_var(string v, int fnptr, int l, bool* found);
	void print_symTable();
	void print_funcTable(int fnptr);
	int add_function(string name, string result_type
		);
	int add_param(int fn_ptr, string param_name, string type);
	int add_var(int fn_ptr, string var_name, string type, int level, string var_tag, vector<int> *dimlist_ptr);
	int patch(string type, list<int> *var_list, int level);
	void check_param_type(int call_ptr, int param_num, string type, bool &ok);
};

struct Node {
// public:
	map<string, string> attr;
	map<string, vector<int>* > attr_list;
	list<int> *namelist;
};

SymTable* symtab = new SymTable;


int active_func_ptr = 0; // suggest global
int current_level = 0;
int call_name_ptr = 0;

stack<int> curr_func_stack;


/**
 * Returns fnptr of the function with name n.
 */
int SymTable::search_func(string n, bool* found) {
	*found = false;

	for (int i=0; i<(symtab->func_name_table).size(); i++) {
		if (n == symtab->func_name_table[i].name) {
			*found = true;
			return i;
		}
	}

	return -1;
}

/**
 * Returns pnptr of the parameter of function fnptr with name p.
 */
int SymTable::search_param(string p, bool* found, int fnptr) {
	*found = false;

	for (int i=0; i<(symtab->func_name_table)[fnptr].paramlist_ptr.size();i++) {
		if (p == (symtab->func_name_table)[fnptr].paramlist_ptr[i].name) {
			*found = true;
			return i;
		}
	}

	return -1;
}

/**
 * Returns vnptr of the variable of function fnptr with name v.
 */
int SymTable::search_var(string v, int fnptr, int l, bool* found) {
	*found = false;
	int x = symtab->func_name_table[fnptr].loc_varlist_ptr.size();
	for (int i=0; i<(symtab->func_name_table)[fnptr].loc_varlist_ptr.size(); i++) {
		if (v == (symtab->func_name_table)[fnptr].loc_varlist_ptr[i].name && l >= (symtab->func_name_table)[fnptr].loc_varlist_ptr[i].level) {
			*found = true;
			return i;
		}
	}

	return -1;
}


void SymTable::print_symTable(){

	cout << "Symbol Table" << endl;
	for (int i=0; i<(symtab->func_name_table).size(); i++) {
		cout << symtab->func_name_table[i].name << "\t" << symtab->func_name_table[i].result_type << "\t" << symtab->func_name_table[i].num_params << endl;
		print_funcTable(i);
	}
	cout << "" << endl;
}

void SymTable::print_funcTable(int fnptr){
	cout << "\t>>Name: " << symtab->func_name_table[fnptr].name << "\n";
	cout << "\t>>Param count: " << symtab->func_name_table[fnptr].num_params << endl;
	cout << "\t>>Params : ";
	for (int i = 0; i < (symtab->func_name_table[fnptr].paramlist_ptr).size(); ++i)
	{
		cout << (symtab->func_name_table[fnptr].paramlist_ptr[i]).name << "("<<(symtab->func_name_table[fnptr].paramlist_ptr[i]).type <<")(" << (symtab->func_name_table[fnptr].paramlist_ptr[i]).level <<")  ";
	}
	cout << endl <<"\t>>Var : ";
	auto loc_ptr = symtab->func_name_table[fnptr].loc_varlist_ptr;
	for (int i = 0; i < loc_ptr.size(); ++i)
	{
		cout << (loc_ptr[i]).name << "("<<(loc_ptr[i]).type <<")(" << (loc_ptr[i]).level<<")" << "  " << loc_ptr[i].var_tag << " " ;
		for(auto it = loc_ptr[i].dimlist_ptr->begin(); it != loc_ptr[i].dimlist_ptr->end(); it++) {
			cout << *it << " ";
		}

	}
	cout << endl;
}
int SymTable::add_function(string name, string result_type) {
	int fn_ptr = symtab->func_name_table.size();
	// cout << fn_ptr << endl;
	FuncNameRecord fn_record;
	fn_record.name = name;
	fn_record.result_type = result_type;
	fn_record.num_params = 0;
	fn_record.returned = false;
	symtab->func_name_table.push_back(fn_record);
	symtab->func_name_table[fn_ptr].loc_varlist_ptr = symtab->func_name_table[0].loc_varlist_ptr;
	return fn_ptr;
}

int SymTable::add_param(int fn_ptr, string param_name, string type) {
	VarNameRecord param;
	param.name = param_name;
	param.type = type;
	// param.var_tag = var_tag;
	param.level =1;
	symtab->func_name_table[fn_ptr].paramlist_ptr.push_back(param);
	symtab->func_name_table[fn_ptr].num_params += 1;
	return symtab->func_name_table[fn_ptr].paramlist_ptr.size() - 1;
}

int SymTable::add_var(int fn_ptr, string var_name, string type, int level, string var_tag, vector<int> *dimlist_ptr) {
	VarNameRecord var;
	var.name = var_name;
	var.type = type;
	var.level =level;
	var.var_tag = var_tag;
	var.dimlist_ptr = dimlist_ptr;
	symtab->func_name_table[fn_ptr].loc_varlist_ptr.push_back(var);
	return symtab->func_name_table[fn_ptr].loc_varlist_ptr.size() - 1;
}


// Patch datatype to the parameter of "active" function
// Returns 1 if success, 0 if fails
int SymTable::patch(string type, list<int> *var_list, int level) {
	list<int>::const_iterator iter;
	int func_var_count = symtab->func_name_table[active_func_ptr].loc_varlist_ptr.size();
	for (iter = var_list->begin(); iter != var_list->end(); ++iter) {
	    if (*iter >= func_var_count)
	    {
	    	return 0;
	    }
	    if (level == symtab->func_name_table[active_func_ptr].loc_varlist_ptr[*iter].level)
	    {
	    	symtab->func_name_table[active_func_ptr].loc_varlist_ptr[*iter].type = type;	
	    }
	    
	}
	return 1;
}

void SymTable::check_param_type(int call_ptr, int param_num, string type, bool &ok) {
	if (call_ptr < this->func_name_table.size() && param_num < this->func_name_table[call_ptr].num_params)
	{	
		if(this->func_name_table[call_ptr].paramlist_ptr[param_num - 1].type == type) 
			ok = true;
		else 
			ok = false;		
	}
	else{
		ok = false;	
	}
	
		
}