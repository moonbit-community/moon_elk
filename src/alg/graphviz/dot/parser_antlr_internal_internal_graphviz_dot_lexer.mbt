///|
pub let graphviz_dot_lexer_token_names : Array[String] = [
  "<invalid>", "<EOR>", "<DOWN>", "<UP>", "RULE_ID", "RULE_INT", "RULE_FLOAT", "RULE_STRING",
  "RULE_PREC_LINE", "RULE_ML_COMMENT", "RULE_SL_COMMENT", "RULE_WS", "RULE_ANY_OTHER",
  "'strict'", "'{'", "'}'", "';'", "'='", "'['", "','", "']'", "':'", "'subgraph'",
  "'->'", "'--'", "'graph'", "'digraph'", "'node'", "'edge'",
]

///|
pub let graphviz_dot_lexer_rule_id : Int = 4

///|
pub let graphviz_dot_lexer_rule_int : Int = 5

///|
pub let graphviz_dot_lexer_rule_float : Int = 6

///|
pub let graphviz_dot_lexer_rule_string : Int = 7

///|
pub let graphviz_dot_lexer_rule_prec_line : Int = 8

///|
pub let graphviz_dot_lexer_rule_ml_comment : Int = 9

///|
pub let graphviz_dot_lexer_rule_sl_comment : Int = 10

///|
pub let graphviz_dot_lexer_rule_ws : Int = 11

///|
pub let graphviz_dot_lexer_rule_any_other : Int = 12

///|
pub struct GraphvizDotLexToken {
  token_type : Int
  token_name : String
  lexeme : String
}

///|
pub fn new_graphviz_dot_lex_token(
  token_type : Int,
  token_name : String,
  lexeme : String,
) -> GraphvizDotLexToken {
  { token_type, token_name, lexeme }
}

///|
pub struct InternalGraphvizDotLexer {
  input : String
}

///|
pub fn new_internal_graphviz_dot_lexer(
  input : String,
) -> InternalGraphvizDotLexer {
  { input, }
}

///|
pub fn InternalGraphvizDotLexer::get_grammar_file_name(
  self : InternalGraphvizDotLexer,
) -> String {
  ignore(self)
  "InternalGraphvizDot.g"
}

///|
pub fn InternalGraphvizDotLexer::get_token_names(
  self : InternalGraphvizDotLexer,
) -> Array[String] {
  ignore(self)
  graphviz_dot_lexer_token_names
}

///|
fn graphviz_dot_lexer_is_id_start(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
}

///|
fn graphviz_dot_lexer_is_id_part(c : Char) -> Bool {
  graphviz_dot_lexer_is_id_start(c) || (c >= '0' && c <= '9')
}

///|
fn graphviz_dot_lexer_is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
fn graphviz_dot_lexer_keyword_token_type(lexeme : String) -> Int? {
  if lexeme == "strict" {
    Some(13)
  } else if lexeme == "subgraph" {
    Some(22)
  } else if lexeme == "graph" {
    Some(25)
  } else if lexeme == "digraph" {
    Some(26)
  } else if lexeme == "node" {
    Some(27)
  } else if lexeme == "edge" {
    Some(28)
  } else {
    None
  }
}

///|
fn graphviz_dot_lexer_symbol_token_type(lexeme : String) -> Int? {
  if lexeme == "{" {
    Some(14)
  } else if lexeme == "}" {
    Some(15)
  } else if lexeme == ";" {
    Some(16)
  } else if lexeme == "=" {
    Some(17)
  } else if lexeme == "[" {
    Some(18)
  } else if lexeme == "," {
    Some(19)
  } else if lexeme == "]" {
    Some(20)
  } else if lexeme == ":" {
    Some(21)
  } else if lexeme == "->" {
    Some(23)
  } else if lexeme == "--" {
    Some(24)
  } else {
    None
  }
}

///|
fn graphviz_dot_lexer_token_name(token_type : Int) -> String {
  if token_type >= 0 && token_type < graphviz_dot_lexer_token_names.length() {
    graphviz_dot_lexer_token_names[token_type]
  } else {
    "RULE_ANY_OTHER"
  }
}

