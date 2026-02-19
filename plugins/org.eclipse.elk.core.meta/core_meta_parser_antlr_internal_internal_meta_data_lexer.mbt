///|
pub let core_meta_lexer_rule_string : Int = 4

///|
pub let core_meta_lexer_rule_id : Int = 5

///|
pub let core_meta_lexer_rule_int : Int = 7

///|
pub let core_meta_lexer_rule_ml_comment : Int = 9

///|
pub let core_meta_lexer_rule_sl_comment : Int = 10

///|
pub let core_meta_lexer_rule_ws : Int = 11

///|
pub let core_meta_lexer_rule_any_other : Int = 12

///|
pub struct CoreMetaLexToken {
  token_type : Int
  token_name : String
  lexeme : String
}

///|
pub fn new_core_meta_lex_token(
  token_type : Int,
  token_name : String,
  lexeme : String,
) -> CoreMetaLexToken {
  { token_type, token_name, lexeme }
}

///|
pub struct InternalMetaDataLexer {
  input : String
}

///|
pub fn new_internal_meta_data_lexer(input : String) -> InternalMetaDataLexer {
  { input, }
}

///|
pub fn InternalMetaDataLexer::get_grammar_file_name(
  self : InternalMetaDataLexer,
) -> String {
  ignore(self)
  "InternalMetaData.g"
}

///|
pub fn InternalMetaDataLexer::get_token_names(
  self : InternalMetaDataLexer,
) -> Array[String] {
  ignore(self)
  [
    "<invalid>", "<EOR>", "<DOWN>", "<UP>", "RULE_STRING", "RULE_ID", "RULE_HEX",
    "RULE_INT", "RULE_DECIMAL", "RULE_ML_COMMENT", "RULE_SL_COMMENT", "RULE_WS",
    "RULE_ANY_OTHER", "'package'", "'bundle'", "'{'", "'label'", "'metadataClass'",
    "'documentationFolder'", "'idPrefix'", "'}'", "'group'", "'documentation'", "'deprecated'",
    "'advanced'", "'programmatic'", "'output'", "'global'", "'option'", "':'", "'description'",
    "'default'", "'='", "'lowerBound'", "'upperBound'", "'targets'", "','", "'legacyIds'",
    "'requires'", "'=='", "'algorithm'", "'('", "'#'", "')'", "'category'", "'preview'",
    "'features'", "'validator'", "'supports'", "'/'", "'-'", "'+='", "'-='", "'*='",
    "'/='", "'%='", "'<'", "'>'", "'>='", "'||'", "'&&'", "'!='", "'==='", "'!=='",
    "'instanceof'", "'->'", "'..<'", "'..'", "'=>'", "'<>'", "'?:'", "'+'", "'*'",
    "'**'", "'%'", "'!'", "'as'", "'++'", "'--'", "'.'", "'::'", "'?.'", "'['", "']'",
    "'|'", "';'", "'if'", "'else'", "'switch'", "'case'", "'for'", "'while'", "'do'",
    "'var'", "'val'", "'extends'", "'static'", "'import'", "'extension'", "'super'",
    "'new'", "'false'", "'true'", "'null'", "'typeof'", "'throw'", "'return'", "'try'",
    "'finally'", "'synchronized'", "'catch'", "'?'", "'&'", "'parents'", "'nodes'",
    "'edges'", "'ports'", "'labels'", "'self_loops'", "'inside_self_loops'", "'multi_edges'",
    "'edge_labels'", "'compound'", "'clusters'", "'disconnected'",
  ]
}

///|
fn core_meta_lexer_is_id_start(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
}

///|
fn core_meta_lexer_is_id_part(c : Char) -> Bool {
  core_meta_lexer_is_id_start(c) || (c >= '0' && c <= '9')
}

///|
fn core_meta_lexer_is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
fn core_meta_lexer_keyword_token_type(lexeme : String) -> Int? {
  if lexeme == "package" {
    Some(13)
  } else if lexeme == "bundle" {
    Some(14)
  } else if lexeme == "label" {
    Some(16)
  } else if lexeme == "metadataClass" {
    Some(17)
  } else if lexeme == "documentationFolder" {
    Some(18)
  } else if lexeme == "idPrefix" {
    Some(19)
  } else if lexeme == "group" {
    Some(21)
  } else if lexeme == "documentation" {
    Some(22)
  } else if lexeme == "deprecated" {
    Some(23)
  } else if lexeme == "advanced" {
    Some(24)
  } else if lexeme == "programmatic" {
    Some(25)
  } else if lexeme == "output" {
    Some(26)
  } else if lexeme == "global" {
    Some(27)
  } else if lexeme == "option" {
    Some(28)
  } else if lexeme == "description" {
    Some(30)
  } else if lexeme == "default" {
    Some(31)
  } else if lexeme == "lowerBound" {
    Some(33)
  } else if lexeme == "upperBound" {
    Some(34)
  } else if lexeme == "targets" {
    Some(35)
  } else if lexeme == "legacyIds" {
    Some(37)
  } else if lexeme == "requires" {
    Some(38)
  } else if lexeme == "algorithm" {
    Some(40)
  } else if lexeme == "category" {
    Some(44)
  } else if lexeme == "preview" {
    Some(45)
  } else if lexeme == "features" {
    Some(46)
  } else if lexeme == "validator" {
    Some(47)
  } else if lexeme == "supports" {
    Some(48)
  } else if lexeme == "import" {
    Some(97)
  } else if lexeme == "parents" {
    Some(113)
  } else if lexeme == "nodes" {
    Some(114)
  } else if lexeme == "edges" {
    Some(115)
  } else if lexeme == "ports" {
    Some(116)
  } else if lexeme == "labels" {
    Some(117)
  } else if lexeme == "self_loops" {
    Some(118)
  } else if lexeme == "inside_self_loops" {
    Some(119)
  } else if lexeme == "multi_edges" {
    Some(120)
  } else if lexeme == "edge_labels" {
    Some(121)
  } else if lexeme == "compound" {
    Some(122)
  } else if lexeme == "clusters" {
    Some(123)
  } else if lexeme == "disconnected" {
    Some(124)
  } else {
    None
  }
}

