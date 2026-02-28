///|
fn mrtree_fan_format_right(value : Int, len : Int) -> String {
  let mut text = value.to_string()
  while text.length() < len {
    text = "0" + text
  }
  text
}

///|
fn mrtree_fan_safe_slice(text : String, start : Int, end_ : Int) -> String {
  try text[start:end_] catch {
    _ => ""
  } noraise {
    value => value.to_string()
  }
}

///|
fn mrtree_fan_calculate(
  current_level : Array[MrtreeNode],
  global_fan_map : Map[String, Int],
  global_desc_map : Map[String, Int],
) -> Unit {
  if current_level.is_empty() {
    return
  }

  let next_level = []
  let mut parent_id = ""
  let mut has_parent_id = false
  let digits = current_level.length().to_string().length()
  let mut index = 0
  let mut last_assigned_id = ""

  for node in current_level {
    let node_parent_id = mrtree_node_internal_id(node)
    if !has_parent_id || parent_id != node_parent_id {
      parent_id = node_parent_id
      has_parent_id = true
      index = 0
    }
    let id = if parent_id == "" {
      mrtree_fan_format_right(index, digits)
    } else {
      parent_id + mrtree_fan_format_right(index, digits)
    }
    index += 1
    last_assigned_id = id
    mrtree_node_set_internal_id(node, id)
    for child in mrtree_node_children_copy(node) {
      next_level.push(child)
      mrtree_node_set_internal_id(child, id)
    }
  }

  let local_fan_map : Map[String, Int] = {}
  let prefix_count = last_assigned_id.length() - digits
  for i = 0; i < prefix_count; i = i + 1 {
    for node in current_level {
      let key = mrtree_fan_safe_slice(mrtree_node_internal_id(node), 0, i + 1)
      let block_size = match local_fan_map.get(key) {
        Some(value) => value + 1
        None => 1
      }
      local_fan_map[key] = block_size
    }
  }

  for entry in local_fan_map.to_array() {
    let key = entry.0
    let local_value = entry.1
    let desc_value = match global_desc_map.get(key) {
      Some(value) => value
      None => 0
    }
    global_desc_map[key] = local_value + desc_value

    match global_fan_map.get(key) {
      Some(current) =>
        if current < local_value {
          global_fan_map[key] = local_value
        }
      None => global_fan_map[key] = local_value
    }
  }

  mrtree_fan_calculate(next_level, global_fan_map, global_desc_map)
}

///|
fn mrtree_fan_processor_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Processor compute fanout", 1.0))
    None => ()
  }

  let global_fan_map : Map[String, Int] = {}
  let global_desc_map : Map[String, Int] = {}

  let mut root : MrtreeNode? = None
  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_root(node) {
      root = Some(node)
      break
    }
  }

  match root {
    Some(root_node) =>
      mrtree_fan_calculate([root_node], global_fan_map, global_desc_map)
    None => ()
  }

  for node in mrtree_graph_nodes(graph) {
    let key = mrtree_node_internal_id(node)
    let fan = match global_fan_map.get(key) {
      Some(value) => value
      None => 0
    }
    let desc_base = match global_desc_map.get(key) {
      Some(value) => value
      None => 0
    }
    let descendants = 1 + desc_base
    mrtree_node_set_fan(node, fan)
    mrtree_node_set_descendants(node, descendants)
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_fan_processor_layout_processor() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_processor(mrtree_fan_processor_process)
}
