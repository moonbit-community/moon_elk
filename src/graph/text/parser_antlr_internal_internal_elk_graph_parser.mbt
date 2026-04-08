///|
pub struct GraphTextPendingOutgoingSection {
  source : @graph.ElkEdgeSection
  target_id : String
}

///|
pub fn new_graph_text_pending_outgoing_section(
  source : @graph.ElkEdgeSection,
  target_id : String,
) -> GraphTextPendingOutgoingSection {
  { source, target_id }
}

///|
pub struct InternalElkGraphParser {
  tokens : Array[ElkGraphLexToken]
  grammar_access : ElkGraphGrammarAccess
}

///|
pub fn new_internal_elk_graph_parser(
  tokens : Array[ElkGraphLexToken],
  grammar_access? : ElkGraphGrammarAccess = new_elk_graph_grammar_access(),
) -> InternalElkGraphParser {
  { tokens, grammar_access }
}

///|
pub fn InternalElkGraphParser::get_token_names(
  self : InternalElkGraphParser,
) -> Array[String] {
  ignore(self)
  graph_text_lexer_token_names
}

///|
pub fn InternalElkGraphParser::get_grammar_file_name(
  self : InternalElkGraphParser,
) -> String {
  ignore(self)
  "InternalElkGraph.g"
}

///|
pub fn InternalElkGraphParser::get_first_rule_name(
  self : InternalElkGraphParser,
) -> String {
  ignore(self)
  "RootNode"
}

///|
pub fn InternalElkGraphParser::get_grammar_access(
  self : InternalElkGraphParser,
) -> ElkGraphGrammarAccess {
  self.grammar_access
}

///|
fn graph_text_parser_decode_id(lexeme : String) -> String {
  if lexeme.length() > 0 && lexeme.has_prefix("^") {
    lexeme.unsafe_substring(start=1, end=lexeme.length())
  } else {
    lexeme
  }
}

