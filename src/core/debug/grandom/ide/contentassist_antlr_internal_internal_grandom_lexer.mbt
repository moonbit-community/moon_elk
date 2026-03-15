///|
pub let core_debug_grandom_ide_token_names : Array[String] = [
  "<invalid>", "<EOR>", "<DOWN>", "<UP>", "RULE_INT", "RULE_STRING", "RULE_ID", "RULE_ML_COMMENT",
  "RULE_SL_COMMENT", "RULE_WS", "RULE_ANY_OTHER", "'labels'", "'+/-'", "'elkt'",
  "'elkg'", "'trees'", "'graphs'", "'bipartite graphs'", "'biconnected graphs'",
  "'triconnected graphs'", "'acyclic graphs'", "'north'", "'east'", "'south'", "'west'",
  "'incoming'", "'outgoing'", "'free'", "'side'", "'position'", "'order'", "'ratio'",
  "'generate'", "'{'", "'}'", "'='", "'seed'", "'format'", "'filename'", "'hierarchy'",
  "'levels'", "'cross-hierarchy edges'", "'compound nodes'", "'cross-hierarchy relative edges'",
  "'edges'", "'nodes'", "'size'", "'height'", "'width'", "'ports'", "'re-use'", "'constraint'",
  "'.'", "'maxWidth'", "'maxDegree'", "'partitionFraction'", "'density'", "'total'",
  "'relative'", "'self loops'", "'remove isolated'", "'to'",
]

///|
pub let core_debug_grandom_ide_rule_int : Int = 4

///|
pub let core_debug_grandom_ide_rule_string : Int = 5

///|
pub let core_debug_grandom_ide_rule_id : Int = 6

///|
pub let core_debug_grandom_ide_rule_ml_comment : Int = 7

///|
pub let core_debug_grandom_ide_rule_sl_comment : Int = 8

///|
pub let core_debug_grandom_ide_rule_ws : Int = 9

///|
pub let core_debug_grandom_ide_rule_any_other : Int = 10

///|
pub(all) struct CoreDebugGRandomIdeLexToken {
  token_type : Int
  token_name : String
  lexeme : String
}

///|
pub fn new_core_debug_grandom_ide_lex_token(
  token_type : Int,
  token_name : String,
  lexeme : String,
) -> CoreDebugGRandomIdeLexToken {
  { token_type, token_name, lexeme }
}

///|
pub(all) struct InternalCoreDebugGRandomLexer {
  input : String
}

///|
pub fn new_internal_core_debug_grandom_lexer(
  input : String,
) -> InternalCoreDebugGRandomLexer {
  { input, }
}

///|
pub fn InternalCoreDebugGRandomLexer::get_grammar_file_name(
  self : InternalCoreDebugGRandomLexer,
) -> String {
  ignore(self)
  "InternalGRandom.g"
}

///|
pub fn InternalCoreDebugGRandomLexer::get_token_names(
  self : InternalCoreDebugGRandomLexer,
) -> Array[String] {
  ignore(self)
  core_debug_grandom_ide_token_names
}

///|
fn core_debug_grandom_ide_lexer_is_id_start(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'
}

///|
fn core_debug_grandom_ide_lexer_is_id_part(ch : Char) -> Bool {
  core_debug_grandom_ide_lexer_is_id_start(ch) || (ch >= '0' && ch <= '9')
}

///|
fn core_debug_grandom_ide_lexer_is_digit(ch : Char) -> Bool {
  ch >= '0' && ch <= '9'
}

///|
fn core_debug_grandom_ide_lexer_token_name(token_type : Int) -> String {
  if token_type >= 0 && token_type < core_debug_grandom_ide_token_names.length() {
    core_debug_grandom_ide_token_names[token_type]
  } else {
    "RULE_ANY_OTHER"
  }
}

