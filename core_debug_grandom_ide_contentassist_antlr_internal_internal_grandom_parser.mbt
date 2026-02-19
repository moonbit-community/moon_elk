///|
pub struct InternalCoreDebugGRandomParser {
  tokens : Array[CoreDebugGRandomIdeLexToken]
  grammar_access : CoreDebugGRandomIdeGrammarAccess
}

///|
pub fn new_internal_core_debug_grandom_parser(
  tokens : Array[CoreDebugGRandomIdeLexToken],
  grammar_access? : CoreDebugGRandomIdeGrammarAccess = new_core_debug_grandom_ide_grammar_access(),
) -> InternalCoreDebugGRandomParser {
  { tokens, grammar_access }
}

///|
pub fn InternalCoreDebugGRandomParser::get_token_names(
  self : InternalCoreDebugGRandomParser,
) -> Array[String] {
  ignore(self)
  core_debug_grandom_ide_token_names
}

///|
pub fn InternalCoreDebugGRandomParser::get_grammar_file_name(
  self : InternalCoreDebugGRandomParser,
) -> String {
  ignore(self)
  "InternalGRandom.g"
}

///|
pub fn InternalCoreDebugGRandomParser::get_first_rule_name(
  self : InternalCoreDebugGRandomParser,
) -> String {
  ignore(self)
  "RandGraph"
}

///|
pub fn InternalCoreDebugGRandomParser::get_grammar_access(
  self : InternalCoreDebugGRandomParser,
) -> CoreDebugGRandomIdeGrammarAccess {
  self.grammar_access
}

///|
fn core_debug_grandom_ide_parser_strip_quotes(text : String) -> String {
  if text.length() >= 2 && text.has_prefix("\"") && text.has_suffix("\"") {
    text.unsafe_substring(start=1, end=text.length() - 1)
  } else {
    text
  }
}

///|
fn core_debug_grandom_ide_parser_parse_int(
  token : CoreDebugGRandomIdeLexToken,
) -> Int? {
  if token.token_type != core_debug_grandom_ide_rule_int {
    return None
  }
  let parsed : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
    token.lexeme,
  )
  match parsed {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn core_debug_grandom_ide_parser_parse_double_at(
  tokens : Array[CoreDebugGRandomIdeLexToken],
  start : Int,
) -> (Double, Int)? {
  if start >= tokens.length() {
    return None
  }
  let first = tokens[start]
  if first.token_type == core_debug_grandom_ide_rule_int {
    if start + 2 < tokens.length() &&
      tokens[start + 1].lexeme == "." &&
      tokens[start + 2].token_type == core_debug_grandom_ide_rule_int {
      let joined = first.lexeme + "." + tokens[start + 2].lexeme
      let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
        joined,
      )
      match parsed {
        Ok(value) => return Some((value, 3))
        Err(_) => ()
      }
    }
    let parsed_int = core_debug_grandom_ide_parser_parse_int(first)
    match parsed_int {
      Some(value) => Some((value.to_double(), 1))
      None => None
    }
  } else if first.token_type == core_debug_grandom_ide_rule_string ||
    first.token_type == core_debug_grandom_ide_rule_id {
    let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
      core_debug_grandom_ide_parser_strip_quotes(first.lexeme),
    )
    match parsed {
      Ok(value) => Some((value, 1))
      Err(_) => None
    }
  } else {
    None
  }
}

///|
fn core_debug_grandom_ide_parser_parse_block_end(
  tokens : Array[CoreDebugGRandomIdeLexToken],
  start : Int,
) -> Int {
  let mut depth = 1
  let mut index = start
  while index < tokens.length() {
    let lexeme = tokens[index].lexeme
    if lexeme == "{" {
      depth += 1
    } else if lexeme == "}" {
      depth -= 1
      if depth == 0 {
        return index + 1
      }
    }
    index += 1
  }
  tokens.length()
}

///|
fn core_debug_grandom_ide_parser_optional_equals(
  tokens : Array[CoreDebugGRandomIdeLexToken],
  start : Int,
) -> Int {
  if start < tokens.length() && tokens[start].lexeme == "=" {
    start + 1
  } else {
    start
  }
}