///|
fn graph_text_parser_strip_quotes(text : String) -> String {
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
fn graph_text_parser_parse_double(text : String) -> Double? {
  let parsed : Result[Double, Error] = try? @string.parse_double(text)
  match parsed {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn graph_text_parser_parse_number_token(token : ElkGraphLexToken) -> Double? {
  if token.token_type == graph_text_lexer_rule_signed_int ||
    token.token_type == graph_text_lexer_rule_int ||
    token.token_type == graph_text_lexer_rule_float {
    graph_text_parser_parse_double(token.lexeme)
  } else {
    None
  }
}

///|
fn graph_text_parser_parse_number_at(
  tokens : Array[ElkGraphLexToken],
  start : Int,
) -> (Double, Int)? {
  if start >= tokens.length() {
    return None
  }
  match graph_text_parser_parse_number_token(tokens[start]) {
    Some(value) => Some((value, 1))
    None => None
  }
}

///|
fn graph_text_parser_last_segment(qualified_id : String) -> String {
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
fn graph_text_parser_has_dot(text : String) -> Bool {
  let mut idx = 0
  while idx < text.length() {
    if text[idx].unsafe_to_char() == '.' {
      return true
    }
    idx += 1
  }
  false
}

///|
fn graph_text_parser_parent_qualified_id(qualified_id : String) -> String {
  let mut last_dot = -1
  let mut idx = 0
  while idx < qualified_id.length() {
    if qualified_id[idx].unsafe_to_char() == '.' {
      last_dot = idx
    }
    idx += 1
  }
  if last_dot > 0 {
    qualified_id.unsafe_substring(start=0, end=last_dot)
  } else {
    ""
  }
}

///|
fn graph_text_parser_join_qualified_id(prefix : String, id : String) -> String {
  if prefix == "" {
    id
  } else if id == "" {
    prefix
  } else {
    prefix + "." + id
  }
}

///|
fn graph_text_parser_parse_qualified_id(
  tokens : Array[ElkGraphLexToken],
  start : Int,
) -> (String, Int)? {
  if start >= tokens.length() ||
    tokens[start].token_type != graph_text_lexer_rule_id {
    return None
  }
  let mut index = start
  let mut result = graph_text_parser_decode_id(tokens[index].lexeme)
  index += 1
  while index + 1 < tokens.length() &&
        tokens[index].lexeme == "." &&
        tokens[index + 1].token_type == graph_text_lexer_rule_id {
    result = result +
      "." +
      graph_text_parser_decode_id(tokens[index + 1].lexeme)
    index += 2
  }
  Some((result, index - start))
}

///|
fn graph_text_parser_resolve_shape(
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  scope_qualified_id : String,
  qualified_id : String,
) -> @graph.ElkConnectableShape? {
  if graph_text_parser_has_dot(qualified_id) {
    match id_to_shape.get(qualified_id) {
      Some(shape) => return Some(shape)
      None => ()
    }
  }

  let mut scope = scope_qualified_id
  while scope != "" {
    let candidate = graph_text_parser_join_qualified_id(scope, qualified_id)
    match id_to_shape.get(candidate) {
      Some(shape) => return Some(shape)
      None => ()
    }
    scope = graph_text_parser_parent_qualified_id(scope)
  }

  if graph_text_parser_has_dot(qualified_id) {
    None
  } else {
    id_to_shape.get(qualified_id)
  }
}

///|
fn graph_text_parser_parse_property_key(
  tokens : Array[ElkGraphLexToken],
  start : Int,
) -> (GraphTextPropertyKey, Int)? {
  match graph_text_parser_parse_qualified_id(tokens, start) {
    Some((id, consumed)) =>
      match @core.layout_meta_data_service_get_option_data_by_suffix(id) {
        Some(option_data) => Some((LayoutOption(option_data), consumed))
        None => Some((CustomProperty(id), consumed))
      }
    None => None
  }
}

///|
fn graph_text_parser_parse_property_value(
  tokens : Array[ElkGraphLexToken],
  start : Int,
) -> (GraphTextPropertyValue, Int) {
  if start >= tokens.length() {
    return (NullValue, 0)
  }
  let token = tokens[start]
  if token.token_type == graph_text_lexer_rule_string {
    return (StringValue(graph_text_parser_strip_quotes(token.lexeme)), 1)
  }
  if token.lexeme == "null" {
    return (NullValue, 1)
  }
  if token.lexeme == "true" {
    return (BooleanValue(true), 1)
  }
  if token.lexeme == "false" {
    return (BooleanValue(false), 1)
  }
  match graph_text_parser_parse_number_token(token) {
    Some(number) => (NumberValue(number), 1)
    None =>
      match graph_text_parser_parse_qualified_id(tokens, start) {
        Some((id, consumed)) => (ProxyValue(id), consumed)
        None => (NullValue, 0)
      }
  }
}

///|
fn graph_text_parser_parse_property(
  tokens : Array[ElkGraphLexToken],
  start : Int,
) -> (GraphTextPropertyAssignment, Int)? {
  match graph_text_parser_parse_property_key(tokens, start) {
    Some((key, key_consumed)) => {
      let mut index = start + key_consumed
      if index >= tokens.length() || tokens[index].lexeme != ":" {
        return None
      }
      index += 1
      let (value, consumed) = graph_text_parser_parse_property_value(
        tokens, index,
      )
      index += consumed
      Some((new_graph_text_property_assignment(key, value), index - start))
    }
    None => None
  }
}

///|
fn graph_text_parser_apply_property_to_node(
  node : @graph.ElkNode,
  property : GraphTextPropertyAssignment,
) -> Unit {
  @graph.node_set_layout_option_string_by_id(
    node,
    graph_text_property_key_id(property.key),
    graph_text_property_value_to_string(property.value),
  )
}

///|
fn graph_text_parser_apply_property_to_port(
  port : @graph.ElkPort,
  property : GraphTextPropertyAssignment,
) -> Unit {
  @graph.port_set_layout_option_string_by_id(
    port,
    graph_text_property_key_id(property.key),
    graph_text_property_value_to_string(property.value),
  )
}

///|
fn graph_text_parser_apply_property_to_edge(
  edge : @graph.ElkEdge,
  property : GraphTextPropertyAssignment,
) -> Unit {
  @graph.edge_set_layout_option_string_by_id(
    edge,
    graph_text_property_key_id(property.key),
    graph_text_property_value_to_string(property.value),
  )
}

///|
fn graph_text_parser_apply_property_to_label(
  label : @graph.ElkLabel,
  property : GraphTextPropertyAssignment,
) -> Unit {
  @graph.label_set_layout_option_string_by_id(
    label,
    graph_text_property_key_id(property.key),
    graph_text_property_value_to_string(property.value),
  )
}

///|
fn graph_text_parser_parse_shape_layout(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  shape : GraphTextShape,
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
      match graph_text_parser_parse_number_at(tokens, cursor) {
        Some((x, x_consumed)) => {
          cursor += x_consumed
          if cursor < tokens.length() && tokens[cursor].lexeme == "," {
            cursor += 1
          }
          match graph_text_parser_parse_number_at(tokens, cursor) {
            Some((y, y_consumed)) => {
              cursor += y_consumed
              graph_text_shape_set_location(shape, x, y)
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
      match graph_text_parser_parse_number_at(tokens, cursor) {
        Some((width, width_consumed)) => {
          cursor += width_consumed
          if cursor < tokens.length() && tokens[cursor].lexeme == "," {
            cursor += 1
          }
          match graph_text_parser_parse_number_at(tokens, cursor) {
            Some((height, height_consumed)) => {
              cursor += height_consumed
              graph_text_shape_set_size(shape, width, height)
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
fn graph_text_parser_parse_bends(
  tokens : Array[ElkGraphLexToken],
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
    match graph_text_parser_parse_number_at(tokens, index) {
      Some((_, consumed_x)) => {
        index += consumed_x
        if index < tokens.length() && tokens[index].lexeme == "," {
          index += 1
        }
        match graph_text_parser_parse_number_at(tokens, index) {
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
fn graph_text_parser_parse_edge_section_body(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  section : @graph.ElkEdgeSection,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  scope_qualified_id : String,
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
      match graph_text_parser_parse_qualified_id(tokens, cursor) {
        Some((qualified_id, consumed)) => {
          cursor += consumed
          match
            graph_text_parser_resolve_shape(
              id_to_shape, scope_qualified_id, qualified_id,
            ) {
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
      match graph_text_parser_parse_number_at(tokens, cursor) {
        Some((x, consumed_x)) => {
          cursor += consumed_x
          if cursor < tokens.length() && tokens[cursor].lexeme == "," {
            cursor += 1
          }
          match graph_text_parser_parse_number_at(tokens, cursor) {
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
      index = graph_text_parser_parse_bends(tokens, index)
      continue
    }
    match graph_text_parser_parse_property(tokens, index) {
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
fn graph_text_parser_parse_named_edge_section(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  edge : @graph.ElkEdge,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  scope_qualified_id : String,
  section_by_id : Map[String, @graph.ElkEdgeSection],
  pending_outgoing : Array[GraphTextPendingOutgoingSection],
) -> (@graph.ElkEdgeSection, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "section" {
    return None
  }
  let section = @graph.create_edge_section(edge)
  let mut index = start + 1
  if index < tokens.length() &&
    tokens[index].token_type == graph_text_lexer_rule_id {
    let section_id = graph_text_parser_decode_id(tokens[index].lexeme)
    @graph.edge_section_set_identifier(section, section_id)
    section_by_id[section_id] = section
    index += 1
  }
  if index < tokens.length() && tokens[index].lexeme == "->" {
    index += 1
    while index < tokens.length() {
      match graph_text_parser_parse_qualified_id(tokens, index) {
        Some((outgoing_id, consumed)) => {
          pending_outgoing.push(
            new_graph_text_pending_outgoing_section(section, outgoing_id),
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
    index = graph_text_parser_parse_edge_section_body(
      tokens,
      index + 1,
      section,
      id_to_shape,
      scope_qualified_id,
      "]",
    )
    if index < tokens.length() && tokens[index].lexeme == "]" {
      index += 1
    }
  }
  Some((section, index))
}

///|
fn graph_text_parser_parse_single_edge_section(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  edge : @graph.ElkEdge,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  scope_qualified_id : String,
) -> (@graph.ElkEdgeSection, Int) {
  let section = @graph.create_edge_section(edge)
  let mut index = graph_text_parser_parse_edge_section_body(
    tokens, start, section, id_to_shape, scope_qualified_id, "]",
  )
  while index < tokens.length() && tokens[index].lexeme == "|" {
    index += 1
  }
  (section, index)
}

///|
fn graph_text_parser_parse_edge_layout(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  edge : @graph.ElkEdge,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  scope_qualified_id : String,
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
  let pending_outgoing : Array[GraphTextPendingOutgoingSection] = []
  while index < tokens.length() && tokens[index].lexeme != "]" {
    if tokens[index].lexeme == "section" {
      match
        graph_text_parser_parse_named_edge_section(
          tokens, index, edge, id_to_shape, scope_qualified_id, section_by_id, pending_outgoing,
        ) {
        Some((_, consumed_index)) => {
          index = consumed_index
          continue
        }
        None => ()
      }
    } else {
      let (_, consumed_index) = graph_text_parser_parse_single_edge_section(
        tokens, index, edge, id_to_shape, scope_qualified_id,
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
          section_by_id.get(graph_text_parser_last_segment(pending.target_id)) {
          Some(target_section) =>
            @graph.edge_section_add_outgoing_section(
              pending.source,
              target_section,
            )
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
fn graph_text_parser_register_shape(
  id_to_shape : Map[String, @graph.ElkConnectableShape],
  id : String,
  shape : @graph.ElkConnectableShape,
) -> Unit {
  if id != "" {
    id_to_shape[id] = shape
  }
}

///|
fn graph_text_parser_parse_label(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  owner : GraphTextLabelOwner,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkLabel, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "label" {
    return None
  }
  let label = @graph.create_label(Some(graph_text_label_owner_to_parent(owner)))
  let mut index = start + 1
  if index + 1 < tokens.length() &&
    tokens[index].token_type == graph_text_lexer_rule_id &&
    tokens[index + 1].lexeme == ":" {
    @graph.label_set_identifier(
      label,
      graph_text_parser_decode_id(tokens[index].lexeme),
    )
    index += 2
  }
  if index < tokens.length() &&
    tokens[index].token_type == graph_text_lexer_rule_string {
    @graph.label_set_text(
      label,
      graph_text_parser_strip_quotes(tokens[index].lexeme),
    )
    index += 1
  }
  if index < tokens.length() && tokens[index].lexeme == "{" {
    index += 1
    while index < tokens.length() && tokens[index].lexeme != "}" {
      if tokens[index].lexeme == "layout" {
        index = graph_text_parser_parse_shape_layout(
          tokens,
          index,
          ShapeLabel(label),
        )
        continue
      }
      if tokens[index].lexeme == "label" {
        match
          graph_text_parser_parse_label(
            tokens,
            index,
            LabelOnLabel(label),
            id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      match graph_text_parser_parse_property(tokens, index) {
        Some((property, consumed)) => {
          graph_text_parser_apply_property_to_label(label, property)
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
fn graph_text_parser_parse_port(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  parent : @graph.ElkNode,
  parent_qualified_id : String,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkPort, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "port" {
    return None
  }
  let mut index = start + 1
  if index >= tokens.length() ||
    tokens[index].token_type != graph_text_lexer_rule_id {
    return None
  }
  let port = @graph.create_port(Some(parent))
  let port_id = graph_text_parser_decode_id(tokens[index].lexeme)
  @graph.port_set_identifier(port, port_id)
  let port_qualified_id = graph_text_parser_join_qualified_id(
    parent_qualified_id, port_id,
  )
  graph_text_parser_register_shape(
    id_to_shape,
    port_id,
    @graph.make_port_shape(port),
  )
  if port_qualified_id != port_id {
    graph_text_parser_register_shape(
      id_to_shape,
      port_qualified_id,
      @graph.make_port_shape(port),
    )
  }
  index += 1
  if index < tokens.length() && tokens[index].lexeme == "{" {
    index += 1
    while index < tokens.length() && tokens[index].lexeme != "}" {
      if tokens[index].lexeme == "layout" {
        index = graph_text_parser_parse_shape_layout(
          tokens,
          index,
          ShapePort(port),
        )
        continue
      }
      if tokens[index].lexeme == "label" {
        match
          graph_text_parser_parse_label(
            tokens,
            index,
            LabelOnPort(port),
            id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      match graph_text_parser_parse_property(tokens, index) {
        Some((property, consumed)) => {
          graph_text_parser_apply_property_to_port(port, property)
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
fn graph_text_parser_parse_edge(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  parent : @graph.ElkNode,
  scope_qualified_id : String,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkEdge, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "edge" {
    return None
  }
  let edge = @graph.create_edge(Some(parent))
  let mut index = start + 1
  if index + 1 < tokens.length() &&
    tokens[index].token_type == graph_text_lexer_rule_id &&
    tokens[index + 1].lexeme == ":" {
    @graph.edge_set_identifier(
      edge,
      graph_text_parser_decode_id(tokens[index].lexeme),
    )
    index += 2
  }
  let mut read_sources = false
  while index < tokens.length() {
    if tokens[index].lexeme == "->" {
      index += 1
      break
    }
    match graph_text_parser_parse_qualified_id(tokens, index) {
      Some((id, consumed)) => {
        read_sources = true
        match
          graph_text_parser_resolve_shape(id_to_shape, scope_qualified_id, id) {
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
    match graph_text_parser_parse_qualified_id(tokens, index) {
      Some((id, consumed)) => {
        match
          graph_text_parser_resolve_shape(id_to_shape, scope_qualified_id, id) {
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
        index = graph_text_parser_parse_edge_layout(
          tokens, index, edge, id_to_shape, scope_qualified_id,
        )
        continue
      }
      if tokens[index].lexeme == "label" {
        match
          graph_text_parser_parse_label(
            tokens,
            index,
            LabelOnEdge(edge),
            id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      match graph_text_parser_parse_property(tokens, index) {
        Some((property, consumed)) => {
          graph_text_parser_apply_property_to_edge(edge, property)
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
fn graph_text_parser_parse_node(
  tokens : Array[ElkGraphLexToken],
  start : Int,
  parent : @graph.ElkNode,
  parent_qualified_id : String,
  id_to_shape : Map[String, @graph.ElkConnectableShape],
) -> (@graph.ElkNode, Int)? {
  if start >= tokens.length() || tokens[start].lexeme != "node" {
    return None
  }
  let mut index = start + 1
  if index >= tokens.length() ||
    tokens[index].token_type != graph_text_lexer_rule_id {
    return None
  }
  let node = @graph.create_node(Some(parent))
  let node_id = graph_text_parser_decode_id(tokens[index].lexeme)
  @graph.node_set_identifier(node, node_id)
  let node_qualified_id = graph_text_parser_join_qualified_id(
    parent_qualified_id, node_id,
  )
  graph_text_parser_register_shape(
    id_to_shape,
    node_id,
    @graph.make_node_shape(node),
  )
  if node_qualified_id != node_id {
    graph_text_parser_register_shape(
      id_to_shape,
      node_qualified_id,
      @graph.make_node_shape(node),
    )
  }
  index += 1
  if index < tokens.length() && tokens[index].lexeme == "{" {
    index += 1
    while index < tokens.length() && tokens[index].lexeme != "}" {
      if tokens[index].lexeme == "layout" {
        index = graph_text_parser_parse_shape_layout(
          tokens,
          index,
          ShapeNode(node),
        )
        continue
      }
      if tokens[index].lexeme == "label" {
        match
          graph_text_parser_parse_label(
            tokens,
            index,
            LabelOnNode(node),
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
          graph_text_parser_parse_port(
            tokens, index, node, node_qualified_id, id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      if tokens[index].lexeme == "node" {
        match
          graph_text_parser_parse_node(
            tokens, index, node, node_qualified_id, id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      if tokens[index].lexeme == "edge" {
        match
          graph_text_parser_parse_edge(
            tokens, index, node, node_qualified_id, id_to_shape,
          ) {
          Some((_, next_index)) => {
            index = next_index
            continue
          }
          None => ()
        }
      }
      match graph_text_parser_parse_property(tokens, index) {
        Some((property, consumed)) => {
          graph_text_parser_apply_property_to_node(node, property)
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
pub fn InternalElkGraphParser::entry_rule_root_node(
  self : InternalElkGraphParser,
) -> @graph.ElkNode {
  self.rule_root_node()
}

///|
pub fn InternalElkGraphParser::rule_root_node(
  self : InternalElkGraphParser,
) -> @graph.ElkNode {
  let root = @graph.create_graph()
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  let mut root_qualified_id = ""
  let mut index = 0
  if index < self.tokens.length() && self.tokens[index].lexeme == "graph" {
    index += 1
    if index < self.tokens.length() &&
      self.tokens[index].token_type == graph_text_lexer_rule_id {
      let root_id = graph_text_parser_decode_id(self.tokens[index].lexeme)
      @graph.node_set_identifier(root, root_id)
      root_qualified_id = root_id
      graph_text_parser_register_shape(
        id_to_shape,
        root_id,
        @graph.make_node_shape(root),
      )
      index += 1
    }
  }
  if index < self.tokens.length() && self.tokens[index].lexeme == "layout" {
    index = graph_text_parser_parse_shape_layout(
      self.tokens,
      index,
      ShapeNode(root),
    )
  }
  while index < self.tokens.length() {
    if self.tokens[index].lexeme == "label" {
      match
        graph_text_parser_parse_label(
          self.tokens,
          index,
          LabelOnNode(root),
          id_to_shape,
        ) {
        Some((_, next_index)) => {
          index = next_index
          continue
        }
        None => ()
      }
    }
    if self.tokens[index].lexeme == "port" {
      match
        graph_text_parser_parse_port(
          self.tokens,
          index,
          root,
          root_qualified_id,
          id_to_shape,
        ) {
        Some((_, next_index)) => {
          index = next_index
          continue
        }
        None => ()
      }
    }
    if self.tokens[index].lexeme == "node" {
      match
        graph_text_parser_parse_node(
          self.tokens,
          index,
          root,
          root_qualified_id,
          id_to_shape,
        ) {
        Some((_, next_index)) => {
          index = next_index
          continue
        }
        None => ()
      }
    }
    if self.tokens[index].lexeme == "edge" {
      match
        graph_text_parser_parse_edge(
          self.tokens,
          index,
          root,
          root_qualified_id,
          id_to_shape,
        ) {
        Some((_, next_index)) => {
          index = next_index
          continue
        }
        None => ()
      }
    }
    match graph_text_parser_parse_property(self.tokens, index) {
      Some((property, consumed)) => {
        graph_text_parser_apply_property_to_node(root, property)
        index += consumed
        continue
      }
      None => ()
    }
    index += 1
  }
  root
}

///|
pub fn InternalElkGraphParser::entry_rule_elk_node(
  self : InternalElkGraphParser,
) -> @graph.ElkNode {
  self.rule_elk_node()
}

///|
pub fn InternalElkGraphParser::rule_elk_node(
  self : InternalElkGraphParser,
) -> @graph.ElkNode {
  let root = @graph.create_graph()
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  match graph_text_parser_parse_node(self.tokens, 0, root, "", id_to_shape) {
    Some((node, _)) => node
    None => @graph.create_node(Some(root))
  }
}

///|
pub fn InternalElkGraphParser::entry_rule_elk_label(
  self : InternalElkGraphParser,
) -> @graph.ElkLabel {
  self.rule_elk_label()
}

///|
pub fn InternalElkGraphParser::rule_elk_label(
  self : InternalElkGraphParser,
) -> @graph.ElkLabel {
  let root = @graph.create_graph()
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  match
    graph_text_parser_parse_label(
      self.tokens,
      0,
      LabelOnNode(root),
      id_to_shape,
    ) {
    Some((label, _)) => label
    None => @graph.create_label(Some(@graph.make_node_label_parent(root)))
  }
}

///|
pub fn InternalElkGraphParser::entry_rule_elk_port(
  self : InternalElkGraphParser,
) -> @graph.ElkPort {
  self.rule_elk_port()
}

///|
pub fn InternalElkGraphParser::rule_elk_port(
  self : InternalElkGraphParser,
) -> @graph.ElkPort {
  let root = @graph.create_graph()
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  match graph_text_parser_parse_port(self.tokens, 0, root, "", id_to_shape) {
    Some((port, _)) => port
    None => @graph.create_port(Some(root))
  }
}

///|
pub fn InternalElkGraphParser::entry_rule_elk_edge(
  self : InternalElkGraphParser,
) -> @graph.ElkEdge {
  self.rule_elk_edge()
}

///|
pub fn InternalElkGraphParser::rule_elk_edge(
  self : InternalElkGraphParser,
) -> @graph.ElkEdge {
  let root = @graph.create_graph()
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  match graph_text_parser_parse_edge(self.tokens, 0, root, "", id_to_shape) {
    Some((edge, _)) => edge
    None => @graph.create_edge(Some(root))
  }
}

///|
pub fn InternalElkGraphParser::rule_shape_layout(
  self : InternalElkGraphParser,
  current : GraphTextShape,
) -> GraphTextShape {
  ignore(graph_text_parser_parse_shape_layout(self.tokens, 0, current))
  current
}

///|
pub fn InternalElkGraphParser::rule_edge_layout(
  self : InternalElkGraphParser,
  edge : @graph.ElkEdge,
) -> @graph.ElkEdge {
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  ignore(
    graph_text_parser_parse_edge_layout(self.tokens, 0, edge, id_to_shape, ""),
  )
  edge
}

///|
pub fn InternalElkGraphParser::entry_rule_elk_single_edge_section(
  self : InternalElkGraphParser,
) -> @graph.ElkEdgeSection {
  self.rule_elk_single_edge_section()
}

///|
pub fn InternalElkGraphParser::rule_elk_single_edge_section(
  self : InternalElkGraphParser,
) -> @graph.ElkEdgeSection {
  let root = @graph.create_graph()
  let edge = @graph.create_edge(Some(root))
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  let (section, _) = graph_text_parser_parse_single_edge_section(
    self.tokens,
    0,
    edge,
    id_to_shape,
    "",
  )
  section
}

///|
pub fn InternalElkGraphParser::entry_rule_elk_edge_section(
  self : InternalElkGraphParser,
) -> @graph.ElkEdgeSection {
  self.rule_elk_edge_section()
}

///|
pub fn InternalElkGraphParser::rule_elk_edge_section(
  self : InternalElkGraphParser,
) -> @graph.ElkEdgeSection {
  let root = @graph.create_graph()
  let edge = @graph.create_edge(Some(root))
  let id_to_shape : Map[String, @graph.ElkConnectableShape] = {}
  let section_by_id : Map[String, @graph.ElkEdgeSection] = {}
  let pending_outgoing : Array[GraphTextPendingOutgoingSection] = []
  match
    graph_text_parser_parse_named_edge_section(
      self.tokens,
      0,
      edge,
      id_to_shape,
      "",
      section_by_id,
      pending_outgoing,
    ) {
    Some((section, _)) => section
    None => @graph.create_edge_section(edge)
  }
}

///|
pub fn InternalElkGraphParser::entry_rule_elk_bend_point(
  self : InternalElkGraphParser,
) -> (Double, Double) {
  self.rule_elk_bend_point()
}

///|
pub fn InternalElkGraphParser::rule_elk_bend_point(
  self : InternalElkGraphParser,
) -> (Double, Double) {
  let first = graph_text_parser_parse_number_at(self.tokens, 0)
  let second = graph_text_parser_parse_number_at(self.tokens, 2)
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
pub fn InternalElkGraphParser::entry_rule_qualified_id(
  self : InternalElkGraphParser,
) -> String {
  self.rule_qualified_id()
}

///|
pub fn InternalElkGraphParser::rule_qualified_id(
  self : InternalElkGraphParser,
) -> String {
  match graph_text_parser_parse_qualified_id(self.tokens, 0) {
    Some((qualified_id, _)) => qualified_id
    None => ""
  }
}

///|
pub fn InternalElkGraphParser::entry_rule_number(
  self : InternalElkGraphParser,
) -> Double {
  self.rule_number()
}

///|
pub fn InternalElkGraphParser::rule_number(
  self : InternalElkGraphParser,
) -> Double {
  match graph_text_parser_parse_number_at(self.tokens, 0) {
    Some((number, _)) => number
    None => 0.0
  }
}

///|
pub fn InternalElkGraphParser::entry_rule_property(
  self : InternalElkGraphParser,
) -> GraphTextPropertyAssignment {
  self.rule_property()
}

///|
pub fn InternalElkGraphParser::rule_property(
  self : InternalElkGraphParser,
) -> GraphTextPropertyAssignment {
  match graph_text_parser_parse_property(self.tokens, 0) {
    Some((property, _)) => property
    None => new_graph_text_property_assignment(CustomProperty(""), NullValue)
  }
}

///|
pub fn InternalElkGraphParser::entry_rule_property_key(
  self : InternalElkGraphParser,
) -> GraphTextPropertyKey {
  self.rule_property_key()
}

///|
pub fn InternalElkGraphParser::rule_property_key(
  self : InternalElkGraphParser,
) -> GraphTextPropertyKey {
  match graph_text_parser_parse_property_key(self.tokens, 0) {
    Some((key, _)) => key
    None => CustomProperty("")
  }
}

///|
pub fn InternalElkGraphParser::entry_rule_string_value(
  self : InternalElkGraphParser,
) -> GraphTextPropertyValue {
  self.rule_string_value()
}

///|
pub fn InternalElkGraphParser::rule_string_value(
  self : InternalElkGraphParser,
) -> GraphTextPropertyValue {
  let (value, _) = graph_text_parser_parse_property_value(self.tokens, 0)
  value
}

///|
pub fn InternalElkGraphParser::entry_rule_qualified_id_value(
  self : InternalElkGraphParser,
) -> GraphTextPropertyValue {
  self.rule_qualified_id_value()
}

///|
pub fn InternalElkGraphParser::rule_qualified_id_value(
  self : InternalElkGraphParser,
) -> GraphTextPropertyValue {
  let (value, _) = graph_text_parser_parse_property_value(self.tokens, 0)
  value
}

///|
pub fn InternalElkGraphParser::entry_rule_number_value(
  self : InternalElkGraphParser,
) -> GraphTextPropertyValue {
  self.rule_number_value()
}

///|
pub fn InternalElkGraphParser::rule_number_value(
  self : InternalElkGraphParser,
) -> GraphTextPropertyValue {
  let (value, _) = graph_text_parser_parse_property_value(self.tokens, 0)
  value
}

///|
pub fn InternalElkGraphParser::entry_rule_boolean_value(
  self : InternalElkGraphParser,
) -> GraphTextPropertyValue {
  self.rule_boolean_value()
}

///|
pub fn InternalElkGraphParser::rule_boolean_value(
  self : InternalElkGraphParser,
) -> GraphTextPropertyValue {
  let (value, _) = graph_text_parser_parse_property_value(self.tokens, 0)
  value
}
