///|
pub struct ElkGraphJsonImportBuilder {
  graph : String?
  json_graph : Json?
  importer_maybe : @core.Maybe[JsonImporter]?
  lenient : Bool
}

///|
pub struct ElkGraphJsonExportBuilder {
  graph : @graph.ElkNode
  pretty_print : Bool
  omit_zero_position : Bool
  omit_zero_dimension : Bool
  omit_layout_information : Bool
  short_layout_option_keys : Bool
  omit_unknown_layout_options : Bool
}

///|

///|
priv enum JsonShapeCoordsMode {
  ShapeInherit
  ShapeParent
  ShapeRoot
}

///|
priv enum JsonEdgeCoordsMode {
  EdgeInherit
  EdgeContainer
  EdgeParent
  EdgeRoot
}

///|
let _graph_json_layered_algorithm_id = @layered.layered_algorithm_id

///|
pub fn elk_graph_json_for_graph(graph : String) -> ElkGraphJsonImportBuilder {
  { graph: Some(graph), json_graph: None, importer_maybe: None, lenient: true }
}

///|
pub fn elk_graph_json_for_json_graph(graph : Json) -> ElkGraphJsonImportBuilder {
  { graph: None, json_graph: Some(graph), importer_maybe: None, lenient: true }
}

///|
pub fn elk_graph_json_for_elk_graph(
  graph : @graph.ElkNode,
) -> ElkGraphJsonExportBuilder {
  {
    graph,
    pretty_print: false,
    omit_zero_position: true,
    omit_zero_dimension: true,
    omit_layout_information: false,
    short_layout_option_keys: true,
    omit_unknown_layout_options: true,
  }
}

///|
fn parse_non_lenient_json(graph : String) -> Json {
  let parsed = try @core_json.parse(graph) catch {
    _ => {
      @core.layout_runtime_report_json_import("Failed to parse JSON input.")
      Json::object({})
    }
  } noraise {
    parsed => parsed
  }
  parsed
}

///|
fn char_at(source : String, index : Int) -> Char {
  source[index].unsafe_to_char()
}

///|
fn safe_slice(source : String, start : Int, end_ : Int) -> String {
  try source[start:end_] catch {
    _ => ""
  } noraise {
    value => value.to_string()
  }
}

///|
fn safe_slice_from(source : String, start : Int) -> String {
  try source[start:] catch {
    _ => ""
  } noraise {
    value => value.to_string()
  }
}

///|
fn strip_json_comments(source : String) -> String {
  let output = @buffer.new()
  let mut index = 0
  let mut in_string = false
  let mut escaped = false
  let mut in_line_comment = false
  let mut in_block_comment = false
  while index < source.length() {
    let current = char_at(source, index)
    let next = if index + 1 < source.length() {
      Some(char_at(source, index + 1))
    } else {
      None
    }
    if in_line_comment {
      if current == '\n' {
        in_line_comment = false
        output.write_char(current)
      }
      index += 1
      continue
    }
    if in_block_comment {
      if current == '*' && next == Some('/') {
        in_block_comment = false
        index += 2
      } else {
        index += 1
      }
      continue
    }
    if in_string {
      output.write_char(current)
      if escaped {
        escaped = false
      } else if current == '\\' {
        escaped = true
      } else if current == '"' {
        in_string = false
      }
      index += 1
      continue
    }
    if current == '"' {
      in_string = true
      output.write_char(current)
      index += 1
      continue
    }
    if current == '/' && next == Some('/') {
      in_line_comment = true
      index += 2
      continue
    }
    if current == '/' && next == Some('*') {
      in_block_comment = true
      index += 2
      continue
    }
    output.write_char(current)
    index += 1
  }
  output.to_string()
}

///|
fn replace_single_quotes(source : String) -> String {
  let output = @buffer.new()
  let mut index = 0
  let mut in_double_string = false
  let mut escaped = false
  while index < source.length() {
    let current = char_at(source, index)
    if in_double_string {
      output.write_char(current)
      if escaped {
        escaped = false
      } else if current == '\\' {
        escaped = true
      } else if current == '"' {
        in_double_string = false
      }
      index += 1
      continue
    }
    if current == '"' {
      in_double_string = true
      output.write_char(current)
      index += 1
      continue
    }
    if current == '\'' {
      output.write_char('"')
      index += 1
      continue
    }
    output.write_char(current)
    index += 1
  }
  output.to_string()
}

