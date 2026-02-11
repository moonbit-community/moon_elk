///|
pub let graph_json_text_antlr_token_file_path : String = "org/eclipse/elk/graph/json/text/parser/antlr/internal/InternalElkGraphJson.tokens"

///|
pub let graph_json_text_antlr_token_file_content : String = "',=23\n'->'=27\n'.'=35\n':'=18\n'['=21\n']'=25\n'bends'=32\n'edge'=26\n'end'=31\n'false'=38\n'graph'=13\n'incoming'=28\n'label'=17\n'layout'=20\n'node'=14\n'null'=36\n'outgoing'=29\n'port'=19\n'position'=22\n'section'=34\n'size'=24\n'start'=30\n'true'=37\n'{'=15\n'|'=33\n'}'=16\nRULE_ANY_OTHER=12\nRULE_FLOAT=7\nRULE_ID=5\nRULE_INT=8\nRULE_ML_COMMENT=9\nRULE_SIGNED_INT=6\nRULE_SL_COMMENT=10\nRULE_STRING=4\nRULE_WS=11\nT__13=13\nT__14=14\nT__15=15\nT__16=16\nT__17=17\nT__18=18\nT__19=19\nT__20=20\nT__21=21\nT__22=22\nT__23=23\nT__24=24\nT__25=25\nT__26=26\nT__27=27\nT__28=28\nT__29=29\nT__30=30\nT__31=31\nT__32=32\nT__33=33\nT__34=34\nT__35=35\nT__36=36\nT__37=37\nT__38=38\n"

///|
pub struct ElkGraphJsonAntlrTokenFileProvider {
  marker : Unit
}

///|
pub fn new_elk_graph_json_antlr_token_file_provider() -> ElkGraphJsonAntlrTokenFileProvider {
  { marker: () }
}

///|
pub fn ElkGraphJsonAntlrTokenFileProvider::get_antlr_token_file_path(
  self : ElkGraphJsonAntlrTokenFileProvider,
) -> String {
  ignore(self)
  graph_json_text_antlr_token_file_path
}

///|
pub fn ElkGraphJsonAntlrTokenFileProvider::get_antlr_token_file(
  self : ElkGraphJsonAntlrTokenFileProvider,
) -> String {
  ignore(self)
  graph_json_text_antlr_token_file_content
}