///|
fn core_debug_grandom_ide_lexer_keyword_token_type(keyword : String) -> Int? {
  if keyword == "labels" {
    Some(11)
  } else if keyword == "+/-" {
    Some(12)
  } else if keyword == "elkt" {
    Some(13)
  } else if keyword == "elkg" {
    Some(14)
  } else if keyword == "trees" {
    Some(15)
  } else if keyword == "graphs" {
    Some(16)
  } else if keyword == "bipartite graphs" {
    Some(17)
  } else if keyword == "biconnected graphs" {
    Some(18)
  } else if keyword == "triconnected graphs" {
    Some(19)
  } else if keyword == "acyclic graphs" {
    Some(20)
  } else if keyword == "north" {
    Some(21)
  } else if keyword == "east" {
    Some(22)
  } else if keyword == "south" {
    Some(23)
  } else if keyword == "west" {
    Some(24)
  } else if keyword == "incoming" {
    Some(25)
  } else if keyword == "outgoing" {
    Some(26)
  } else if keyword == "free" {
    Some(27)
  } else if keyword == "side" {
    Some(28)
  } else if keyword == "position" {
    Some(29)
  } else if keyword == "order" {
    Some(30)
  } else if keyword == "ratio" {
    Some(31)
  } else if keyword == "generate" {
    Some(32)
  } else if keyword == "seed" {
    Some(36)
  } else if keyword == "format" {
    Some(37)
  } else if keyword == "filename" {
    Some(38)
  } else if keyword == "hierarchy" {
    Some(39)
  } else if keyword == "levels" {
    Some(40)
  } else if keyword == "cross-hierarchy edges" {
    Some(41)
  } else if keyword == "compound nodes" {
    Some(42)
  } else if keyword == "cross-hierarchy relative edges" {
    Some(43)
  } else if keyword == "edges" {
    Some(44)
  } else if keyword == "nodes" {
    Some(45)
  } else if keyword == "size" {
    Some(46)
  } else if keyword == "height" {
    Some(47)
  } else if keyword == "width" {
    Some(48)
  } else if keyword == "ports" {
    Some(49)
  } else if keyword == "re-use" {
    Some(50)
  } else if keyword == "constraint" {
    Some(51)
  } else if keyword == "maxWidth" {
    Some(53)
  } else if keyword == "maxDegree" {
    Some(54)
  } else if keyword == "partitionFraction" {
    Some(55)
  } else if keyword == "density" {
    Some(56)
  } else if keyword == "total" {
    Some(57)
  } else if keyword == "relative" {
    Some(58)
  } else if keyword == "self loops" {
    Some(59)
  } else if keyword == "remove isolated" {
    Some(60)
  } else if keyword == "to" {
    Some(61)
  } else {
    None
  }
}

///|
fn core_debug_grandom_ide_lexer_symbol_token_type(symbol : String) -> Int? {
  if symbol == "{" {
    Some(33)
  } else if symbol == "}" {
    Some(34)
  } else if symbol == "=" {
    Some(35)
  } else if symbol == "." {
    Some(52)
  } else {
    None
  }
}

///|
fn core_debug_grandom_ide_lexer_slice(
  text : String,
  start : Int,
  end_ : Int,
) -> String {
  text[start:end_].to_string()
}

///|
fn core_debug_grandom_ide_lexer_is_word_boundary(
  text : String,
  index : Int,
) -> Bool {
  if index < 0 || index >= text.length() {
    return true
  }
  let ch = text[index].unsafe_to_char()
  !(core_debug_grandom_ide_lexer_is_id_part(ch) || ch == '-')
}

