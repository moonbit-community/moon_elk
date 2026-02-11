///|
pub struct InternalMetaDataParser {
  tokens : Array[CoreMetaLexToken]
  grammar_access : MetaDataGrammarAccess
}

///|
pub fn new_internal_meta_data_parser(
  tokens : Array[CoreMetaLexToken],
  grammar_access? : MetaDataGrammarAccess = new_meta_data_grammar_access(),
) -> InternalMetaDataParser {
  { tokens, grammar_access }
}

///|
pub fn InternalMetaDataParser::get_token_names(
  self : InternalMetaDataParser,
) -> Array[String] {
  ignore(self)
  new_internal_meta_data_lexer("").get_token_names()
}

///|
pub fn InternalMetaDataParser::get_grammar_file_name(
  self : InternalMetaDataParser,
) -> String {
  ignore(self)
  "InternalMetaData.g"
}

///|
pub fn InternalMetaDataParser::get_first_rule_name(
  self : InternalMetaDataParser,
) -> String {
  ignore(self)
  "MdModel"
}

///|
pub fn InternalMetaDataParser::get_grammar_access(
  self : InternalMetaDataParser,
) -> MetaDataGrammarAccess {
  self.grammar_access
}

///|
fn core_meta_parser_peek(
  tokens : Array[CoreMetaLexToken],
  index : Int,
) -> CoreMetaLexToken? {
  if index >= 0 && index < tokens.length() {
    Some(tokens[index])
  } else {
    None
  }
}

///|
fn core_meta_parser_peek_lexeme(
  tokens : Array[CoreMetaLexToken],
  index : Int,
) -> String? {
  match core_meta_parser_peek(tokens, index) {
    Some(token) => Some(token.lexeme)
    None => None
  }
}

///|
fn core_meta_parser_consume_if_lexeme(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
  lexeme : String,
) -> Bool {
  match core_meta_parser_peek_lexeme(tokens, index_ref.val) {
    Some(current) =>
      if current == lexeme {
        index_ref.val += 1
        true
      } else {
        false
      }
    None => false
  }
}

///|
fn core_meta_parser_unquote(text : String) -> String {
  if text.length() >= 2 && text.has_prefix("\"") && text.has_suffix("\"") {
    text.unsafe_substring(start=1, end=text.length() - 1)
  } else {
    text
  }
}

///|
fn core_meta_parser_token_is_name(token : CoreMetaLexToken) -> Bool {
  token.token_type == core_meta_lexer_rule_id ||
  token.token_type == core_meta_lexer_rule_int
}