///|
fn replace_semicolons(source : String) -> String {
  let output = @buffer.new()
  let mut index = 0
  let mut in_string = false
  let mut escaped = false
  while index < source.length() {
    let current = char_at(source, index)
    if in_string {
      output.write_char(current)
      if escaped {
        escaped = false
      } else if current == '\\' {
        escaped = true
      } else if current == '"' {
        in_string = false
      }
      index += 1
      continue
    }
    if current == '"' {
      in_string = true
      output.write_char(current)
      index += 1
      continue
    }
    if current == ';' {
      output.write_char(',')
      index += 1
      continue
    }
    output.write_char(current)
    index += 1
  }
  output.to_string()
}

///|
fn is_unquoted_key_start(current : Char) -> Bool {
  current.is_ascii_alphabetic() || current == '_'
}

///|
fn is_unquoted_key_part(current : Char) -> Bool {
  current.is_ascii_alphabetic() ||
  current.is_ascii_digit() ||
  current == '_' ||
  current == '-' ||
  current == '.'
}

///|
fn context_expects_key(
  context_is_object : Array[Bool],
  context_expect_key : Array[Bool],
) -> Bool {
  if context_is_object.is_empty() {
    false
  } else {
    let top = context_is_object.length() - 1
    context_is_object[top] && context_expect_key[top]
  }
}

///|
fn set_context_expect_key(
  context_is_object : Array[Bool],
  context_expect_key : Array[Bool],
  expect_key : Bool,
) -> Unit {
  if context_is_object.is_empty() {
    return
  }
  let top = context_is_object.length() - 1
  if context_is_object[top] {
    context_expect_key[top] = expect_key
  }
}

///|
fn quote_unquoted_object_keys(source : String) -> String {
  let output = @buffer.new()
  let context_is_object : Array[Bool] = []
  let context_expect_key : Array[Bool] = []
  let mut index = 0
  let mut in_string = false
  let mut escaped = false
  while index < source.length() {
    let current = char_at(source, index)
    if in_string {
      output.write_char(current)
      if escaped {
        escaped = false
      } else if current == '\\' {
        escaped = true
      } else if current == '"' {
        in_string = false
      }
      index += 1
      continue
    }
    if current == '"' {
      in_string = true
      output.write_char(current)
      index += 1
      continue
    }
    if current == '{' {
      context_is_object.push(true)
      context_expect_key.push(true)
      output.write_char(current)
      index += 1
      continue
    }
    if current == '[' {
      context_is_object.push(false)
      context_expect_key.push(false)
      output.write_char(current)
      index += 1
      continue
    }
    if current == '}' || current == ']' {
      if !context_is_object.is_empty() {
        ignore(context_is_object.pop())
        ignore(context_expect_key.pop())
      }
      output.write_char(current)
      index += 1
      continue
    }
    if current == ':' {
      set_context_expect_key(context_is_object, context_expect_key, false)
      output.write_char(current)
      index += 1
      continue
    }
    if current == ',' {
      set_context_expect_key(context_is_object, context_expect_key, true)
      output.write_char(current)
      index += 1
      continue
    }
    if context_expects_key(context_is_object, context_expect_key) &&
      is_unquoted_key_start(current) {
      let token_start = index
      index += 1
      while index < source.length() &&
            is_unquoted_key_part(char_at(source, index)) {
        index += 1
      }
      let token = safe_slice(source, token_start, index)
      let mut next = index
      while next < source.length() &&
            char_at(source, next).is_ascii_whitespace() {
        next += 1
      }
      if next < source.length() && char_at(source, next) == ':' {
        output.write_char('"')
        output.write_string(token)
        output.write_char('"')
      } else {
        output.write_string(token)
      }
      continue
    }
    output.write_char(current)
    index += 1
  }
  output.to_string()
}

///|
fn parse_lenient_json(graph : String) -> Json {
  let normalized = quote_unquoted_object_keys(
    replace_semicolons(replace_single_quotes(strip_json_comments(graph))),
  )
  parse_non_lenient_json(normalized)
}

///|
fn parse_json_graph(graph : String, lenient : Bool) -> Json {
  if lenient {
    parse_lenient_json(graph)
  } else {
    parse_non_lenient_json(graph)
  }
}

