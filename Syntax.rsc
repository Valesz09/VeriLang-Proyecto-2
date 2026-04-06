module verilang::Syntax

// ─── Layout ──────────────────────────────────────────────────────────────────
// Define los espacios en blanco (espacios, tabs, saltos de línea) que el parser ignora.
layout Whitespace = [\ \t\n\r]* !>> [\ \t\n\r];

// ─── Keywords ────────────────────────────────────────────────────────────────
// Palabras reservadas del lenguaje Verilang.
// No pueden ser usadas como identificadores.
keyword Keywords
  = "defmodule" | "using"    | "defspace"     | "defoperator"
  | "defexpression" | "defrule" | "defvar"    | "forall"
  | "exists"    | "defer"    | "end"          | "in"
  | "and"       | "or"       | "neg"          ;

// ─── Lexical ──────────────────────────────────────────────────────────────────
// Identificadores:
// - Deben comenzar con una letra
// - Pueden contener letras, números y guiones
// - No pueden ser palabras reservadas
lexical Id = ([a-zA-Z] [a-zA-Z0-9\-]* !>> [a-zA-Z0-9\-]) \ Keywords;

// ─── Start symbol ────────────────────────────────────────────────────────────
// Punto de entrada del programa (símbolo inicial de la gramática).
start syntax Program
  = program: "defmodule" Id ImportList ComponentList "end"
  ;

// ─── Imports ─────────────────────────────────────────────────────────────────
// Lista de imports (puede estar vacía o tener múltiples).
syntax ImportList
  = importListEmpty:
  | importListCons: ImportList ImportDecl
  ;

// Declaración de importación de otro módulo.
syntax ImportDecl
  = importDecl: "using" Id
  ;

// ─── Components ──────────────────────────────────────────────────────────────
// Lista de componentes del módulo (puede tener múltiples elementos).
syntax ComponentList
  = componentListEmpty:
  | componentListCons: ComponentList Component
  ;

// Tipos de componentes permitidos en el lenguaje.
syntax Component
  = spaceComp:      SpaceDecl
  | operatorComp:   OperatorDecl
  | expressionComp: ExpressionDecl
  | ruleComp:       RuleDecl
  | varComp:        VarDecl
  | equationComp:   EquationDecl
  ;

// ─── Space Declaration ───────────────────────────────────────────────────────
// Declaración de espacios:
// - Puede ser simple
// - O puede heredar de otro espacio usando "<"
syntax SpaceDecl
  = spaceDeclSimple:    "defspace" Id "end"
  | spaceDeclSubspace:  "defspace" Id "\<" Id "end"
  ;

// ─── Operator Declaration ────────────────────────────────────────────────────
// Declaración de operadores.
// IMPORTANTE: Los operadores NO tienen atributos (según la retroalimentación).
syntax OperatorDecl
  = operatorDecl: "defoperator" Id ":" TypeExpr "end"
  ;

// Expresión de tipos (soporta currying).
// Ejemplo: Int -> Bool -> Int
syntax TypeExpr
  = typeBase: Id
  | typeArrow: Id "-\>" TypeExpr
  ;

// ─── Variable Declaration ────────────────────────────────────────────────────
// Declaración de variables.
// Permite múltiples variables separadas por comas.
syntax VarDecl
  = varDecl: "defvar" {VarBinding ","}+ "end"
  ;

// Asociación variable:tipo
syntax VarBinding
  = varBinding: Id ":" Id
  ;

// ─── Rule Declaration ────────────────────────────────────────────────────────
// Reglas entre aplicaciones de operadores.
syntax RuleDecl
  = ruleDecl: "defrule" OperatorApp "-\>" OperatorApp "end"
  ;

// Aplicación de operador:
// - Solo permite valores simples (NO expresiones completas)
// - Esto corrige un error del proyecto 1
syntax OperatorApp
  = operatorApp: "(" Id {SimpleExpr " "}* ")"
  ;

// ─── Equation Declaration ────────────────────────────────────────────────────
// Declaración de ecuaciones.
// Este no terminal faltaba en el proyecto 1.
syntax EquationDecl
  = equationDecl: "defequation" Expr "=" Expr "end"
  ;

// ─── Expression Declaration ──────────────────────────────────────────────────
// Declaración de expresiones.
// Los atributos son opcionales.
syntax ExpressionDecl
  = expressionDeclNoAttr: "defexpression" Expr "end"
  | expressionDeclAttr:   "defexpression" Expr AttrList "end"
  ;

// ─── Expressions ─────────────────────────────────────────────────────────────
// Expresiones del lenguaje.
syntax Expr
  = quantifiedExpr: Quantifier Id "in" Id "." Expr
  | infixExpr:      InfixExpr
  ;

// Cuantificadores lógicos.
// No están restringidos solo a expresiones de pertenencia.
syntax Quantifier
  = forall: "forall"
  | exists: "exists"
  ;

// Expresiones infijas:
// Permiten encadenar múltiples operaciones.
syntax InfixExpr
  = infixSingle: SimpleExpr
  | infixChain:  SimpleExpr InfixOp InfixExpr
  ;

// Operadores infijos soportados por el lenguaje.
syntax InfixOp
  = opAnd:   "and"
  | opOr:    "or"
  | opNeg:   "neg"
  | opEq:    "="
  | opLt:    "\<"
  | opGt:    "\>"
  | opLte:   "\<="
  | opGte:   "\>="
  | opNeq:   "\<\>"
  | opEquiv: "≡"
  | opImpl:  "=\>"
  | opArrow: "-\>"
  | opPlus:  "+"
  | opMinus: "-"
  | opMul:   "*"
  | opDiv:   "/"
  | opPow:   "**"
  | opMod:   "%"
  | opIn:    "in"
  ;

// Expresiones simples:
// Se definen claramente para evitar ambigüedades.
syntax SimpleExpr
  = simpleApp:    OperatorApp
  | simpleParens: "(" Expr ")"
  | simpleId:     Id
  ;

// ─── Attributes ──────────────────────────────────────────────────────────────
// Lista de atributos (uno o más elementos dentro de corchetes).
syntax AttrList
  = attrList: "[" AttrItem+ "]"
  ;

// Elemento de atributo:
// Puede ser simple o con valor.
syntax AttrItem
  = attrItemSimple:  Id
  | attrItemColon:   Id ":" AttrValue
  ;

// Valor de atributo.
syntax AttrValue
  = attrValId:    Id
  | attrValEmpty: "∅"
  ;