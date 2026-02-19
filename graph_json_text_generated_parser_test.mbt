///|
fn graph_json_text_generated_test_contains(
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
test "AbstractElkGraphJsonRuntimeModule exposes generated bindings" {
  let runtime_module = new_abstract_elk_graph_json_runtime_module()
  inspect(
    runtime_module.configure_language_name(),
    content="org.eclipse.elk.graph.json.text.ElkGraphJson",
  )
  inspect(runtime_module.configure_file_extensions(), content="elkj")
  inspect(
    runtime_module.bind_igrammar_access(),
    content="org.eclipse.elk.graph.json.text.services.ElkGraphJsonGrammarAccess",
  )
  inspect(
    runtime_module.bind_iparser(),
    content="org.eclipse.elk.graph.json.text.parser.antlr.ElkGraphJsonParser",
  )
  inspect(
    runtime_module.bind_iantlr_token_file_provider(),
    content="org.eclipse.elk.graph.json.text.parser.antlr.ElkGraphJsonAntlrTokenFileProvider",
  )
  inspect(
    runtime_module.bind_lexer(),
    content="org.eclipse.elk.graph.json.text.parser.antlr.internal.InternalElkGraphJsonLexer",
  )

  let properties : Map[String, String] = {}
  properties["fileExtensions"] = "json"
  runtime_module.configure(properties)
  inspect(runtime_module.configure_file_extensions(), content="json")
}

///|
test "ElkGraphJsonGrammarAccess exposes generated grammar rules" {
  let grammar_access = new_elk_graph_json_grammar_access()
  inspect(
    grammar_access.get_grammar(),
    content="org.eclipse.elk.graph.json.text.ElkGraphJson",
  )
  inspect(
    graph_json_text_generated_test_contains(
      grammar_access.get_rule_names(),
      "ElkNode",
    ),
    content="true",
  )
  inspect(
    graph_json_text_generated_test_contains(
      grammar_access.get_rule_names(),
      "PropertyKey",
    ),
    content="true",
  )
  inspect(
    graph_json_text_generated_test_contains(
      grammar_access.get_rule_names(),
      "JsonObject",
    ),
    content="true",
  )
  inspect(
    grammar_access.get_elk_node_rule().contains("children"),
    content="true",
  )
}

///|
test "ElkGraphJsonAntlrTokenFileProvider returns generated token file data" {
  let provider = new_elk_graph_json_antlr_token_file_provider()
  inspect(
    provider.get_antlr_token_file_path(),
    content="org/eclipse/elk/graph/json/text/parser/antlr/internal/InternalElkGraphJson.tokens",
  )
  let token_file = provider.get_antlr_token_file()
  inspect(token_file.contains("RULE_STRING=4"), content="true")
  inspect(token_file.contains("RULE_ID=5"), content="true")
}

///|
test "InternalElkGraphJsonLexer tokenizes generated terminal set" {
  let lexer = new_internal_elk_graph_json_lexer(
    "{\"id\":\"root\",\"children\":[{\"id\":\"n\"}],\"layoutOptions\":{\"org.eclipse.elk.algorithm\":\"org.eclipse.elk.layered\"}}",
  )
  let tokens = lexer.lex_all()
  inspect(lexer.get_grammar_file_name(), content="InternalElkGraphJson.g")
  inspect(tokens.length() > 10, content="true")
  inspect(tokens[0].lexeme, content="{")
  inspect(tokens[1].token_name, content="RULE_STRING")
}

///|
test "InternalElkGraphJsonParser parses node graph from json text" {
  reset_graph_model_for_test()
  let text = "{\"id\":\"root\",\"children\":[{\"id\":\"n1\"}],\"edges\":[{\"id\":\"e1\",\"sources\":[\"n1\"],\"targets\":[\"n1\"]}]}"
  let lexer = new_internal_elk_graph_json_lexer(text)
  let parser = new_internal_elk_graph_json_parser(lexer.lex_all())
  let root = parser.entry_rule_elk_node()

  inspect(parser.get_grammar_file_name(), content="InternalElkGraphJson.g")
  inspect(parser.get_first_rule_name(), content="ElkNode")
  inspect(node_identifier(root), content="root")
  inspect(node_children(root).length(), content="1")
  inspect(node_contained_edges(root).length(), content="1")
  inspect(edge_identifier(node_contained_edges(root)[0]), content="e1")
}

///|
test "ElkGraphJsonParser wires lexer and internal parser" {
  reset_graph_model_for_test()
  let parser = new_elk_graph_json_parser()
  inspect(parser.get_default_rule_name(), content="ElkNode")
  inspect(parser.get_initial_hidden_tokens().length(), content="3")
  let root = parser.parse(
    "{\"id\":\"demo\",\"children\":[{\"id\":\"n1\"}],\"edges\":[{\"id\":\"e\",\"sources\":[\"n1\"],\"targets\":[\"n1\"]}]}",
  )
  inspect(node_identifier(root), content="demo")
  inspect(node_children(root).length(), content="1")
  inspect(node_contained_edges(root).length(), content="1")
}
