///|
let layout_dot_exporter_nslimit_base : Float = 100.0

///|
fn layout_dot_exporter_parse_double(text : String?) -> Double? {
  let normalized = match text {
    Some(value) => value.trim().to_string()
    None => ""
  }
  if normalized.is_empty() {
    return None
  }
  let parsed_double : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    normalized,
  )
  match parsed_double {
    Ok(value) => Some(value)
    Err(_) =>
      if normalized.has_suffix("f") ||
        normalized.has_suffix("F") ||
        normalized.has_suffix("d") ||
        normalized.has_suffix("D") {
        let without_suffix = normalized.substring(
          start=0,
          end=normalized.length() - 1,
        )
        if without_suffix.is_empty() {
          None
        } else {
          let parsed_without_suffix : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
            without_suffix,
          )
          match parsed_without_suffix {
            Ok(value) => Some(value)
            Err(_) => None
          }
        }
      } else {
        None
      }
  }
}

///|
fn layout_dot_exporter_parse_int(text : String?) -> Int? {
  let normalized = match text {
    Some(value) => value.trim().to_string()
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
      match layout_dot_exporter_parse_double(Some(normalized)) {
        Some(value) => Some(value.to_int())
        None => None
      }
  }
}

///|
fn layout_dot_exporter_parse_bool(text : String?) -> Bool? {
  let normalized = match text {
    Some(value) => value.trim().to_string().to_lower()
    None => ""
  }
  if normalized.is_empty() {
    None
  } else if normalized == "true" || normalized == "1" {
    Some(true)
  } else if normalized == "false" || normalized == "0" {
    Some(false)
  } else {
    None
  }
}

///|
fn layout_dot_exporter_node_option_string(
  node : ElkNode,
  option : IProperty[String],
) -> String {
  match node_layout_option_string_value(node, option.get_id()) {
    Some(value) => value
    None => node_get_string_property(node, option)
  }
}

///|
fn layout_dot_exporter_node_option_bool(
  node : ElkNode,
  option : IProperty[Bool],
) -> Bool {
  match node_layout_option_string_value(node, option.get_id()) {
    Some(value) =>
      match layout_dot_exporter_parse_bool(Some(value)) {
        Some(parsed) => parsed
        None => node_get_bool_property(node, option)
      }
    None => node_get_bool_property(node, option)
  }
}

