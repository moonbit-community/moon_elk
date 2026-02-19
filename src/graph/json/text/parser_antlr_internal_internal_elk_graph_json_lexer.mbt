///|
pub let graph_json_text_lexer_token_names : Array[String] = [
  "<invalid>", "<EOR>", "<DOWN>", "<UP>", "RULE_ID", "RULE_STRING", "RULE_SIGNED_INT",
  "RULE_FLOAT", "RULE_INT", "RULE_ML_COMMENT", "RULE_SL_COMMENT", "RULE_WS", "RULE_ANY_OTHER",
  "'graph'", "'node'", "'{'", "'}'", "'label'", "':'", "'port'", "'layout'", "'['",
  "'position'", "','", "'size'", "']'", "'edge'", "'->'", "'incoming'", "'outgoing'",
  "'start'", "'end'", "'bends'", "'|'", "'section'", "'.'", "'null'", "'true'", "'false'",
]

///|
pub let graph_json_text_lexer_rule_id : Int = 4

///|
pub let graph_json_text_lexer_rule_string : Int = 5

///|
pub let graph_json_text_lexer_rule_signed_int : Int = 6

///|
pub let graph_json_text_lexer_rule_float : Int = 7

///|
pub let graph_json_text_lexer_rule_int : Int = 8

///|
pub let graph_json_text_lexer_rule_ml_comment : Int = 9

///|
pub let graph_json_text_lexer_rule_sl_comment : Int = 10

///|
pub let graph_json_text_lexer_rule_ws : Int = 11

///|
pub let graph_json_text_lexer_rule_any_other : Int = 12

///|
pub struct ElkGraphJsonLexToken {
  token_type : Int
  token_name : String
  lexeme : String
}

///|
pub fn new_elk_graph_json_lex_token(
  token_type : Int,
  token_name : String,
  lexeme : String,
) -> ElkGraphJsonLexToken {
  { token_type, token_name, lexeme }
}

///|
pub struct InternalElkGraphJsonLexer {
  input : String
}

///|
pub fn new_internal_elk_graph_json_lexer(
  input : String,
) -> InternalElkGraphJsonLexer {
  { input, }
}

///|
pub fn InternalElkGraphJsonLexer::get_grammar_file_name(
  self : InternalElkGraphJsonLexer,
) -> String {
  ignore(self)
  "InternalElkGraphJson.g"
}

///|
pub fn InternalElkGraphJsonLexer::get_token_names(
  self : InternalElkGraphJsonLexer,
) -> Array[String] {
  ignore(self)
  graph_json_text_lexer_token_names
}

///|
fn graph_json_text_lexer_token_name(token_type : Int) -> String {
  if token_type >= 0 && token_type < graph_json_text_lexer_token_names.length() {
    graph_json_text_lexer_token_names[token_type]
  } else {
    "RULE_ANY_OTHER"
  }
}

///|
fn graph_json_text_lexer_is_id_start(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'
}

///|
fn graph_json_text_lexer_is_id_part(ch : Char) -> Bool {
  graph_json_text_lexer_is_id_start(ch) || (ch >= '0' && ch <= '9')
}

///|
fn graph_json_text_lexer_is_digit(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}

///|
fn graph_json_text_lexer_keyword_token_type(lexeme : String) -> Int? {
  if lexeme == "graph" {
    Some(13)
  } else if lexeme == "node" {
    Some(14)
  } else if lexeme == "label" {
    Some(17)
  } else if lexeme == "port" {
    Some(19)
  } else if lexeme == "layout" {
    Some(20)
  } else if lexeme == "position" {
    Some(22)
  } else if lexeme == "size" {
    Some(24)
  } else if lexeme == "edge" {
    Some(26)
  } else if lexeme == "incoming" {
    Some(28)
  } else if lexeme == "outgoing" {
    Some(29)
  } else if lexeme == "start" {
    Some(30)
  } else if lexeme == "end" {
    Some(31)
  } else if lexeme == "bends" {
    Some(32)
  } else if lexeme == "section" {
    Some(34)
  } else if lexeme == "null" {
    Some(36)
  } else if lexeme == "true" {
    Some(37)
  } else if lexeme == "false" {
    Some(38)
  } else {
    None
  }
}

///|
fn graph_json_text_lexer_symbol_token_type(lexeme : String) -> Int? {
  if lexeme == "{" {
    Some(15)
  } else if lexeme == "}" {
    Some(16)
  } else if lexeme == ":" {
    Some(18)
  } else if lexeme == "[" {
    Some(21)
  } else if lexeme == "," {
    Some(23)
  } else if lexeme == "]" {
    Some(25)
  } else if lexeme == "->" {
    Some(27)
  } else if lexeme == "|" {
    Some(33)
  } else if lexeme == "." {
    Some(35)
  } else {
    None
  }
}