///|
fn ensure_json_object(value : Json) -> Map[String, Json] {
  match value {
    Object(obj) => obj
    _ => {
      @core.layout_runtime_report_json_import(
        "Top-level element of the graph must be a json object.",
      )
      {}
    }
  }
}

///|
fn json_value_as_string(value : Json) -> String? {
  match value {
    String(text) => Some(text)
    Number(number, repr~) => {
      ignore(repr)
      Some(number.to_string())
    }
    True => Some("true")
    False => Some("false")
    _ => None
  }
}

///|
fn json_id_to_string(value : Json) -> String? {
  match value {
    String(id) => Some(id)
    Number(number, repr~) => {
      ignore(repr)
      if number == number.floor() {
        Some(number.to_int().to_string())
      } else {
        None
      }
    }
    _ => None
  }
}

///|
fn required_json_id(json_obj : Map[String, Json]) -> String {
  match json_obj.get("id") {
    Some(id_json) =>
      match json_id_to_string(id_json) {
        Some(id) => id
        None => {
          @core.layout_runtime_report_json_import(
            "Id must be a string or an integer.",
          )
          ""
        }
      }
    None => {
      @core.layout_runtime_report_json_import("Every element must have an id.")
      ""
    }
  }
}

///|
fn json_array_field(
  json_obj : Map[String, Json],
  field : String,
) -> Array[Json]? {
  match json_obj.get(field) {
    Some(Array(values)) => Some(values)
    _ => None
  }
}

///|
fn json_object_field(
  json_obj : Map[String, Json],
  field : String,
) -> Map[String, Json]? {
  match json_obj.get(field) {
    Some(Object(value)) => Some(value)
    _ => None
  }
}

///|
fn is_direction_option_id(id : String) -> Bool {
  id == "direction" ||
  id == "elk.direction" ||
  id == "org.eclipse.elk.direction"
}

///|
fn is_algorithm_option_id(id : String) -> Bool {
  id == "algorithm" ||
  id == "elk.algorithm" ||
  id == "org.eclipse.elk.algorithm"
}

///|
fn is_no_layout_option_id(id : String) -> Bool {
  id == "noLayout" || id == "elk.noLayout" || id == "org.eclipse.elk.noLayout"
}

///|
fn is_shape_coords_option_id(id : String) -> Bool {
  id == "shapeCoords" ||
  id == "json.shapeCoords" ||
  id == "elk.json.shapeCoords" ||
  id == "org.eclipse.elk.json.shapeCoords"
}

///|
fn is_edge_coords_option_id(id : String) -> Bool {
  id == "edgeCoords" ||
  id == "json.edgeCoords" ||
  id == "elk.json.edgeCoords" ||
  id == "org.eclipse.elk.json.edgeCoords"
}

///|
fn parse_bool_option(text : String) -> Bool? {
  let normalized = text.trim().to_string()
  match normalized {
    "true" | "TRUE" | "True" => Some(true)
    "false" | "FALSE" | "False" => Some(false)
    _ => None
  }
}

///|
fn canonical_layout_option_id(id : String) -> String {
  if id == "direction" || id == "elk.direction" {
    "org.eclipse.elk.direction"
  } else if id == "algorithm" || id == "elk.algorithm" {
    "org.eclipse.elk.algorithm"
  } else if id == "noLayout" || id == "elk.noLayout" {
    "org.eclipse.elk.noLayout"
  } else if is_shape_coords_option_id(id) {
    "org.eclipse.elk.json.shapeCoords"
  } else if is_edge_coords_option_id(id) {
    "org.eclipse.elk.json.edgeCoords"
  } else if id.has_prefix("elk.") {
    "org.eclipse.elk." + safe_slice_from(id, 4)
  } else {
    id
  }
}

///|
fn short_layout_option_id(id : String) -> String {
  if id == "org.eclipse.elk.direction" {
    return "elk.direction"
  }
  if id == "org.eclipse.elk.algorithm" {
    return "elk.algorithm"
  }
  if id == "org.eclipse.elk.noLayout" {
    return "elk.noLayout"
  }
  if id == "org.eclipse.elk.json.shapeCoords" {
    return "elk.json.shapeCoords"
  }
  if id == "org.eclipse.elk.json.edgeCoords" {
    return "elk.json.edgeCoords"
  }
  if id.has_prefix("org.eclipse.elk.") {
    return "elk." + safe_slice_from(id, 16)
  }
  id
}