///|
fn core_debug_grandom_ide_lexer_match_keyword(
  text : String,
  start : Int,
) -> (String, Int)? {
  let keywords = [
    "cross-hierarchy relative edges", "biconnected graphs", "triconnected graphs",
    "cross-hierarchy edges", "bipartite graphs", "acyclic graphs", "remove isolated",
    "compound nodes", "self loops", "partitionFraction", "maxDegree", "maxWidth",
    "generate", "hierarchy", "incoming", "outgoing", "constraint", "position", "filename",
    "format", "labels", "levels", "density", "relative", "nodes", "edges", "ports",
    "height", "width", "re-use", "seed", "elkt", "elkg", "trees", "graphs", "north",
    "south", "west", "east", "free", "side", "order", "ratio", "total", "to", "+/-",
    "size",
  ]
  for keyword in keywords {
    let keyword_length = keyword.length()
    if start + keyword_length > text.length() {
      continue
    }
    let candidate = core_debug_grandom_ide_lexer_slice(
      text,
      start,
      start + keyword_length,
    )
    if candidate == keyword &&
      core_debug_grandom_ide_lexer_is_word_boundary(text, start - 1) &&
      core_debug_grandom_ide_lexer_is_word_boundary(
        text,
        start + keyword_length,
      ) {
      match core_debug_grandom_ide_lexer_keyword_token_type(keyword) {
        Some(token_type) => return Some((keyword, token_type))
        None => ()
      }
    }
  }
  None
}

///|
pub fn InternalCoreDebugGRandomLexer::lex_all(
  self : InternalCoreDebugGRandomLexer,
) -> Array[CoreDebugGRandomIdeLexToken] {
  let text = self.input
  let tokens : Array[CoreDebugGRandomIdeLexToken] = []
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

    match core_debug_grandom_ide_lexer_match_keyword(text, index) {
      Some((keyword, token_type)) => {
        tokens.push(
          new_core_debug_grandom_ide_lex_token(
            token_type,
            core_debug_grandom_ide_lexer_token_name(token_type),
            keyword,
          ),
        )
        index += keyword.length()
        continue
      }
      None => ()
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
      let lexeme = core_debug_grandom_ide_lexer_slice(text, start, index)
      tokens.push(
        new_core_debug_grandom_ide_lex_token(
          core_debug_grandom_ide_rule_string,
          core_debug_grandom_ide_lexer_token_name(
            core_debug_grandom_ide_rule_string,
          ),
          lexeme,
        ),
      )
      continue
    }

    if core_debug_grandom_ide_lexer_is_digit(ch) {
      let start = index
      index += 1
      while index < text.length() &&
            core_debug_grandom_ide_lexer_is_digit(text[index].unsafe_to_char()) {
        index += 1
      }
      tokens.push(
        new_core_debug_grandom_ide_lex_token(
          core_debug_grandom_ide_rule_int,
          core_debug_grandom_ide_lexer_token_name(
            core_debug_grandom_ide_rule_int,
          ),
          core_debug_grandom_ide_lexer_slice(text, start, index),
        ),
      )
      continue
    }

    if core_debug_grandom_ide_lexer_is_id_start(ch) {
      let start = index
      index += 1
      while index < text.length() &&
            core_debug_grandom_ide_lexer_is_id_part(
              text[index].unsafe_to_char(),
            ) {
        index += 1
      }
      let lexeme = core_debug_grandom_ide_lexer_slice(text, start, index)
      tokens.push(
        new_core_debug_grandom_ide_lex_token(
          core_debug_grandom_ide_rule_id,
          core_debug_grandom_ide_lexer_token_name(
            core_debug_grandom_ide_rule_id,
          ),
          lexeme,
        ),
      )
      continue
    }

    let symbol = core_debug_grandom_ide_lexer_slice(text, index, index + 1)
    match core_debug_grandom_ide_lexer_symbol_token_type(symbol) {
      Some(token_type) => {
        tokens.push(
          new_core_debug_grandom_ide_lex_token(
            token_type,
            core_debug_grandom_ide_lexer_token_name(token_type),
            symbol,
          ),
        )
        index += 1
      }
      None => {
        tokens.push(
          new_core_debug_grandom_ide_lex_token(
            core_debug_grandom_ide_rule_any_other,
            core_debug_grandom_ide_lexer_token_name(
              core_debug_grandom_ide_rule_any_other,
            ),
            symbol,
          ),
        )
        index += 1
      }
    }
  }
  tokens
}
