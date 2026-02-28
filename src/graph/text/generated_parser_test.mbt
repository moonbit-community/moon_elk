///|
fn graph_text_generated_test_contains(
  values : Array[String],
  target : String,
) -> Bool {
  for value in values {
    if value == target {
      return true
    }
  }
  false
}

///|
test "AbstractElkGraphRuntimeModule exposes generated bindings" {
  let runtime_module = new_abstract_elk_graph_runtime_module()
  inspect(
    runtime_module.configure_language_name(),
    content="org.eclipse.elk.graph.text.ElkGraph",
  )
  inspect(runtime_module.configure_file_extensions(), content="elkt")
  inspect(
    runtime_module.bind_igrammar_access(),
    content="org.eclipse.elk.graph.text.services.ElkGraphGrammarAccess",
  )
  inspect(
    runtime_module.bind_iparser(),
    content="org.eclipse.elk.graph.text.parser.antlr.ElkGraphParser",
  )
  inspect(
    runtime_module.bind_iantlr_token_file_provider(),
    content="org.eclipse.elk.graph.text.parser.antlr.ElkGraphAntlrTokenFileProvider",
  )
  inspect(
    runtime_module.bind_lexer(),
    content="org.eclipse.elk.graph.text.parser.antlr.internal.InternalElkGraphLexer",
  )

  let properties : Map[String, String] = {}
  properties["fileExtensions"] = "txt"
  runtime_module.configure(properties)
  inspect(runtime_module.configure_file_extensions(), content="txt")
}

///|
test "ElkGraphGrammarAccess exposes generated grammar rules" {
  let grammar_access = new_elk_graph_grammar_access()
  inspect(
    grammar_access.get_grammar(),
    content="org.eclipse.elk.graph.text.ElkGraph",
  )
  inspect(
    grammar_access.get_root_node_rule().contains("'graph'"),
    content="true",
  )
  inspect(grammar_access.get_elk_edge_rule().contains("'edge'"), content="true")
  let rule_names = grammar_access.get_rule_names()
  inspect(
    graph_text_generated_test_contains(rule_names, "ElkNode"),
    content="true",
  )
  inspect(
    graph_text_generated_test_contains(rule_names, "PropertyKey"),
    content="true",
  )
}

///|
test "ElkGraphAntlrTokenFileProvider returns generated token file data" {
  let provider = new_elk_graph_antlr_token_file_provider()
  inspect(
    provider.get_antlr_token_file_path(),
    content="org/eclipse/elk/graph/text/parser/antlr/internal/InternalElkGraph.tokens",
  )
  inspect(provider.get_antlr_token_file().contains("RULE_ID=4"), content="true")
  inspect(
    provider.get_antlr_token_file().contains("'graph'=13"),
    content="true",
  )
}

///|
test "InternalElkGraphLexer tokenizes generated terminal set" {
  let lexer = new_internal_elk_graph_lexer(
    "graph root node a { } edge a -> a { }",
  )
  let tokens = lexer.lex_all()
  inspect(lexer.get_grammar_file_name(), content="InternalElkGraph.g")
  inspect(tokens.length() > 10, content="true")
  inspect(tokens[0].token_name, content="'graph'")
  inspect(tokens[1].token_name, content="RULE_ID")
  inspect(tokens[2].token_name, content="'node'")
  inspect(tokens[6].token_name, content="'edge'")
}

///|
test "InternalElkGraphParser parses root node with children and edge sections" {
  @graph.reset_graph_model_for_test()
  let text = "graph root node a { layout [position: 10, 20] } node b { } edge e: a -> b { layout [ section s1 [ start: 0, 0 end: 5, 5 ] ] }"
  let lexer = new_internal_elk_graph_lexer(text)
  let parser = new_internal_elk_graph_parser(lexer.lex_all())
  let root = parser.entry_rule_root_node()

  inspect(parser.get_grammar_file_name(), content="InternalElkGraph.g")
  inspect(parser.get_first_rule_name(), content="RootNode")
  inspect(@graph.node_identifier(root), content="root")
  inspect(@graph.node_children(root).length(), content="2")
  inspect(@graph.node_contained_edges(root).length(), content="1")
  let edge = @graph.node_contained_edges(root)[0]
  inspect(@graph.edge_identifier(edge), content="e")
  inspect(@graph.edge_sections(edge).length(), content="1")
  inspect(
    @graph.edge_section_identifier(@graph.edge_sections(edge)[0]),
    content="s1",
  )
}

///|
test "ElkGraphParser wires lexer and internal parser" {
  @graph.reset_graph_model_for_test()
  let parser = new_elk_graph_parser()
  inspect(parser.get_default_rule_name(), content="RootNode")
  inspect(parser.get_initial_hidden_tokens().length(), content="3")
  let root = parser.parse(
    "graph demo node n1 { layout [size: 30, 40] } edge n1 -> n1 { }",
  )
  inspect(@graph.node_identifier(root), content="demo")
  inspect(@graph.node_children(root).length(), content="1")
  inspect(@graph.node_contained_edges(root).length(), content="1")
}
