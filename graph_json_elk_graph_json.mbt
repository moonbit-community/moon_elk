///|
pub struct ElkGraphJsonImportBuilder {
  graph : String?
  json_graph : Json?
  importer_maybe : Maybe[JsonImporter]?
  lenient : Bool
}

///|
pub struct ElkGraphJsonExportBuilder {
  graph : ElkNode
  pretty_print : Bool
  omit_zero_position : Bool
  omit_zero_dimension : Bool
  omit_layout_information : Bool
  short_layout_option_keys : Bool
  omit_unknown_layout_options : Bool
}

///|
pub struct JsonImporter {
  mut input_model : Map[String, Json]?
  node_id_map : Map[String, ElkNode]
  port_id_map : Map[String, ElkPort]
  node_json_map : Map[ElkNode, Map[String, Json]]
  port_json_map : Map[ElkPort, Map[String, Json]]
  edge_json_map : Map[ElkEdge, Map[String, Json]]
  label_json_map : Map[ElkLabel, Map[String, Json]]
  edge_original_parent_map : Map[ElkEdge, ElkNode]
}

///|
priv struct JsonExporter {
  omit_zero_position : Bool
  omit_zero_dimension : Bool
  omit_layout_information : Bool
  short_layout_option_keys : Bool
  omit_unknown_layout_options : Bool
  node_id_map : Map[ElkNode, String]
  edge_id_map : Map[ElkEdge, String]
  used_ids : Map[String, Bool]
  mut node_id_counter : Int
  mut edge_id_counter : Int
  mut duplicate_id_counter : Int
}

///|
pub fn new_json_importer() -> JsonImporter {
  {
    input_model: None,
    node_id_map: {},
    port_id_map: {},
    node_json_map: {},
    port_json_map: {},
    edge_json_map: {},
    label_json_map: {},
    edge_original_parent_map: {},
  }
}

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
pub fn elk_graph_json_for_graph(graph : String) -> ElkGraphJsonImportBuilder {
  { graph: Some(graph), json_graph: None, importer_maybe: None, lenient: true }
}

///|
pub fn elk_graph_json_for_json_graph(graph : Json) -> ElkGraphJsonImportBuilder {
  { graph: None, json_graph: Some(graph), importer_maybe: None, lenient: true }
}

///|
pub fn elk_graph_json_for_elk_graph(
  graph : ElkNode,
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
  let parsed = try @json.parse(graph) catch {
    _ => abort("JsonIOException")
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
      let token = source.substring(start=token_start, end=index)
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
    _ => abort("JsonImportException")
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
        None => abort("JsonImportException")
      }
    None => abort("JsonImportException")
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
    return "elk." + id.substring(start=16)
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
  canonical == aspect_ratio.get_id() ||
  canonical == spacing_node_node.get_id() ||
  canonical == spacing_edge_node.get_id() ||
  canonical == content_alignment.get_id()
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
    let suffix = canonical.substring(start=16)
    if !keys.contains(suffix) {
      keys.push(suffix)
    }
  }
  keys
}

