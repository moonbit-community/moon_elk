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
      if node_shape_coords_mode(node) is ShapeRoot {
        label_x(label) + node_global_x(node)
      } else {
        label_x(label)
      }
    Some(PortLabelParent(port)) =>
      if port_shape_coords_mode(port) is ShapeRoot {
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
      if node_shape_coords_mode(node) is ShapeRoot {
        label_y(label) + node_global_y(node)
      } else {
        label_y(label)
      }
    Some(PortLabelParent(port)) =>
      if port_shape_coords_mode(port) is ShapeRoot {
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
      if node_shape_coords_mode(parent) is ShapeRoot {
        node_x(node) + node_global_x(parent)
      } else {
        node_x(node)
      }
    None => node_x(node)
  }
  let output_y = match node_parent(node) {
    Some(parent) =>
      if node_shape_coords_mode(parent) is ShapeRoot {
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
        let port_output_x = if node_shape_coords_mode(node) is ShapeRoot {
          port_x(port) + node_global_x(node)
        } else {
          port_x(port)
        }
        let port_output_y = if node_shape_coords_mode(node) is ShapeRoot {
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
    if edge_mode is EdgeContainer {
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
