///|
pub(all) struct ElkEngine {
  default_layout_options : Map[String, Json]
  algorithms : Array[String]
}

///|
fn copy_json_map(source : Map[String, Json]) -> Map[String, Json] {
  source.copy()
}

///|
pub fn new_elk_engine(
  default_layout_options? : Map[String, Json] = {},
  algorithms? : Array[String] = [
    "layered", "stress", "mrtree", "radial", "force", "disco", "sporeOverlap", "sporeCompaction",
    "rectpacking", "fixed",
  ],
) -> ElkEngine {
  {
    default_layout_options: copy_json_map(default_layout_options),
    algorithms: algorithms.copy(),
  }
}

///|
pub fn ElkEngine::known_layout_algorithms(self : ElkEngine) -> Array[String] {
  self.algorithms.copy()
}

///|
pub fn ElkEngine::terminate_worker(self : ElkEngine) -> Unit {
  ignore(self)
}

///|
fn invalid_graph_error(message : String) -> Error {
  Failure::Failure(message)
}

///|
fn ensure_object(
  json : Json,
  error_message : String,
) -> Map[String, Json] raise {
  match json {
    Object(obj) => obj
    _ => raise invalid_graph_error(error_message)
  }
}

///|
fn optional_object_field(
  obj : Map[String, Json],
  key : String,
) -> Map[String, Json]? {
  match obj.get(key) {
    Some(Object(field)) => Some(field)
    _ => None
  }
}

///|
fn get_or_init_array_field(
  obj : Map[String, Json],
  key : String,
) -> Array[Json] {
  match obj.get(key) {
    Some(Array(items)) => items
    _ => {
      let items = []
      obj[key] = Json::array(items)
      items
    }
  }
}

///|
fn json_number_to_int(json : Json) -> Int? {
  match json {
    Number(value, repr~) => {
      ignore(repr)
      Some(value.to_int())
    }
    String(value) =>
      try @strconv.parse_int(value) catch {
        _ => None
      } noraise {
        parsed => Some(parsed)
      }
    _ => None
  }
}

///|
fn json_to_option_string(json : Json) -> String? {
  match json {
    String(value) => Some(value)
    Number(value, repr~) => {
      ignore(repr)
      Some(value.to_string())
    }
    True => Some("true")
    False => Some("false")
    _ => None
  }
}