///|
fn is_known_layout_option_id(id : String) -> Bool {
  let canonical = canonical_layout_option_id(id)
  canonical == "org.eclipse.elk.direction" ||
  canonical == "org.eclipse.elk.algorithm" ||
  canonical == "org.eclipse.elk.noLayout" ||
  canonical == "org.eclipse.elk.json.shapeCoords" ||
  canonical == "org.eclipse.elk.json.edgeCoords" ||
  canonical == @core.aspect_ratio.get_id() ||
  canonical == @core.spacing_node_node.get_id() ||
  canonical == @core.spacing_edge_node.get_id() ||
  canonical == @core.content_alignment.get_id()
}

///|
fn parse_shape_coords_mode(text : String) -> JsonShapeCoordsMode {
  let normalized = text.trim().to_string()
  match normalized {
    "ROOT" | "root" => ShapeRoot
    "PARENT" | "parent" => ShapeParent
    "INHERIT" | "inherit" => ShapeInherit
    _ => ShapeInherit
  }
}

///|
fn parse_edge_coords_mode(text : String) -> JsonEdgeCoordsMode {
  let normalized = text.trim().to_string()
  match normalized {
    "ROOT" | "root" => EdgeRoot
    "PARENT" | "parent" => EdgeParent
    "CONTAINER" | "container" => EdgeContainer
    "INHERIT" | "inherit" => EdgeInherit
    _ => EdgeInherit
  }
}

///|
fn layout_option_lookup_keys(option_id : String) -> Array[String] {
  let canonical = canonical_layout_option_id(option_id)
  let short = short_layout_option_id(canonical)
  let keys = [option_id]
  if !keys.contains(canonical) {
    keys.push(canonical)
  }
  if !keys.contains(short) {
    keys.push(short)
  }
  if canonical.has_prefix("org.eclipse.elk.") {
    let suffix = safe_slice_from(canonical, 16)
    if !keys.contains(suffix) {
      keys.push(suffix)
    }
  }
  keys
}