///|
fn core_meta_lexer_symbol_token_type(lexeme : String) -> Int? {
  if lexeme == "{" {
    Some(15)
  } else if lexeme == "}" {
    Some(20)
  } else if lexeme == ":" {
    Some(29)
  } else if lexeme == "," {
    Some(36)
  } else if lexeme == "=" {
    Some(32)
  } else if lexeme == "==" {
    Some(39)
  } else if lexeme == "(" {
    Some(41)
  } else if lexeme == "#" {
    Some(42)
  } else if lexeme == ")" {
    Some(43)
  } else if lexeme == "/" {
    Some(49)
  } else if lexeme == "-" {
    Some(50)
  } else if lexeme == "." {
    Some(79)
  } else if lexeme == "[" {
    Some(82)
  } else if lexeme == "]" {
    Some(83)
  } else if lexeme == ";" {
    Some(85)
  } else {
    None
  }
}

///|
fn core_meta_lexer_token_name(token_type : Int) -> String {
  if token_type == core_meta_lexer_rule_string {
    "RULE_STRING"
  } else if token_type == core_meta_lexer_rule_id {
    "RULE_ID"
  } else if token_type == core_meta_lexer_rule_int {
    "RULE_INT"
  } else if token_type == core_meta_lexer_rule_ml_comment {
    "RULE_ML_COMMENT"
  } else if token_type == core_meta_lexer_rule_sl_comment {
    "RULE_SL_COMMENT"
  } else if token_type == core_meta_lexer_rule_ws {
    "RULE_WS"
  } else if token_type == core_meta_lexer_rule_any_other {
    "RULE_ANY_OTHER"
  } else {
    let token_names = new_internal_meta_data_lexer("").get_token_names()
    if token_type >= 0 && token_type < token_names.length() {
      token_names[token_type]
    } else {
      "RULE_ANY_OTHER"
    }
  }
}

///|
fn core_meta_lexer_push_symbol_token(
  tokens : Array[CoreMetaLexToken],
  lexeme : String,
) -> Unit {
  let token_type = match core_meta_lexer_symbol_token_type(lexeme) {
    Some(value) => value
    None => core_meta_lexer_rule_any_other
  }
  tokens.push(
    new_core_meta_lex_token(
      token_type,
      core_meta_lexer_token_name(token_type),
      lexeme,
    ),
  )
}

///|
pub fn InternalMetaDataLexer::lex_all(
  self : InternalMetaDataLexer,
) -> Array[CoreMetaLexToken] {
  let tokens : Array[CoreMetaLexToken] = []
  let text = self.input
  let mut index = 0
  while index < text.length() {
    let ch = text[index].unsafe_to_char()

    if ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n' {
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
      let lexeme = text.substring(start~, end=index)
      tokens.push(
        new_core_meta_lex_token(
          core_meta_lexer_rule_string,
          core_meta_lexer_token_name(core_meta_lexer_rule_string),
          lexeme,
        ),
      )
      continue
    }

    if ch == '=' &&
      index + 1 < text.length() &&
      text[index + 1].unsafe_to_char() == '=' {
      core_meta_lexer_push_symbol_token(tokens, "==")
      index += 2
      continue
    }

    if core_meta_lexer_is_id_start(ch) {
      let start = index
      index += 1
      while index < text.length() &&
            core_meta_lexer_is_id_part(text[index].unsafe_to_char()) {
        index += 1
      }
      let lexeme = text.substring(start~, end=index)
      match core_meta_lexer_keyword_token_type(lexeme) {
        Some(token_type) =>
          tokens.push(
            new_core_meta_lex_token(
              token_type,
              core_meta_lexer_token_name(token_type),
              lexeme,
            ),
          )
        None =>
          tokens.push(
            new_core_meta_lex_token(
              core_meta_lexer_rule_id,
              core_meta_lexer_token_name(core_meta_lexer_rule_id),
              lexeme,
            ),
          )
      }
      continue
    }

    if core_meta_lexer_is_digit(ch) {
      let start = index
      index += 1
      while index < text.length() &&
            core_meta_lexer_is_digit(text[index].unsafe_to_char()) {
        index += 1
      }
      let lexeme = text.substring(start~, end=index)
      tokens.push(
        new_core_meta_lex_token(
          core_meta_lexer_rule_int,
          core_meta_lexer_token_name(core_meta_lexer_rule_int),
          lexeme,
        ),
      )
      continue
    }

    let symbol = text.substring(start=index, end=index + 1)
    core_meta_lexer_push_symbol_token(tokens, symbol)
    index += 1
  }
  tokens
}
