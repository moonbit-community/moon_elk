///|
priv struct JsonExporter {
  omit_zero_position : Bool
  omit_zero_dimension : Bool
  omit_layout_information : Bool
  short_layout_option_keys : Bool
  omit_unknown_layout_options : Bool
  node_id_map : Map[@graph.ElkNode, String]
  edge_id_map : Map[@graph.ElkEdge, String]
  used_ids : Map[String, Bool]
  mut node_id_counter : Int
  mut edge_id_counter : Int
  mut duplicate_id_counter : Int
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
fn exporter_node_id(exporter : JsonExporter, node : @graph.ElkNode) -> String {
  match exporter.node_id_map.get(node) {
    Some(existing) => existing
    None => {
      let base = if @graph.node_identifier(node).is_empty() {
        let generated = "n" + exporter.node_id_counter.to_string()
        exporter.node_id_counter += 1
        generated
      } else {
        @graph.node_identifier(node)
      }
      let unique = exporter_unique_id(exporter, base)
      exporter.node_id_map[node] = unique
      unique
    }
  }
}

///|
fn exporter_edge_id(exporter : JsonExporter, edge : @graph.ElkEdge) -> String {
  match exporter.edge_id_map.get(edge) {
    Some(existing) => existing
    None => {
      let base = if @graph.edge_identifier(edge).is_empty() {
        let generated = "e" + exporter.edge_id_counter.to_string()
        exporter.edge_id_counter += 1
        generated
      } else {
        @graph.edge_identifier(edge)
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
  node : @graph.ElkNode,
) -> Unit {
  if !exporter.omit_layout_information {
    if !exporter.omit_zero_position || @graph.node_x(node) != 0.0 {
      json_obj["x"] = Json::number(@graph.node_x(node))
    }
    if !exporter.omit_zero_position || @graph.node_y(node) != 0.0 {
      json_obj["y"] = Json::number(@graph.node_y(node))
    }
  }
  if !exporter.omit_zero_dimension || @graph.node_width(node) != 0.0 {
    json_obj["width"] = Json::number(@graph.node_width(node))
  }
  if !exporter.omit_zero_dimension || @graph.node_height(node) != 0.0 {
    json_obj["height"] = Json::number(@graph.node_height(node))
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
  node : @graph.ElkNode,
) -> Unit {
  let layout_options : Map[String, Json] = {}
  if @graph.node_has_string_property(node, @core.direction) {
    let key = exporter_option_key(exporter, @core.direction.get_id())
    layout_options[key] = Json::string(
      @graph.node_get_string_property(node, @core.direction),
    )
  }
  if @graph.node_has_string_property(node, @core.algorithm) {
    let key = exporter_option_key(exporter, @core.algorithm.get_id())
    layout_options[key] = Json::string(
      @graph.node_get_string_property(node, @core.algorithm),
    )
  }
  for entry in @graph.node_layout_option_string_entries(node) {
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
  node : @graph.ElkNode,
) -> Unit {
  let individual_spacings : Map[String, Json] = {}
  for entry in @graph.node_individual_spacing_option_string_entries(node) {
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
fn exporter_transform_edge(exporter : JsonExporter, edge : @graph.ElkEdge) -> Json {
  let json_edge : Map[String, Json] = {}
  json_edge["id"] = Json::string(exporter_edge_id(exporter, edge))
  let sources = []
  for source in @graph.edge_sources(edge) {
    match connectable_shape_id(source, exporter.node_id_map, {}) {
      Some(id) => sources.push(Json::string(id))
      None => ()
    }
  }
  json_edge["sources"] = Json::array(sources)
  let targets = []
  for target in @graph.edge_targets(edge) {
    match connectable_shape_id(target, exporter.node_id_map, {}) {
      Some(id) => targets.push(Json::string(id))
      None => ()
    }
  }
  json_edge["targets"] = Json::array(targets)
  Json::object(json_edge)
}

///|
fn exporter_transform_node(exporter : JsonExporter, node : @graph.ElkNode) -> Json {
  let json_node : Map[String, Json] = {}
  json_node["id"] = Json::string(exporter_node_id(exporter, node))
  let children = []
  for child in @graph.node_children(node) {
    children.push(exporter_transform_node(exporter, child))
  }
  if !children.is_empty() {
    json_node["children"] = Json::array(children)
  }
  let edges = []
  for edge in @graph.node_contained_edges(node) {
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
fn exporter_export(exporter : JsonExporter, root : @graph.ElkNode) -> Json {
  exporter.node_id_map.clear()
  exporter.edge_id_map.clear()
  exporter.used_ids.clear()
  exporter.node_id_counter = 0
  exporter.edge_id_counter = 0
  exporter.duplicate_id_counter = 0
  exporter_transform_node(exporter, root)
}