///|
fn node_layout_option_value_by_any_id(
  node : @graph.ElkNode,
  option_id : String,
) -> String? {
  for key in layout_option_lookup_keys(option_id) {
    match @graph.node_layout_option_string_value(node, key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn port_layout_option_value_by_any_id(
  port : @graph.ElkPort,
  option_id : String,
) -> String? {
  for key in layout_option_lookup_keys(option_id) {
    match @graph.port_layout_option_string_value(port, key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn _edge_layout_option_value_by_any_id(
  edge : @graph.ElkEdge,
  option_id : String,
) -> String? {
  for key in layout_option_lookup_keys(option_id) {
    match @graph.edge_layout_option_string_value(edge, key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn _label_layout_option_value_by_any_id(
  label : @graph.ElkLabel,
  option_id : String,
) -> String? {
  for key in layout_option_lookup_keys(option_id) {
    match @graph.label_layout_option_string_value(label, key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
pub fn ElkGraphJsonImportBuilder::remember_importer(
  self : ElkGraphJsonImportBuilder,
  maybe : @core.Maybe[JsonImporter],
) -> ElkGraphJsonImportBuilder {
  {
    graph: self.graph,
    json_graph: self.json_graph,
    importer_maybe: Some(maybe),
    lenient: self.lenient,
  }
}

///|
pub fn ElkGraphJsonImportBuilder::lenient(
  self : ElkGraphJsonImportBuilder,
  be_lenient : Bool,
) -> ElkGraphJsonImportBuilder {
  {
    graph: self.graph,
    json_graph: self.json_graph,
    importer_maybe: self.importer_maybe,
    lenient: be_lenient,
  }
}

///|
fn import_builder_graph_object(
  builder : ElkGraphJsonImportBuilder,
) -> Map[String, Json] {
  match builder.json_graph {
    Some(json_graph) => ensure_json_object(json_graph)
    None =>
      match builder.graph {
        Some(text) =>
          ensure_json_object(parse_json_graph(text, builder.lenient))
        None => {
          @core.layout_runtime_report_json_import("Graph input is missing.")
          {}
        }
      }
  }
}

///|
pub fn ElkGraphJsonImportBuilder::to_elk(
  self : ElkGraphJsonImportBuilder,
) -> @graph.ElkNode {
  @core.layout_runtime_clear_error()
  let json_graph = import_builder_graph_object(self)
  let importer = new_json_importer()
  let root = importer.transform(json_graph)
  match self.importer_maybe {
    Some(importer_maybe) => importer_maybe.set(Some(importer))
    None => ()
  }
  root
}

///|
pub fn ElkGraphJsonExportBuilder::pretty_print(
  self : ElkGraphJsonExportBuilder,
  pretty : Bool,
) -> ElkGraphJsonExportBuilder {
  {
    graph: self.graph,
    pretty_print: pretty,
    omit_zero_position: self.omit_zero_position,
    omit_zero_dimension: self.omit_zero_dimension,
    omit_layout_information: self.omit_layout_information,
    short_layout_option_keys: self.short_layout_option_keys,
    omit_unknown_layout_options: self.omit_unknown_layout_options,
  }
}

///|
pub fn ElkGraphJsonExportBuilder::short_layout_option_keys(
  self : ElkGraphJsonExportBuilder,
  short_keys : Bool,
) -> ElkGraphJsonExportBuilder {
  {
    graph: self.graph,
    pretty_print: self.pretty_print,
    omit_zero_position: self.omit_zero_position,
    omit_zero_dimension: self.omit_zero_dimension,
    omit_layout_information: self.omit_layout_information,
    short_layout_option_keys: short_keys,
    omit_unknown_layout_options: self.omit_unknown_layout_options,
  }
}

///|
pub fn ElkGraphJsonExportBuilder::omit_zero_positions(
  self : ElkGraphJsonExportBuilder,
  omit_zero_pos : Bool,
) -> ElkGraphJsonExportBuilder {
  {
    graph: self.graph,
    pretty_print: self.pretty_print,
    omit_zero_position: omit_zero_pos,
    omit_zero_dimension: self.omit_zero_dimension,
    omit_layout_information: self.omit_layout_information,
    short_layout_option_keys: self.short_layout_option_keys,
    omit_unknown_layout_options: self.omit_unknown_layout_options,
  }
}

///|
pub fn ElkGraphJsonExportBuilder::omit_zero_dimension(
  self : ElkGraphJsonExportBuilder,
  omit_zero_dim : Bool,
) -> ElkGraphJsonExportBuilder {
  {
    graph: self.graph,
    pretty_print: self.pretty_print,
    omit_zero_position: self.omit_zero_position,
    omit_zero_dimension: omit_zero_dim,
    omit_layout_information: self.omit_layout_information,
    short_layout_option_keys: self.short_layout_option_keys,
    omit_unknown_layout_options: self.omit_unknown_layout_options,
  }
}

///|
pub fn ElkGraphJsonExportBuilder::omit_layout(
  self : ElkGraphJsonExportBuilder,
  omit_layout : Bool,
) -> ElkGraphJsonExportBuilder {
  {
    graph: self.graph,
    pretty_print: self.pretty_print,
    omit_zero_position: self.omit_zero_position,
    omit_zero_dimension: self.omit_zero_dimension,
    omit_layout_information: omit_layout,
    short_layout_option_keys: self.short_layout_option_keys,
    omit_unknown_layout_options: self.omit_unknown_layout_options,
  }
}

///|
pub fn ElkGraphJsonExportBuilder::omit_unknown_layout_options(
  self : ElkGraphJsonExportBuilder,
  omit_unknown : Bool,
) -> ElkGraphJsonExportBuilder {
  {
    graph: self.graph,
    pretty_print: self.pretty_print,
    omit_zero_position: self.omit_zero_position,
    omit_zero_dimension: self.omit_zero_dimension,
    omit_layout_information: self.omit_layout_information,
    short_layout_option_keys: self.short_layout_option_keys,
    omit_unknown_layout_options: omit_unknown,
  }
}

///|
pub fn ElkGraphJsonExportBuilder::to_json(
  self : ElkGraphJsonExportBuilder,
) -> String {
  let exporter = new_json_exporter(self)
  let exported = exporter_export(exporter, self.graph)
  if self.pretty_print {
    exported.stringify(indent=2)
  } else {
    exported.stringify()
  }
}
