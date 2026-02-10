///|
pub let graphviz_dot_antlr_token_file_path : String = "org/eclipse/elk/alg/graphviz/dot/parser/antlr/internal/InternalGraphvizDot.tokens"

///|
pub let graphviz_dot_antlr_token_file_content : String = "'','=19\n" +
  "'--'=24\n" +
  "'->'=23\n" +
  "':'=21\n" +
  "';'=16\n" +
  "'='=17\n" +
  "'['=18\n" +
  "']'=20\n" +
  "'digraph'=26\n" +
  "'edge'=28\n" +
  "'graph'=25\n" +
  "'node'=27\n" +
  "'strict'=13\n" +
  "'subgraph'=22\n" +
  "'{'=14\n" +
  "'}'=15\n" +
  "RULE_ANY_OTHER=12\n" +
  "RULE_FLOAT=6\n" +
  "RULE_ID=4\n" +
  "RULE_INT=5\n" +
  "RULE_ML_COMMENT=9\n" +
  "RULE_PREC_LINE=8\n" +
  "RULE_SL_COMMENT=10\n" +
  "RULE_STRING=7\n" +
  "RULE_WS=11\n" +
  "T__13=13\n" +
  "T__14=14\n" +
  "T__15=15\n" +
  "T__16=16\n" +
  "T__17=17\n" +
  "T__18=18\n" +
  "T__19=19\n" +
  "T__20=20\n" +
  "T__21=21\n" +
  "T__22=22\n" +
  "T__23=23\n" +
  "T__24=24\n" +
  "T__25=25\n" +
  "T__26=26\n" +
  "T__27=27\n" +
  "T__28=28\n"

///|
pub struct GraphvizDotAntlrTokenFileProvider {
  marker : Unit
}

///|
pub fn new_graphviz_dot_antlr_token_file_provider() -> GraphvizDotAntlrTokenFileProvider {
  { marker: () }
}

///|
pub fn GraphvizDotAntlrTokenFileProvider::get_antlr_token_file_path(
  self : GraphvizDotAntlrTokenFileProvider,
) -> String {
  ignore(self)
  graphviz_dot_antlr_token_file_path
}

///|
pub fn GraphvizDotAntlrTokenFileProvider::get_antlr_token_file(
  self : GraphvizDotAntlrTokenFileProvider,
) -> String {
  ignore(self)
  graphviz_dot_antlr_token_file_content
}
