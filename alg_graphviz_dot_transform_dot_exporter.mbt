///|
pub let dot_exporter_def_spacing_small : Double = 20.0

///|
pub let dot_exporter_def_spacing_large : Double = 40.0

///|
pub let dot_exporter_def_spacing_xlarge : Double = 60.0

///|
pub let dot_exporter_dpi : Float = 72.0

///|
pub let dot_exporter_option_edge_labels_placement = "org.eclipse.elk.edgeLabels.placement"

///|
pub let dot_exporter_option_font_name = "org.eclipse.elk.font.name"

///|
pub let dot_exporter_option_font_size = "org.eclipse.elk.font.size"

///|
let dot_exporter_font_size_mult : Double = 1.4

///|
let dot_exporter_min_out_char = ' '

///|
let dot_exporter_max_out_char = '~'

///|
pub struct DotExporter {
  _dummy : Unit
}

///|
pub fn new_dot_exporter() -> DotExporter {
  { _dummy: () }
}

///|
pub fn dot_exporter_create_attribute(
  name : String,
  value : String,
) -> DotAttribute {
  let attribute = dot_create_attribute()
  attribute.set_name(Some(name))
  attribute.set_value(Some(value))
  attribute
}

///|
pub fn dot_exporter_create_attribute_int(
  name : String,
  value : Int,
) -> DotAttribute {
  dot_exporter_create_attribute(name, "\"" + value.to_string() + "\"")
}

///|
pub fn dot_exporter_create_attribute_float(
  name : String,
  value : Float,
) -> DotAttribute {
  dot_exporter_create_attribute(name, "\"" + value.to_string() + "\"")
}

///|
pub fn dot_exporter_create_attribute_double(
  name : String,
  value : Double,
) -> DotAttribute {
  dot_exporter_create_attribute(name, "\"" + value.to_string() + "\"")
}

///|
pub fn dot_exporter_set_general_node_attributes(
  statements : Array[DotStatement],
) -> Array[DotAttribute] {
  let node_attr_statement = dot_create_attribute_statement()
  node_attr_statement.set_type(Some(dot_attribute_type_node()))
  let node_attrs = node_attr_statement.get_attributes()
  statements.push(dot_statement_attribute_statement(node_attr_statement))
  node_attrs.push(dot_exporter_create_attribute(dot_attr_shape, "box"))
  node_attrs.push(dot_exporter_create_attribute(dot_attr_fixedsize, "true"))
  node_attrs
}

///|
pub fn DotExporter::set_graph_attributes(
  self : DotExporter,
  statements : Array[DotStatement],
  parent_node : ElkNode,
) -> Unit {
  let _ = self
  let _ = statements
  let _ = parent_node
}

///|
pub fn DotExporter::set_general_node_attributes(
  self : DotExporter,
  statements : Array[DotStatement],
) -> Array[DotAttribute] {
  let _ = self
  dot_exporter_set_general_node_attributes(statements)
}

///|
pub fn DotExporter::set_general_edge_attributes(
  self : DotExporter,
  statements : Array[DotStatement],
) -> Array[DotAttribute] {
  let _ = self
  dot_exporter_set_general_edge_attributes(statements)
}

///|
pub fn dot_exporter_set_general_edge_attributes(
  statements : Array[DotStatement],
) -> Array[DotAttribute] {
  let edge_attr_statement = dot_create_attribute_statement()
  edge_attr_statement.set_type(Some(dot_attribute_type_edge()))
  let edge_attrs = edge_attr_statement.get_attributes()
  statements.push(dot_statement_attribute_statement(edge_attr_statement))
  edge_attrs.push(dot_exporter_create_attribute(dot_attr_edgedir, "none"))
  edge_attrs
}

///|
fn dot_exporter_parse_edge_label_placement(
  value : String?,
) -> EdgeLabelPlacement {
  let normalized = match value {
    Some(v) => v.trim().to_string().to_upper()
    None => ""
  }
  if normalized == "HEAD" || normalized.has_suffix(".HEAD") {
    Head
  } else if normalized == "TAIL" || normalized.has_suffix(".TAIL") {
    Tail
  } else {
    Centered
  }
}

///|
fn dot_exporter_parse_int_token(text : String?) -> Int? {
  let normalized = match text {
    Some(v) => v.trim().to_string()
    None => ""
  }
  if normalized.is_empty() {
    return None
  }
  let parsed_int : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
    normalized,
  )
  match parsed_int {
    Ok(value) => Some(value)
    Err(_) =>
      match dot_exporter_parse_double_token(normalized) {
        Some(value) => Some(value.to_int())
        None => None
      }
  }
}