///|
fn core_debug_grandom_ide_parser_parse_nodes(
  tokens : Array[CoreDebugGRandomIdeLexToken],
  start : Int,
) -> (CoreDebugGRandomNodes?, Int) {
  let mut index = core_debug_grandom_ide_parser_optional_equals(tokens, start)
  if index >= tokens.length() {
    return (None, index)
  }
  if tokens[index].lexeme == "{" {
    let block_end = core_debug_grandom_ide_parser_parse_block_end(
      tokens,
      index + 1,
    )
    index += 1
    let mut nodes = new_core_debug_grandom_nodes()
    while index + 1 < block_end {
      let key = tokens[index].lexeme
      let value_index = core_debug_grandom_ide_parser_optional_equals(
        tokens,
        index + 1,
      )
      if key == "labels" {
        nodes = nodes.set_labels(true)
        index += 1
        continue
      }
      match core_debug_grandom_ide_parser_parse_double_at(tokens, value_index) {
        Some((value, consumed)) =>
          if key == "nodes" {
            nodes = nodes.set_n_nodes(
              Some(core_debug_grandom_double_quantity_exact(value)),
            )
            index = value_index + consumed
          } else {
            index += 1
          }
        None => index += 1
      }
    }
    (Some(nodes), block_end)
  } else {
    match core_debug_grandom_ide_parser_parse_double_at(tokens, index) {
      Some((value, consumed)) =>
        (
          Some(
            new_core_debug_grandom_nodes().set_n_nodes(
              Some(core_debug_grandom_double_quantity_exact(value)),
            ),
          ),
          index + consumed,
        )
      None => (None, index)
    }
  }
}

///|
fn core_debug_grandom_ide_parser_parse_edges(
  tokens : Array[CoreDebugGRandomIdeLexToken],
  start : Int,
) -> (CoreDebugGRandomEdges?, Int) {
  let mut index = core_debug_grandom_ide_parser_optional_equals(tokens, start)
  if index >= tokens.length() {
    return (None, index)
  }
  if tokens[index].lexeme == "{" {
    let block_end = core_debug_grandom_ide_parser_parse_block_end(
      tokens,
      index + 1,
    )
    index += 1
    let mut edges = new_core_debug_grandom_edges()
    while index + 1 < block_end {
      let key = tokens[index].lexeme
      let value_index = core_debug_grandom_ide_parser_optional_equals(
        tokens,
        index + 1,
      )
      if key == "labels" {
        edges = edges.set_labels(true)
        index += 1
        continue
      }
      if key == "self loops" {
        edges = edges.set_self_loops(true)
        index += 1
        continue
      }
      if key == "total" {
        edges = edges.set_total(true)
        index += 1
        continue
      }
      match core_debug_grandom_ide_parser_parse_double_at(tokens, value_index) {
        Some((value, consumed)) =>
          if key == "edges" || key == "density" || key == "relative" {
            edges = edges.set_n_edges(
              Some(core_debug_grandom_double_quantity_exact(value)),
            )
            index = value_index + consumed
          } else {
            index += 1
          }
        None => index += 1
      }
    }
    (Some(edges), block_end)
  } else {
    match core_debug_grandom_ide_parser_parse_double_at(tokens, index) {
      Some((value, consumed)) =>
        (
          Some(
            new_core_debug_grandom_edges().set_n_edges(
              Some(core_debug_grandom_double_quantity_exact(value)),
            ),
          ),
          index + consumed,
        )
      None => (None, index)
    }
  }
}

///|
fn core_debug_grandom_ide_parser_parse_hierarchy(
  tokens : Array[CoreDebugGRandomIdeLexToken],
  start : Int,
) -> (CoreDebugGRandomHierarchy?, Int) {
  let mut index = core_debug_grandom_ide_parser_optional_equals(tokens, start)
  if index >= tokens.length() || tokens[index].lexeme != "{" {
    return (None, index)
  }
  let block_end = core_debug_grandom_ide_parser_parse_block_end(
    tokens,
    index + 1,
  )
  index += 1
  let mut hierarchy = new_core_debug_grandom_hierarchy()
  while index + 1 < block_end {
    let key = tokens[index].lexeme
    let value_index = core_debug_grandom_ide_parser_optional_equals(
      tokens,
      index + 1,
    )
    match core_debug_grandom_ide_parser_parse_double_at(tokens, value_index) {
      Some((value, consumed)) => {
        let quantity = Some(core_debug_grandom_double_quantity_exact(value))
        if key == "levels" {
          hierarchy = hierarchy.set_levels(quantity)
        } else if key == "cross-hierarchy edges" {
          hierarchy = hierarchy.set_edges(quantity)
        } else if key == "compound nodes" {
          hierarchy = hierarchy.set_num_hierarch_nodes(quantity)
        } else if key == "cross-hierarchy relative edges" {
          hierarchy = hierarchy.set_cross_hierarch_rel(quantity)
        }
        index = value_index + consumed
      }
      None => index += 1
    }
  }
  (Some(hierarchy), block_end)
}

