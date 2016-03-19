/// ABSTRACT: get access to internal interpreter commands 

#ifndef SINGULAR_KERNEL_COMMANDS_H
#define SINGULAR_KERNEL_COMMANDS_H


#include <kernel/mod2.h>
#include <Singular/tok.h>
#include <Singular/grammar.h>

// to produce convert_table.texi for doc:
//#define CONVERT_TABLE 1

// bits 0,1 for PLURAL
#define NO_PLURAL        0
#define ALLOW_PLURAL     1
#define COMM_PLURAL      2
#define  PLURAL_MASK     3

// bit 2 for RING-CF
#define ALLOW_RING       4
#define NO_RING          0

// bit 3 for zerodivisors
#define NO_ZERODIVISOR   8
#define ALLOW_ZERODIVISOR  0

// bit 4 for warning, if used at toplevel
#define WARN_RING        16

/* 
typedef proc1 PROC1;
typedef proc2 PROC2;
typedef proc3 PROC3;
#define D(A)     A
#define NULL_VAL NULL
*/

typedef  int PROC1;
typedef  int PROC2;
typedef  int PROC3;

#define D(A)     2
#define NULL_VAL 0

struct sValCmd1
{
  PROC1 p;
  short cmd;
  short res;
  short arg;
  short valid_for;
};

struct sValCmd2
{
  PROC2 p;
  short cmd;
  short res;
  short arg1;
  short arg2;
  short valid_for;
};

struct sValCmd3
{
  PROC3 p;
  short cmd;
  short res;
  short arg1;
  short arg2;
  short arg3;
  short valid_for;
};

struct sValCmdM
{
  PROC1 p;
  short cmd;
  short res;
  short number_of_args; // (1,2,3)=>jCALL?ARG, -1:args:*,-2:args:1+*, 0,4,5,6,...=> exactly that 
  short valid_for;
};

// =============== types =====================
struct _scmdnames
{
  const char *name;
  short alias;
  short tokval;
  short toktype;
};
typedef struct _scmdnames cmdnames;


/*
struct sValAssign_sys
{
  int p;
  short res;
  short arg;
};

struct sValAssign
{
  int p;
  short res;
  short arg;
};
struct sConvertTypes
{
  int i_typ;
  int o_typ;
  int p;
  int pl;
};
*/

#define jjWRONG   1
#define jjWRONG2  1
#define jjWRONG3  1
#define XS(A) A



// #define IPCONV
// #define IPASSIGN

#define IPARITH
#define GENTABLE

#include <Singular/table.h>

#define ARITH_SIZE(d)  ((sizeof(d) / sizeof(d[0])) - 1)

const int arith1_size = ARITH_SIZE(dArith1);
const int arith2_size = ARITH_SIZE(dArith2);
const int arith3_size = ARITH_SIZE(dArith3);
const int arithM_size = ARITH_SIZE(dArithM);

static inline sValCmd1* getArith1( int i )
{
  if( i < 0 || i > arith1_size )
    return NULL;
  return &dArith1[i];
}
static inline sValCmd2* getArith2( int i )
{
  if( i < 0 || i > arith2_size )
    return NULL;
  return &dArith2[i];
}
static inline sValCmd3* getArith3( int i )
{
  if( i < 0 || i > arith3_size )
    return NULL;
  return &dArith3[i];
}
static inline sValCmdM* getArithM( int i )
{
  if( i < 0 || i > arithM_size )
    return NULL;
  return &dArithM[i];
}


/// ?
static inline const char * __Tok2Cmdname(int tok)
{
  int i = 0;
  if (tok < 0)
  {
    return cmds[0].name;
  }
  if (tok==COMMAND) return "COMMAND";
  if (tok==ANY_TYPE) return "ANY_TYPE";
  if (tok==NONE) return "NONE";
  //if (tok==IFBREAK) return "if_break";
  //if (tok==VECTOR_FROM_POLYS) return "vector_from_polys";
  //if (tok==ORDER_VECTOR) return "ordering";
  //if (tok==REF_VAR) return "ref";
  //if (tok==OBJECT) return "object";
  //if (tok==PRINT_EXPR) return "print_expr";
  if (tok==IDHDL) return "IDHDL";
  // we do not blackbox objects during table generation:
  //if (tok>MAX_TOK) return getBlackboxName(tok);
  while (cmds[i].tokval!=0)
  {
    if ((cmds[i].tokval == tok)&&(cmds[i].alias==0))
    {
      return cmds[i].name;
    }
    i++;
  }
  return cmds[0].name;
}