///|
fn node_layout_option_value_by_any_id(
  node : ElkNode,
  option_id : String,
) -> String? {
  for key in layout_option_lookup_keys(option_id) {
    match node_layout_option_string_value(node, key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn port_layout_option_value_by_any_id(
  port : ElkPort,
  option_id : String,
) -> String? {
  for key in layout_option_lookup_keys(option_id) {
    match port_layout_option_string_value(port, key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn edge_layout_option_value_by_any_id(
  edge : ElkEdge,
  option_id : String,
) -> String? {
  for key in layout_option_lookup_keys(option_id) {
    match edge_layout_option_string_value(edge, key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn label_layout_option_value_by_any_id(
  label : ElkLabel,
  option_id : String,
) -> String? {
  for key in layout_option_lookup_keys(option_id) {
    match label_layout_option_string_value(label, key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
pub fn ElkGraphJsonImportBuilder::remember_importer(
  self : ElkGraphJsonImportBuilder,
  maybe : Maybe[JsonImporter],
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
        None => abort("JsonImportException")
      }
  }
}

///|
pub fn ElkGraphJsonImportBuilder::to_elk(
  self : ElkGraphJsonImportBuilder,
) -> ElkNode {
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
fn importer_apply_option(
  importer : JsonImporter,
  node : ElkNode,
  option_id : String,
  value : String,
) -> Unit {
  ignore(importer)
  let canonical_id = canonical_layout_option_id(option_id)
  node_set_layout_option_string_by_id(node, canonical_id, value)
  if is_direction_option_id(canonical_id) {
    node_set_string_property(node, direction, value)
  }
  if is_algorithm_option_id(canonical_id) {
    node_set_string_property(node, algorithm, value)
  }
  if is_no_layout_option_id(canonical_id) {
    match parse_bool_option(value) {
      Some(parsed) => node_set_bool_property(node, no_layout, parsed)
      None => ()
    }
  }
}

///|
fn importer_transform_layout_options(
  importer : JsonImporter,
  json_options : Map[String, Json],
  node : ElkNode,
) -> Unit {
  json_options.each((key, value) => {
    match json_value_as_string(value) {
      Some(value_string) =>
        importer_apply_option(importer, node, key, value_string)
      None => ()
    }
  })
}

///|
fn importer_transform_properties(
  importer : JsonImporter,
  json_node : Map[String, Json],
  node : ElkNode,
) -> Unit {
  match json_object_field(json_node, "properties") {
    Some(properties) =>
      importer_transform_layout_options(importer, properties, node)
    None => ()
  }
  match json_object_field(json_node, "layoutOptions") {
    Some(layout_options) =>
      importer_transform_layout_options(importer, layout_options, node)
    None => ()
  }
}

///|
fn importer_transform_individual_spacings(
  json_node : Map[String, Json],
  node : ElkNode,
) -> Unit {
  match json_object_field(json_node, "individualSpacings") {
    Some(individual_spacings) =>
      individual_spacings.each((key, value) => {
        match json_value_as_string(value) {
          Some(value_string) =>
            node_set_individual_spacing_option_string_by_id(
              node,
              canonical_layout_option_id(key),
              value_string,
            )
          None => ()
        }
      })
    None => ()
  }
}

///|
fn importer_transform_shape_layout_node(
  json_node : Map[String, Json],
  node : ElkNode,
) -> Unit {
  match json_node.get("x") {
    Some(Number(x, repr~)) => {
      ignore(repr)
      node_set_location(node, x, node_y(node))
    }
    _ => ()
  }
  match json_node.get("y") {
    Some(Number(y, repr~)) => {
      ignore(repr)
      node_set_location(node, node_x(node), y)
    }
    _ => ()
  }
  match json_node.get("width") {
    Some(Number(width, repr~)) => {
      ignore(repr)
      node_set_dimensions(node, width, node_height(node))
    }
    _ => ()
  }
  match json_node.get("height") {
    Some(Number(height, repr~)) => {
      ignore(repr)
      node_set_dimensions(node, node_width(node), height)
    }
    _ => ()
  }
}

///|
fn importer_transform_layout_options_port(
  json_options : Map[String, Json],
  port : ElkPort,
) -> Unit {
  json_options.each((key, value) => {
    match json_value_as_string(value) {
      Some(value_string) =>
        port_set_layout_option_string_by_id(
          port,
          canonical_layout_option_id(key),
          value_string,
        )
      None => ()
    }
  })
}

///|
fn importer_transform_properties_port(
  json_port : Map[String, Json],
  port : ElkPort,
) -> Unit {
  match json_object_field(json_port, "properties") {
    Some(properties) => importer_transform_layout_options_port(properties, port)
    None => ()
  }
  match json_object_field(json_port, "layoutOptions") {
    Some(layout_options) =>
      importer_transform_layout_options_port(layout_options, port)
    None => ()
  }
}

///|
fn importer_transform_layout_options_edge(
  json_options : Map[String, Json],
  edge : ElkEdge,
) -> Unit {
  json_options.each((key, value) => {
    match json_value_as_string(value) {
      Some(value_string) =>
        edge_set_layout_option_string_by_id(
          edge,
          canonical_layout_option_id(key),
          value_string,
        )
      None => ()
    }
  })
}

///|
fn importer_transform_properties_edge(
  json_edge : Map[String, Json],
  edge : ElkEdge,
) -> Unit {
  match json_object_field(json_edge, "properties") {
    Some(properties) => importer_transform_layout_options_edge(properties, edge)
    None => ()
  }
  match json_object_field(json_edge, "layoutOptions") {
    Some(layout_options) =>
      importer_transform_layout_options_edge(layout_options, edge)
    None => ()
  }
}

///|
fn importer_transform_layout_options_label(
  json_options : Map[String, Json],
  label : ElkLabel,
) -> Unit {
  json_options.each((key, value) => {
    match json_value_as_string(value) {
      Some(value_string) =>
        label_set_layout_option_string_by_id(
          label,
          canonical_layout_option_id(key),
          value_string,
        )
      None => ()
    }
  })
}

///|
fn importer_transform_properties_label(
  json_label : Map[String, Json],
  label : ElkLabel,
) -> Unit {
  match json_object_field(json_label, "properties") {
    Some(properties) =>
      importer_transform_layout_options_label(properties, label)
    None => ()
  }
  match json_object_field(json_label, "layoutOptions") {
    Some(layout_options) =>
      importer_transform_layout_options_label(layout_options, label)
    None => ()
  }
}

///|
fn importer_transform_shape_layout_port(
  json_port : Map[String, Json],
  port : ElkPort,
) -> Unit {
  match json_port.get("x") {
    Some(Number(x, repr~)) => {
      ignore(repr)
      port_set_location(port, x, port_y(port))
    }
    _ => ()
  }
  match json_port.get("y") {
    Some(Number(y, repr~)) => {
      ignore(repr)
      port_set_location(port, port_x(port), y)
    }
    _ => ()
  }
  match json_port.get("width") {
    Some(Number(width, repr~)) => {
      ignore(repr)
      port_set_dimensions(port, width, port_height(port))
    }
    _ => ()
  }
  match json_port.get("height") {
    Some(Number(height, repr~)) => {
      ignore(repr)
      port_set_dimensions(port, port_width(port), height)
    }
    _ => ()
  }
}

///|
fn importer_transform_shape_layout_label(
  json_label : Map[String, Json],
  label : ElkLabel,
) -> Unit {
  match json_label.get("x") {
    Some(Number(x, repr~)) => {
      ignore(repr)
      label_set_location(label, x, label_y(label))
    }
    _ => ()
  }
  match json_label.get("y") {
    Some(Number(y, repr~)) => {
      ignore(repr)
      label_set_location(label, label_x(label), y)
    }
    _ => ()
  }
  match json_label.get("width") {
    Some(Number(width, repr~)) => {
      ignore(repr)
      label_set_dimensions(label, width, label_height(label))
    }
    _ => ()
  }
  match json_label.get("height") {
    Some(Number(height, repr~)) => {
      ignore(repr)
      label_set_dimensions(label, label_width(label), height)
    }
    _ => ()
  }
}

///|
fn importer_transform_labels_for_node(
  importer : JsonImporter,
  json_node : Map[String, Json],
  node : ElkNode,
) -> Unit {
  match json_array_field(json_node, "labels") {
    Some(labels) =>
      for label_json in labels {
        match label_json {
          Object(label_obj) => {
            let text = match label_obj.get("text") {
              Some(text_json) => json_value_as_string(text_json).unwrap_or("")
              None => ""
            }
            let label = create_label(Some(make_node_label_parent(node)))
            label_set_text(label, text)
            importer.label_json_map[label] = label_obj
            importer_transform_properties_label(label_obj, label)
            importer_transform_shape_layout_label(label_obj, label)
          }
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn importer_transform_labels_for_port(
  importer : JsonImporter,
  json_port : Map[String, Json],
  port : ElkPort,
) -> Unit {
  match json_array_field(json_port, "labels") {
    Some(labels) =>
      for label_json in labels {
        match label_json {
          Object(label_obj) => {
            let text = match label_obj.get("text") {
              Some(text_json) => json_value_as_string(text_json).unwrap_or("")
              None => ""
            }
            let label = create_label(Some(make_port_label_parent(port)))
            label_set_text(label, text)
            importer.label_json_map[label] = label_obj
            importer_transform_properties_label(label_obj, label)
            importer_transform_shape_layout_label(label_obj, label)
          }
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn importer_transform_labels_for_edge(
  importer : JsonImporter,
  json_edge : Map[String, Json],
  edge : ElkEdge,
) -> Unit {
  match json_array_field(json_edge, "labels") {
    Some(labels) =>
      for label_json in labels {
        match label_json {
          Object(label_obj) => {
            let text = match label_obj.get("text") {
              Some(text_json) => json_value_as_string(text_json).unwrap_or("")
              None => ""
            }
            let label = create_label(Some(make_edge_label_parent(edge)))
            label_set_text(label, text)
            importer.label_json_map[label] = label_obj
            importer_transform_properties_label(label_obj, label)
            importer_transform_shape_layout_label(label_obj, label)
          }
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn importer_transform_port(
  importer : JsonImporter,
  json_port : Map[String, Json],
  parent : ElkNode,
) -> Unit {
  let port = create_port(Some(parent))
  let port_id = required_json_id(json_port)
  importer.port_id_map[port_id] = port
  importer.port_json_map[port] = json_port
  importer_transform_properties_port(json_port, port)
  importer_transform_shape_layout_port(json_port, port)
  importer_transform_labels_for_port(importer, json_port, port)
}

///|
fn importer_transform_ports(
  importer : JsonImporter,
  json_node : Map[String, Json],
  parent : ElkNode,
) -> Unit {
  match json_array_field(json_node, "ports") {
    Some(ports) =>
      for port in ports {
        match port {
          Object(port_obj) =>
            importer_transform_port(importer, port_obj, parent)
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn importer_transform_node(
  importer : JsonImporter,
  json_node : Map[String, Json],
  parent : ElkNode?,
) -> ElkNode {
  let node = create_node(parent)
  let id = required_json_id(json_node)
  node_set_identifier(node, id)
  match json_value_as_string(json_node.get("id").unwrap_or(Json::string(id))) {
    Some(identifier) => node_set_identifier(node, identifier)
    None => ()
  }
  importer_transform_shape_layout_node(json_node, node)
  importer.node_id_map[id] = node
  importer.node_json_map[node] = json_node
  importer_transform_properties(importer, json_node, node)
  importer_transform_individual_spacings(json_node, node)
  importer_transform_ports(importer, json_node, node)
  importer_transform_labels_for_node(importer, json_node, node)
  match json_array_field(json_node, "children") {
    Some(children) =>
      for child in children {
        match child {
          Object(child_node) =>
            ignore(importer_transform_node(importer, child_node, Some(node)))
          _ => ()
        }
      }
    None => ()
  }
  node
}

///|
fn importer_transform_edge(
  importer : JsonImporter,
  json_edge : Map[String, Json],
  parent : ElkNode,
) -> ElkEdge {
  let edge = create_edge(Some(parent))
  let edge_id = required_json_id(json_edge)
  edge_set_identifier(edge, edge_id)
  importer.edge_json_map[edge] = json_edge
  importer.edge_original_parent_map[edge] = parent
  if json_edge.contains("sources") || json_edge.contains("targets") {
    match json_array_field(json_edge, "sources") {
      Some(sources) =>
        for source in sources {
          match json_id_to_string(source) {
            Some(source_id) =>
              match importer_shape_by_id(importer, source_id) {
                Some(source_shape) => edge_add_source(edge, source_shape)
                None => ()
              }
            None => ()
          }
        }
      None => ()
    }
    match json_array_field(json_edge, "targets") {
      Some(targets) =>
        for target in targets {
          match json_id_to_string(target) {
            Some(target_id) =>
              match importer_shape_by_id(importer, target_id) {
                Some(target_shape) => edge_add_target(edge, target_shape)
                None => ()
              }
            None => ()
          }
        }
      None => ()
    }
    if !edge_is_connected(edge) {
      abort("JsonImportException")
    }
  } else {
    let source_id = match json_edge.get("source") {
      Some(source_json) =>
        match json_id_to_string(source_json) {
          Some(source) => source
          None => abort("JsonImportException")
        }
      None => abort("JsonImportException")
    }
    let target_id = match json_edge.get("target") {
      Some(target_json) =>
        match json_id_to_string(target_json) {
          Some(target) => target
          None => abort("JsonImportException")
        }
      None => abort("JsonImportException")
    }
    let source_node = match importer.node_id_map.get(source_id) {
      Some(node) => node
      None => abort("JsonImportException")
    }
    let source_shape = match json_edge.get("sourcePort") {
      Some(port_json) =>
        match json_id_to_string(port_json) {
          Some(port_id) =>
            match importer.port_id_map.get(port_id) {
              Some(port) =>
                if port_parent(port) == Some(source_node) {
                  make_port_shape(port)
                } else {
                  abort("JsonImportException")
                }
              None => abort("JsonImportException")
            }
          None => abort("JsonImportException")
        }
      None => make_node_shape(source_node)
    }
    let target_node = match importer.node_id_map.get(target_id) {
      Some(node) => node
      None => abort("JsonImportException")
    }
    let target_shape = match json_edge.get("targetPort") {
      Some(port_json) =>
        match json_id_to_string(port_json) {
          Some(port_id) =>
            match importer.port_id_map.get(port_id) {
              Some(port) =>
                if port_parent(port) == Some(target_node) {
                  make_port_shape(port)
                } else {
                  abort("JsonImportException")
                }
              None => abort("JsonImportException")
            }
          None => abort("JsonImportException")
        }
      None => make_node_shape(target_node)
    }
    edge_add_source(edge, source_shape)
    edge_add_target(edge, target_shape)
  }
  importer_transform_properties_edge(json_edge, edge)
  importer_transform_edge_sections(importer, json_edge, edge)
  importer_transform_labels_for_edge(importer, json_edge, edge)
  update_containment(Some(edge))
  edge
}

///|
fn importer_shape_by_id(
  importer : JsonImporter,
  shape_id : String,
) -> ElkConnectableShape? {
  match importer.node_id_map.get(shape_id) {
    Some(node) => Some(make_node_shape(node))
    None =>
      match importer.port_id_map.get(shape_id) {
        Some(port) => Some(make_port_shape(port))
        None => None
      }
  }
}

///|
fn json_number_in_object(json_obj : Map[String, Json], key : String) -> Double? {
  match json_obj.get(key) {
    Some(Number(value, repr~)) => {
      ignore(repr)
      Some(value)
    }
    _ => None
  }
}

///|
fn json_id_array_values(value : Json?) -> Array[String] {
  match value {
    Some(Array(ids)) => {
      let result = []
      for id in ids {
        match json_id_to_string(id) {
          Some(as_string) => result.push(as_string)
          None => ()
        }
      }
      result
    }
    _ => []
  }
}

///|
fn importer_fill_edge_section_points(
  json_section : Map[String, Json],
  section : ElkEdgeSection,
) -> Unit {
  let start_point = match json_object_field(json_section, "startPoint") {
    Some(value) => value
    None => abort("JsonImportException")
  }
  let end_point = match json_object_field(json_section, "endPoint") {
    Some(value) => value
    None => abort("JsonImportException")
  }
  let start_x = json_number_in_object(start_point, "x").unwrap_or(0.0)
  let start_y = json_number_in_object(start_point, "y").unwrap_or(0.0)
  let end_x = json_number_in_object(end_point, "x").unwrap_or(0.0)
  let end_y = json_number_in_object(end_point, "y").unwrap_or(0.0)
  edge_section_set_start(section, start_x, start_y)
  edge_section_set_end(section, end_x, end_y)
}

///|
fn importer_transform_edge_sections(
  importer : JsonImporter,
  json_edge : Map[String, Json],
  edge : ElkEdge,
) -> Unit {
  let sections_json = match json_array_field(json_edge, "sections") {
    Some(sections) => sections
    None => return
  }
  let section_by_id : Map[String, ElkEdgeSection] = {}
  let incoming_section_ids : Map[ElkEdgeSection, Array[String]] = {}
  let outgoing_section_ids : Map[ElkEdgeSection, Array[String]] = {}
  for section_json in sections_json {
    let section_obj = match section_json {
      Object(value) => value
      _ => continue
    }
    let section = create_edge_section(edge)
    let section_id = required_json_id(section_obj)
    edge_section_set_identifier(section, section_id)
    section_by_id[section_id] = section
    importer_fill_edge_section_points(section_obj, section)
    match section_obj.get("incomingShape") {
      Some(shape_json) =>
        match json_id_to_string(shape_json) {
          Some(shape_id) =>
            match importer_shape_by_id(importer, shape_id) {
              Some(shape) =>
                edge_section_set_incoming_shape(section, Some(shape))
              None => ()
            }
          None => ()
        }
      None => ()
    }
    match section_obj.get("outgoingShape") {
      Some(shape_json) =>
        match json_id_to_string(shape_json) {
          Some(shape_id) =>
            match importer_shape_by_id(importer, shape_id) {
              Some(shape) =>
                edge_section_set_outgoing_shape(section, Some(shape))
              None => ()
            }
          None => ()
        }
      None => ()
    }
    incoming_section_ids[section] = json_id_array_values(
      section_obj.get("incomingSections"),
    )
    outgoing_section_ids[section] = json_id_array_values(
      section_obj.get("outgoingSections"),
    )
  }
  incoming_section_ids.each((section, section_ids) => {
    for section_id in section_ids {
      match section_by_id.get(section_id) {
        Some(referenced) =>
          edge_section_add_incoming_section(section, referenced)
        None => abort("JsonImportException")
      }
    }
  })
  outgoing_section_ids.each((section, section_ids) => {
    for section_id in section_ids {
      match section_by_id.get(section_id) {
        Some(referenced) =>
          edge_section_add_outgoing_section(section, referenced)
        None => abort("JsonImportException")
      }
    }
  })
  if edge_sources(edge).length() == 1 &&
    edge_targets(edge).length() == 1 &&
    edge_sections(edge).length() == 1 {
    let section = edge_sections(edge)[0]
    if edge_section_incoming_shape(section) is None &&
      edge_section_outgoing_shape(section) is None {
      edge_section_set_incoming_shape(section, Some(edge_sources(edge)[0]))
      edge_section_set_outgoing_shape(section, Some(edge_targets(edge)[0]))
    }
  }
}

///|
fn importer_transform_edges(
  importer : JsonImporter,
  json_node : Map[String, Json],
) -> Unit {
  let node_id = required_json_id(json_node)
  let node = match importer.node_id_map.get(node_id) {
    Some(node) => node
    None => abort("JsonImportException")
  }
  match json_array_field(json_node, "edges") {
    Some(edges) =>
      for edge in edges {
        match edge {
          Object(edge_obj) =>
            ignore(importer_transform_edge(importer, edge_obj, node))
          _ => ()
        }
      }
    None => ()
  }
  match json_array_field(json_node, "children") {
    Some(children) =>
      for child in children {
        match child {
          Object(child_node) => importer_transform_edges(importer, child_node)
          _ => ()
        }
      }
    None => ()
  }
}

///|
pub fn JsonImporter::transform(
  self : JsonImporter,
  graph : Map[String, Json],
) -> ElkNode {
  self.input_model = Some(graph)
  self.node_id_map.clear()
  self.port_id_map.clear()
  self.node_json_map.clear()
  self.port_json_map.clear()
  self.edge_json_map.clear()
  self.label_json_map.clear()
  self.edge_original_parent_map.clear()
  let root = importer_transform_node(self, graph, None)
  importer_transform_edges(self, graph)
  root
}

///|
pub fn JsonImporter::get_input_model(self : JsonImporter) -> Map[String, Json]? {
  self.input_model
}

///|
fn connectable_shape_id(
  connectable_shape : ElkConnectableShape,
  node_id_map : Map[ElkNode, String],
  port_id_map : Map[ElkPort, String],
) -> String? {
  match connectable_shape {
    NodeShape(node) => node_id_map.get(node)
    PortShape(port) => port_id_map.get(port)
  }
}

///|
fn set_node_layout(
  json_obj : Map[String, Json],
  x : Double,
  y : Double,
  node : ElkNode,
) -> Unit {
  json_obj["x"] = Json::number(x)
  json_obj["y"] = Json::number(y)
  json_obj["width"] = Json::number(node_width(node))
  json_obj["height"] = Json::number(node_height(node))
}

///|
fn set_port_layout(
  json_obj : Map[String, Json],
  x : Double,
  y : Double,
  port : ElkPort,
) -> Unit {
  json_obj["x"] = Json::number(x)
  json_obj["y"] = Json::number(y)
  json_obj["width"] = Json::number(port_width(port))
  json_obj["height"] = Json::number(port_height(port))
}

///|
fn set_label_layout(
  json_obj : Map[String, Json],
  x : Double,
  y : Double,
  label : ElkLabel,
) -> Unit {
  json_obj["x"] = Json::number(x)
  json_obj["y"] = Json::number(y)
  json_obj["width"] = Json::number(label_width(label))
  json_obj["height"] = Json::number(label_height(label))
}

///|
fn node_global_x(node : ElkNode) -> Double {
  match node_parent(node) {
    Some(parent) => node_x(node) + node_global_x(parent)
    None => node_x(node)
  }
}

///|
fn node_global_y(node : ElkNode) -> Double {
  match node_parent(node) {
    Some(parent) => node_y(node) + node_global_y(parent)
    None => node_y(node)
  }
}

///|
fn port_global_x(port : ElkPort) -> Double {
  match port_parent(port) {
    Some(parent) => port_x(port) + node_global_x(parent)
    None => port_x(port)
  }
}

///|
fn port_global_y(port : ElkPort) -> Double {
  match port_parent(port) {
    Some(parent) => port_y(port) + node_global_y(parent)
    None => port_y(port)
  }
}

///|
fn node_shape_coords_mode(node : ElkNode) -> JsonShapeCoordsMode {
  let own = match
    node_layout_option_value_by_any_id(node, "org.eclipse.elk.json.shapeCoords") {
    Some(value) => parse_shape_coords_mode(value)
    None => ShapeInherit
  }
  match own {
    ShapeInherit => ()
    _ => return own
  }
  match node_parent(node) {
    Some(parent) => node_shape_coords_mode(parent)
    None => ShapeParent
  }
}

///|
fn node_edge_coords_mode(node : ElkNode) -> JsonEdgeCoordsMode {
  let own = match
    node_layout_option_value_by_any_id(node, "org.eclipse.elk.json.edgeCoords") {
    Some(value) => parse_edge_coords_mode(value)
    None => EdgeInherit
  }
  match own {
    EdgeInherit => ()
    _ => return own
  }
  match node_parent(node) {
    Some(parent) => node_edge_coords_mode(parent)
    None => EdgeContainer
  }
}

///|
fn port_shape_coords_mode(port : ElkPort) -> JsonShapeCoordsMode {
  let own = match
    port_layout_option_value_by_any_id(port, "org.eclipse.elk.json.shapeCoords") {
    Some(value) => parse_shape_coords_mode(value)
    None => ShapeInherit
  }
  match own {
    ShapeInherit => ()
    _ => return own
  }
  match port_parent(port) {
    Some(parent) => node_shape_coords_mode(parent)
    None => ShapeParent
  }
}

///|
fn edge_adjust_x(importer : JsonImporter, edge : ElkEdge, x : Double) -> Double {
  let original_parent = match importer.edge_original_parent_map.get(edge) {
    Some(parent) => parent
    None =>
      match edge_containing_node(edge) {
        Some(container) => container
        None => return x
      }
  }
  let containing = match edge_containing_node(edge) {
    Some(container) => container
    None => original_parent
  }
  match node_edge_coords_mode(original_parent) {
    EdgeRoot => x + node_global_x(containing)
    EdgeParent => x + node_global_x(containing) - node_global_x(original_parent)
    _ => x
  }
}

///|
fn edge_adjust_y(importer : JsonImporter, edge : ElkEdge, y : Double) -> Double {
  let original_parent = match importer.edge_original_parent_map.get(edge) {
    Some(parent) => parent
    None =>
      match edge_containing_node(edge) {
        Some(container) => container
        None => return y
      }
  }
  let containing = match edge_containing_node(edge) {
    Some(container) => container
    None => original_parent
  }
  match node_edge_coords_mode(original_parent) {
    EdgeRoot => y + node_global_y(containing)
    EdgeParent => y + node_global_y(containing) - node_global_y(original_parent)
    _ => y
  }
}

///|
fn label_adjusted_x(importer : JsonImporter, label : ElkLabel) -> Double {
  match label_parent(label) {
    Some(NodeLabelParent(node)) =>
      if (match node_shape_coords_mode(node) {
          ShapeRoot => true
          _ => false
        }) {
        label_x(label) + node_global_x(node)
      } else {
        label_x(label)
      }
    Some(PortLabelParent(port)) =>
      if (match port_shape_coords_mode(port) {
          ShapeRoot => true
          _ => false
        }) {
        label_x(label) + port_global_x(port)
      } else {
        label_x(label)
      }
    Some(EdgeLabelParent(edge)) => edge_adjust_x(importer, edge, label_x(label))
    Some(LabelLabelParent(parent_label)) =>
      label_x(label) + label_adjusted_x(importer, parent_label)
    None => label_x(label)
  }
}

///|
fn label_adjusted_y(importer : JsonImporter, label : ElkLabel) -> Double {
  match label_parent(label) {
    Some(NodeLabelParent(node)) =>
      if (match node_shape_coords_mode(node) {
          ShapeRoot => true
          _ => false
        }) {
        label_y(label) + node_global_y(node)
      } else {
        label_y(label)
      }
    Some(PortLabelParent(port)) =>
      if (match port_shape_coords_mode(port) {
          ShapeRoot => true
          _ => false
        }) {
        label_y(label) + port_global_y(port)
      } else {
        label_y(label)
      }
    Some(EdgeLabelParent(edge)) => edge_adjust_y(importer, edge, label_y(label))
    Some(LabelLabelParent(parent_label)) =>
      label_y(label) + label_adjusted_y(importer, parent_label)
    None => label_y(label)
  }
}

///|
fn importer_node_id_by_node(importer : JsonImporter, node : ElkNode) -> String? {
  let mut result : String? = None
  importer.node_id_map.each((id, mapped) => {
    if mapped == node {
      result = Some(id)
    }
  })
  result
}

///|
fn importer_shape_id(
  importer : JsonImporter,
  shape : ElkConnectableShape,
) -> String? {
  match shape {
    NodeShape(node) => importer_node_id_by_node(importer, node)
    PortShape(port) => {
      for entry in importer.port_id_map.to_array() {
        if entry.1 == port {
          return Some(entry.0)
        }
      }
      None
    }
  }
}

///|
fn importer_transfer_edge_sections(
  importer : JsonImporter,
  json_edge : Map[String, Json],
  edge : ElkEdge,
  edge_id : String,
) -> Unit {
  if edge_sections(edge).is_empty() {
    return
  }
  let sections_json = []
  for i = 0; i < edge_sections(edge).length(); i = i + 1 {
    let section = edge_sections(edge)[i]
    let section_id = if edge_section_identifier(section).is_empty() {
      edge_id + "_s" + i.to_string()
    } else {
      edge_section_identifier(section)
    }
    let section_obj : Map[String, Json] = {
      "id": Json::string(section_id),
      "startPoint": Json::object({
        "x": Json::number(
          edge_adjust_x(importer, edge, edge_section_start_x(section)),
        ),
        "y": Json::number(
          edge_adjust_y(importer, edge, edge_section_start_y(section)),
        ),
      }),
      "endPoint": Json::object({
        "x": Json::number(
          edge_adjust_x(importer, edge, edge_section_end_x(section)),
        ),
        "y": Json::number(
          edge_adjust_y(importer, edge, edge_section_end_y(section)),
        ),
      }),
    }
    match edge_section_incoming_shape(section) {
      Some(shape) =>
        match importer_shape_id(importer, shape) {
          Some(id) => section_obj["incomingShape"] = Json::string(id)
          None => ()
        }
      None => ()
    }
    match edge_section_outgoing_shape(section) {
      Some(shape) =>
        match importer_shape_id(importer, shape) {
          Some(id) => section_obj["outgoingShape"] = Json::string(id)
          None => ()
        }
      None => ()
    }
    if !edge_section_incoming_sections(section).is_empty() {
      let incoming_refs = []
      for referenced in edge_section_incoming_sections(section) {
        if !edge_section_identifier(referenced).is_empty() {
          incoming_refs.push(Json::string(edge_section_identifier(referenced)))
        }
      }
      if !incoming_refs.is_empty() {
        section_obj["incomingSections"] = Json::array(incoming_refs)
      }
    }
    if !edge_section_outgoing_sections(section).is_empty() {
      let outgoing_refs = []
      for referenced in edge_section_outgoing_sections(section) {
        if !edge_section_identifier(referenced).is_empty() {
          outgoing_refs.push(Json::string(edge_section_identifier(referenced)))
        }
      }
      if !outgoing_refs.is_empty() {
        section_obj["outgoingSections"] = Json::array(outgoing_refs)
      }
    }
    sections_json.push(Json::object(section_obj))
  }
  if !sections_json.is_empty() {
    json_edge["sections"] = Json::array(sections_json)
  }
}

///|
fn importer_transfer_layout_node(
  importer : JsonImporter,
  node : ElkNode,
) -> Unit {
  let json_node = match importer.node_json_map.get(node) {
    Some(json_obj) => json_obj
    None => abort("JsonImportException")
  }
  let output_x = match node_parent(node) {
    Some(parent) =>
      if (match node_shape_coords_mode(parent) {
          ShapeRoot => true
          _ => false
        }) {
        node_x(node) + node_global_x(parent)
      } else {
        node_x(node)
      }
    None => node_x(node)
  }
  let output_y = match node_parent(node) {
    Some(parent) =>
      if (match node_shape_coords_mode(parent) {
          ShapeRoot => true
          _ => false
        }) {
        node_y(node) + node_global_y(parent)
      } else {
        node_y(node)
      }
    None => node_y(node)
  }
  set_node_layout(json_node, output_x, output_y, node)
  for port in node_ports(node) {
    match importer.port_json_map.get(port) {
      Some(json_port) => {
        let port_output_x = if (match node_shape_coords_mode(node) {
            ShapeRoot => true
            _ => false
          }) {
          port_x(port) + node_global_x(node)
        } else {
          port_x(port)
        }
        let port_output_y = if (match node_shape_coords_mode(node) {
            ShapeRoot => true
            _ => false
          }) {
          port_y(port) + node_global_y(node)
        } else {
          port_y(port)
        }
        set_port_layout(json_port, port_output_x, port_output_y, port)
      }
      None => ()
    }
  }
  for label in node_labels(node) {
    match importer.label_json_map.get(label) {
      Some(json_label) =>
        set_label_layout(
          json_label,
          label_adjusted_x(importer, label),
          label_adjusted_y(importer, label),
          label,
        )
      None => ()
    }
  }
  for port in node_ports(node) {
    for label in port_labels(port) {
      match importer.label_json_map.get(label) {
        Some(json_label) =>
          set_label_layout(
            json_label,
            label_adjusted_x(importer, label),
            label_adjusted_y(importer, label),
            label,
          )
        None => ()
      }
    }
  }
  for edge in node_contained_edges(node) {
    let json_edge = match importer.edge_json_map.get(edge) {
      Some(json_obj) => json_obj
      None => abort("JsonImportException")
    }
    let edge_id = if edge_identifier(edge).is_empty() {
      required_json_id(json_edge)
    } else {
      edge_identifier(edge)
    }
    importer_transfer_edge_sections(importer, json_edge, edge, edge_id)
    let edge_mode = match importer.edge_original_parent_map.get(edge) {
      Some(original_parent) => node_edge_coords_mode(original_parent)
      None => EdgeContainer
    }
    if (match edge_mode {
        EdgeContainer => true
        _ => false
      }) {
      match edge_containing_node(edge) {
        Some(container) =>
          if !node_identifier(container).is_empty() {
            json_edge["container"] = Json::string(node_identifier(container))
          }
        None => ()
      }
    }
    for label in edge_labels(edge) {
      match importer.label_json_map.get(label) {
        Some(json_label) =>
          set_label_layout(
            json_label,
            label_adjusted_x(importer, label),
            label_adjusted_y(importer, label),
            label,
          )
        None => ()
      }
    }
  }
  for child in node_children(node) {
    importer_transfer_layout_node(importer, child)
  }
}

///|
pub fn JsonImporter::transfer_layout(
  self : JsonImporter,
  graph : ElkNode,
) -> Unit {
  importer_transfer_layout_node(self, graph)
}

///|
fn new_json_exporter(builder : ElkGraphJsonExportBuilder) -> JsonExporter {
  {
    omit_zero_position: builder.omit_zero_position,
    omit_zero_dimension: builder.omit_zero_dimension,
    omit_layout_information: builder.omit_layout_information,
    short_layout_option_keys: builder.short_layout_option_keys,
    omit_unknown_layout_options: builder.omit_unknown_layout_options,
    node_id_map: {},
    edge_id_map: {},
    used_ids: {},
    node_id_counter: 0,
    edge_id_counter: 0,
    duplicate_id_counter: 0,
  }
}

///|
fn format_six_digits(value : Int) -> String {
  let mut text = value.to_string()
  while text.length() < 6 {
    text = "0" + text
  }
  text
}

///|
fn exporter_unique_id(exporter : JsonExporter, base_id : String) -> String {
  if !exporter.used_ids.contains(base_id) {
    exporter.used_ids[base_id] = true
    return base_id
  }
  while true {
    let candidate = "\{base_id}_g\{format_six_digits(exporter.duplicate_id_counter)}"
    exporter.duplicate_id_counter += 1
    if !exporter.used_ids.contains(candidate) {
      exporter.used_ids[candidate] = true
      return candidate
    }
  }
  base_id
}

///|
fn exporter_node_id(exporter : JsonExporter, node : ElkNode) -> String {
  match exporter.node_id_map.get(node) {
    Some(existing) => existing
    None => {
      let base = if node_identifier(node).is_empty() {
        let generated = "n" + exporter.node_id_counter.to_string()
        exporter.node_id_counter += 1
        generated
      } else {
        node_identifier(node)
      }
      let unique = exporter_unique_id(exporter, base)
      exporter.node_id_map[node] = unique
      unique
    }
  }
}

///|
fn exporter_edge_id(exporter : JsonExporter, edge : ElkEdge) -> String {
  match exporter.edge_id_map.get(edge) {
    Some(existing) => existing
    None => {
      let base = if edge_identifier(edge).is_empty() {
        let generated = "e" + exporter.edge_id_counter.to_string()
        exporter.edge_id_counter += 1
        generated
      } else {
        edge_identifier(edge)
      }
      let unique = exporter_unique_id(exporter, base)
      exporter.edge_id_map[edge] = unique
      unique
    }
  }
}

///|
fn exporter_set_shape_layout(
  exporter : JsonExporter,
  json_obj : Map[String, Json],
  node : ElkNode,
) -> Unit {
  if !exporter.omit_layout_information {
    if !exporter.omit_zero_position || node_x(node) != 0.0 {
      json_obj["x"] = Json::number(node_x(node))
    }
    if !exporter.omit_zero_position || node_y(node) != 0.0 {
      json_obj["y"] = Json::number(node_y(node))
    }
  }
  if !exporter.omit_zero_dimension || node_width(node) != 0.0 {
    json_obj["width"] = Json::number(node_width(node))
  }
  if !exporter.omit_zero_dimension || node_height(node) != 0.0 {
    json_obj["height"] = Json::number(node_height(node))
  }
}

///|
fn exporter_option_key(exporter : JsonExporter, option_id : String) -> String {
  let canonical = canonical_layout_option_id(option_id)
  if exporter.short_layout_option_keys {
    short_layout_option_id(canonical)
  } else {
    canonical
  }
}

///|
fn exporter_include_option(exporter : JsonExporter, option_id : String) -> Bool {
  !exporter.omit_unknown_layout_options || is_known_layout_option_id(option_id)
}

///|
fn exporter_add_layout_options(
  exporter : JsonExporter,
  json_obj : Map[String, Json],
  node : ElkNode,
) -> Unit {
  let layout_options : Map[String, Json] = {}
  if node_has_string_property(node, direction) {
    let key = exporter_option_key(exporter, direction.get_id())
    layout_options[key] = Json::string(
      node_get_string_property(node, direction),
    )
  }
  if node_has_string_property(node, algorithm) {
    let key = exporter_option_key(exporter, algorithm.get_id())
    layout_options[key] = Json::string(
      node_get_string_property(node, algorithm),
    )
  }
  for entry in node_layout_option_string_entries(node) {
    let option_id = entry.0
    let option_value = entry.1
    if exporter_include_option(exporter, option_id) {
      let key = exporter_option_key(exporter, option_id)
      layout_options[key] = Json::string(option_value)
    }
  }
  if !layout_options.is_empty() {
    json_obj["layoutOptions"] = Json::object(layout_options)
  }
}

///|
fn exporter_add_individual_spacings(
  exporter : JsonExporter,
  json_obj : Map[String, Json],
  node : ElkNode,
) -> Unit {
  let individual_spacings : Map[String, Json] = {}
  for entry in node_individual_spacing_option_string_entries(node) {
    let option_id = entry.0
    let option_value = entry.1
    if exporter_include_option(exporter, option_id) {
      let key = exporter_option_key(exporter, option_id)
      individual_spacings[key] = Json::string(option_value)
    }
  }
  if !individual_spacings.is_empty() {
    json_obj["individualSpacings"] = Json::object(individual_spacings)
  }
}

///|
fn exporter_transform_edge(exporter : JsonExporter, edge : ElkEdge) -> Json {
  let json_edge : Map[String, Json] = {}
  json_edge["id"] = Json::string(exporter_edge_id(exporter, edge))
  let sources = []
  for source in edge_sources(edge) {
    match connectable_shape_id(source, exporter.node_id_map, {}) {
      Some(id) => sources.push(Json::string(id))
      None => ()
    }
  }
  json_edge["sources"] = Json::array(sources)
  let targets = []
  for target in edge_targets(edge) {
    match connectable_shape_id(target, exporter.node_id_map, {}) {
      Some(id) => targets.push(Json::string(id))
      None => ()
    }
  }
  json_edge["targets"] = Json::array(targets)
  Json::object(json_edge)
}

///|
fn exporter_transform_node(exporter : JsonExporter, node : ElkNode) -> Json {
  let json_node : Map[String, Json] = {}
  json_node["id"] = Json::string(exporter_node_id(exporter, node))
  let children = []
  for child in node_children(node) {
    children.push(exporter_transform_node(exporter, child))
  }
  if !children.is_empty() {
    json_node["children"] = Json::array(children)
  }
  let edges = []
  for edge in node_contained_edges(node) {
    edges.push(exporter_transform_edge(exporter, edge))
  }
  if !edges.is_empty() {
    json_node["edges"] = Json::array(edges)
  }
  exporter_add_layout_options(exporter, json_node, node)
  exporter_add_individual_spacings(exporter, json_node, node)
  exporter_set_shape_layout(exporter, json_node, node)
  Json::object(json_node)
}

///|
fn exporter_export(exporter : JsonExporter, root : ElkNode) -> Json {
  exporter.node_id_map.clear()
  exporter.edge_id_map.clear()
  exporter.used_ids.clear()
  exporter.node_id_counter = 0
  exporter.edge_id_counter = 0
  exporter.duplicate_id_counter = 0
  exporter_transform_node(exporter, root)
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
