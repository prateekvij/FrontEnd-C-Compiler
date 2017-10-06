out = open('tokens.h','w')
tokens = open('tokens').readlines()
i= 0
for token in tokens:
	i += 1
	token = token.strip()
	out.write("\""+token+"\" \t\t\t\t\tRET(\""+token.upper()+"\", "+token.upper()+")\n")