///|
fn graph_json_text_lexer_scan_number(
  text : String,
  start : Int,
) -> (Int, Bool)? {
  let mut index = start
  if index < text.length() {
    let sign = text[index].unsafe_to_char()
    if sign == '+' || sign == '-' {
      index += 1
    }
  }
  let mut digit_count = 0
  while index < text.length() &&
        graph_json_text_lexer_is_digit(text[index].unsafe_to_char()) {
    digit_count += 1
    index += 1
  }
  if digit_count == 0 {
    return None
  }
  let mut has_dot = false
  let mut has_exp = false
  if index + 1 < text.length() &&
    text[index].unsafe_to_char() == '.' &&
    graph_json_text_lexer_is_digit(text[index + 1].unsafe_to_char()) {
    has_dot = true
    index += 1
    while index < text.length() &&
          graph_json_text_lexer_is_digit(text[index].unsafe_to_char()) {
      index += 1
    }
  }
  if index < text.length() {
    let ch = text[index].unsafe_to_char()
    if ch == 'e' || ch == 'E' {
      let mut exp_index = index + 1
      if exp_index < text.length() {
        let sign = text[exp_index].unsafe_to_char()
        if sign == '+' || sign == '-' {
          exp_index += 1
        }
      }
      let mut exp_digits = 0
      while exp_index < text.length() &&
            graph_json_text_lexer_is_digit(text[exp_index].unsafe_to_char()) {
        exp_digits += 1
        exp_index += 1
      }
      if exp_digits > 0 {
        has_exp = true
        index = exp_index
      }
    }
  }
  Some((index, has_dot || has_exp))
}

///|
pub fn InternalElkGraphJsonLexer::lex_all(
  self : InternalElkGraphJsonLexer,
) -> Array[ElkGraphJsonLexToken] {
  let tokens : Array[ElkGraphJsonLexToken] = []
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
      if next == '*' {
        index += 2
        while index + 1 < text.length() {
          if text[index].unsafe_to_char() == '*' &&
            text[index + 1].unsafe_to_char() == '/' {
            index += 2
            break
          }
          index += 1
        }
        continue
      }
    }
    if ch == '"' || ch == '\'' {
      let quote = ch
      let start = index
      index += 1
      while index < text.length() {
        let current = text[index].unsafe_to_char()
        if current == quote {
          index += 1
          break
        }
        if current == '\\' && index + 1 < text.length() {
          index += 2
        } else {
          index += 1
        }
      }
      let lexeme = text.unsafe_substring(start~, end=index)
      tokens.push(
        new_elk_graph_json_lex_token(
          graph_json_text_lexer_rule_string,
          graph_json_text_lexer_token_name(graph_json_text_lexer_rule_string),
          lexeme,
        ),
      )
      continue
    }
    if ch == '-' &&
      index + 1 < text.length() &&
      text[index + 1].unsafe_to_char() == '>' {
      let lexeme = "->"
      let token_type = 27
      tokens.push(
        new_elk_graph_json_lex_token(
          token_type,
          graph_json_text_lexer_token_name(token_type),
          lexeme,
        ),
      )
      index += 2
      continue
    }
    let maybe_number = graph_json_text_lexer_is_digit(ch) ||
      (
        (ch == '+' || ch == '-') &&
        index + 1 < text.length() &&
        graph_json_text_lexer_is_digit(text[index + 1].unsafe_to_char())
      )
    if maybe_number {
      match graph_json_text_lexer_scan_number(text, index) {
        Some((end_index, is_float)) => {
          let lexeme = text.unsafe_substring(start=index, end=end_index)
          let token_type = if is_float {
            graph_json_text_lexer_rule_float
          } else {
            graph_json_text_lexer_rule_signed_int
          }
          tokens.push(
            new_elk_graph_json_lex_token(
              token_type,
              graph_json_text_lexer_token_name(token_type),
              lexeme,
            ),
          )
          index = end_index
          continue
        }
        None => ()
      }
    }
    if graph_json_text_lexer_is_id_start(ch) || ch == '^' {
      let start = index
      if ch == '^' {
        index += 1
      }
      if index < text.length() &&
        graph_json_text_lexer_is_id_start(text[index].unsafe_to_char()) {
        index += 1
        while index < text.length() &&
              graph_json_text_lexer_is_id_part(text[index].unsafe_to_char()) {
          index += 1
        }
        let lexeme = text.unsafe_substring(start~, end=index)
        match graph_json_text_lexer_keyword_token_type(lexeme) {
          Some(token_type) =>
            tokens.push(
              new_elk_graph_json_lex_token(
                token_type,
                graph_json_text_lexer_token_name(token_type),
                lexeme,
              ),
            )
          None =>
            tokens.push(
              new_elk_graph_json_lex_token(
                graph_json_text_lexer_rule_id,
                graph_json_text_lexer_token_name(graph_json_text_lexer_rule_id),
                lexeme,
              ),
            )
        }
        continue
      } else {
        index = start
      }
    }
    let symbol_lexeme = text.unsafe_substring(start=index, end=index + 1)
    index += 1
    let token_type = match
      graph_json_text_lexer_symbol_token_type(symbol_lexeme) {
      Some(value) => value
      None => graph_json_text_lexer_rule_any_other
    }
    tokens.push(
      new_elk_graph_json_lex_token(
        token_type,
        graph_json_text_lexer_token_name(token_type),
        symbol_lexeme,
      ),
    )
  }
  tokens
}
