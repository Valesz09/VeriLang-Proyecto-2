module verilang::AST

// ─── Program ─────────────────────────────────────────────────────────────────
data Program
  = program(str name, list[ImportDecl] imports, list[Component] components)
  ;

// ─── Imports ─────────────────────────────────────────────────────────────────
data ImportDecl
  = importDecl(str moduleName)
  ;

// ─── Components ──────────────────────────────────────────────────────────────
data Component
  = spaceComp(SpaceDecl space)
  | operatorComp(OperatorDecl op)
  | expressionComp(ExpressionDecl expr)
  | ruleComp(RuleDecl rule)
  | varComp(VarDecl varDecl)
  | equationComp(EquationDecl equation)
  ;

// ─── Space Declaration ───────────────────────────────────────────────────────
data SpaceDecl
  = spaceSimple(str name)
  | spaceSubspace(str name, str superspace)
  ;

// ─── Operator Declaration ────────────────────────────────────────────────────
data OperatorDecl
  = operatorDecl(str name, TypeExpr typeExpr)
  ;

// TypeExpr models curried types: A -> B -> C
data TypeExpr
  = typeBase(str name)
  | typeArrow(str domain, TypeExpr codomain)
  ;

// ─── Variable Declaration ────────────────────────────────────────────────────
data VarDecl
  = varDecl(list[VarBinding] bindings)
  ;

data VarBinding
  = varBinding(str name, str domain)
  ;

// ─── Rule Declaration ────────────────────────────────────────────────────────
data RuleDecl
  = ruleDecl(OperatorApp lhs, OperatorApp rhs)
  ;

data OperatorApp
  = operatorApp(str operator, list[SimpleExpr] args)
  ;

// ─── Equation Declaration ────────────────────────────────────────────────────
data EquationDecl
  = equationDecl(Expr lhs, Expr rhs)
  ;

// ─── Expression Declaration ──────────────────────────────────────────────────
data ExpressionDecl
  = expressionDeclNoAttr(Expr expr)
  | expressionDeclAttr(Expr expr, AttrList attrs)
  ;

// ─── Expressions ─────────────────────────────────────────────────────────────
data Expr
  = quantifiedExpr(Quantifier quantifier, str variable, str domain, Expr body)
  | infixExpr(InfixExpr expr)
  ;

data Quantifier
  = forall()
  | exists()
  ;

data InfixExpr
  = infixSingle(SimpleExpr expr)
  | infixChain(SimpleExpr left, InfixOp op, InfixExpr right)
  ;

data SimpleExpr
  = simpleApp(OperatorApp app)
  | simpleParens(Expr expr)
  | simpleId(str name)
  ;

data InfixOp
  = opAnd()
  | opOr()
  | opNeg()
  | opEq()
  | opLt()
  | opGt()
  | opLte()
  | opGte()
  | opNeq()
  | opEquiv()
  | opImpl()
  | opArrow()
  | opPlus()
  | opMinus()
  | opMul()
  | opDiv()
  | opPow()
  | opMod()
  | opIn()
  ;

// ─── Attributes ──────────────────────────────────────────────────────────────
data AttrList
  = attrList(list[AttrItem] items)
  ;

data AttrItem
  = attrItemSimple(str name)
  | attrItemColon(str name, AttrValue value)
  ;

data AttrValue
  = attrValId(str name)
  | attrValEmpty()
  ;
