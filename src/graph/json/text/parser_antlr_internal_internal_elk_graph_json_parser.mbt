///|
pub struct GraphJsonTextPendingOutgoingSection {
  source : @graph.ElkEdgeSection
  target_id : String
}

///|
pub fn new_graph_json_text_pending_outgoing_section(
  source : @graph.ElkEdgeSection,
  target_id : String,
) -> GraphJsonTextPendingOutgoingSection {
  { source, target_id }
}

///|
pub struct InternalElkGraphJsonParser {
  tokens : Array[ElkGraphJsonLexToken]
  grammar_access : ElkGraphJsonGrammarAccess
}

///|
pub fn new_internal_elk_graph_json_parser(
  tokens : Array[ElkGraphJsonLexToken],
  grammar_access? : ElkGraphJsonGrammarAccess = new_elk_graph_json_grammar_access(),
) -> InternalElkGraphJsonParser {
  { tokens, grammar_access }
}

///|
pub fn InternalElkGraphJsonParser::get_token_names(
  self : InternalElkGraphJsonParser,
) -> Array[String] {
  ignore(self)
  graph_json_text_lexer_token_names
}

///|
pub fn InternalElkGraphJsonParser::get_grammar_file_name(
  self : InternalElkGraphJsonParser,
) -> String {
  ignore(self)
  "InternalElkGraphJson.g"
}

///|
pub fn InternalElkGraphJsonParser::get_first_rule_name(
  self : InternalElkGraphJsonParser,
) -> String {
  ignore(self)
  "ElkNode"
}

///|
pub fn InternalElkGraphJsonParser::get_grammar_access(
  self : InternalElkGraphJsonParser,
) -> ElkGraphJsonGrammarAccess {
  self.grammar_access
}

///|
fn graph_json_text_parser_rebuild_json(
  tokens : Array[ElkGraphJsonLexToken],
) -> String {
  let buffer = @buffer.new()
  for token in tokens {
    buffer.write_string(token.lexeme)
  }
  buffer.to_string()
}

///|
fn graph_json_text_parser_decode_id(lexeme : String) -> String {
  if lexeme.length() > 0 && lexeme.has_prefix("^") {
    lexeme.unsafe_substring(start=1, end=lexeme.length())
  } else {
    lexeme
  }
}

///|
fn graph_json_text_parser_strip_quotes(text : String) -> String {
  if text.length() >= 2 &&
    (
      (text.has_prefix("\"") && text.has_suffix("\"")) ||
      (text.has_prefix("'") && text.has_suffix("'"))
    ) {
    text.unsafe_substring(start=1, end=text.length() - 1)
  } else {
    text
  }
}

