///|
pub struct JsonImporter {
  mut input_model : Map[String, Json]?
  node_id_map : Map[String, @graph.ElkNode]
  port_id_map : Map[String, @graph.ElkPort]
  node_json_map : Map[@graph.ElkNode, Map[String, Json]]
  port_json_map : Map[@graph.ElkPort, Map[String, Json]]
  edge_json_map : Map[@graph.ElkEdge, Map[String, Json]]
  label_json_map : Map[@graph.ElkLabel, Map[String, Json]]
  edge_original_parent_map : Map[@graph.ElkEdge, @graph.ElkNode]
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
fn importer_apply_option(
  importer : JsonImporter,
  node : @graph.ElkNode,
  option_id : String,
  value : String,
) -> Unit {
  ignore(importer)
  let canonical_id = canonical_layout_option_id(option_id)
  @graph.node_set_layout_option_string_by_id(node, canonical_id, value)
  if is_direction_option_id(canonical_id) {
    @graph.node_set_string_property(node, @core.direction, value)
  }
  if is_algorithm_option_id(canonical_id) {
    @graph.node_set_string_property(node, @core.algorithm, value)
  }
  if is_no_layout_option_id(canonical_id) {
    match parse_bool_option(value) {
      Some(parsed) =>
        @graph.node_set_bool_property(node, @core.no_layout, parsed)
      None => ()
    }
  }
}

///|
fn importer_transform_layout_options(
  importer : JsonImporter,
  json_options : Map[String, Json],
  node : @graph.ElkNode,
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
  node : @graph.ElkNode,
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
  node : @graph.ElkNode,
) -> Unit {
  match json_object_field(json_node, "individualSpacings") {
    Some(individual_spacings) =>
      individual_spacings.each((key, value) => {
        match json_value_as_string(value) {
          Some(value_string) =>
            @graph.node_set_individual_spacing_option_string_by_id(
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
  node : @graph.ElkNode,
) -> Unit {
  match json_node.get("x") {
    Some(Number(x, repr~)) => {
      ignore(repr)
      @graph.node_set_location(node, x, @graph.node_y(node))
    }
    _ => ()
  }
  match json_node.get("y") {
    Some(Number(y, repr~)) => {
      ignore(repr)
      @graph.node_set_location(node, @graph.node_x(node), y)
    }
    _ => ()
  }
  match json_node.get("width") {
    Some(Number(width, repr~)) => {
      ignore(repr)
      @graph.node_set_dimensions(node, width, @graph.node_height(node))
    }
    _ => ()
  }
  match json_node.get("height") {
    Some(Number(height, repr~)) => {
      ignore(repr)
      @graph.node_set_dimensions(node, @graph.node_width(node), height)
    }
    _ => ()
  }
}

///|
fn importer_transform_layout_options_port(
  json_options : Map[String, Json],
  port : @graph.ElkPort,
) -> Unit {
  json_options.each((key, value) => {
    match json_value_as_string(value) {
      Some(value_string) =>
        @graph.port_set_layout_option_string_by_id(
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
  port : @graph.ElkPort,
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
  edge : @graph.ElkEdge,
) -> Unit {
  json_options.each((key, value) => {
    match json_value_as_string(value) {
      Some(value_string) =>
        @graph.edge_set_layout_option_string_by_id(
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
  edge : @graph.ElkEdge,
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
  label : @graph.ElkLabel,
) -> Unit {
  json_options.each((key, value) => {
    match json_value_as_string(value) {
      Some(value_string) =>
        @graph.label_set_layout_option_string_by_id(
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
  label : @graph.ElkLabel,
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
  port : @graph.ElkPort,
) -> Unit {
  match json_port.get("x") {
    Some(Number(x, repr~)) => {
      ignore(repr)
      @graph.port_set_location(port, x, @graph.port_y(port))
    }
    _ => ()
  }
  match json_port.get("y") {
    Some(Number(y, repr~)) => {
      ignore(repr)
      @graph.port_set_location(port, @graph.port_x(port), y)
    }
    _ => ()
  }
  match json_port.get("width") {
    Some(Number(width, repr~)) => {
      ignore(repr)
      @graph.port_set_dimensions(port, width, @graph.port_height(port))
    }
    _ => ()
  }
  match json_port.get("height") {
    Some(Number(height, repr~)) => {
      ignore(repr)
      @graph.port_set_dimensions(port, @graph.port_width(port), height)
    }
    _ => ()
  }
}

///|
fn importer_transform_shape_layout_label(
  json_label : Map[String, Json],
  label : @graph.ElkLabel,
) -> Unit {
  match json_label.get("x") {
    Some(Number(x, repr~)) => {
      ignore(repr)
      @graph.label_set_location(label, x, @graph.label_y(label))
    }
    _ => ()
  }
  match json_label.get("y") {
    Some(Number(y, repr~)) => {
      ignore(repr)
      @graph.label_set_location(label, @graph.label_x(label), y)
    }
    _ => ()
  }
  match json_label.get("width") {
    Some(Number(width, repr~)) => {
      ignore(repr)
      @graph.label_set_dimensions(label, width, @graph.label_height(label))
    }
    _ => ()
  }
  match json_label.get("height") {
    Some(Number(height, repr~)) => {
      ignore(repr)
      @graph.label_set_dimensions(label, @graph.label_width(label), height)
    }
    _ => ()
  }
}

///|
fn importer_transform_labels_for_node(
  importer : JsonImporter,
  json_node : Map[String, Json],
  node : @graph.ElkNode,
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
            let label = @graph.create_label(
              Some(@graph.make_node_label_parent(node)),
            )
            @graph.label_set_text(label, text)
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
  port : @graph.ElkPort,
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
            let label = @graph.create_label(
              Some(@graph.make_port_label_parent(port)),
            )
            @graph.label_set_text(label, text)
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
  edge : @graph.ElkEdge,
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
            let label = @graph.create_label(
              Some(@graph.make_edge_label_parent(edge)),
            )
            @graph.label_set_text(label, text)
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
  parent : @graph.ElkNode,
) -> Unit {
  let port = @graph.create_port(Some(parent))
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
  parent : @graph.ElkNode,
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
  parent : @graph.ElkNode?,
) -> @graph.ElkNode {
  let node = @graph.create_node(parent)
  let id = required_json_id(json_node)
  @graph.node_set_identifier(node, id)
  match json_value_as_string(json_node.get("id").unwrap_or(Json::string(id))) {
    Some(identifier) => @graph.node_set_identifier(node, identifier)
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
  parent : @graph.ElkNode,
) -> @graph.ElkEdge {
  let edge = @graph.create_edge(Some(parent))
  let edge_id = required_json_id(json_edge)
  @graph.edge_set_identifier(edge, edge_id)
  importer.edge_json_map[edge] = json_edge
  importer.edge_original_parent_map[edge] = parent
  if json_edge.contains("sources") || json_edge.contains("targets") {
    match json_array_field(json_edge, "sources") {
      Some(sources) =>
        for source in sources {
          match json_id_to_string(source) {
            Some(source_id) =>
              match importer_shape_by_id(importer, source_id) {
                Some(source_shape) => @graph.edge_add_source(edge, source_shape)
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
                Some(target_shape) => @graph.edge_add_target(edge, target_shape)
                None => ()
              }
            None => ()
          }
        }
      None => ()
    }
    if !@graph.edge_is_connected(edge) {
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
                if @graph.port_parent(port) == Some(source_node) {
                  @graph.make_port_shape(port)
                } else {
                  abort("JsonImportException")
                }
              None => abort("JsonImportException")
            }
          None => abort("JsonImportException")
        }
      None => @graph.make_node_shape(source_node)
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
                if @graph.port_parent(port) == Some(target_node) {
                  @graph.make_port_shape(port)
                } else {
                  abort("JsonImportException")
                }
              None => abort("JsonImportException")
            }
          None => abort("JsonImportException")
        }
      None => @graph.make_node_shape(target_node)
    }
    @graph.edge_add_source(edge, source_shape)
    @graph.edge_add_target(edge, target_shape)
  }
  importer_transform_properties_edge(json_edge, edge)
  importer_transform_edge_sections(importer, json_edge, edge)
  importer_transform_labels_for_edge(importer, json_edge, edge)
  @graph.update_containment(Some(edge))
  edge
}

///|
fn importer_shape_by_id(
  importer : JsonImporter,
  shape_id : String,
) -> @graph.ElkConnectableShape? {
  match importer.node_id_map.get(shape_id) {
    Some(node) => Some(@graph.make_node_shape(node))
    None =>
      match importer.port_id_map.get(shape_id) {
        Some(port) => Some(@graph.make_port_shape(port))
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
  section : @graph.ElkEdgeSection,
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
  @graph.edge_section_set_start(section, start_x, start_y)
  @graph.edge_section_set_end(section, end_x, end_y)
}

///|
fn importer_transform_edge_sections(
  importer : JsonImporter,
  json_edge : Map[String, Json],
  edge : @graph.ElkEdge,
) -> Unit {
  let sections_json = match json_array_field(json_edge, "sections") {
    Some(sections) => sections
    None => return
  }
  let section_by_id : Map[String, @graph.ElkEdgeSection] = {}
  let incoming_section_ids : Map[@graph.ElkEdgeSection, Array[String]] = {}
  let outgoing_section_ids : Map[@graph.ElkEdgeSection, Array[String]] = {}
  for section_json in sections_json {
    let section_obj = match section_json {
      Object(value) => value
      _ => continue
    }
    let section = @graph.create_edge_section(edge)
    let section_id = required_json_id(section_obj)
    @graph.edge_section_set_identifier(section, section_id)
    section_by_id[section_id] = section
    importer_fill_edge_section_points(section_obj, section)
    match section_obj.get("incomingShape") {
      Some(shape_json) =>
        match json_id_to_string(shape_json) {
          Some(shape_id) =>
            match importer_shape_by_id(importer, shape_id) {
              Some(shape) =>
                @graph.edge_section_set_incoming_shape(section, Some(shape))
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
                @graph.edge_section_set_outgoing_shape(section, Some(shape))
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
          @graph.edge_section_add_incoming_section(section, referenced)
        None => abort("JsonImportException")
      }
    }
  })
  outgoing_section_ids.each((section, section_ids) => {
    for section_id in section_ids {
      match section_by_id.get(section_id) {
        Some(referenced) =>
          @graph.edge_section_add_outgoing_section(section, referenced)
        None => abort("JsonImportException")
      }
    }
  })
  if @graph.edge_sources(edge).length() == 1 &&
    @graph.edge_targets(edge).length() == 1 &&
    @graph.edge_sections(edge).length() == 1 {
    let section = @graph.edge_sections(edge)[0]
    if @graph.edge_section_incoming_shape(section) is None &&
      @graph.edge_section_outgoing_shape(section) is None {
      @graph.edge_section_set_incoming_shape(
        section,
        Some(@graph.edge_sources(edge)[0]),
      )
      @graph.edge_section_set_outgoing_shape(
        section,
        Some(@graph.edge_targets(edge)[0]),
      )
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
) -> @graph.ElkNode {
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
  connectable_shape : @graph.ElkConnectableShape,
  node_id_map : Map[@graph.ElkNode, String],
  port_id_map : Map[@graph.ElkPort, String],
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
  node : @graph.ElkNode,
) -> Unit {
  json_obj["x"] = Json::number(x)
  json_obj["y"] = Json::number(y)
  json_obj["width"] = Json::number(@graph.node_width(node))
  json_obj["height"] = Json::number(@graph.node_height(node))
}

///|
fn set_port_layout(
  json_obj : Map[String, Json],
  x : Double,
  y : Double,
  port : @graph.ElkPort,
) -> Unit {
  json_obj["x"] = Json::number(x)
  json_obj["y"] = Json::number(y)
  json_obj["width"] = Json::number(@graph.port_width(port))
  json_obj["height"] = Json::number(@graph.port_height(port))
}

///|
fn set_label_layout(
  json_obj : Map[String, Json],
  x : Double,
  y : Double,
  label : @graph.ElkLabel,
) -> Unit {
  json_obj["x"] = Json::number(x)
  json_obj["y"] = Json::number(y)
  json_obj["width"] = Json::number(@graph.label_width(label))
  json_obj["height"] = Json::number(@graph.label_height(label))
}

///|
fn node_global_x(node : @graph.ElkNode) -> Double {
  match @graph.node_parent(node) {
    Some(parent) => @graph.node_x(node) + node_global_x(parent)
    None => @graph.node_x(node)
  }
}

///|
fn node_global_y(node : @graph.ElkNode) -> Double {
  match @graph.node_parent(node) {
    Some(parent) => @graph.node_y(node) + node_global_y(parent)
    None => @graph.node_y(node)
  }
}

///|
fn port_global_x(port : @graph.ElkPort) -> Double {
  match @graph.port_parent(port) {
    Some(parent) => @graph.port_x(port) + node_global_x(parent)
    None => @graph.port_x(port)
  }
}

///|
fn port_global_y(port : @graph.ElkPort) -> Double {
  match @graph.port_parent(port) {
    Some(parent) => @graph.port_y(port) + node_global_y(parent)
    None => @graph.port_y(port)
  }
}

///|
fn node_shape_coords_mode(node : @graph.ElkNode) -> JsonShapeCoordsMode {
  let own = match
    node_layout_option_value_by_any_id(node, "org.eclipse.elk.json.shapeCoords") {
    Some(value) => parse_shape_coords_mode(value)
    None => ShapeInherit
  }
  match own {
    ShapeInherit => ()
    _ => return own
  }
  match @graph.node_parent(node) {
    Some(parent) => node_shape_coords_mode(parent)
    None => ShapeParent
  }
}

///|
fn node_edge_coords_mode(node : @graph.ElkNode) -> JsonEdgeCoordsMode {
  let own = match
    node_layout_option_value_by_any_id(node, "org.eclipse.elk.json.edgeCoords") {
    Some(value) => parse_edge_coords_mode(value)
    None => EdgeInherit
  }
  match own {
    EdgeInherit => ()
    _ => return own
  }
  match @graph.node_parent(node) {
    Some(parent) => node_edge_coords_mode(parent)
    None => EdgeContainer
  }
}

///|
fn port_shape_coords_mode(port : @graph.ElkPort) -> JsonShapeCoordsMode {
  let own = match
    port_layout_option_value_by_any_id(port, "org.eclipse.elk.json.shapeCoords") {
    Some(value) => parse_shape_coords_mode(value)
    None => ShapeInherit
  }
  match own {
    ShapeInherit => ()
    _ => return own
  }
  match @graph.port_parent(port) {
    Some(parent) => node_shape_coords_mode(parent)
    None => ShapeParent
  }
}

///|
fn edge_adjust_x(
  importer : JsonImporter,
  edge : @graph.ElkEdge,
  x : Double,
) -> Double {
  let original_parent = match importer.edge_original_parent_map.get(edge) {
    Some(parent) => parent
    None =>
      match @graph.edge_containing_node(edge) {
        Some(container) => container
        None => return x
      }
  }
  let containing = match @graph.edge_containing_node(edge) {
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
fn edge_adjust_y(
  importer : JsonImporter,
  edge : @graph.ElkEdge,
  y : Double,
) -> Double {
  let original_parent = match importer.edge_original_parent_map.get(edge) {
    Some(parent) => parent
    None =>
      match @graph.edge_containing_node(edge) {
        Some(container) => container
        None => return y
      }
  }
  let containing = match @graph.edge_containing_node(edge) {
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
fn label_adjusted_x(importer : JsonImporter, label : @graph.ElkLabel) -> Double {
  match @graph.label_parent(label) {
    Some(NodeLabelParent(node)) =>
      if node_shape_coords_mode(node) is ShapeRoot {
        @graph.label_x(label) + node_global_x(node)
      } else {
        @graph.label_x(label)
      }
    Some(PortLabelParent(port)) =>
      if port_shape_coords_mode(port) is ShapeRoot {
        @graph.label_x(label) + port_global_x(port)
      } else {
        @graph.label_x(label)
      }
    Some(EdgeLabelParent(edge)) =>
      edge_adjust_x(importer, edge, @graph.label_x(label))
    Some(LabelLabelParent(parent_label)) =>
      @graph.label_x(label) + label_adjusted_x(importer, parent_label)
    None => @graph.label_x(label)
  }
}

///|
fn label_adjusted_y(importer : JsonImporter, label : @graph.ElkLabel) -> Double {
  match @graph.label_parent(label) {
    Some(NodeLabelParent(node)) =>
      if node_shape_coords_mode(node) is ShapeRoot {
        @graph.label_y(label) + node_global_y(node)
      } else {
        @graph.label_y(label)
      }
    Some(PortLabelParent(port)) =>
      if port_shape_coords_mode(port) is ShapeRoot {
        @graph.label_y(label) + port_global_y(port)
      } else {
        @graph.label_y(label)
      }
    Some(EdgeLabelParent(edge)) =>
      edge_adjust_y(importer, edge, @graph.label_y(label))
    Some(LabelLabelParent(parent_label)) =>
      @graph.label_y(label) + label_adjusted_y(importer, parent_label)
    None => @graph.label_y(label)
  }
}

///|
fn importer_node_id_by_node(
  importer : JsonImporter,
  node : @graph.ElkNode,
) -> String? {
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
  shape : @graph.ElkConnectableShape,
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
  edge : @graph.ElkEdge,
  edge_id : String,
) -> Unit {
  if @graph.edge_sections(edge).is_empty() {
    return
  }
  let sections_json = []
  for i = 0; i < @graph.edge_sections(edge).length(); i = i + 1 {
    let section = @graph.edge_sections(edge)[i]
    let section_id = if @graph.edge_section_identifier(section).is_empty() {
      edge_id + "_s" + i.to_string()
    } else {
      @graph.edge_section_identifier(section)
    }
    let section_obj : Map[String, Json] = {
      "id": Json::string(section_id),
      "startPoint": Json::object({
        "x": Json::number(
          edge_adjust_x(importer, edge, @graph.edge_section_start_x(section)),
        ),
        "y": Json::number(
          edge_adjust_y(importer, edge, @graph.edge_section_start_y(section)),
        ),
      }),
      "endPoint": Json::object({
        "x": Json::number(
          edge_adjust_x(importer, edge, @graph.edge_section_end_x(section)),
        ),
        "y": Json::number(
          edge_adjust_y(importer, edge, @graph.edge_section_end_y(section)),
        ),
      }),
    }
    match @graph.edge_section_incoming_shape(section) {
      Some(shape) =>
        match importer_shape_id(importer, shape) {
          Some(id) => section_obj["incomingShape"] = Json::string(id)
          None => ()
        }
      None => ()
    }
    match @graph.edge_section_outgoing_shape(section) {
      Some(shape) =>
        match importer_shape_id(importer, shape) {
          Some(id) => section_obj["outgoingShape"] = Json::string(id)
          None => ()
        }
      None => ()
    }
    if !@graph.edge_section_incoming_sections(section).is_empty() {
      let incoming_refs = []
      for referenced in @graph.edge_section_incoming_sections(section) {
        if !@graph.edge_section_identifier(referenced).is_empty() {
          incoming_refs.push(
            Json::string(@graph.edge_section_identifier(referenced)),
          )
        }
      }
      if !incoming_refs.is_empty() {
        section_obj["incomingSections"] = Json::array(incoming_refs)
      }
    }
    if !@graph.edge_section_outgoing_sections(section).is_empty() {
      let outgoing_refs = []
      for referenced in @graph.edge_section_outgoing_sections(section) {
        if !@graph.edge_section_identifier(referenced).is_empty() {
          outgoing_refs.push(
            Json::string(@graph.edge_section_identifier(referenced)),
          )
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
  node : @graph.ElkNode,
) -> Unit {
  let json_node = match importer.node_json_map.get(node) {
    Some(json_obj) => json_obj
    None => abort("JsonImportException")
  }
  let output_x = match @graph.node_parent(node) {
    Some(parent) =>
      if node_shape_coords_mode(parent) is ShapeRoot {
        @graph.node_x(node) + node_global_x(parent)
      } else {
        @graph.node_x(node)
      }
    None => @graph.node_x(node)
  }
  let output_y = match @graph.node_parent(node) {
    Some(parent) =>
      if node_shape_coords_mode(parent) is ShapeRoot {
        @graph.node_y(node) + node_global_y(parent)
      } else {
        @graph.node_y(node)
      }
    None => @graph.node_y(node)
  }
  set_node_layout(json_node, output_x, output_y, node)
  for port in @graph.node_ports(node) {
    match importer.port_json_map.get(port) {
      Some(json_port) => {
        let port_output_x = if node_shape_coords_mode(node) is ShapeRoot {
          @graph.port_x(port) + node_global_x(node)
        } else {
          @graph.port_x(port)
        }
        let port_output_y = if node_shape_coords_mode(node) is ShapeRoot {
          @graph.port_y(port) + node_global_y(node)
        } else {
          @graph.port_y(port)
        }
        set_port_layout(json_port, port_output_x, port_output_y, port)
      }
      None => ()
    }
  }
  for label in @graph.node_labels(node) {
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
  for port in @graph.node_ports(node) {
    for label in @graph.port_labels(port) {
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
  for edge in @graph.node_contained_edges(node) {
    let json_edge = match importer.edge_json_map.get(edge) {
      Some(json_obj) => json_obj
      None => abort("JsonImportException")
    }
    let edge_id = if @graph.edge_identifier(edge).is_empty() {
      required_json_id(json_edge)
    } else {
      @graph.edge_identifier(edge)
    }
    importer_transfer_edge_sections(importer, json_edge, edge, edge_id)
    let edge_mode = match importer.edge_original_parent_map.get(edge) {
      Some(original_parent) => node_edge_coords_mode(original_parent)
      None => EdgeContainer
    }
    if edge_mode is EdgeContainer {
      match @graph.edge_containing_node(edge) {
        Some(container) =>
          if !@graph.node_identifier(container).is_empty() {
            json_edge["container"] = Json::string(
              @graph.node_identifier(container),
            )
          }
        None => ()
      }
    }
    for label in @graph.edge_labels(edge) {
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
  for child in @graph.node_children(node) {
    importer_transfer_layout_node(importer, child)
  }
}

///|
pub fn JsonImporter::transfer_layout(
  self : JsonImporter,
  graph : @graph.ElkNode,
) -> Unit {
  importer_transfer_layout_node(self, graph)
}
