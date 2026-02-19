///|
fn graphviz_dot_generated_test_string_or_none(value : String?) -> String {
  match value {
    Some(result) => result
    None => "none"
  }
}

///|
fn graphviz_dot_generated_test_contains(
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
test "AbstractGraphvizDotRuntimeModule exposes generated bindings" {
  let runtime_module = new_abstract_graphviz_dot_runtime_module()
  inspect(
    runtime_module.configure_language_name(),
    content="org.eclipse.elk.alg.graphviz.dot.GraphvizDot",
  )
  inspect(runtime_module.configure_file_extensions(), content="graphviz_dot")
  inspect(
    runtime_module.bind_igrammar_access(),
    content="org.eclipse.elk.alg.graphviz.dot.services.GraphvizDotGrammarAccess",
  )
  inspect(
    runtime_module.bind_iparser(),
    content="org.eclipse.elk.alg.graphviz.dot.parser.antlr.GraphvizDotParser",
  )
  inspect(
    runtime_module.bind_iantlr_token_file_provider(),
    content="org.eclipse.elk.alg.graphviz.dot.parser.antlr.GraphvizDotAntlrTokenFileProvider",
  )
  inspect(
    runtime_module.bind_lexer(),
    content="org.eclipse.elk.alg.graphviz.dot.parser.antlr.internal.InternalGraphvizDotLexer",
  )
  inspect(
    runtime_module.provide_internal_graphviz_dot_lexer(),
    content="org.eclipse.elk.alg.graphviz.dot.parser.antlr.internal.InternalGraphvizDotLexer",
  )
  inspect(
    runtime_module.configure_runtime_lexer(),
    content="org.eclipse.elk.alg.graphviz.dot.parser.antlr.internal.InternalGraphvizDotLexer",
  )
  inspect(
    runtime_module.configure_formatter_preferences(),
    content="org.eclipse.xtext.formatting2.FormatterPreferenceValuesProvider",
  )
  let properties : Map[String, String] = {}
  properties["fileExtensions"] = "dot"
  runtime_module.configure(properties)
  inspect(runtime_module.configure_file_extensions(), content="dot")
}

///|
test "GraphvizDotGrammarAccess exposes core generated rules" {
  let grammar_access = new_graphviz_dot_grammar_access()
  inspect(
    grammar_access.get_grammar(),
    content="org.eclipse.elk.alg.graphviz.dot.GraphvizDot",
  )
  inspect(grammar_access.get_graphviz_model_rule(), content="graphs+=Graph*")
  inspect(
    grammar_access.get_graph_rule(),
    content="strict? type=GraphType name=DotID? '{' statements+=Statement* '}'",
  )
  let rule_names = grammar_access.get_rule_names()
  inspect(
    rule_names.length(),
    content=(
      #|16
    ),
  )
  inspect(
    graphviz_dot_generated_test_contains(rule_names, "EdgeOperator"),
    content="true",
  )
}

///|
test "GraphvizDotAntlrTokenFileProvider returns generated token file data" {
  let provider = new_graphviz_dot_antlr_token_file_provider()
  inspect(
    provider.get_antlr_token_file_path(),
    content="org/eclipse/elk/alg/graphviz/dot/parser/antlr/internal/InternalGraphvizDot.tokens",
  )
  inspect(provider.get_antlr_token_file().contains("RULE_ID=4"), content="true")
  inspect(provider.get_antlr_token_file().contains("T__28=28"), content="true")
}

///|
test "InternalGraphvizDotLexer tokenizes generated terminal set" {
  let lexer = new_internal_graphviz_dot_lexer("strict digraph G { a -> b; }")
  let tokens = lexer.lex_all()
  inspect(lexer.get_grammar_file_name(), content="InternalGraphvizDot.g")
  inspect(tokens.length(), content="9")
  inspect(tokens[0].token_name, content="'strict'")
  inspect(tokens[1].token_name, content="'digraph'")
  inspect(tokens[2].token_name, content="RULE_ID")
  inspect(tokens[5].token_name, content="'->'")
  inspect(tokens[7].token_name, content="';'")
  inspect(tokens[8].token_name, content="'}'")
}

///|
test "InternalGraphvizDotParser parses top-level graph headers" {
  let lexer = new_internal_graphviz_dot_lexer("strict digraph G { a -> b; }")
  let parser = new_internal_graphviz_dot_parser(lexer.lex_all())
  let model = parser.entry_rule_graphviz_model()
  inspect(parser.get_grammar_file_name(), content="InternalGraphvizDot.g")
  inspect(parser.get_first_rule_name(), content="GraphvizModel")
  inspect(model.get_graphs().length(), content="1")
  let graph = model.get_graphs()[0]
  inspect(graph.is_strict(), content="true")
  inspect(dot_graph_type_name(graph.get_type()), content="digraph")
  inspect(
    graphviz_dot_generated_test_string_or_none(graph.get_name()),
    content="G",
  )
}

///|
test "GraphvizDotParser wires lexer and parser generated classes" {
  let parser = new_graphviz_dot_parser()
  inspect(parser.get_default_rule_name(), content="GraphvizModel")
  inspect(parser.get_initial_hidden_tokens().length(), content="4")
  let model = parser.parse("graph demo { }")
  inspect(model.get_graphs().length(), content="1")
  inspect(
    graphviz_dot_generated_test_string_or_none(model.get_graphs()[0].get_name()),
    content="demo",
  )
  inspect(
    dot_graph_type_name(model.get_graphs()[0].get_type()),
    content="graph",
  )
}