/// generic
static inline const char * __iiTwoOps(int t)
{
  if (t<127)
  {
    static char ch[7]= { 'B', 'a', 's', 'e', '.', '\0', '\0' }; // 'B', 'a', 's', 'e', '.', 

    switch (t)
    {
      //      case '-':        return "Base.-";
      case '(':        return "Base.call";
      //      case '|':        return "|";
      default:
        ch[5]=t; //        ch[1]='\0';
    }
    return ch;
  }
  switch (t)
  {
    case COLONCOLON:  return "::";
    case DOTDOT:      return "..";
    //case PLUSEQUAL:   return "+=";
    //case MINUSEQUAL:  return "-=";
    case MINUSMINUS:  return "--";
    case PLUSPLUS:    return "++";
    case EQUAL_EQUAL: return "Base.==";
    case LE:          return "Base.<=";
    case GE:          return "Base.>=";
    case NOTEQUAL:    return "Base.!=";
    case COUNT_CMD:   return "_size";
      //    case PRINT_CMD:   return "Base.print"
    default:          return __Tok2Cmdname(t);
  }
}
/*
import Base: Array, call, checkbounds, convert, cmp, contains, deepcopy,
             den, div, divrem, gcd, gcdx, getindex, hash, inv, invmod, isequal, 
             isless, lcm, length, mod, ndigits, num, one, parent, print,
             promote_rule, Rational, rem, setindex!, show, sign, size, string,  zero,
 */


/*
// automatic conversions:

/// try to convert 'inputType' in 'outputType'
/// return 0 on failure, an index (<>0) on success
static inline int __iiTestConvert (int inputType, int outputType)
{
  if ((inputType==outputType)
  || (outputType==DEF_CMD)
  || (outputType==IDHDL)
  || (outputType==ANY_TYPE))
  {
    return -1;
  }

  // search the list
  int i=0;
  while (dConvertTypes[i].i_typ!=0)
  {
    if((dConvertTypes[i].i_typ==inputType)
    &&(dConvertTypes[i].o_typ==outputType))
    {
      // Print("test convert %d to %d (%s -> %s):%d\n",inputType,outputType,
      // Tok2Cmdname(inputType), Tok2Cmdname(outputType),i+1);
      return i+1;
    }
    i++;
  }
  // Print("test convert %d to %d (%s -> %s):0\n",inputType,outputType,
  // Tok2Cmdname(inputType), Tok2Cmdname(outputType));
  return 0;
}
*/

/*
void ttGen1()
{
  int i;
//  printf(
//  "#########################################\n"
//  "#  Computer Algebra System SINGULAR     #\n"
//  "#########################################\n"
//  "# Mappings for the high level GAP interface\n"
//  "# This file is automatically generated by gentableforGAP.\n"
//  "# Please do not edit it.\n\n");

//  printf("BindGlobal(\"SI_OPERATIONS\", [\n[\n");
  int op;
  i=0;
  while ((op=dArith1[i].cmd)!=0)
  {
    if (dArith1[i].p!=jjWRONG) {
        const char *s = __iiTwoOps(op);
        printf("  [\"%s\",[\"%s\"],\"%s\",%d],\n",
              s,
              __Tok2Cmdname(dArith1[i].arg),
              __Tok2Cmdname(dArith1[i].res),
              i);
    }
    i++;
  }
//  printf("],\n#################################################\n[\n");
  i=0;
  while ((op=dArith2[i].cmd)!=0)
  {
    if (dArith2[i].p!=jjWRONG2) {
        const char *s = __iiTwoOps(op);
        printf("  [\"%s\",[\"%s\",\"%s\"],\"%s\",%d],\n",
              s,
              __Tok2Cmdname(dArith2[i].arg1),
              __Tok2Cmdname(dArith2[i].arg2),
              __Tok2Cmdname(dArith2[i].res),
              i);
    }
    i++;
  }
//  printf("],\n#################################################\n[\n");
  i=0;
  while ((op=dArith3[i].cmd)!=0)
  {
    const char *s = __iiTwoOps(op);
    if (dArith3[i].p!=jjWRONG3) {
        printf("  [\"%s\",[\"%s\",\"%s\",\"%s\"],\"%s\",%d],\n",
              s,
              __Tok2Cmdname(dArith3[i].arg1),
              __Tok2Cmdname(dArith3[i].arg2),
              __Tok2Cmdname(dArith3[i].arg3),
              __Tok2Cmdname(dArith3[i].res),
              i);
    }
    i++;
  }
//  printf("],\n#################################################\n[\n");
  i=0;
  while ((op=dArithM[i].cmd)!=0)
  {
    const char *s = __iiTwoOps(op);
    printf("  [\"%s\",%d,\"%s\",%d],\n", 
            s, dArithM[i].number_of_args, __Tok2Cmdname(dArithM[i].res), i);
    i++;
  }
//  printf("]\n]);\n");
//  // Seems no longer to be needed
//  printf("BindGlobal(\"SI_TOKENLIST\", [\n");
  char ops[]="=>/<+-*[.^,%(;";
  for(i=0;ops[i]!='\0';i++)
    printf("  %d,\"%c\",\n", (int)ops[i], ops[i]);
  for (i=257;i<=MAX_TOK;i++)
  {
    const char *s=__iiTwoOps(i);
    if (s[0]!='$')
    {
      printf("  %d,\"%s\",\n", i, s);
    }
  }
  printf("]);\n");
}
// int main(){  ttGen1();  return 0;}
*/

#endif // /* ifdef/define SINGULAR_KERNEL_COMMANDS_H */