///|
fn dot_exporter_parse_edge_label_spacing(edge : ElkEdge) -> Double {
  match edge_layout_option_string_value(edge, spacing_edge_label.get_id()) {
    Some(raw_value) =>
      match dot_exporter_parse_double_token(raw_value) {
        Some(value) => value
        None => spacing_edge_label.get_default()
      }
    None => spacing_edge_label.get_default()
  }
}

///|
fn dot_exporter_append_label_line(current : String, line : String) -> String {
  if current.is_empty() {
    line
  } else {
    current + "\n" + line
  }
}

///|
pub fn dot_exporter_set_edge_labels(
  elkedge : ElkEdge,
  attributes : Array[DotAttribute],
  is_vertical : Bool,
) -> Unit {
  let labels = edge_labels(elkedge)
  if labels.is_empty() {
    return
  }

  let mut mid_label = ""
  let mut head_label = ""
  let mut tail_label = ""
  let mut font_name : String? = None
  let mut font_size = 0
  let mut is_center_font_name = false
  let mut is_center_font_size = false

  for label in labels {
    let placement = dot_exporter_parse_edge_label_placement(
      label_layout_option_string_value(
        label, dot_exporter_option_edge_labels_placement,
      ),
    )
    let mut take_font_name = false
    let mut take_font_size = false
    match placement {
      Head => {
        take_font_name = font_name is None
        take_font_size = font_size <= 0
        head_label = dot_exporter_append_label_line(
          head_label,
          label_text(label),
        )
      }
      Tail => {
        take_font_name = font_name is None
        take_font_size = font_size <= 0
        tail_label = dot_exporter_append_label_line(
          tail_label,
          label_text(label),
        )
      }
      Centered => {
        take_font_name = font_name is None || !is_center_font_name
        is_center_font_name = true
        take_font_size = font_size <= 0 || !is_center_font_size
        is_center_font_size = true
        mid_label = dot_exporter_append_label_line(mid_label, label_text(label))
      }
    }
    if take_font_name {
      font_name = label_layout_option_string_value(
        label, dot_exporter_option_font_name,
      )
    }
    if take_font_size {
      match
        dot_exporter_parse_int_token(
          label_layout_option_string_value(label, dot_exporter_option_font_size),
        ) {
        Some(parsed_size) => {
          font_size = parsed_size
          if font_size > 0 {
            font_size = (font_size.to_double() * dot_exporter_font_size_mult).to_int()
          }
        }
        None => ()
      }
    }
  }

  if !mid_label.is_empty() {
    let mut label_spacing = dot_exporter_parse_edge_label_spacing(elkedge)
    if label_spacing < 1.0 {
      label_spacing = 0.0
    }
    let chars_to_add = label_spacing.to_int() - 1
    let mut index = 0
    while index < chars_to_add {
      if is_vertical {
        mid_label = mid_label + "O"
      } else {
        mid_label = mid_label + "\nO"
      }
      index += 1
    }
    attributes.push(
      dot_exporter_create_attribute(
        dot_attr_label,
        dot_exporter_create_string(mid_label),
      ),
    )
  }
  if !head_label.is_empty() {
    attributes.push(
      dot_exporter_create_attribute(
        dot_attr_headlabel,
        dot_exporter_create_string(head_label),
      ),
    )
  }
  if !tail_label.is_empty() {
    attributes.push(
      dot_exporter_create_attribute(
        dot_attr_taillabel,
        dot_exporter_create_string(tail_label),
      ),
    )
  }
  match font_name {
    Some(name) =>
      if !name.is_empty() {
        attributes.push(
          dot_exporter_create_attribute(dot_attr_fontname, "\"" + name + "\""),
        )
      }
    None => ()
  }
  if font_size > 0 {
    attributes.push(
      dot_exporter_create_attribute_int(dot_attr_fontsize, font_size),
    )
  }
}

///|
pub fn DotExporter::set_edge_labels(
  self : DotExporter,
  elkedge : ElkEdge,
  attributes : Array[DotAttribute],
  is_vertical : Bool,
) -> Unit {
  let _ = self
  dot_exporter_set_edge_labels(elkedge, attributes, is_vertical)
}

///|
pub fn dot_exporter_is_inside_graph(node : ElkNode, root : ElkNode) -> Bool {
  let mut current : ElkNode? = Some(node)
  while current is Some(value) {
    if value == root {
      return true
    }
    current = node_parent(value)
  }
  false
}

///|
pub fn DotExporter::is_inside_graph(
  self : DotExporter,
  node : ElkNode,
  root : ElkNode,
) -> Bool {
  let _ = self
  dot_exporter_is_inside_graph(node, root)
}

