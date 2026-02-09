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
  node_json_map : Map[ElkNode, Map[String, Json]]
  edge_json_map : Map[ElkEdge, Map[String, Json]]
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
  { input_model: None, node_id_map: {}, node_json_map: {}, edge_json_map: {} }
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
  canonical == aspect_ratio.get_id() ||
  canonical == spacing_node_node.get_id() ||
  canonical == spacing_edge_node.get_id() ||
  canonical == content_alignment.get_id()
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
  node_set_layout_option_string_by_id(node, option_id, value)
  if is_direction_option_id(option_id) {
    node_set_string_property(node, direction, value)
  }
  if is_algorithm_option_id(option_id) {
    node_set_string_property(node, algorithm, value)
  }
  if is_no_layout_option_id(option_id) {
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
  json_options.each((key, value) => match json_value_as_string(value) {
    Some(value_string) =>
      importer_apply_option(importer, node, key, value_string)
    None => ()
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
  importer.node_id_map[id] = node
  importer.node_json_map[node] = json_node
  importer_transform_properties(importer, json_node, node)
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
  if json_edge.contains("sources") || json_edge.contains("targets") {
    match json_array_field(json_edge, "sources") {
      Some(sources) =>
        for source in sources {
          match json_id_to_string(source) {
            Some(source_id) =>
              match importer.node_id_map.get(source_id) {
                Some(source_node) =>
                  edge_add_source(edge, make_node_shape(source_node))
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
              match importer.node_id_map.get(target_id) {
                Some(target_node) =>
                  edge_add_target(edge, make_node_shape(target_node))
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
    let target_node = match importer.node_id_map.get(target_id) {
      Some(node) => node
      None => abort("JsonImportException")
    }
    edge_add_source(edge, make_node_shape(source_node))
    edge_add_target(edge, make_node_shape(target_node))
  }
  importer_transform_edge_sections(importer, json_edge, edge)
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
    None => None
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
  incoming_section_ids.each((section, section_ids) => for
    section_id in section_ids {
    match section_by_id.get(section_id) {
      Some(referenced) => edge_section_add_incoming_section(section, referenced)
      None => abort("JsonImportException")
    }
  })
  outgoing_section_ids.each((section, section_ids) => for
    section_id in section_ids {
    match section_by_id.get(section_id) {
      Some(referenced) => edge_section_add_outgoing_section(section, referenced)
      None => abort("JsonImportException")
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
  self.node_json_map.clear()
  self.edge_json_map.clear()
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
) -> String? {
  match connectable_shape {
    NodeShape(node) => node_id_map.get(node)
    PortShape(_) => None
  }
}

///|
fn set_shape_layout(json_obj : Map[String, Json], node : ElkNode) -> Unit {
  json_obj["x"] = Json::number(node_x(node))
  json_obj["y"] = Json::number(node_y(node))
  json_obj["width"] = Json::number(node_width(node))
  json_obj["height"] = Json::number(node_height(node))
}

///|
fn importer_node_id_by_node(importer : JsonImporter, node : ElkNode) -> String? {
  let mut result : String? = None
  importer.node_id_map.each((id, mapped) => if mapped == node {
    result = Some(id)
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
    PortShape(_) => None
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
        "x": Json::number(edge_section_start_x(section)),
        "y": Json::number(edge_section_start_y(section)),
      }),
      "endPoint": Json::object({
        "x": Json::number(edge_section_end_x(section)),
        "y": Json::number(edge_section_end_y(section)),
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
  set_shape_layout(json_node, node)
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
    match edge_containing_node(edge) {
      Some(container) =>
        if !node_identifier(container).is_empty() {
          json_edge["container"] = Json::string(node_identifier(container))
        }
      None => ()
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
fn exporter_transform_edge(exporter : JsonExporter, edge : ElkEdge) -> Json {
  let json_edge : Map[String, Json] = {}
  json_edge["id"] = Json::string(exporter_edge_id(exporter, edge))
  let sources = []
  for source in edge_sources(edge) {
    match connectable_shape_id(source, exporter.node_id_map) {
      Some(id) => sources.push(Json::string(id))
      None => ()
    }
  }
  json_edge["sources"] = Json::array(sources)
  let targets = []
  for target in edge_targets(edge) {
    match connectable_shape_id(target, exporter.node_id_map) {
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