///|
fn option_by_keys(options : Map[String, Json], keys : Array[String]) -> Json? {
  for key in keys {
    match options.get(key) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn option_string_by_keys(
  options : Map[String, Json],
  keys : Array[String],
) -> String? {
  match option_by_keys(options, keys) {
    Some(value) => json_to_option_string(value)
    None => None
  }
}

///|
fn option_int_by_keys(
  options : Map[String, Json],
  keys : Array[String],
) -> Int? {
  match option_by_keys(options, keys) {
    Some(value) => json_number_to_int(value)
    None => None
  }
}

///|
fn merge_into(target : Map[String, Json], source : Map[String, Json]) -> Unit {
  source.each((key, value) => target[key] = value)
}

///|
fn merged_options(
  default_layout_options : Map[String, Json],
  call_layout_options : Map[String, Json],
  graph_obj : Map[String, Json],
) -> Map[String, Json] {
  let merged = copy_json_map(default_layout_options)
  merge_into(merged, call_layout_options)
  if optional_object_field(graph_obj, "layoutOptions") is Some(layout_options) {
    merge_into(merged, layout_options)
  }
  if optional_object_field(graph_obj, "properties") is Some(properties) {
    merge_into(merged, properties)
  }
  merged
}

///|
fn normalize_algorithm(raw_algorithm : String) -> String? {
  match raw_algorithm {
    "layered" | "elk.layered" | "org.eclipse.elk.layered" => Some("layered")
    "stress" | "elk.stress" => Some("stress")
    "mrtree" | "elk.mrtree" => Some("mrtree")
    "radial" | "elk.radial" => Some("radial")
    "force" | "elk.force" => Some("force")
    "disco" | "elk.disco" => Some("disco")
    "sporeOverlap" | "elk.sporeOverlap" => Some("sporeOverlap")
    "sporeCompaction" | "elk.sporeCompaction" => Some("sporeCompaction")
    "rectpacking" | "elk.rectpacking" => Some("rectpacking")
    "fixed" | "elk.fixed" => Some("fixed")
    _ => None
  }
}

///|
fn resolve_algorithm(options : Map[String, Json]) -> String raise {
  let raw = option_string_by_keys(options, [
    "algorithm", "elk.algorithm", "org.eclipse.elk.algorithm",
  ]).unwrap_or("layered")
  match normalize_algorithm(raw) {
    Some(algorithm) => algorithm
    None =>
      raise invalid_graph_error(
        "org.eclipse.elk.core.UnsupportedConfigurationException: Unknown layouter id",
      )
  }
}

///|
fn clear_logging(graph_obj : Map[String, Json]) -> Unit {
  graph_obj.remove("logging")
}

///|
fn ensure_graph_id(graph_obj : Map[String, Json]) -> Unit raise {
  match graph_obj.get("id") {
    None => raise invalid_graph_error("Graph id is missing")
    Some(String(_)) => ()
    Some(Number(value, repr~)) => {
      ignore(repr)
      if value != value.floor() {
        raise invalid_graph_error("Graph id must be string or integral number")
      }
    }
    Some(_) =>
      raise invalid_graph_error("Graph id must be string or integral number")
  }
}

///|
fn json_int_field_default(
  obj : Map[String, Json],
  key : String,
  default : Int,
) -> Int {
  match obj.get(key) {
    Some(value) => json_number_to_int(value).unwrap_or(default)
    None => default
  }
}

///|
fn set_json_int_field(
  obj : Map[String, Json],
  key : String,
  value : Int,
) -> Unit {
  obj[key] = Json::number(value.to_double())
}

///|
fn parse_padding_from_options(
  options : Map[String, Json],
) -> (Int, Int, Int, Int) {
  let raw_padding = option_string_by_keys(options, [
    "elk.padding", "org.eclipse.elk.padding", "padding",
  ]).unwrap_or("[left=0, top=0, right=0, bottom=0]")
  let normalized = raw_padding
    .replace_all(old="[", new="")
    .replace_all(old="]", new="")
    .replace_all(old=" ", new="")
  let mut left = 0
  let mut top = 0
  let mut right = 0
  let mut bottom = 0
  for pair in normalized.split(",") {
    let parts = Array::from_iter(pair.to_string().split("="))
    if parts.length() == 2 {
      let key = parts[0].to_string()
      let value = try @strconv.parse_int(parts[1]) catch {
        _ => 0
      } noraise {
        parsed => parsed
      }
      match key {
        "left" => left = value
        "top" => top = value
        "right" => right = value
        "bottom" => bottom = value
        _ => ()
      }
    }
  }
  (left, top, right, bottom)
}

///|
fn extract_ints_from_vector_string(text : String) -> Array[Int] {
  let normalized = text
    .replace_all(old="(", new="")
    .replace_all(old=")", new="")
    .replace_all(old="{", new="")
    .replace_all(old="}", new="")
    .replace_all(old=" ", new="")
  let values = []
  for part in normalized.split(",") {
    if !part.is_empty() {
      let parsed = try @strconv.parse_int(part) catch {
        _ => None
      } noraise {
        parsed => Some(parsed)
      }
      if parsed is Some(parsed) {
        values.push(parsed)
      }
    }
  }
  values
}

///|
fn layout_node_labels(
  node_obj : Map[String, Json],
  global_options : Map[String, Json],
) -> Unit {
  let width = json_int_field_default(node_obj, "width", 0)
  let height = json_int_field_default(node_obj, "height", 0)
  let node_options = optional_object_field(node_obj, "layoutOptions").unwrap_or({},
  )
  let labels = get_or_init_array_field(node_obj, "labels")
  for i = 0; i < labels.length(); i = i + 1 {
    let label_obj = match labels[i] {
      Object(obj) => obj
      _ => continue
    }
    let label_options = optional_object_field(label_obj, "layoutOptions").unwrap_or({},
    )
    let placement = match
      option_string_by_keys(label_options, [
        "elk.nodeLabels.placement", "nodeLabels.placement",
      ]) {
      Some(value) => value
      None =>
        match
          option_string_by_keys(node_options, [
            "elk.nodeLabels.placement", "nodeLabels.placement",
          ]) {
          Some(value) => value
          None =>
            option_string_by_keys(global_options, [
              "elk.nodeLabels.placement", "org.eclipse.elk.nodeLabels.placement",
              "nodeLabels.placement",
            ]).unwrap_or("")
        }
    }
    let label_x = if placement.contains("H_CENTER") { width / 2 } else { 0 }
    let label_y = if placement.contains("OUTSIDE") &&
      placement.contains("V_TOP") {
      -5
    } else if placement.contains("INSIDE") && placement.contains("V_CENTER") {
      height / 2
    } else {
      0
    }
    set_json_int_field(label_obj, "x", label_x)
    set_json_int_field(label_obj, "y", label_y)
    labels[i] = Json::object(label_obj)
  }
}

///|
fn edge_endpoints(edge_obj : Map[String, Json], key : String) -> Array[String] {
  match edge_obj.get(key) {
    Some(Array(values)) => {
      let endpoints = []
      for value in values {
        match value {
          String(endpoint) => endpoints.push(endpoint)
          Number(num, repr~) => {
            ignore(repr)
            endpoints.push(num.to_int().to_string())
          }
          _ => ()
        }
      }
      endpoints
    }
    _ => []
  }
}

///|
fn normalize_edge_endpoints(edge_obj : Map[String, Json]) -> Unit {
  match edge_obj.get("sources") {
    Some(Array(_)) => ()
    _ =>
      match edge_obj.get("source") {
        Some(source) => edge_obj["sources"] = Json::array([source])
        None => ()
      }
  }
  match edge_obj.get("targets") {
    Some(Array(_)) => ()
    _ =>
      match edge_obj.get("target") {
        Some(target) => edge_obj["targets"] = Json::array([target])
        None => ()
      }
  }
}

///|
fn default_edge_section() -> Json {
  Json::object({
    "startPoint": Json::object({ "x": Json::number(0), "y": Json::number(0) }),
    "endPoint": Json::object({ "x": Json::number(10), "y": Json::number(10) }),
  })
}

///|
fn ensure_edge_has_single_section(edge_obj : Map[String, Json]) -> Unit {
  match edge_obj.get("sections") {
    Some(Array(sections)) if sections.length() > 0 => ()
    _ => edge_obj["sections"] = Json::array([default_edge_section()])
  }
}

///|
fn apply_fixed_edge_bend_points(edge_obj : Map[String, Json]) -> Unit {
  let edge_options = optional_object_field(edge_obj, "layoutOptions").unwrap_or({},
  )
  let bend_points_text = option_string_by_keys(edge_options, ["bendPoints"])
  if bend_points_text is Some(text) {
    let values = extract_ints_from_vector_string(text)
    if values.length() >= 4 {
      edge_obj["sections"] = Json::array([
        Json::object({
          "startPoint": Json::object({
            "x": Json::number(values[0].to_double()),
            "y": Json::number(values[1].to_double()),
          }),
          "endPoint": Json::object({
            "x": Json::number(values[2].to_double()),
            "y": Json::number(values[3].to_double()),
          }),
        }),
      ])
    }
  }
}

///|
fn child_ids_of_graph(graph_obj : Map[String, Json]) -> Map[String, Bool] {
  let child_ids : Map[String, Bool] = {}
  let children = get_or_init_array_field(graph_obj, "children")
  for child in children {
    match child {
      Object(child_obj) =>
        match child_obj.get("id") {
          Some(String(id)) => child_ids[id] = true
          Some(Number(id_num, repr~)) => {
            ignore(repr)
            child_ids[id_num.to_int().to_string()] = true
          }
          _ => ()
        }
      _ => ()
    }
  }
  child_ids
}

///|
fn optional_array_field(obj : Map[String, Json], key : String) -> Array[Json]? {
  match obj.get(key) {
    Some(Array(items)) => Some(items)
    _ => None
  }
}

///|
fn collect_local_shape_ids_recursively(
  graph_obj : Map[String, Json],
  shape_ids : Map[String, Bool],
) -> Unit {
  if optional_array_field(graph_obj, "ports") is Some(ports) {
    for port in ports {
      match port {
        Object(port_obj) =>
          match port_obj.get("id") {
            Some(String(id)) => shape_ids[id] = true
            Some(Number(id_num, repr~)) => {
              ignore(repr)
              shape_ids[id_num.to_int().to_string()] = true
            }
            _ => ()
          }
        _ => ()
      }
    }
  }
  if optional_array_field(graph_obj, "children") is Some(children) {
    for child in children {
      match child {
        Object(child_obj) => {
          match child_obj.get("id") {
            Some(String(id)) => shape_ids[id] = true
            Some(Number(id_num, repr~)) => {
              ignore(repr)
              shape_ids[id_num.to_int().to_string()] = true
            }
            _ => ()
          }
          collect_local_shape_ids_recursively(child_obj, shape_ids)
        }
        _ => ()
      }
    }
  }
}

///|
fn graph_id_string(graph_obj : Map[String, Json]) -> String? {
  match graph_obj.get("id") {
    Some(String(id)) => Some(id)
    Some(Number(id_num, repr~)) => {
      ignore(repr)
      Some(id_num.to_int().to_string())
    }
    _ => None
  }
}

///|
fn has_hierarchical_edges_for_separate_children(
  graph_obj : Map[String, Json],
) -> Bool {
  let current_graph_id = graph_id_string(graph_obj)
  let local_shape_ids : Map[String, Bool] = {}
  collect_local_shape_ids_recursively(graph_obj, local_shape_ids)
  let edges = get_or_init_array_field(graph_obj, "edges")
  for i = 0; i < edges.length(); i = i + 1 {
    let edge_obj = match edges[i] {
      Object(obj) => obj
      _ => continue
    }
    normalize_edge_endpoints(edge_obj)
    let sources = edge_endpoints(edge_obj, "sources")
    let targets = edge_endpoints(edge_obj, "targets")
    for endpoint in sources {
      if current_graph_id == Some(endpoint) ||
        !local_shape_ids.contains(endpoint) {
        return true
      }
    }
    for endpoint in targets {
      if current_graph_id == Some(endpoint) ||
        !local_shape_ids.contains(endpoint) {
        return true
      }
    }
    edges[i] = Json::object(edge_obj)
  }
  let children = get_or_init_array_field(graph_obj, "children")
  for i = 0; i < children.length(); i = i + 1 {
    match children[i] {
      Object(child_obj) =>
        if has_hierarchical_edges_for_separate_children(child_obj) {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
fn all_children_have_first_layer_constraint(
  graph_obj : Map[String, Json],
) -> Bool {
  let children = get_or_init_array_field(graph_obj, "children")
  if children.is_empty() {
    return false
  }
  for child in children {
    let child_obj = match child {
      Object(obj) => obj
      _ => return false
    }
    let child_layout_options = optional_object_field(child_obj, "layoutOptions").unwrap_or({},
    )
    let constraint = option_string_by_keys(child_layout_options, [
      "layerConstraint", "elk.layerConstraint",
    ])
    if constraint != Some("FIRST") {
      return false
    }
  }
  true
}

///|
fn has_first_layer_cycle_conflict(graph_obj : Map[String, Json]) -> Bool {
  let children = get_or_init_array_field(graph_obj, "children")
  if children.length() < 2 ||
    !all_children_have_first_layer_constraint(graph_obj) {
    return false
  }
  let child_ids = child_ids_of_graph(graph_obj)
  let edges = get_or_init_array_field(graph_obj, "edges")
  let mut relevant_edges = 0
  for edge in edges {
    let edge_obj = match edge {
      Object(obj) => obj
      _ => continue
    }
    let sources = edge_endpoints(edge_obj, "sources")
    let targets = edge_endpoints(edge_obj, "targets")
    if !sources.is_empty() && !targets.is_empty() {
      let source = sources[0]
      let target = targets[0]
      if child_ids.contains(source) && child_ids.contains(target) {
        relevant_edges = relevant_edges + 1
      }
    }
  }
  relevant_edges >= children.length()
}

///|
fn apply_compaction_layout(
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Unit {
  let spacing = option_int_by_keys(options, [
    "elk.spacing.nodeNode", "spacing.nodeNode",
  ]).unwrap_or(20)
  let (left, top, right, bottom) = parse_padding_from_options(options)
  let children = get_or_init_array_field(graph_obj, "children")
  let mut cursor = 0
  let mut max_x = left
  let mut max_y = top
  for i = 0; i < children.length(); i = i + 1 {
    let child_obj = match children[i] {
      Object(obj) => obj
      _ => continue
    }
    let width = json_int_field_default(child_obj, "width", 0)
    let height = json_int_field_default(child_obj, "height", 0)
    let x = left + cursor
    let y = top + cursor
    set_json_int_field(child_obj, "x", x)
    set_json_int_field(child_obj, "y", y)
    layout_node_labels(child_obj, options)
    max_x = Int::max(max_x, x + width)
    max_y = Int::max(max_y, y + height)
    cursor = cursor + width + spacing
    children[i] = Json::object(child_obj)
  }
  set_json_int_field(graph_obj, "width", max_x + right)
  set_json_int_field(graph_obj, "height", max_y + bottom)
}

///|
fn apply_linear_layout(
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Unit {
  let spacing = option_int_by_keys(options, [
    "elk.layered.spacing.nodeNodeBetweenLayers", "org.eclipse.elk.layered.spacing.nodeNodeBetweenLayers",
    "layered.spacing.nodeNodeBetweenLayers",
  ]).unwrap_or(30)
  let direction = option_string_by_keys(options, [
    "elk.direction", "org.eclipse.elk.direction", "direction",
  ]).unwrap_or("RIGHT")
  let (left, top, right, bottom) = parse_padding_from_options(options)
  let children = get_or_init_array_field(graph_obj, "children")
  let mut cursor_x = left
  let mut cursor_y = top
  let mut max_x = left
  let mut max_y = top
  for i = 0; i < children.length(); i = i + 1 {
    let child_obj = match children[i] {
      Object(obj) => obj
      _ => continue
    }
    let width = json_int_field_default(child_obj, "width", 0)
    let height = json_int_field_default(child_obj, "height", 0)
    set_json_int_field(child_obj, "x", cursor_x)
    set_json_int_field(child_obj, "y", cursor_y)
    layout_node_labels(child_obj, options)
    max_x = Int::max(max_x, cursor_x + width)
    max_y = Int::max(max_y, cursor_y + height)
    if direction == "DOWN" {
      cursor_y = cursor_y + height + spacing
    } else {
      cursor_x = cursor_x + width + spacing
    }
    children[i] = Json::object(child_obj)
  }
  set_json_int_field(graph_obj, "width", max_x + right)
  set_json_int_field(graph_obj, "height", max_y + bottom)
}

///|
fn apply_fixed_layout(
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Unit {
  ignore(options)
  let children = get_or_init_array_field(graph_obj, "children")
  for i = 0; i < children.length(); i = i + 1 {
    let child_obj = match children[i] {
      Object(obj) => obj
      _ => continue
    }
    let child_options = optional_object_field(child_obj, "layoutOptions").unwrap_or({},
    )
    if option_string_by_keys(child_options, ["position"]) is Some(position_text) {
      let values = extract_ints_from_vector_string(position_text)
      if values.length() >= 2 {
        set_json_int_field(child_obj, "x", values[0])
        set_json_int_field(child_obj, "y", values[1])
      }
    }
    layout_node_labels(child_obj, options)
    children[i] = Json::object(child_obj)
  }
  let edges = get_or_init_array_field(graph_obj, "edges")
  for i = 0; i < edges.length(); i = i + 1 {
    let edge_obj = match edges[i] {
      Object(obj) => obj
      _ => continue
    }
    normalize_edge_endpoints(edge_obj)
    apply_fixed_edge_bend_points(edge_obj)
    edges[i] = Json::object(edge_obj)
  }
}

///|
priv struct NodeBounds {
  x : Int
  y : Int
  width : Int
  height : Int
}

///|
fn graph_id_from_object(graph_obj : Map[String, Json]) -> String? {
  match graph_obj.get("id") {
    Some(String(id)) => Some(id)
    Some(Number(value, repr~)) => {
      ignore(repr)
      Some(value.to_int().to_string())
    }
    _ => None
  }
}

///|
fn node_bounds_collect_recursively(
  graph_obj : Map[String, Json],
  origin_x : Int,
  origin_y : Int,
  node_bounds : Map[String, NodeBounds],
) -> Unit {
  let width = json_int_field_default(graph_obj, "width", 0)
  let height = json_int_field_default(graph_obj, "height", 0)
  if graph_id_from_object(graph_obj) is Some(graph_id) {
    node_bounds[graph_id] = { x: origin_x, y: origin_y, width, height }
  }
  let children = get_or_init_array_field(graph_obj, "children")
  for i = 0; i < children.length(); i = i + 1 {
    let child_obj = match children[i] {
      Object(obj) => obj
      _ => continue
    }
    let child_x = json_int_field_default(child_obj, "x", 0)
    let child_y = json_int_field_default(child_obj, "y", 0)
    node_bounds_collect_recursively(
      child_obj,
      origin_x + child_x,
      origin_y + child_y,
      node_bounds,
    )
  }
}

///|
fn routed_edge_section(
  direction : String,
  source_bounds : NodeBounds,
  target_bounds : NodeBounds,
) -> Json {
  let source_center_x = source_bounds.x + source_bounds.width / 2
  let source_center_y = source_bounds.y + source_bounds.height / 2
  let target_center_x = target_bounds.x + target_bounds.width / 2
  let target_center_y = target_bounds.y + target_bounds.height / 2
  let (start_x, start_y, end_x, end_y) = match direction {
    "DOWN" =>
      (
        source_center_x,
        source_bounds.y + source_bounds.height,
        target_center_x,
        target_bounds.y,
      )
    "UP" =>
      (
        source_center_x,
        source_bounds.y,
        target_center_x,
        target_bounds.y + target_bounds.height,
      )
    "LEFT" =>
      (
        source_bounds.x,
        source_center_y,
        target_bounds.x + target_bounds.width,
        target_center_y,
      )
    _ =>
      (
        source_bounds.x + source_bounds.width,
        source_center_y,
        target_bounds.x,
        target_center_y,
      )
  }
  Json::object({
    "startPoint": Json::object({
      "x": Json::number(start_x.to_double()),
      "y": Json::number(start_y.to_double()),
    }),
    "endPoint": Json::object({
      "x": Json::number(end_x.to_double()),
      "y": Json::number(end_y.to_double()),
    }),
  })
}

///|
fn route_edges_for_graph(
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Unit {
  let direction = option_string_by_keys(options, [
    "elk.direction", "org.eclipse.elk.direction", "direction",
  ]).unwrap_or("RIGHT")
  let node_bounds : Map[String, NodeBounds] = {}
  node_bounds_collect_recursively(graph_obj, 0, 0, node_bounds)
  let edges = get_or_init_array_field(graph_obj, "edges")
  for i = 0; i < edges.length(); i = i + 1 {
    let edge_obj = match edges[i] {
      Object(obj) => obj
      _ => continue
    }
    normalize_edge_endpoints(edge_obj)
    let sources = edge_endpoints(edge_obj, "sources")
    let targets = edge_endpoints(edge_obj, "targets")
    if !sources.is_empty() &&
      !targets.is_empty() &&
      node_bounds.contains(sources[0]) &&
      node_bounds.contains(targets[0]) {
      edge_obj["sections"] = Json::array([
        routed_edge_section(
          direction,
          node_bounds[sources[0]],
          node_bounds[targets[0]],
        ),
      ])
    } else {
      ensure_edge_has_single_section(edge_obj)
    }
    edges[i] = Json::object(edge_obj)
  }
}

///|
fn merge_graph_options(
  inherited_options : Map[String, Json],
  graph_obj : Map[String, Json],
) -> Map[String, Json] {
  let merged = copy_json_map(inherited_options)
  if optional_object_field(graph_obj, "layoutOptions") is Some(layout_options) {
    merge_into(merged, layout_options)
  }
  if optional_object_field(graph_obj, "properties") is Some(properties) {
    merge_into(merged, properties)
  }
  merged
}

///|
fn graph_hierarchy_handling(options : Map[String, Json]) -> String {
  option_string_by_keys(options, [
    "hierarchyHandling", "elk.hierarchyHandling", "org.eclipse.elk.hierarchyHandling",
  ]).unwrap_or("SEPARATE_CHILDREN")
}

///|
fn ensure_edge_sections(graph_obj : Map[String, Json]) -> Unit {
  let edges = get_or_init_array_field(graph_obj, "edges")
  for i = 0; i < edges.length(); i = i + 1 {
    let edge_obj = match edges[i] {
      Object(obj) => obj
      _ => continue
    }
    normalize_edge_endpoints(edge_obj)
    ensure_edge_has_single_section(edge_obj)
    edges[i] = Json::object(edge_obj)
  }
}

///|
fn apply_layout_recursively(
  engine : ElkEngine,
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Unit raise {
  let children = get_or_init_array_field(graph_obj, "children")
  for i = 0; i < children.length(); i = i + 1 {
    let child_obj = match children[i] {
      Object(obj) => obj
      _ => continue
    }
    let child_options = merge_graph_options(options, child_obj)
    apply_layout_recursively(engine, child_obj, child_options)
    children[i] = Json::object(child_obj)
  }
  let edges = get_or_init_array_field(graph_obj, "edges")
  if children.is_empty() && edges.is_empty() {
    return
  }

  let algorithm = resolve_algorithm(options)
  if !engine.algorithms.contains(algorithm) {
    raise invalid_graph_error(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Unknown layouter id",
    )
  }
  if algorithm == "layered" && has_first_layer_cycle_conflict(graph_obj) {
    raise invalid_graph_error(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Layer constraint conflict",
    )
  }

  apply_layout_algorithm(graph_obj, algorithm, options)
  if algorithm == "fixed" &&
    graph_hierarchy_handling(options) != "INCLUDE_CHILDREN" {
    ensure_edge_sections(graph_obj)
  } else {
    route_edges_for_graph(graph_obj, options)
  }
}

///|
fn apply_layout_algorithm(
  graph_obj : Map[String, Json],
  algorithm : String,
  options : Map[String, Json],
) -> Unit {
  match algorithm {
    "sporeCompaction" | "sporeOverlap" =>
      apply_compaction_layout(graph_obj, options)
    "fixed" => apply_fixed_layout(graph_obj, options)
    _ => apply_linear_layout(graph_obj, options)
  }
}

///|
fn add_logging(
  graph_obj : Map[String, Json],
  include_execution_time : Bool,
) -> Unit {
  let logging = { "children": Json::array([Json::object({})]) }
  if include_execution_time {
    logging["executionTime"] = Json::number(1)
  }
  graph_obj["logging"] = Json::object(logging)
}

///|
pub fn ElkEngine::layout(
  self : ElkEngine,
  graph? : Json,
  layout_options? : Map[String, Json] = {},
  logging? : Bool = false,
  measure_execution_time? : Bool = false,
) -> Json raise {
  let graph = match graph {
    Some(graph) => graph
    None => raise invalid_graph_error("Missing mandatory parameter 'graph'.")
  }
  let graph_obj = ensure_object(graph, "Graph must be an object")
  ensure_graph_id(graph_obj)
  clear_logging(graph_obj)
  let options = merged_options(
    self.default_layout_options,
    layout_options,
    graph_obj,
  )
  let hierarchy_handling = graph_hierarchy_handling(options)
  if hierarchy_handling == "SEPARATE_CHILDREN" &&
    has_hierarchical_edges_for_separate_children(graph_obj) {
    raise invalid_graph_error(
      "org.eclipse.elk.core.UnsupportedGraphException: Hierarchical edge cannot be laid out separately",
    )
  }
  apply_layout_recursively(self, graph_obj, options)
  if logging || measure_execution_time {
    add_logging(graph_obj, measure_execution_time)
  }
  Json::object(graph_obj)
}