///|
fn layout_dot_exporter_node_option_int(
  node : ElkNode,
  option : IProperty[Int],
) -> Int {
  match node_layout_option_string_value(node, option.get_id()) {
    Some(value) =>
      match layout_dot_exporter_parse_int(Some(value)) {
        Some(parsed) => parsed
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn layout_dot_exporter_node_option_double(
  node : ElkNode,
  option : IProperty[Double],
) -> Double {
  match node_layout_option_string_value(node, option.get_id()) {
    Some(value) =>
      match layout_dot_exporter_parse_double(Some(value)) {
        Some(parsed) => parsed
        None => node_get_double_property(node, option)
      }
    None => node_get_double_property(node, option)
  }
}

///|
fn layout_dot_exporter_edge_option_double(
  edge : ElkEdge,
  option : IProperty[Double],
) -> Double {
  match edge_layout_option_string_value(edge, option.get_id()) {
    Some(value) =>
      match layout_dot_exporter_parse_double(Some(value)) {
        Some(parsed) => parsed
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn layout_dot_exporter_parse_neato_model(value : String) -> NeatoModel {
  let normalized = value.trim().to_string().to_upper()
  if normalized == "CIRCUIT" {
    Circuit
  } else if normalized == "SUBSET" {
    Subset
  } else {
    Shortpath
  }
}

///|
fn layout_dot_exporter_parse_overlap_mode(value : String) -> OverlapMode {
  let normalized = value.trim().to_string().to_upper()
  if normalized == "NONE" || normalized == "TRUE" {
    OverlapNone
  } else if normalized == "SCALE" {
    OverlapScale
  } else if normalized == "SCALEXY" {
    OverlapScalexy
  } else if normalized == "COMPRESS" {
    OverlapCompress
  } else {
    OverlapPrism
  }
}

///|
fn layout_dot_exporter_parse_edge_label_placement(
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
fn layout_dot_exporter_is_end_label_placement(
  placement : EdgeLabelPlacement,
) -> Bool {
  match placement {
    Head => true
    Tail => true
    _ => false
  }
}

///|
fn layout_dot_exporter_is_shortpath(model : NeatoModel) -> Bool {
  match model {
    Shortpath => true
    _ => false
  }
}

///|
fn layout_dot_exporter_is_command_dot(command : Command) -> Bool {
  match command {
    Dot => true
    _ => false
  }
}

///|
fn layout_dot_exporter_is_command_twopi(command : Command) -> Bool {
  match command {
    Twopi => true
    _ => false
  }
}

///|
fn layout_dot_exporter_is_command_neato_or_fdp(command : Command) -> Bool {
  match command {
    Neato => true
    Fdp => true
    _ => false
  }
}

///|
fn layout_dot_exporter_is_overlap_none(mode : OverlapMode) -> Bool {
  match mode {
    OverlapNone => true
    _ => false
  }
}

///|
fn layout_dot_exporter_has_end_labels(edge : ElkEdge) -> Bool {
  for label in edge_labels(edge) {
    let placement = layout_dot_exporter_parse_edge_label_placement(
      label_layout_option_string_value(
        label, dot_exporter_option_edge_labels_placement,
      ),
    )
    if layout_dot_exporter_is_end_label_placement(placement) {
      return true
    }
  }
  false
}

///|
fn layout_dot_exporter_unquote(text : String) -> String {
  if text.length() >= 2 && text.has_prefix("\"") && text.has_suffix("\"") {
    text.substring(start=1, end=text.length() - 1)
  } else {
    text
  }
}

///|
fn layout_dot_exporter_statement_attribute_map(
  edge_statement : DotEdgeStatement,
) -> Map[String, String] {
  dot_exporter_create_attribute_map(edge_statement.get_attributes())
}

///|
fn layout_dot_exporter_append_graph_attributes(
  statements : Array[DotStatement],
  parent_node : ElkNode,
  command : Command,
  trans_data : DotTransformationData[ElkNode, DotGraphvizModel],
) -> Unit {
  let graph_attr_statement = dot_create_attribute_statement()
  graph_attr_statement.set_type(Some(dot_attribute_type_graph()))
  statements.insert(0, dot_statement_attribute_statement(graph_attr_statement))
  let graph_attrs = graph_attr_statement.get_attributes()

  let node_attr_statement = dot_create_attribute_statement()
  node_attr_statement.set_type(Some(dot_attribute_type_node()))
  statements.insert(1, dot_statement_attribute_statement(node_attr_statement))
  let node_attrs = node_attr_statement.get_attributes()
  node_attrs.push(dot_exporter_create_attribute(dot_attr_shape, "box"))
  node_attrs.push(dot_exporter_create_attribute(dot_attr_fixedsize, "true"))

  let edge_attr_statement = dot_create_attribute_statement()
  edge_attr_statement.set_type(Some(dot_attribute_type_edge()))
  statements.insert(2, dot_statement_attribute_statement(edge_attr_statement))
  let edge_attrs = edge_attr_statement.get_attributes()
  edge_attrs.push(dot_exporter_create_attribute(dot_attr_edgedir, "none"))

  let mut spacing = layout_dot_exporter_node_option_double(
    parent_node, spacing_node_node,
  )
  if spacing < 0.0 {
    match command {
      Circo | Fdp | Neato => spacing = dot_exporter_def_spacing_large
      Twopi => spacing = dot_exporter_def_spacing_xlarge
      _ => spacing = dot_exporter_def_spacing_small
    }
  }

  match command {
    Dot => {
      graph_attrs.push(
        dot_exporter_create_attribute_double(
          dot_attr_nodesep,
          spacing / dot_exporter_dpi.to_double(),
        ),
      )
      let rank_sep_factor = layout_dot_exporter_node_option_double(
        parent_node, graphviz_option_layer_spacing_factor,
      )
      graph_attrs.push(
        dot_exporter_create_attribute_double(
          dot_attr_ranksep,
          rank_sep_factor * spacing / dot_exporter_dpi.to_double(),
        ),
      )
      let direction_value = node_get_string_property(parent_node, direction).to_upper()
      if direction_value == "UP" {
        graph_attrs.push(dot_exporter_create_attribute(dot_attr_rankdir, "BT"))
      } else if direction_value == "LEFT" {
        graph_attrs.push(dot_exporter_create_attribute(dot_attr_rankdir, "RL"))
      } else if direction_value == "RIGHT" {
        graph_attrs.push(dot_exporter_create_attribute(dot_attr_rankdir, "LR"))
      } else {
        graph_attrs.push(dot_exporter_create_attribute(dot_attr_rankdir, "TB"))
      }
      let iterations_factor = layout_dot_exporter_node_option_double(
        parent_node, graphviz_option_iterations_factor,
      )
      if iterations_factor > 0.0 {
        graph_attrs.push(
          dot_exporter_create_attribute_double(
            dot_attr_crossmin_limit, iterations_factor,
          ),
        )
        if iterations_factor < 1.0 {
          graph_attrs.push(
            dot_exporter_create_attribute_double(
              dot_attr_simplex_limit,
              iterations_factor * layout_dot_exporter_nslimit_base.to_double(),
            ),
          )
        }
      }
      let hierarchy_handling = layout_dot_exporter_node_option_string(
        parent_node, graphviz_core_option_hierarchy_handling,
      ).to_upper()
      if hierarchy_handling == "INCLUDE_CHILDREN" {
        graph_attrs.push(
          dot_exporter_create_attribute(dot_attr_compound, "true"),
        )
      }
    }
    Twopi =>
      graph_attrs.push(
        dot_exporter_create_attribute_double(
          dot_attr_ranksep,
          spacing / dot_exporter_dpi.to_double(),
        ),
      )
    Circo =>
      graph_attrs.push(
        dot_exporter_create_attribute_double(
          dot_attr_mindist,
          spacing / dot_exporter_dpi.to_double(),
        ),
      )
    Neato => {
      edge_attrs.push(
        dot_exporter_create_attribute_double(
          dot_attr_edgelen,
          spacing / dot_exporter_dpi.to_double(),
        ),
      )
      let seed_value = layout_dot_exporter_node_option_int(
        parent_node, graphviz_core_option_random_seed,
      )
      let seed = if seed_value == 0 {
        -1
      } else if seed_value < 0 {
        -seed_value
      } else {
        seed_value
      }
      graph_attrs.push(
        dot_exporter_create_attribute(
          dot_attr_start,
          "random" + seed.to_string(),
        ),
      )
      let epsilon = layout_dot_exporter_node_option_double(
        parent_node, graphviz_option_epsilon,
      )
      if epsilon > 0.0 {
        graph_attrs.push(
          dot_exporter_create_attribute_double(dot_attr_epsilon, epsilon),
        )
      }
      let model = layout_dot_exporter_parse_neato_model(
        layout_dot_exporter_node_option_string(
          parent_node, graphviz_option_neato_model,
        ),
      )
      if !layout_dot_exporter_is_shortpath(model) {
        graph_attrs.push(
          dot_exporter_create_attribute(
            dot_attr_neato_model,
            neato_model_literal(model),
          ),
        )
      }
    }
    Fdp =>
      graph_attrs.push(
        dot_exporter_create_attribute_double(
          dot_attr_spring_constant,
          spacing / dot_exporter_dpi.to_double(),
        ),
      )
    Invalid => ()
  }

  if layout_dot_exporter_is_command_neato_or_fdp(command) {
    let maxiter = layout_dot_exporter_node_option_int(
      parent_node, graphviz_option_maxiter,
    )
    if maxiter > 0 {
      graph_attrs.push(
        dot_exporter_create_attribute_int(dot_attr_maxiter, maxiter),
      )
    }
  }

  if !layout_dot_exporter_is_command_dot(command) {
    let overlap_mode = layout_dot_exporter_parse_overlap_mode(
      layout_dot_exporter_node_option_string(
        parent_node, graphviz_option_overlap_mode,
      ),
    )
    if !layout_dot_exporter_is_overlap_none(overlap_mode) {
      graph_attrs.push(
        dot_exporter_create_attribute(
          dot_attr_overlap,
          overlap_mode_literal(overlap_mode),
        ),
      )
      graph_attrs.push(
        dot_exporter_create_attribute(
          dot_attr_sep,
          "\"+" + (spacing / 2.0).round().to_int().to_string() + "\"",
        ),
      )
    }
    let pack = layout_dot_exporter_node_option_bool(
      parent_node, graphviz_core_option_separate_connected_components,
    )
    if layout_dot_exporter_is_command_twopi(command) || pack {
      graph_attrs.push(
        dot_exporter_create_attribute_int(dot_attr_pack, spacing.to_int()),
      )
    }
  }

  let edge_routing = layout_dot_exporter_node_option_string(
    parent_node, graphviz_core_option_edge_routing,
  ).to_upper()
  if edge_routing == "POLYLINE" {
    graph_attrs.push(
      dot_exporter_create_attribute(dot_attr_splines, "polyline"),
    )
  } else if edge_routing == "ORTHOGONAL" {
    graph_attrs.push(dot_exporter_create_attribute(dot_attr_splines, "ortho"))
  } else {
    graph_attrs.push(dot_exporter_create_attribute(dot_attr_splines, "spline"))
    trans_data.set_bool_property(dot_exporter_use_splines, true)
  }

  if layout_dot_exporter_node_option_bool(
      parent_node, graphviz_option_concentrate,
    ) {
    graph_attrs.push(
      dot_exporter_create_attribute(dot_attr_concentrate, "true"),
    )
  }
}

///|
fn layout_dot_exporter_apply_graph_attributes_recursive(
  statements : Array[DotStatement],
  parent_node : ElkNode,
  command : Command,
  trans_data : DotTransformationData[ElkNode, DotGraphvizModel],
) -> Unit {
  layout_dot_exporter_append_graph_attributes(
    statements, parent_node, command, trans_data,
  )
  let graph_elems = trans_data.get_graph_elem_map_property(
    dot_exporter_graph_elems,
  )
  for statement in statements.copy() {
    match statement {
      DotStatementSubgraph(subgraph) =>
        match subgraph.get_name() {
          Some(name) =>
            match graph_elems.get(name) {
              Some(graph_elem) =>
                match dot_graph_element_as_node(graph_elem) {
                  Some(node) =>
                    layout_dot_exporter_apply_graph_attributes_recursive(
                      subgraph.get_statements(),
                      node,
                      command,
                      trans_data,
                    )
                  None => ()
                }
              None => ()
            }
          None => ()
        }
      _ => ()
    }
  }
}

///|
fn layout_dot_exporter_set_edge_labels_for_statement(
  edge_statement : DotEdgeStatement,
  trans_data : DotTransformationData[ElkNode, DotGraphvizModel],
) -> Unit {
  let attributes = edge_statement.get_attributes()
  let attr_map = layout_dot_exporter_statement_attribute_map(edge_statement)
  let edge_id = match attr_map.get(dot_attr_comment) {
    Some(value) => layout_dot_exporter_unquote(value)
    None => return
  }
  let graph_elems = trans_data.get_graph_elem_map_property(
    dot_exporter_graph_elems,
  )
  let edge = match graph_elems.get(edge_id) {
    Some(graph_elem) =>
      match dot_graph_element_as_edge(graph_elem) {
        Some(value) => value
        None => return
      }
    None => return
  }
  if !layout_dot_exporter_has_end_labels(edge) {
    return
  }
  if attr_map.get(dot_attr_labeldistance) is None {
    let distance = layout_dot_exporter_edge_option_double(
      edge, graphviz_option_label_distance,
    )
    if distance >= 0.0 {
      attributes.push(
        dot_exporter_create_attribute_double(dot_attr_labeldistance, distance),
      )
    }
  }
  if attr_map.get(dot_attr_labelangle) is None {
    let angle = layout_dot_exporter_edge_option_double(
      edge, graphviz_option_label_angle,
    )
    attributes.push(
      dot_exporter_create_attribute_double(dot_attr_labelangle, angle),
    )
  }
}

///|
fn layout_dot_exporter_apply_edge_labels_recursive(
  statements : Array[DotStatement],
  trans_data : DotTransformationData[ElkNode, DotGraphvizModel],
) -> Unit {
  for statement in statements {
    match statement {
      DotStatementEdgeStatement(edge_statement) =>
        layout_dot_exporter_set_edge_labels_for_statement(
          edge_statement, trans_data,
        )
      DotStatementSubgraph(subgraph) =>
        layout_dot_exporter_apply_edge_labels_recursive(
          subgraph.get_statements(),
          trans_data,
        )
      _ => ()
    }
  }
}

///|
pub struct LayoutDotExporter {
  base : DotExporter
}

///|
pub fn new_layout_dot_exporter() -> LayoutDotExporter {
  { base: new_dot_exporter() }
}

///|
pub fn LayoutDotExporter::transform(
  self : LayoutDotExporter,
  trans_data : DotTransformationData[ElkNode, DotGraphvizModel],
) -> Unit {
  let source_graph = match trans_data.get_source_graph() {
    Some(graph) => graph
    None => return
  }
  let command = trans_data.get_command_property(dot_exporter_command)
  let hierarchy_handling = layout_dot_exporter_node_option_string(
    source_graph, graphviz_core_option_hierarchy_handling,
  ).to_upper()
  trans_data.set_bool_property(dot_exporter_use_edge_ids, true)
  trans_data.set_bool_property(
    dot_exporter_hierarchy,
    hierarchy_handling == "INCLUDE_CHILDREN" &&
    layout_dot_exporter_is_command_dot(command),
  )
  trans_data.set_bool_property(
    dot_exporter_transform_node_layout,
    layout_dot_exporter_node_option_bool(
      source_graph, graphviz_core_option_interactive,
    ),
  )
  trans_data.set_bool_property(dot_exporter_transform_edge_layout, false)
  trans_data.set_bool_property(dot_exporter_transform_node_labels, false)
  trans_data.set_bool_property(
    dot_exporter_adapt_port_positions,
    layout_dot_exporter_node_option_bool(
      source_graph, graphviz_option_adapt_port_positions,
    ),
  )
  self.base.transform(trans_data)

  let target_graphs = trans_data.get_target_graphs()
  if target_graphs.is_empty() {
    return
  }
  let graphs = target_graphs[0].get_graphs()
  if graphs.is_empty() {
    return
  }
  let statements = graphs[0].get_statements()
  layout_dot_exporter_apply_graph_attributes_recursive(
    statements, source_graph, command, trans_data,
  )
  layout_dot_exporter_apply_edge_labels_recursive(statements, trans_data)
}
