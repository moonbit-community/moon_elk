///|
pub struct InternalGraphvizDotParser {
  tokens : Array[GraphvizDotLexToken]
  grammar_access : GraphvizDotGrammarAccess
}

///|
pub fn new_internal_graphviz_dot_parser(
  tokens : Array[GraphvizDotLexToken],
  grammar_access? : GraphvizDotGrammarAccess = new_graphviz_dot_grammar_access(),
) -> InternalGraphvizDotParser {
  { tokens, grammar_access }
}

///|
pub fn InternalGraphvizDotParser::get_token_names(
  self : InternalGraphvizDotParser,
) -> Array[String] {
  ignore(self)
  graphviz_dot_lexer_token_names
}

///|
pub fn InternalGraphvizDotParser::get_grammar_file_name(
  self : InternalGraphvizDotParser,
) -> String {
  ignore(self)
  "InternalGraphvizDot.g"
}

///|
pub fn InternalGraphvizDotParser::get_first_rule_name(
  self : InternalGraphvizDotParser,
) -> String {
  ignore(self)
  "GraphvizModel"
}

///|
pub fn InternalGraphvizDotParser::get_grammar_access(
  self : InternalGraphvizDotParser,
) -> GraphvizDotGrammarAccess {
  self.grammar_access
}

///|
fn graphviz_dot_internal_parser_token_is_dot_id(
  token : GraphvizDotLexToken,
) -> Bool {
  token.token_type == graphviz_dot_lexer_rule_id ||
  token.token_type == graphviz_dot_lexer_rule_int ||
  token.token_type == graphviz_dot_lexer_rule_float ||
  token.token_type == graphviz_dot_lexer_rule_string ||
  token.token_type == graphviz_dot_lexer_rule_prec_line
}

///|
pub fn InternalGraphvizDotParser::entry_rule_graphviz_model(
  self : InternalGraphvizDotParser,
) -> DotGraphvizModel {
  self.rule_graphviz_model()
}

///|
pub fn InternalGraphvizDotParser::rule_graphviz_model(
  self : InternalGraphvizDotParser,
) -> DotGraphvizModel {
  let model = dot_create_graphviz_model()
  let mut index = 0
  while index < self.tokens.length() {
    let mut strict = false
    if self.tokens[index].lexeme == "strict" {
      strict = true
      index += 1
      if index >= self.tokens.length() {
        break
      }
    }
    let graph_type = if self.tokens[index].lexeme == "graph" {
      Some(dot_graph_type_graph())
    } else if self.tokens[index].lexeme == "digraph" {
      Some(dot_graph_type_digraph())
    } else {
      None
    }
    if graph_type is None {
      index += 1
      continue
    }
    let graph = dot_create_graph()
    graph.set_strict(strict)
    graph.set_type(graph_type)
    index += 1

    if index < self.tokens.length() &&
      graphviz_dot_internal_parser_token_is_dot_id(self.tokens[index]) &&
      self.tokens[index].lexeme != "{" {
      graph.set_name(Some(self.tokens[index].lexeme))
      index += 1
    }

    while index < self.tokens.length() && self.tokens[index].lexeme != "{" {
      index += 1
    }
    if index >= self.tokens.length() {
      model.get_graphs().push(graph)
      break
    }

    let mut depth = 0
    while index < self.tokens.length() {
      if self.tokens[index].lexeme == "{" {
        depth += 1
      } else if self.tokens[index].lexeme == "}" {
        depth -= 1
        if depth == 0 {
          index += 1
          break
        }
      }
      index += 1
    }
    model.get_graphs().push(graph)
  }
  model
}