///|
fn core_meta_parser_parse_single_literal(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> String? {
  match core_meta_parser_peek(tokens, index_ref.val) {
    Some(token) => {
      index_ref.val += 1
      if token.token_type == core_meta_lexer_rule_string {
        Some(core_meta_parser_unquote(token.lexeme))
      } else {
        Some(token.lexeme)
      }
    }
    None => None
  }
}

///|
fn core_meta_parser_parse_qualified_name(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> String? {
  match core_meta_parser_peek(tokens, index_ref.val) {
    Some(first) => {
      if !core_meta_parser_token_is_name(first) {
        return None
      }
      let mut result = first.lexeme
      index_ref.val += 1
      while core_meta_parser_consume_if_lexeme(tokens, index_ref, ".") {
        match core_meta_parser_peek(tokens, index_ref.val) {
          Some(next) =>
            if core_meta_parser_token_is_name(next) {
              result = result + "." + next.lexeme
              index_ref.val += 1
            } else {
              break
            }
          None => break
        }
      }
      Some(result)
    }
    None => None
  }
}

///|
fn core_meta_parser_parse_path(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> String? {
  match core_meta_parser_parse_qualified_name(tokens, index_ref) {
    Some(first) => {
      let mut result = first
      while true {
        let separator = match
          core_meta_parser_peek_lexeme(tokens, index_ref.val) {
          Some(value) if value == "/" || value == "-" => Some(value)
          _ => None
        }
        match separator {
          Some(symbol) => {
            index_ref.val += 1
            match core_meta_parser_parse_qualified_name(tokens, index_ref) {
              Some(next) => result = result + symbol + next
              None => {
                result = result + symbol
                break
              }
            }
          }
          None => break
        }
      }
      Some(result)
    }
    None => None
  }
}

///|
fn core_meta_parser_parse_string_or_name(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> String? {
  match core_meta_parser_peek(tokens, index_ref.val) {
    Some(token) =>
      if token.token_type == core_meta_lexer_rule_string {
        index_ref.val += 1
        Some(core_meta_parser_unquote(token.lexeme))
      } else {
        core_meta_parser_parse_qualified_name(tokens, index_ref)
      }
    None => None
  }
}

///|
fn core_meta_parser_parse_option_target_type(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdOptionTargetType? {
  match core_meta_parser_peek(tokens, index_ref.val) {
    Some(token) => {
      index_ref.val += 1
      core_meta_md_option_target_type_from_string(token.lexeme)
    }
    None => None
  }
}

///|
fn core_meta_parser_parse_graph_feature(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdGraphFeature? {
  match core_meta_parser_peek(tokens, index_ref.val) {
    Some(token) => {
      index_ref.val += 1
      core_meta_md_graph_feature_from_string(token.lexeme)
    }
    None => None
  }
}

///|
fn core_meta_parser_is_option_start(
  tokens : Array[CoreMetaLexToken],
  index : Int,
) -> Bool {
  let mut i = index
  if i < tokens.length() && tokens[i].lexeme == "deprecated" {
    i += 1
  }
  if i < tokens.length() {
    let modifier = tokens[i].lexeme
    if modifier == "advanced" ||
      modifier == "programmatic" ||
      modifier == "output" ||
      modifier == "global" {
      i += 1
    }
  }
  i < tokens.length() && tokens[i].lexeme == "option"
}

///|
fn core_meta_parser_is_algorithm_start(
  tokens : Array[CoreMetaLexToken],
  index : Int,
) -> Bool {
  if index >= tokens.length() {
    return false
  }
  if tokens[index].lexeme == "algorithm" {
    return true
  }
  index + 1 < tokens.length() &&
  tokens[index].lexeme == "deprecated" &&
  tokens[index + 1].lexeme == "algorithm"
}

///|
fn core_meta_parser_is_category_start(
  tokens : Array[CoreMetaLexToken],
  index : Int,
) -> Bool {
  if index >= tokens.length() {
    return false
  }
  if tokens[index].lexeme == "category" {
    return true
  }
  index + 1 < tokens.length() &&
  tokens[index].lexeme == "deprecated" &&
  tokens[index + 1].lexeme == "category"
}

///|
fn core_meta_parser_parse_md_option(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdOption {
  let option = core_meta_create_md_option()

  if core_meta_parser_consume_if_lexeme(tokens, index_ref, "deprecated") {
    option.set_deprecated(true)
  }
  if core_meta_parser_consume_if_lexeme(tokens, index_ref, "advanced") {
    option.set_advanced(true)
  } else if core_meta_parser_consume_if_lexeme(
      tokens, index_ref, "programmatic",
    ) {
    option.set_programmatic(true)
  } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "output") {
    option.set_output(true)
  } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "global") {
    option.set_global(true)
  }

  ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, "option"))

  match core_meta_parser_parse_single_literal(tokens, index_ref) {
    Some(name) => option.set_name(Some(name))
    None => ()
  }

  if core_meta_parser_consume_if_lexeme(tokens, index_ref, ":") {
    option.set_type_ref(
      core_meta_parser_parse_qualified_name(tokens, index_ref),
    )
  }

  if !core_meta_parser_consume_if_lexeme(tokens, index_ref, "{") {
    return option
  }

  while index_ref.val < tokens.length() {
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "}") {
      break
    }

    let start = index_ref.val
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "label") {
      option.set_label(core_meta_parser_parse_string_or_name(tokens, index_ref))
    } else if core_meta_parser_consume_if_lexeme(
        tokens, index_ref, "description",
      ) {
      option.set_description(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(
        tokens, index_ref, "documentation",
      ) {
      option.set_documentation(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "default") {
      ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, "="))
      option.set_default_value(
        core_meta_parser_parse_single_literal(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(
        tokens, index_ref, "lowerBound",
      ) {
      ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, "="))
      option.set_lower_bound(
        core_meta_parser_parse_single_literal(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(
        tokens, index_ref, "upperBound",
      ) {
      ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, "="))
      option.set_upper_bound(
        core_meta_parser_parse_single_literal(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "targets") {
      while index_ref.val < tokens.length() {
        match core_meta_parser_parse_option_target_type(tokens, index_ref) {
          Some(target) => option.get_targets().push(target)
          None => break
        }
        if !core_meta_parser_consume_if_lexeme(tokens, index_ref, ",") {
          break
        }
      }
    } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "legacyIds") {
      while index_ref.val < tokens.length() {
        match core_meta_parser_parse_qualified_name(tokens, index_ref) {
          Some(legacy_id) => option.get_legacy_ids().push(legacy_id)
          None => break
        }
        if !core_meta_parser_consume_if_lexeme(tokens, index_ref, ",") {
          break
        }
      }
    } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "requires") {
      let dependency = core_meta_create_md_option_dependency()
      dependency.set_target_name(
        core_meta_parser_parse_qualified_name(tokens, index_ref),
      )
      if core_meta_parser_consume_if_lexeme(tokens, index_ref, "==") {
        dependency.set_value(
          core_meta_parser_parse_single_literal(tokens, index_ref),
        )
      }
      option.get_dependencies().push(dependency)
    } else {
      index_ref.val += 1
    }

    if index_ref.val == start {
      index_ref.val += 1
    }
  }

  option
}

///|
fn core_meta_parser_parse_md_group(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdGroup {
  let group = core_meta_create_md_group()

  ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, "group"))
  group.set_name(core_meta_parser_parse_single_literal(tokens, index_ref))

  if !core_meta_parser_consume_if_lexeme(tokens, index_ref, "{") {
    return group
  }

  while index_ref.val < tokens.length() {
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "}") {
      break
    }
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "documentation") {
      group.set_documentation(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
      continue
    }
    if core_meta_parser_is_option_start(tokens, index_ref.val) {
      group
      .get_children()
      .push(
        core_meta_md_group_or_option_option(
          core_meta_parser_parse_md_option(tokens, index_ref),
        ),
      )
      continue
    }
    match core_meta_parser_peek_lexeme(tokens, index_ref.val) {
      Some("group") =>
        group
        .get_children()
        .push(
          core_meta_md_group_or_option_group(
            core_meta_parser_parse_md_group(tokens, index_ref),
          ),
        )
      _ => index_ref.val += 1
    }
  }

  group
}

///|
fn core_meta_parser_parse_md_option_support(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdOptionSupport {
  let support = core_meta_create_md_option_support()
  ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, "supports"))
  support.set_option_name(
    core_meta_parser_parse_qualified_name(tokens, index_ref),
  )
  if core_meta_parser_consume_if_lexeme(tokens, index_ref, "=") {
    support.set_value(core_meta_parser_parse_single_literal(tokens, index_ref))
  }
  if core_meta_parser_consume_if_lexeme(tokens, index_ref, "documentation") {
    support.set_documentation(
      core_meta_parser_parse_string_or_name(tokens, index_ref),
    )
  }
  support
}

///|
fn core_meta_parser_parse_md_algorithm(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdAlgorithm {
  let algorithm = core_meta_create_md_algorithm()

  if core_meta_parser_consume_if_lexeme(tokens, index_ref, "deprecated") {
    algorithm.set_deprecated(true)
  }
  ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, "algorithm"))

  algorithm.set_name(core_meta_parser_parse_single_literal(tokens, index_ref))

  if core_meta_parser_consume_if_lexeme(tokens, index_ref, "(") {
    algorithm.set_provider(
      core_meta_parser_parse_qualified_name(tokens, index_ref),
    )
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "#") {
      algorithm.set_parameter(
        core_meta_parser_parse_single_literal(tokens, index_ref),
      )
    }
    ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, ")"))
  }

  if !core_meta_parser_consume_if_lexeme(tokens, index_ref, "{") {
    return algorithm
  }

  while index_ref.val < tokens.length() {
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "}") {
      break
    }

    let start = index_ref.val
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "label") {
      algorithm.set_label(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(
        tokens, index_ref, "metadataClass",
      ) {
      algorithm.set_target_class(
        core_meta_parser_parse_qualified_name(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(
        tokens, index_ref, "description",
      ) {
      algorithm.set_description(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(
        tokens, index_ref, "documentation",
      ) {
      algorithm.set_documentation(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "category") {
      algorithm.set_category_name(
        core_meta_parser_parse_qualified_name(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "preview") {
      algorithm.set_preview_image(
        core_meta_parser_parse_path(tokens, index_ref),
      )
    } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "features") {
      while index_ref.val < tokens.length() {
        match core_meta_parser_parse_graph_feature(tokens, index_ref) {
          Some(feature) => algorithm.get_supported_features().push(feature)
          None => break
        }
        if !core_meta_parser_consume_if_lexeme(tokens, index_ref, ",") {
          break
        }
      }
    } else if core_meta_parser_consume_if_lexeme(tokens, index_ref, "validator") {
      algorithm.set_validator(
        core_meta_parser_parse_qualified_name(tokens, index_ref),
      )
    } else {
      let is_supports = match
        core_meta_parser_peek_lexeme(tokens, index_ref.val) {
        Some(value) => value == "supports"
        None => false
      }
      if is_supports {
        algorithm
        .get_supported_options()
        .push(core_meta_parser_parse_md_option_support(tokens, index_ref))
      } else {
        index_ref.val += 1
      }
    }

    if index_ref.val == start {
      index_ref.val += 1
    }
  }

  algorithm
}

///|
fn core_meta_parser_parse_md_category(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdCategory {
  let category = core_meta_create_md_category()

  if core_meta_parser_consume_if_lexeme(tokens, index_ref, "deprecated") {
    category.set_deprecated(true)
  }
  ignore(core_meta_parser_consume_if_lexeme(tokens, index_ref, "category"))

  category.set_name(core_meta_parser_parse_single_literal(tokens, index_ref))

  if !core_meta_parser_consume_if_lexeme(tokens, index_ref, "{") {
    return category
  }

  while index_ref.val < tokens.length() {
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "}") {
      break
    }
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "label") {
      category.set_label(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
      continue
    }
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "description") {
      category.set_description(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
      continue
    }
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "documentation") {
      category.set_documentation(
        core_meta_parser_parse_string_or_name(tokens, index_ref),
      )
      continue
    }
    index_ref.val += 1
  }

  category
}

///|
fn core_meta_parser_parse_md_bundle_member(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdBundleMember? {
  if index_ref.val >= tokens.length() {
    return None
  }

  match core_meta_parser_peek_lexeme(tokens, index_ref.val) {
    Some("group") =>
      Some(
        core_meta_md_bundle_member_group_or_option(
          core_meta_md_group_or_option_group(
            core_meta_parser_parse_md_group(tokens, index_ref),
          ),
        ),
      )
    _ =>
      if core_meta_parser_is_option_start(tokens, index_ref.val) {
        Some(
          core_meta_md_bundle_member_group_or_option(
            core_meta_md_group_or_option_option(
              core_meta_parser_parse_md_option(tokens, index_ref),
            ),
          ),
        )
      } else if core_meta_parser_is_algorithm_start(tokens, index_ref.val) {
        Some(
          core_meta_md_bundle_member_algorithm(
            core_meta_parser_parse_md_algorithm(tokens, index_ref),
          ),
        )
      } else if core_meta_parser_is_category_start(tokens, index_ref.val) {
        Some(
          core_meta_md_bundle_member_category(
            core_meta_parser_parse_md_category(tokens, index_ref),
          ),
        )
      } else {
        None
      }
  }
}

///|
fn core_meta_parser_parse_md_bundle(
  tokens : Array[CoreMetaLexToken],
  index_ref : Ref[Int],
) -> CoreMetaMdBundle {
  let bundle = core_meta_create_md_bundle()

  if core_meta_parser_consume_if_lexeme(tokens, index_ref, "bundle") {
    if core_meta_parser_consume_if_lexeme(tokens, index_ref, "{") {
      while index_ref.val < tokens.length() {
        if core_meta_parser_consume_if_lexeme(tokens, index_ref, "}") {
          break
        }
        let start = index_ref.val
        if core_meta_parser_consume_if_lexeme(tokens, index_ref, "label") {
          bundle.set_label(
            core_meta_parser_parse_string_or_name(tokens, index_ref),
          )
        } else if core_meta_parser_consume_if_lexeme(
            tokens, index_ref, "metadataClass",
          ) {
          bundle.set_target_class(
            core_meta_parser_parse_qualified_name(tokens, index_ref),
          )
        } else if core_meta_parser_consume_if_lexeme(
            tokens, index_ref, "documentationFolder",
          ) {
          bundle.set_documentation_folder(
            core_meta_parser_parse_path(tokens, index_ref),
          )
        } else if core_meta_parser_consume_if_lexeme(
            tokens, index_ref, "idPrefix",
          ) {
          bundle.set_id_prefix(
            core_meta_parser_parse_qualified_name(tokens, index_ref),
          )
        } else {
          index_ref.val += 1
        }

        if index_ref.val == start {
          index_ref.val += 1
        }
      }
    }
  }

  while index_ref.val < tokens.length() {
    match core_meta_parser_parse_md_bundle_member(tokens, index_ref) {
      Some(member) => bundle.get_members().push(member)
      None => index_ref.val += 1
    }
  }

  bundle
}

///|
pub fn InternalMetaDataParser::entry_rule_md_model(
  self : InternalMetaDataParser,
) -> CoreMetaMdModel {
  self.rule_md_model()
}

///|
pub fn InternalMetaDataParser::rule_md_model(
  self : InternalMetaDataParser,
) -> CoreMetaMdModel {
  let model = core_meta_create_md_model()
  let index_ref : Ref[Int] = Ref::new(0)

  if core_meta_parser_consume_if_lexeme(self.tokens, index_ref, "package") {
    model.set_name(
      core_meta_parser_parse_qualified_name(self.tokens, index_ref),
    )

    while core_meta_parser_consume_if_lexeme(self.tokens, index_ref, "import") {
      model.set_import_section(
        core_meta_parser_parse_qualified_name(self.tokens, index_ref),
      )
      ignore(core_meta_parser_consume_if_lexeme(self.tokens, index_ref, ";"))
    }
  }

  let bundle = core_meta_parser_parse_md_bundle(self.tokens, index_ref)
  model.set_bundle(Some(bundle))
  model
}