///|
fn core_debug_grandom_ide_parser_parse_configuration(
  tokens : Array[CoreDebugGRandomIdeLexToken],
  start : Int,
) -> (CoreDebugGRandomConfiguration, Int) {
  let mut config = new_core_debug_grandom_configuration()
  if start >= tokens.length() || tokens[start].lexeme != "{" {
    return (config, start)
  }
  let block_end = core_debug_grandom_ide_parser_parse_block_end(
    tokens,
    start + 1,
  )
  let mut index = start + 1
  while index < block_end {
    let key = tokens[index].lexeme
    let value_index = core_debug_grandom_ide_parser_optional_equals(
      tokens,
      index + 1,
    )

    if key == "trees" {
      config = config.set_form(core_debug_grandom_form_trees())
      index += 1
      continue
    }
    if key == "graphs" {
      config = config.set_form(core_debug_grandom_form_custom())
      index += 1
      continue
    }
    if key == "bipartite graphs" {
      config = config.set_form(core_debug_grandom_form_bipartite())
      index += 1
      continue
    }
    if key == "biconnected graphs" {
      config = config.set_form(FormBiconnected)
      index += 1
      continue
    }
    if key == "triconnected graphs" {
      config = config.set_form(FormTriconnected)
      index += 1
      continue
    }
    if key == "acyclic graphs" {
      config = config.set_form(FormAcyclic)
      index += 1
      continue
    }

    if key == "nodes" {
      let (nodes, next_index) = core_debug_grandom_ide_parser_parse_nodes(
        tokens,
        index + 1,
      )
      config = config.set_nodes(nodes)
      index = next_index
      continue
    }
    if key == "edges" {
      let (edges, next_index) = core_debug_grandom_ide_parser_parse_edges(
        tokens,
        index + 1,
      )
      config = config.set_edges(edges)
      index = next_index
      continue
    }
    if key == "hierarchy" {
      let (hierarchy, next_index) = core_debug_grandom_ide_parser_parse_hierarchy(
        tokens,
        index + 1,
      )
      config = config.set_hierarchy(hierarchy)
      index = next_index
      continue
    }
    if key == "maxWidth" {
      match core_debug_grandom_ide_parser_parse_int(tokens[value_index]) {
        Some(value) => {
          config = config.set_tree_limits(Some(value), config.max_degree)
          index = value_index + 1
        }
        None => index += 1
      }
      continue
    }
    if key == "maxDegree" {
      match core_debug_grandom_ide_parser_parse_int(tokens[value_index]) {
        Some(value) => {
          config = config.set_tree_limits(config.max_width, Some(value))
          index = value_index + 1
        }
        None => index += 1
      }
      continue
    }
    if key == "seed" {
      match core_debug_grandom_ide_parser_parse_int(tokens[value_index]) {
        Some(value) => {
          config = config.set_seed(Some(value))
          index = value_index + 1
        }
        None => index += 1
      }
      continue
    }
    if key == "format" {
      if value_index < tokens.length() {
        let value = tokens[value_index].lexeme
        if value == "elkt" {
          config = config.set_format(Some(core_debug_grandom_format_elkt()))
        } else if value == "elkg" {
          config = config.set_format(Some(core_debug_grandom_format_elkg()))
        }
        index = value_index + 1
      } else {
        index += 1
      }
      continue
    }
    if key == "filename" {
      if value_index < tokens.length() {
        config = config.set_filename(
          Some(
            core_debug_grandom_ide_parser_strip_quotes(
              tokens[value_index].lexeme,
            ),
          ),
        )
        index = value_index + 1
      } else {
        index += 1
      }
      continue
    }
    if key == "partitionFraction" {
      match core_debug_grandom_ide_parser_parse_double_at(tokens, value_index) {
        Some((value, consumed)) => {
          config = config.set_fraction(
            Some(core_debug_grandom_double_quantity_exact(value)),
          )
          index = value_index + consumed
        }
        None => index += 1
      }
      continue
    }

    index += 1
  }

  (config, block_end)
}

///|
pub fn InternalCoreDebugGRandomParser::entry_rule_rand_graph(
  self : InternalCoreDebugGRandomParser,
) -> CoreDebugGRandomRandGraph {
  self.rule_rand_graph()
}

///|
pub fn InternalCoreDebugGRandomParser::rule_rand_graph(
  self : InternalCoreDebugGRandomParser,
) -> CoreDebugGRandomRandGraph {
  let configs : Array[CoreDebugGRandomConfiguration] = []
  let mut index = 0
  while index < self.tokens.length() {
    if self.tokens[index].lexeme == "generate" {
      let (configuration, next_index) = core_debug_grandom_ide_parser_parse_configuration(
        self.tokens,
        index + 1,
      )
      configs.push(configuration)
      if next_index > index {
        index = next_index
      } else {
        index += 1
      }
    } else {
      index += 1
    }
  }
  new_core_debug_grandom_rand_graph(configs~)
}