///|
fn graphviz_dot_lexer_slice(text : String, start : Int, end_ : Int) -> String {
  text[start:end_].to_string()
}

///|
pub fn InternalGraphvizDotLexer::lex_all(
  self : InternalGraphvizDotLexer,
) -> Array[GraphvizDotLexToken] {
  let tokens : Array[GraphvizDotLexToken] = []
  let text = self.input
  let mut index = 0
  while index < text.length() {
    let ch = text[index].unsafe_to_char()
    if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' {
      index += 1
      continue
    }
    if ch == '/' && index + 1 < text.length() {
      let next = text[index + 1].unsafe_to_char()
      if next == '/' {
        index += 2
        while index < text.length() && text[index].unsafe_to_char() != '\n' {
          index += 1
        }
        continue
      }
    }
    if ch == '"' {
      let start = index
      index += 1
      while index < text.length() {
        let current = text[index].unsafe_to_char()
        if current == '"' {
          index += 1
          break
        }
        if current == '\\' && index + 1 < text.length() {
          index += 2
        } else {
          index += 1
        }
      }
      let lexeme = graphviz_dot_lexer_slice(text, start, index)
      tokens.push(
        new_graphviz_dot_lex_token(
          graphviz_dot_lexer_rule_string,
          graphviz_dot_lexer_token_name(graphviz_dot_lexer_rule_string),
          lexeme,
        ),
      )
      continue
    }
    if ch == '-' && index + 1 < text.length() {
      let next = text[index + 1].unsafe_to_char()
      if next == '>' || next == '-' {
        let lexeme = graphviz_dot_lexer_slice(text, index, index + 2)
        index += 2
        let token_type = match graphviz_dot_lexer_symbol_token_type(lexeme) {
          Some(value) => value
          None => graphviz_dot_lexer_rule_any_other
        }
        tokens.push(
          new_graphviz_dot_lex_token(
            token_type,
            graphviz_dot_lexer_token_name(token_type),
            lexeme,
          ),
        )
        continue
      }
    }
    if graphviz_dot_lexer_is_id_start(ch) {
      let start = index
      index += 1
      while index < text.length() &&
            graphviz_dot_lexer_is_id_part(text[index].unsafe_to_char()) {
        index += 1
      }
      let lexeme = graphviz_dot_lexer_slice(text, start, index)
      match graphviz_dot_lexer_keyword_token_type(lexeme) {
        Some(token_type) =>
          tokens.push(
            new_graphviz_dot_lex_token(
              token_type,
              graphviz_dot_lexer_token_name(token_type),
              lexeme,
            ),
          )
        None =>
          tokens.push(
            new_graphviz_dot_lex_token(
              graphviz_dot_lexer_rule_id,
              graphviz_dot_lexer_token_name(graphviz_dot_lexer_rule_id),
              lexeme,
            ),
          )
      }
      continue
    }
    if graphviz_dot_lexer_is_digit(ch) {
      let start = index
      let mut has_dot = false
      index += 1
      while index < text.length() {
        let current = text[index].unsafe_to_char()
        if graphviz_dot_lexer_is_digit(current) {
          index += 1
        } else if current == '.' && !has_dot {
          has_dot = true
          index += 1
        } else {
          break
        }
      }
      let lexeme = graphviz_dot_lexer_slice(text, start, index)
      let token_type = if has_dot {
        graphviz_dot_lexer_rule_float
      } else {
        graphviz_dot_lexer_rule_int
      }
      tokens.push(
        new_graphviz_dot_lex_token(
          token_type,
          graphviz_dot_lexer_token_name(token_type),
          lexeme,
        ),
      )
      continue
    }
    let symbol_lexeme = graphviz_dot_lexer_slice(text, index, index + 1)
    index += 1
    let token_type = match graphviz_dot_lexer_symbol_token_type(symbol_lexeme) {
      Some(value) => value
      None => graphviz_dot_lexer_rule_any_other
    }
    tokens.push(
      new_graphviz_dot_lex_token(
        token_type,
        graphviz_dot_lexer_token_name(token_type),
        symbol_lexeme,
      ),
    )
  }
  tokens
}