///|
fn graph_json_text_parser_parse_double(text : String) -> Double? {
  let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    text,
  )
  match parsed {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn graph_json_text_parser_parse_number_token(
  token : ElkGraphJsonLexToken,
) -> Double? {
  if token.token_type == graph_json_text_lexer_rule_signed_int ||
    token.token_type == graph_json_text_lexer_rule_int ||
    token.token_type == graph_json_text_lexer_rule_float {
    graph_json_text_parser_parse_double(token.lexeme)
  } else {
    None
  }
}

///|
fn graph_json_text_parser_parse_number_at(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
) -> (Double, Int)? {
  if start >= tokens.length() {
    return None
  }
  match graph_json_text_parser_parse_number_token(tokens[start]) {
    Some(value) => Some((value, 1))
    None => None
  }
}

///|
fn graph_json_text_parser_last_segment(qualified_id : String) -> String {
  let mut last_dot = -1
  let mut idx = 0
  while idx < qualified_id.length() {
    if qualified_id[idx].unsafe_to_char() == '.' {
      last_dot = idx
    }
    idx += 1
  }
  if last_dot >= 0 && last_dot + 1 < qualified_id.length() {
    qualified_id.unsafe_substring(start=last_dot + 1, end=qualified_id.length())
  } else {
    qualified_id
  }
}

///|
fn graph_json_text_parser_parse_qualified_id(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
) -> (String, Int)? {
  if start >= tokens.length() ||
    tokens[start].token_type != graph_json_text_lexer_rule_id {
    return None
  }
  let mut index = start
  let mut result = graph_json_text_parser_decode_id(tokens[index].lexeme)
  index += 1
  while index + 1 < tokens.length() &&
        tokens[index].lexeme == "." &&
        tokens[index + 1].token_type == graph_json_text_lexer_rule_id {
    result = result +
      "." +
      graph_json_text_parser_decode_id(tokens[index + 1].lexeme)
    index += 2
  }
  Some((result, index - start))
}

///|
fn graph_json_text_parser_resolve_shape(
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  qualified_id : String,
) -> @graph.ElkConnectableShape? {
  match id_to_shape.get(qualified_id) {
    Some(shape) => Some(shape)
    None => id_to_shape.get(graph_json_text_parser_last_segment(qualified_id))
  }
}

///|
fn graph_json_text_parser_parse_property_key(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
) -> (GraphJsonTextPropertyKey, Int)? {
  match graph_json_text_parser_parse_qualified_id(tokens, start) {
    Some((id, consumed)) =>
      match @core.layout_meta_data_service_get_option_data_by_suffix(id) {
        Some(option_data) =>
          Some((GraphJsonTextLayoutOption(option_data), consumed))
        None => Some((GraphJsonTextCustomProperty(id), consumed))
      }
    None => None
  }
}

///|
fn graph_json_text_parser_parse_property_value(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
) -> (GraphJsonTextPropertyValue, Int) {
  if start >= tokens.length() {
    return (GraphJsonTextNullValue, 0)
  }
  let token = tokens[start]
  if token.token_type == graph_json_text_lexer_rule_string {
    return (
      GraphJsonTextStringValue(
        graph_json_text_parser_strip_quotes(token.lexeme),
      ),
      1,
    )
  }
  if token.lexeme == "null" {
    return (GraphJsonTextNullValue, 1)
  }
  if token.lexeme == "true" {
    return (GraphJsonTextBooleanValue(true), 1)
  }
  if token.lexeme == "false" {
    return (GraphJsonTextBooleanValue(false), 1)
  }
  match graph_json_text_parser_parse_number_token(token) {
    Some(number) => (GraphJsonTextNumberValue(number), 1)
    None =>
      match graph_json_text_parser_parse_qualified_id(tokens, start) {
        Some((id, consumed)) => (GraphJsonTextProxyValue(id), consumed)
        None => (GraphJsonTextNullValue, 0)
      }
  }
}

///|
fn graph_json_text_parser_parse_property(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
) -> (GraphJsonTextPropertyAssignment, Int)? {
  match graph_json_text_parser_parse_property_key(tokens, start) {
    Some((key, key_consumed)) => {
      let mut index = start + key_consumed
      if index >= tokens.length() || tokens[index].lexeme != ":" {
        return None
      }
      index += 1
      let (value, consumed) = graph_json_text_parser_parse_property_value(
        tokens, index,
      )
      index += consumed
      Some((new_graph_json_text_property_assignment(key, value), index - start))
    }
    None => None
  }
}

///|
fn graph_json_text_parser_apply_property_to_node(
  node : @graph.ElkNode,
  property : GraphJsonTextPropertyAssignment,
) -> Unit {
  @graph.node_set_layout_option_string_by_id(
    node,
    graph_json_text_property_key_id(property.key),
    graph_json_text_property_value_to_string(property.value),
  )
}

///|
fn graph_json_text_parser_apply_property_to_port(
  port : @graph.ElkPort,
  property : GraphJsonTextPropertyAssignment,
) -> Unit {
  @graph.port_set_layout_option_string_by_id(
    port,
    graph_json_text_property_key_id(property.key),
    graph_json_text_property_value_to_string(property.value),
  )
}

///|
fn graph_json_text_parser_apply_property_to_edge(
  edge : @graph.ElkEdge,
  property : GraphJsonTextPropertyAssignment,
) -> Unit {
  @graph.edge_set_layout_option_string_by_id(
    edge,
    graph_json_text_property_key_id(property.key),
    graph_json_text_property_value_to_string(property.value),
  )
}

///|
fn graph_json_text_parser_apply_property_to_label(
  label : @graph.ElkLabel,
  property : GraphJsonTextPropertyAssignment,
) -> Unit {
  @graph.label_set_layout_option_string_by_id(
    label,
    graph_json_text_property_key_id(property.key),
    graph_json_text_property_value_to_string(property.value),
  )
}

///|
fn graph_json_text_parser_parse_shape_layout(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  shape : GraphJsonTextShape,
) -> Int {
  let mut index = start
  if index >= tokens.length() || tokens[index].lexeme != "layout" {
    return start
  }
  index += 1
  if index >= tokens.length() || tokens[index].lexeme != "[" {
    return start
  }
  index += 1
  while index < tokens.length() && tokens[index].lexeme != "]" {
    if tokens[index].lexeme == "position" {
      let mut cursor = index + 1
      if cursor < tokens.length() && tokens[cursor].lexeme == ":" {
        cursor += 1
      }
      match graph_json_text_parser_parse_number_at(tokens, cursor) {
        Some((x, x_consumed)) => {
          cursor += x_consumed
          if cursor < tokens.length() && tokens[cursor].lexeme == "," {
            cursor += 1
          }
          match graph_json_text_parser_parse_number_at(tokens, cursor) {
            Some((y, y_consumed)) => {
              cursor += y_consumed
              graph_json_text_shape_set_location(shape, x, y)
              index = cursor
            }
            None => index += 1
          }
        }
        None => index += 1
      }
      continue
    }
    if tokens[index].lexeme == "size" {
      let mut cursor = index + 1
      if cursor < tokens.length() && tokens[cursor].lexeme == ":" {
        cursor += 1
      }
      match graph_json_text_parser_parse_number_at(tokens, cursor) {
        Some((width, width_consumed)) => {
          cursor += width_consumed
          if cursor < tokens.length() && tokens[cursor].lexeme == "," {
            cursor += 1
          }
          match graph_json_text_parser_parse_number_at(tokens, cursor) {
            Some((height, height_consumed)) => {
              cursor += height_consumed
              graph_json_text_shape_set_size(shape, width, height)
              index = cursor
            }
            None => index += 1
          }
        }
        None => index += 1
      }
      continue
    }
    index += 1
  }
  if index < tokens.length() && tokens[index].lexeme == "]" {
    index + 1
  } else {
    index
  }
}

///|
fn graph_json_text_parser_parse_bends(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
) -> Int {
  let mut index = start
  if index >= tokens.length() || tokens[index].lexeme != "bends" {
    return start
  }
  index += 1
  if index < tokens.length() && tokens[index].lexeme == ":" {
    index += 1
  }
  while index < tokens.length() {
    match graph_json_text_parser_parse_number_at(tokens, index) {
      Some((_, consumed_x)) => {
        index += consumed_x
        if index < tokens.length() && tokens[index].lexeme == "," {
          index += 1
        }
        match graph_json_text_parser_parse_number_at(tokens, index) {
          Some((_, consumed_y)) => {
            index += consumed_y
            if index < tokens.length() && tokens[index].lexeme == "|" {
              index += 1
              continue
            }
          }
          None => ()
        }
      }
      None => ()
    }
    break
  }
  index
}

///|
fn graph_json_text_parser_parse_edge_section_body(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  section : @graph.ElkEdgeSection,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  end_lexeme : String,
) -> Int {
  let mut index = start
  while index < tokens.length() && tokens[index].lexeme != end_lexeme {
    if tokens[index].lexeme == "incoming" || tokens[index].lexeme == "outgoing" {
      let is_incoming = tokens[index].lexeme == "incoming"
      let mut cursor = index + 1
      if cursor < tokens.length() && tokens[cursor].lexeme == ":" {
        cursor += 1
      }
      match graph_json_text_parser_parse_qualified_id(tokens, cursor) {
        Some((qualified_id, consumed)) => {
          cursor += consumed
          match
            graph_json_text_parser_resolve_shape(id_to_shape, qualified_id) {
            Some(shape) =>
              if is_incoming {
                @graph.edge_section_set_incoming_shape(section, Some(shape))
              } else {
                @graph.edge_section_set_outgoing_shape(section, Some(shape))
              }
            None => ()
          }
          index = cursor
          continue
        }
        None => ()
      }
    }
    if tokens[index].lexeme == "start" || tokens[index].lexeme == "end" {
      let is_start = tokens[index].lexeme == "start"
      let mut cursor = index + 1
      if cursor < tokens.length() && tokens[cursor].lexeme == ":" {
        cursor += 1
      }
      match graph_json_text_parser_parse_number_at(tokens, cursor) {
        Some((x, consumed_x)) => {
          cursor += consumed_x
          if cursor < tokens.length() && tokens[cursor].lexeme == "," {
            cursor += 1
          }
          match graph_json_text_parser_parse_number_at(tokens, cursor) {
            Some((y, consumed_y)) => {
              cursor += consumed_y
              if is_start {
                @graph.edge_section_set_start(section, x, y)
              } else {
                @graph.edge_section_set_end(section, x, y)
              }
              index = cursor
              continue
            }
            None => ()
          }
        }
        None => ()
      }
    }
    if tokens[index].lexeme == "bends" {
      index = graph_json_text_parser_parse_bends(tokens, index)
      continue
    }
    match graph_json_text_parser_parse_property(tokens, index) {
      Some((_, consumed)) => {
        index += consumed
        continue
      }
      None => ()
    }
    index += 1
  }
  index
}

///|
fn graph_json_text_parser_parse_named_edge_section(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  edge : @graph.ElkEdge,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  section_by_id : Map[String, @graph.ElkEdgeSection],
  pending_outgoing : Array[GraphJsonTextPendingOutgoingSection],
) -> (@graph.ElkEdgeSection, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "section" {
    return None
  }
  let section = @graph.create_edge_section(edge)
  let mut index = start + 1
  if index < tokens.length() &&
    tokens[index].token_type == graph_json_text_lexer_rule_id {
    let section_id = graph_json_text_parser_decode_id(tokens[index].lexeme)
    @graph.edge_section_set_identifier(section, section_id)
    section_by_id[section_id] = section
    index += 1
  }
  if index < tokens.length() && tokens[index].lexeme == "->" {
    index += 1
    while index < tokens.length() {
      match graph_json_text_parser_parse_qualified_id(tokens, index) {
        Some((outgoing_id, consumed)) => {
          pending_outgoing.push(
            new_graph_json_text_pending_outgoing_section(section, outgoing_id),
          )
          index += consumed
          if index < tokens.length() && tokens[index].lexeme == "," {
            index += 1
            continue
          }
        }
        None => ()
      }
      break
    }
  }
  if index < tokens.length() && tokens[index].lexeme == "[" {
    index = graph_json_text_parser_parse_edge_section_body(
      tokens,
      index + 1,
      section,
      id_to_shape,
      "]",
    )
    if index < tokens.length() && tokens[index].lexeme == "]" {
      index += 1
    }
  }
  Some((section, index))
}

///|
fn graph_json_text_parser_parse_single_edge_section(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  edge : @graph.ElkEdge,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkEdgeSection, Int) {
  let section = @graph.create_edge_section(edge)
  let mut index = graph_json_text_parser_parse_edge_section_body(
    tokens, start, section, id_to_shape, "]",
  )
  while index < tokens.length() && tokens[index].lexeme == "|" {
    index += 1
  }
  (section, index)
}

///|
fn graph_json_text_parser_parse_edge_layout(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  edge : @graph.ElkEdge,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> Int {
  let mut index = start
  if index >= tokens.length() || tokens[index].lexeme != "layout" {
    return start
  }
  index += 1
  if index >= tokens.length() || tokens[index].lexeme != "[" {
    return start
  }
  index += 1
  let section_by_id : Map[String, @graph.ElkEdgeSection] = {}
  let pending_outgoing : Array[GraphJsonTextPendingOutgoingSection] = []
  while index < tokens.length() && tokens[index].lexeme != "]" {
    if tokens[index].lexeme == "section" {
      match
        graph_json_text_parser_parse_named_edge_section(
          tokens, index, edge, id_to_shape, section_by_id, pending_outgoing,
        ) {
        Some((_, consumed_index)) => {
          index = consumed_index
          continue
        }
        None => ()
      }
    } else {
      let (_, consumed_index) = graph_json_text_parser_parse_single_edge_section(
        tokens, index, edge, id_to_shape,
      )
      if consumed_index > index {
        index = consumed_index
        continue
      }
    }
    index += 1
  }
  for pending in pending_outgoing {
    match section_by_id.get(pending.target_id) {
      Some(target_section) =>
        @graph.edge_section_add_outgoing_section(pending.source, target_section)
      None =>
        match
          section_by_id.get(
            graph_json_text_parser_last_segment(pending.target_id),
          ) {
          Some(target_section) =>
            @graph.edge_section_add_outgoing_section(pending.source, target_section)
          None => ()
        }
    }
  }
  if index < tokens.length() && tokens[index].lexeme == "]" {
    index + 1
  } else {
    index
  }
}

///|
fn graph_json_text_parser_register_shape(
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  id : String,
  shape : @graph.ElkConnectableShape,
) -> Unit {
  if id != "" {
    id_to_shape[id] = shape
  }
}

///|
fn graph_json_text_parser_parse_label(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  owner : GraphJsonTextLabelOwner,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkLabel, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "label" {
    return None
  }
  let label = @graph.create_label(Some(graph_json_text_label_owner_to_parent(owner)))
  let mut index = start + 1
  if index + 1 < tokens.length() &&
    tokens[index].token_type == graph_json_text_lexer_rule_id &&
    tokens[index + 1].lexeme == ":" {
    @graph.label_set_identifier(
      label,
      graph_json_text_parser_decode_id(tokens[index].lexeme),
    )
    index += 2
  }
  if index < tokens.length() &&
    tokens[index].token_type == graph_json_text_lexer_rule_string {
    @graph.label_set_text(
      label,
      graph_json_text_parser_strip_quotes(tokens[index].lexeme),
    )
    index += 1
  }
  if index < tokens.length() && tokens[index].lexeme == "{" {
    index += 1
    while index < tokens.length() && tokens[index].lexeme != "}" {
      if tokens[index].lexeme == "layout" {
        index = graph_json_text_parser_parse_shape_layout(
          tokens,
          index,
          GraphJsonTextShapeLabel(label),
        )
        continue
      }
      if tokens[index].lexeme == "label" {
        match
          graph_json_text_parser_parse_label(
            tokens,
            index,
            GraphJsonTextLabelOnLabel(label),
            id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      match graph_json_text_parser_parse_property(tokens, index) {
        Some((property, consumed)) => {
          graph_json_text_parser_apply_property_to_label(label, property)
          index += consumed
          continue
        }
        None => ()
      }
      index += 1
    }
    if index < tokens.length() && tokens[index].lexeme == "}" {
      index += 1
    }
  }
  Some((label, index))
}

///|
fn graph_json_text_parser_parse_port(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  parent : @graph.ElkNode,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkPort, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "port" {
    return None
  }
  let mut index = start + 1
  if index >= tokens.length() ||
    tokens[index].token_type != graph_json_text_lexer_rule_id {
    return None
  }
  let port = @graph.create_port(Some(parent))
  let port_id = graph_json_text_parser_decode_id(tokens[index].lexeme)
  @graph.port_set_identifier(port, port_id)
  graph_json_text_parser_register_shape(
    id_to_shape,
    port_id,
    @graph.make_port_shape(port),
  )
  index += 1
  if index < tokens.length() && tokens[index].lexeme == "{" {
    index += 1
    while index < tokens.length() && tokens[index].lexeme != "}" {
      if tokens[index].lexeme == "layout" {
        index = graph_json_text_parser_parse_shape_layout(
          tokens,
          index,
          GraphJsonTextShapePort(port),
        )
        continue
      }
      if tokens[index].lexeme == "label" {
        match
          graph_json_text_parser_parse_label(
            tokens,
            index,
            GraphJsonTextLabelOnPort(port),
            id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      match graph_json_text_parser_parse_property(tokens, index) {
        Some((property, consumed)) => {
          graph_json_text_parser_apply_property_to_port(port, property)
          index += consumed
          continue
        }
        None => ()
      }
      index += 1
    }
    if index < tokens.length() && tokens[index].lexeme == "}" {
      index += 1
    }
  }
  Some((port, index))
}

///|
fn graph_json_text_parser_parse_edge(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  parent : @graph.ElkNode,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkEdge, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "edge" {
    return None
  }
  let edge = @graph.create_edge(Some(parent))
  let mut index = start + 1
  if index + 1 < tokens.length() &&
    tokens[index].token_type == graph_json_text_lexer_rule_id &&
    tokens[index + 1].lexeme == ":" {
    @graph.edge_set_identifier(
      edge,
      graph_json_text_parser_decode_id(tokens[index].lexeme),
    )
    index += 2
  }
  let mut read_sources = false
  while index < tokens.length() {
    if tokens[index].lexeme == "->" {
      index += 1
      break
    }
    match graph_json_text_parser_parse_qualified_id(tokens, index) {
      Some((id, consumed)) => {
        read_sources = true
        match graph_json_text_parser_resolve_shape(id_to_shape, id) {
          Some(shape) => @graph.edge_add_source(edge, shape)
          None => ()
        }
        index += consumed
        if index < tokens.length() && tokens[index].lexeme == "," {
          index += 1
        }
      }
      None => index += 1
    }
  }
  if !read_sources {
    return Some((edge, index))
  }
  while index < tokens.length() {
    match graph_json_text_parser_parse_qualified_id(tokens, index) {
      Some((id, consumed)) => {
        match graph_json_text_parser_resolve_shape(id_to_shape, id) {
          Some(shape) => @graph.edge_add_target(edge, shape)
          None => ()
        }
        index += consumed
        if index < tokens.length() && tokens[index].lexeme == "," {
          index += 1
          continue
        }
      }
      None => ()
    }
    break
  }
  if index < tokens.length() && tokens[index].lexeme == "{" {
    index += 1
    while index < tokens.length() && tokens[index].lexeme != "}" {
      if tokens[index].lexeme == "layout" {
        index = graph_json_text_parser_parse_edge_layout(
          tokens, index, edge, id_to_shape,
        )
        continue
      }
      if tokens[index].lexeme == "label" {
        match
          graph_json_text_parser_parse_label(
            tokens,
            index,
            GraphJsonTextLabelOnEdge(edge),
            id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      match graph_json_text_parser_parse_property(tokens, index) {
        Some((property, consumed)) => {
          graph_json_text_parser_apply_property_to_edge(edge, property)
          index += consumed
          continue
        }
        None => ()
      }
      index += 1
    }
    if index < tokens.length() && tokens[index].lexeme == "}" {
      index += 1
    }
  }
  Some((edge, index))
}

///|
fn graph_json_text_parser_parse_node(
  tokens : Array[ElkGraphJsonLexToken],
  start : Int,
  parent : @graph.ElkNode,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkNode, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "node" {
    return None
  }
  let mut index = start + 1
  if index >= tokens.length() ||
    tokens[index].token_type != graph_json_text_lexer_rule_id {
    return None
  }
  let node = @graph.create_node(Some(parent))
  let node_id = graph_json_text_parser_decode_id(tokens[index].lexeme)
  @graph.node_set_identifier(node, node_id)
  graph_json_text_parser_register_shape(
    id_to_shape,
    node_id,
    @graph.make_node_shape(node),
  )
  index += 1
  if index < tokens.length() && tokens[index].lexeme == "{" {
    index += 1
    while index < tokens.length() && tokens[index].lexeme != "}" {
      if tokens[index].lexeme == "layout" {
        index = graph_json_text_parser_parse_shape_layout(
          tokens,
          index,
          GraphJsonTextShapeNode(node),
        )
        continue
      }
      if tokens[index].lexeme == "label" {
        match
          graph_json_text_parser_parse_label(
            tokens,
            index,
            GraphJsonTextLabelOnNode(node),
            id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      if tokens[index].lexeme == "port" {
        match
          graph_json_text_parser_parse_port(tokens, index, node, id_to_shape) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      if tokens[index].lexeme == "node" {
        match
          graph_json_text_parser_parse_node(tokens, index, node, id_to_shape) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      if tokens[index].lexeme == "edge" {
        match
          graph_json_text_parser_parse_edge(tokens, index, node, id_to_shape) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      match graph_json_text_parser_parse_property(tokens, index) {
        Some((property, consumed)) => {
          graph_json_text_parser_apply_property_to_node(node, property)
          index += consumed
          continue
        }
        None => ()
      }
      index += 1
    }
    if index < tokens.length() && tokens[index].lexeme == "}" {
      index += 1
    }
  }
  Some((node, index))
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_root_node(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkNode {
  self.rule_root_node()
}

///|
pub fn InternalElkGraphJsonParser::rule_root_node(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkNode {
  @graph_json.elk_graph_json_for_graph(
    graph_json_text_parser_rebuild_json(self.tokens),
  ).to_elk()
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_elk_node(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkNode {
  self.rule_elk_node()
}

///|
pub fn InternalElkGraphJsonParser::rule_elk_node(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkNode {
  self.rule_root_node()
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_elk_label(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkLabel {
  self.rule_elk_label()
}

///|
pub fn InternalElkGraphJsonParser::rule_elk_label(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkLabel {
  let root = @graph.create_graph()
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  match
    graph_json_text_parser_parse_label(
      self.tokens,
      0,
      GraphJsonTextLabelOnNode(root),
      id_to_shape,
    ) {
    Some((label, _)) => label
    None => @graph.create_label(Some(@graph.make_node_label_parent(root)))
  }
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_elk_port(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkPort {
  self.rule_elk_port()
}

///|
pub fn InternalElkGraphJsonParser::rule_elk_port(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkPort {
  let root = @graph.create_graph()
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  match graph_json_text_parser_parse_port(self.tokens, 0, root, id_to_shape) {
    Some((port, _)) => port
    None => @graph.create_port(Some(root))
  }
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_elk_edge(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkEdge {
  self.rule_elk_edge()
}

///|
pub fn InternalElkGraphJsonParser::rule_elk_edge(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkEdge {
  let root = @graph.create_graph()
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  match graph_json_text_parser_parse_edge(self.tokens, 0, root, id_to_shape) {
    Some((edge, _)) => edge
    None => @graph.create_edge(Some(root))
  }
}

///|
pub fn InternalElkGraphJsonParser::rule_shape_layout(
  self : InternalElkGraphJsonParser,
  current : GraphJsonTextShape,
) -> GraphJsonTextShape {
  ignore(graph_json_text_parser_parse_shape_layout(self.tokens, 0, current))
  current
}

///|
pub fn InternalElkGraphJsonParser::rule_edge_layout(
  self : InternalElkGraphJsonParser,
  edge : @graph.ElkEdge,
) -> @graph.ElkEdge {
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  ignore(
    graph_json_text_parser_parse_edge_layout(self.tokens, 0, edge, id_to_shape),
  )
  edge
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_elk_single_edge_section(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkEdgeSection {
  self.rule_elk_single_edge_section()
}

///|
pub fn InternalElkGraphJsonParser::rule_elk_single_edge_section(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkEdgeSection {
  let root = @graph.create_graph()
  let edge = @graph.create_edge(Some(root))
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  let (section, _) = graph_json_text_parser_parse_single_edge_section(
    self.tokens,
    0,
    edge,
    id_to_shape,
  )
  section
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_elk_edge_section(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkEdgeSection {
  self.rule_elk_edge_section()
}

///|
pub fn InternalElkGraphJsonParser::rule_elk_edge_section(
  self : InternalElkGraphJsonParser,
) -> @graph.ElkEdgeSection {
  let root = @graph.create_graph()
  let edge = @graph.create_edge(Some(root))
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  let section_by_id : Map[String, @graph.ElkEdgeSection] = {}
  let pending_outgoing : Array[GraphJsonTextPendingOutgoingSection] = []
  match
    graph_json_text_parser_parse_named_edge_section(
      self.tokens,
      0,
      edge,
      id_to_shape,
      section_by_id,
      pending_outgoing,
    ) {
    Some((section, _)) => section
    None => @graph.create_edge_section(edge)
  }
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_elk_bend_point(
  self : InternalElkGraphJsonParser,
) -> (Double, Double) {
  self.rule_elk_bend_point()
}

///|
pub fn InternalElkGraphJsonParser::rule_elk_bend_point(
  self : InternalElkGraphJsonParser,
) -> (Double, Double) {
  let first = graph_json_text_parser_parse_number_at(self.tokens, 0)
  let second = graph_json_text_parser_parse_number_at(self.tokens, 2)
  match first {
    Some((x, _)) =>
      match second {
        Some((y, _)) => (x, y)
        None => (x, 0.0)
      }
    None => (0.0, 0.0)
  }
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_qualified_id(
  self : InternalElkGraphJsonParser,
) -> String {
  self.rule_qualified_id()
}

///|
pub fn InternalElkGraphJsonParser::rule_qualified_id(
  self : InternalElkGraphJsonParser,
) -> String {
  match graph_json_text_parser_parse_qualified_id(self.tokens, 0) {
    Some((qualified_id, _)) => qualified_id
    None => ""
  }
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_number(
  self : InternalElkGraphJsonParser,
) -> Double {
  self.rule_number()
}

///|
pub fn InternalElkGraphJsonParser::rule_number(
  self : InternalElkGraphJsonParser,
) -> Double {
  match graph_json_text_parser_parse_number_at(self.tokens, 0) {
    Some((number, _)) => number
    None => 0.0
  }
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_property(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyAssignment {
  self.rule_property()
}

///|
pub fn InternalElkGraphJsonParser::rule_property(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyAssignment {
  match graph_json_text_parser_parse_property(self.tokens, 0) {
    Some((property, _)) => property
    None =>
      new_graph_json_text_property_assignment(
        GraphJsonTextCustomProperty(""),
        GraphJsonTextNullValue,
      )
  }
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_property_key(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyKey {
  self.rule_property_key()
}

///|
pub fn InternalElkGraphJsonParser::rule_property_key(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyKey {
  match graph_json_text_parser_parse_property_key(self.tokens, 0) {
    Some((key, _)) => key
    None => GraphJsonTextCustomProperty("")
  }
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_string_value(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyValue {
  self.rule_string_value()
}

///|
pub fn InternalElkGraphJsonParser::rule_string_value(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyValue {
  let (value, _) = graph_json_text_parser_parse_property_value(self.tokens, 0)
  value
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_qualified_id_value(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyValue {
  self.rule_qualified_id_value()
}

///|
pub fn InternalElkGraphJsonParser::rule_qualified_id_value(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyValue {
  let (value, _) = graph_json_text_parser_parse_property_value(self.tokens, 0)
  value
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_number_value(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyValue {
  self.rule_number_value()
}

///|
pub fn InternalElkGraphJsonParser::rule_number_value(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyValue {
  let (value, _) = graph_json_text_parser_parse_property_value(self.tokens, 0)
  value
}

///|
pub fn InternalElkGraphJsonParser::entry_rule_boolean_value(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyValue {
  self.rule_boolean_value()
}

///|
pub fn InternalElkGraphJsonParser::rule_boolean_value(
  self : InternalElkGraphJsonParser,
) -> GraphJsonTextPropertyValue {
  let (value, _) = graph_json_text_parser_parse_property_value(self.tokens, 0)
  value
}
