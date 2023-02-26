/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Skeleton interface for Bison GLR parsers in C

   Copyright (C) 2002-2015, 2018-2021 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    IF = 258,                      /* IF  */
    ELSE = 259,                    /* ELSE  */
    WHILE = 260,                   /* WHILE  */
    DO = 261,                      /* DO  */
    FOR = 262,                     /* FOR  */
    MAIN = 263,                    /* MAIN  */
    STRUCT = 264,                  /* STRUCT  */
    RETURN = 265,                  /* RETURN  */
    DEFAULT = 266,                 /* DEFAULT  */
    CONST = 267,                   /* CONST  */
    BREAK = 268,                   /* BREAK  */
    CONTINUE = 269,                /* CONTINUE  */
    GOTO = 270,                    /* GOTO  */
    VOID = 271,                    /* VOID  */
    INT = 272,                     /* INT  */
    FLOAT = 273,                   /* FLOAT  */
    CHAR = 274,                    /* CHAR  */
    SEMICOLON = 275,               /* SEMICOLON  */
    COMMA = 276,                   /* COMMA  */
    LEFT_SQ_BRACKET = 277,         /* LEFT_SQ_BRACKET  */
    RIGHT_SQ_BRACKET = 278,        /* RIGHT_SQ_BRACKET  */
    LEFT_CURLY_BRACKET = 279,      /* LEFT_CURLY_BRACKET  */
    RIGHT_CURLY_BRACKET = 280,     /* RIGHT_CURLY_BRACKET  */
    LP = 281,                      /* LP  */
    RP = 282,                      /* RP  */
    PLUS = 283,                    /* PLUS  */
    MINUS = 284,                   /* MINUS  */
    ASTERISK = 285,                /* ASTERISK  */
    DIVIDE = 286,                  /* DIVIDE  */
    DOT = 287,                     /* DOT  */
    DEREFERENCE = 288,             /* DEREFERENCE  */
    AMP = 289,                     /* AMP  */
    MODULO = 290,                  /* MODULO  */
    ASSIGN_OP = 291,               /* ASSIGN_OP  */
    AND_EXP = 292,                 /* AND_EXP  */
    OR_EXP = 293,                  /* OR_EXP  */
    NOT_EXP = 294,                 /* NOT_EXP  */
    RIGHT_SHIFT = 295,             /* RIGHT_SHIFT  */
    LEFT_SHIFT = 296,              /* LEFT_SHIFT  */
    AND_BIT = 297,                 /* AND_BIT  */
    OR_BIT = 298,                  /* OR_BIT  */
    LT = 299,                      /* LT  */
    GT = 300,                      /* GT  */
    EQ = 301,                      /* EQ  */
    LTE = 302,                     /* LTE  */
    GTE = 303,                     /* GTE  */
    INTEGER = 304,                 /* INTEGER  */
    CHARACTER = 305,               /* CHARACTER  */
    STRING = 306,                  /* STRING  */
    REAL = 307,                    /* REAL  */
    ID = 308,                      /* ID  */
    _THEN_ = 309,                  /* _THEN_  */
    _ELSE_ = 310                   /* _ELSE_  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 60 "c_parser.y"

  char* lex_val;
  struct Node *node;

#line 119 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