///|
pub fn dot_exporter_create_string(label : String) -> String {
  let escape_buffer = @buffer.new()
  escape_buffer.write_char('"')
  let mut index = 0
  while index < label.length() {
    let c = label[index].unsafe_to_char()
    if c == '"' || c == '\\' || c > dot_exporter_max_out_char {
      escape_buffer.write_char('_')
    } else if c == '\n' {
      escape_buffer.write_string("\\n")
    } else if c >= dot_exporter_min_out_char {
      escape_buffer.write_char(c)
    }
    index += 1
  }
  escape_buffer.write_char('"')
  escape_buffer.to_string()
}

///|
pub fn dot_exporter_create_attribute_map(
  attributes : Array[DotAttribute],
) -> Map[String, String] {
  let attribute_map : Map[String, String] = {}
  for attribute in attributes {
    match (attribute.get_name(), attribute.get_value()) {
      (Some(name), Some(value)) => attribute_map[name] = value
      _ => ()
    }
  }
  attribute_map
}

///|
fn dot_exporter_char_at(source : String, index : Int) -> Char {
  source[index].unsafe_to_char()
}

///|
fn dot_exporter_split_on_quote_and_semicolon(text : String) -> Array[String] {
  let tokens : Array[String] = []
  let mut token_start = 0
  let mut index = 0
  while index < text.length() {
    let current = dot_exporter_char_at(text, index)
    if current == '"' || current == ';' {
      if token_start < index {
        let token = text
          .substring(start=token_start, end=index)
          .trim()
          .to_string()
        if !token.is_empty() {
          tokens.push(token)
        }
      }
      token_start = index + 1
    }
    index += 1
  }
  if token_start < text.length() {
    let token = text.substring(start=token_start).trim().to_string()
    if !token.is_empty() {
      tokens.push(token)
    }
  }
  tokens
}

///|
fn dot_exporter_split_on_whitespace(text : String) -> Array[String] {
  let tokens : Array[String] = []
  let mut token_start = 0
  let mut index = 0
  while index < text.length() {
    let current = dot_exporter_char_at(text, index)
    if current == ' ' || current == '\t' || current == '\n' || current == '\r' {
      if token_start < index {
        tokens.push(text.substring(start=token_start, end=index))
      }
      token_start = index + 1
    }
    index += 1
  }
  if token_start < text.length() {
    tokens.push(text.substring(start=token_start))
  }
  tokens
}

///|
fn dot_exporter_parse_double_token(text : String) -> Double? {
  let normalized = text.trim().to_string()
  if normalized.is_empty() {
    return None
  }
  let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    normalized,
  )
  match parsed {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn dot_exporter_parse_point_token(token : String) -> KVector? {
  let normalized = token.trim().to_string()
  if normalized.is_empty() {
    return None
  }
  let parts = normalized.split(",").to_array()
  if parts.length() != 2 {
    return None
  }
  match
    (
      dot_exporter_parse_double_token(parts[0].to_string()),
      dot_exporter_parse_double_token(parts[1].to_string()),
    ) {
    (Some(x), Some(y)) => Some(new_kvector_xy(x, y))
    _ => None
  }
}

///|
fn dot_exporter_suffix_after_first_comma(token : String) -> String {
  let mut index = 0
  while index < token.length() {
    if dot_exporter_char_at(token, index) == ',' {
      return token.substring(start=index + 1)
    }
    index += 1
  }
  token
}

///|
pub fn dot_exporter_parse_spline_points(
  pos_string : String,
  splines : Array[KVectorChain],
  offset : KVector,
) -> Pair[KVector, KVector] {
  let mut source_point : KVector? = None
  let mut target_point : KVector? = None

  for spline_token in dot_exporter_split_on_quote_and_semicolon(pos_string) {
    let point_list = new_kvector_chain()
    for token in dot_exporter_split_on_whitespace(spline_token) {
      if token.has_prefix("s") {
        if source_point is None {
          match
            dot_exporter_parse_point_token(
              dot_exporter_suffix_after_first_comma(token),
            ) {
            Some(point) => {
              ignore(point.add(offset))
              source_point = Some(point)
            }
            None => ()
          }
        }
      } else if token.has_prefix("e") {
        if target_point is None {
          match
            dot_exporter_parse_point_token(
              dot_exporter_suffix_after_first_comma(token),
            ) {
            Some(point) => {
              ignore(point.add(offset))
              target_point = Some(point)
            }
            None => ()
          }
        }
      } else {
        match dot_exporter_parse_point_token(token) {
          Some(point) => {
            ignore(point.add(offset))
            point_list.add_last_vector(point)
          }
          None => ()
        }
      }
    }
    splines.push(point_list)
  }

  let result : Pair[KVector, KVector] = pair_create()
  result.set_first(source_point)
  result.set_second(target_point)
  result
}
