///|
pub let interactive_layered_graph_visitor_pseudo_position_spacing = 2147483647

///|
pub let interactive_layered_graph_visitor_last_layer_index = 2147483647

///|
pub struct InteractiveLayeredGraphVisitor {
  marker : Int
}

///|
fn interactive_layered_graph_visitor_parse_int(value : String) -> Int? {
  let parsed : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
    value.trim().to_string(),
  )
  match parsed {
    Ok(result) => Some(result)
    Err(_) => None
  }
}

///|
fn interactive_layered_graph_visitor_string_option_value(
  node : ElkNode,
  option : IProperty[String],
) -> String? {
  match node_layout_option_string_value(node, option.get_id()) {
    Some(value) => {
      let normalized = value.trim().to_string()
      if normalized.is_empty() {
        None
      } else {
        Some(normalized)
      }
    }
    None =>
      if node_has_string_property(node, option) {
        let value = node_get_string_property(node, option).trim().to_string()
        if value.is_empty() {
          None
        } else {
          Some(value)
        }
      } else {
        None
      }
  }
}

///|
fn interactive_layered_graph_visitor_int_option_value(
  node : ElkNode,
  option : IProperty[Int],
) -> Int {
  match node_layout_option_string_value(node, option.get_id()) {
    Some(value) =>
      match interactive_layered_graph_visitor_parse_int(value) {
        Some(parsed) => parsed
        None => option.get_default()
      }
    None => option.get_default()
  }
}

///|
fn interactive_layered_graph_visitor_has_int_option(
  node : ElkNode,
  option : IProperty[Int],
) -> Bool {
  match node_layout_option_string_value(node, option.get_id()) {
    Some(value) => !value.trim().to_string().is_empty()
    None => false
  }
}

///|
fn interactive_layered_graph_visitor_set_int_option(
  node : ElkNode,
  option : IProperty[Int],
  value : Int,
) -> Unit {
  node_set_layout_option_string_by_id(node, option.get_id(), value.to_string())
}

///|
fn interactive_layered_graph_visitor_set_string_option(
  node : ElkNode,
  option : IProperty[String],
  value : String,
) -> Unit {
  node_set_string_property(node, option, value)
  node_set_layout_option_string_by_id(node, option.get_id(), value)
}

///|
fn interactive_layered_graph_visitor_clear_string_option(
  node : ElkNode,
  option : IProperty[String],
) -> Unit {
  node_clear_string_property(node, option)
  node_set_layout_option_string_by_id(node, option.get_id(), "")
}

///|
fn interactive_layered_graph_visitor_set_bool_option(
  node : ElkNode,
  option : IProperty[Bool],
  value : Bool,
) -> Unit {
  node_set_bool_property(node, option, value)
  node_set_layout_option_string_by_id(
    node,
    option.get_id(),
    if value {
      "true"
    } else {
      "false"
    },
  )
}

///|
fn interactive_layered_graph_visitor_set_kvector_option(
  node : ElkNode,
  option : IProperty[KVector],
  value : KVector,
) -> Unit {
  node_set_layout_option_string_by_id(node, option.get_id(), value.to_string())
}

///|
fn interactive_layered_graph_visitor_parse_direction(
  value : String,
) -> Direction {
  if value == "RIGHT" {
    return Direction::Rightward
  }
  if value == "LEFT" {
    return Direction::Leftward
  }
  if value == "DOWN" {
    return Direction::Downward
  }
  if value == "UP" {
    return Direction::Upward
  }
  Direction::Undefined
}

///|
fn interactive_layered_graph_visitor_has_in_layer_pred_constraint(
  node : ElkNode,
) -> Bool {
  interactive_layered_graph_visitor_string_option_value(
    node, layered_options_crossing_minimization_in_layer_pred_of,
  )
  is Some(_)
}

///|
fn interactive_layered_graph_visitor_has_in_layer_succ_constraint(
  node : ElkNode,
) -> Bool {
  interactive_layered_graph_visitor_string_option_value(
    node, layered_options_crossing_minimization_in_layer_succ_of,
  )
  is Some(_)
}

///|
fn interactive_layered_graph_visitor_has_relative_constraint(
  node : ElkNode,
) -> Bool {
  interactive_layered_graph_visitor_has_in_layer_pred_constraint(node) ||
  interactive_layered_graph_visitor_has_in_layer_succ_constraint(node)
}

///|
fn interactive_layered_graph_visitor_has_layer_choice_constraint(
  node : ElkNode,
) -> Bool {
  interactive_layered_graph_visitor_has_int_option(
    node, layered_options_layering_layer_choice_constraint,
  )
}

///|
fn interactive_layered_graph_visitor_has_position_choice_constraint(
  node : ElkNode,
) -> Bool {
  interactive_layered_graph_visitor_has_int_option(
    node, layered_options_crossing_minimization_position_choice_constraint,
  )
}

///|
fn interactive_layered_graph_visitor_contains_node(
  nodes : Array[ElkNode],
  target : ElkNode,
) -> Bool {
  for node in nodes {
    if node == target {
      return true
    }
  }
  false
}

///|
fn interactive_layered_graph_visitor_index_of_node(
  nodes : Array[ElkNode],
  target : ElkNode,
) -> Int {
  for i in 0..<nodes.length() {
    if nodes[i] == target {
      return i
    }
  }
  -1
}

///|
fn interactive_layered_graph_visitor_remove_node(
  nodes : Array[ElkNode],
  target : ElkNode,
) -> Bool {
  let index = interactive_layered_graph_visitor_index_of_node(nodes, target)
  if index < 0 {
    return false
  }
  ignore(nodes.remove(index))
  true
}

///|
fn interactive_layered_graph_visitor_sort_nodes_by_int_option(
  nodes : Array[ElkNode],
  option : IProperty[Int],
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let current = nodes[i]
    let current_value = interactive_layered_graph_visitor_int_option_value(
      current, option,
    )
    let mut j = i
    while j > 0 {
      let previous = nodes[j - 1]
      let previous_value = interactive_layered_graph_visitor_int_option_value(
        previous, option,
      )
      if previous_value <= current_value {
        break
      }
      nodes[j] = previous
      j = j - 1
    }
    nodes[j] = current
    i = i + 1
  }
}

///|
fn interactive_layered_graph_visitor_sort_nodes_by_layer_id(
  nodes : Array[ElkNode],
) -> Unit {
  interactive_layered_graph_visitor_sort_nodes_by_int_option(
    nodes, layered_options_layering_layer_id,
  )
}

///|
fn interactive_layered_graph_visitor_sort_nodes_by_coordinate(
  nodes : Array[ElkNode],
  direction : Direction,
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let current = nodes[i]
    let current_coordinate = match direction {
      Direction::Undefined => node_y(current)
      Direction::Rightward => node_y(current)
      Direction::Leftward => node_y(current)
      Direction::Downward => node_x(current)
      Direction::Upward => node_x(current)
    }
    let mut j = i
    while j > 0 {
      let previous = nodes[j - 1]
      let previous_coordinate = match direction {
        Direction::Undefined => node_y(previous)
        Direction::Rightward => node_y(previous)
        Direction::Leftward => node_y(previous)
        Direction::Downward => node_x(previous)
        Direction::Upward => node_x(previous)
      }
      if (previous_coordinate - current_coordinate).to_int() <= 0 {
        break
      }
      nodes[j] = previous
      j = j - 1
    }
    nodes[j] = current
    i = i + 1
  }
}

///|
fn interactive_layered_graph_visitor_get_elk_node(
  nodes : Array[ElkNode],
  id : String,
) -> ElkNode? {
  for node in nodes {
    if id == node_identifier(node) {
      return Some(node)
    }
  }
  None
}

///|
fn interactive_layered_graph_visitor_require_elk_node(
  nodes : Array[ElkNode],
  id : String,
) -> ElkNode {
  match interactive_layered_graph_visitor_get_elk_node(nodes, id) {
    Some(node) => node
    None => abort("interactive layered graph visitor cannot resolve node id")
  }
}

///|
fn interactive_layered_graph_visitor_shape_references_node(
  shape : ElkConnectableShape,
  node : ElkNode,
) -> Bool {
  match shape {
    NodeShape(shape_node) => shape_node == node
    PortShape(shape_port) =>
      match port_parent(shape_port) {
        Some(parent) => parent == node
        None => false
      }
  }
}

///|
fn interactive_layered_graph_visitor_shape_node(
  shape : ElkConnectableShape,
) -> ElkNode? {
  match shape {
    NodeShape(node) => Some(node)
    PortShape(port) => port_parent(port)
  }
}

///|
fn interactive_layered_graph_visitor_first_source_node(
  edge : ElkEdge,
) -> ElkNode? {
  let sources = edge_sources(edge)
  if sources.is_empty() {
    return None
  }
  interactive_layered_graph_visitor_shape_node(sources[0])
}

///|
fn interactive_layered_graph_visitor_first_target_node(
  edge : ElkEdge,
) -> ElkNode? {
  let targets = edge_targets(edge)
  if targets.is_empty() {
    return None
  }
  interactive_layered_graph_visitor_shape_node(targets[0])
}

///|
fn interactive_layered_graph_visitor_set_node_x(
  node : ElkNode,
  x : Double,
) -> Unit {
  node_set_location(node, x, node_y(node))
}

///|
fn interactive_layered_graph_visitor_set_node_y(
  node : ElkNode,
  y : Double,
) -> Unit {
  node_set_location(node, node_x(node), y)
}

///|
fn interactive_layered_graph_visitor_get_chain_by_layer_nodes(
  node : ElkNode,
  layer_nodes : Array[ElkNode],
) -> Array[ElkNode] {
  let pos = interactive_layered_graph_visitor_index_of_node(layer_nodes, node)
  if pos < 0 {
    abort("interactive layered graph visitor node not found in layer")
  }
  let chain_nodes = [node]

  let mut i = pos - 1
  while i >= 0 {
    if interactive_layered_graph_visitor_has_in_layer_pred_constraint(
        layer_nodes[i],
      ) ||
      interactive_layered_graph_visitor_has_in_layer_succ_constraint(
        layer_nodes[i + 1],
      ) {
      ignore(chain_nodes.insert(0, layer_nodes[i]))
    } else {
      break
    }
    i = i - 1
  }

  i = pos + 1
  while i < layer_nodes.length() {
    if interactive_layered_graph_visitor_has_in_layer_succ_constraint(
        layer_nodes[i],
      ) ||
      interactive_layered_graph_visitor_has_in_layer_pred_constraint(
        layer_nodes[i - 1],
      ) {
      chain_nodes.push(layer_nodes[i])
    } else {
      break
    }
    i = i + 1
  }

  chain_nodes
}

///|
fn interactive_layered_graph_visitor_get_chain_by_all_nodes(
  node : ElkNode,
  all_nodes : Array[ElkNode],
) -> Array[ElkNode] {
  let chain = [node]

  let mut succ_name = interactive_layered_graph_visitor_string_option_value(
    node, layered_options_crossing_minimization_in_layer_pred_of,
  )
  let mut pred_name = interactive_layered_graph_visitor_string_option_value(
    node, layered_options_crossing_minimization_in_layer_succ_of,
  )

  while succ_name is Some(name) {
    let succ_node = interactive_layered_graph_visitor_require_elk_node(
      all_nodes, name,
    )
    chain.push(succ_node)
    succ_name = interactive_layered_graph_visitor_string_option_value(
      succ_node, layered_options_crossing_minimization_in_layer_pred_of,
    )
  }

  while pred_name is Some(name) {
    let pred_node = interactive_layered_graph_visitor_require_elk_node(
      all_nodes, name,
    )
    chain.push(pred_node)
    pred_name = interactive_layered_graph_visitor_string_option_value(
      pred_node, layered_options_crossing_minimization_in_layer_pred_of,
    )
  }

  chain
}

///|
fn interactive_layered_graph_visitor_sort_rc_nodes(
  nodes_with_rc : Array[ElkNode],
  all_nodes : Array[ElkNode],
  nodes_without_constraint : Array[ElkNode],
) -> Array[ElkNode] {
  let nodes = []
  while !nodes_with_rc.is_empty() {
    let mut circle = true
    let mut i = 0
    while i < nodes_with_rc.length() {
      let current = nodes_with_rc[i]
      if interactive_layered_graph_visitor_has_in_layer_pred_constraint(current) {
        let target_name = match
          interactive_layered_graph_visitor_string_option_value(
            current, layered_options_crossing_minimization_in_layer_pred_of,
          ) {
          Some(value) => value
          None => abort("interactive layered graph visitor missing pred target")
        }
        let target = interactive_layered_graph_visitor_require_elk_node(
          all_nodes, target_name,
        )
        if !interactive_layered_graph_visitor_contains_node(
            nodes_with_rc, target,
          ) {
          nodes.push(current)
          ignore(nodes_with_rc.remove(i))
          circle = false
          continue
        }
      } else {
        let target_name = match
          interactive_layered_graph_visitor_string_option_value(
            current, layered_options_crossing_minimization_in_layer_succ_of,
          ) {
          Some(value) => value
          None => abort("interactive layered graph visitor missing succ target")
        }
        let target = interactive_layered_graph_visitor_require_elk_node(
          all_nodes, target_name,
        )
        if !interactive_layered_graph_visitor_contains_node(
            nodes_with_rc, target,
          ) {
          nodes.push(current)
          ignore(nodes_with_rc.remove(i))
          circle = false
          continue
        }
      }
      i = i + 1
    }

    if circle {
      let current = nodes_with_rc[0]
      if interactive_layered_graph_visitor_has_in_layer_pred_constraint(current) {
        interactive_layered_graph_visitor_clear_string_option(
          current, layered_options_crossing_minimization_in_layer_pred_of,
        )
      } else {
        interactive_layered_graph_visitor_clear_string_option(
          current, layered_options_crossing_minimization_in_layer_succ_of,
        )
      }
      ignore(nodes_with_rc.remove(0))
      nodes_without_constraint.push(current)
    }
  }
  nodes
}

///|
fn interactive_layered_graph_visitor_sort_nodes_in_layer(
  nodes_with_position_constraint : Array[ElkNode],
  nodes : Array[ElkNode],
  direction : Direction,
) -> Unit {
  interactive_layered_graph_visitor_sort_nodes_by_int_option(
    nodes_with_position_constraint, layered_options_crossing_minimization_position_choice_constraint,
  )
  interactive_layered_graph_visitor_sort_nodes_by_coordinate(nodes, direction)
}

///|
fn interactive_layered_graph_visitor_swap_nodes(
  nodes : Array[ElkNode],
  position : Int,
) -> Unit {
  let pred = nodes[position - 1]
  let succ = nodes[position]

  let mut chain = interactive_layered_graph_visitor_get_chain_by_layer_nodes(
    pred, nodes,
  )
  if interactive_layered_graph_visitor_contains_node(chain, succ) {
    let count = interactive_layered_graph_visitor_index_of_node(chain, succ)
    let mut end = position + (chain.length() - count)

    let swap_nodes = []
    let mut i = 0
    while i < count {
      if end >= nodes.length() {
        break
      }
      let current_node = nodes[end]
      chain = interactive_layered_graph_visitor_get_chain_by_layer_nodes(
        current_node, nodes,
      )
      if chain.length() + i <= count {
        for chain_node in chain {
          ignore(
            interactive_layered_graph_visitor_remove_node(nodes, chain_node),
          )
          swap_nodes.push(chain_node)
        }
        i = i + chain.length()
      } else {
        end = end + chain.length()
        i = i + 1
      }
    }

    let insert_index = position - count
    for i in 0..<swap_nodes.length() {
      ignore(nodes.insert(insert_index + i, swap_nodes[i]))
    }
  }
}

///|
fn interactive_layered_graph_visitor_handle_nodes_with_pc_and_rc(
  all_nodes : Array[ElkNode],
  nodes : Array[ElkNode],
  nodes_with_rc : Array[ElkNode],
  nodes_with_position_constraint : Array[ElkNode],
  nodes_with_pc_and_rc : Array[ElkNode],
) -> Unit {
  let mut i = 0
  while i < nodes_with_pc_and_rc.length() {
    let node = nodes_with_pc_and_rc[i]
    nodes_with_position_constraint.push(node)

    let targets = []
    let vals = []
    let value = interactive_layered_graph_visitor_int_option_value(
      node, layered_options_crossing_minimization_position_choice_constraint,
    )

    if interactive_layered_graph_visitor_has_in_layer_pred_constraint(node) {
      let target_name = match
        interactive_layered_graph_visitor_string_option_value(
          node, layered_options_crossing_minimization_in_layer_pred_of,
        ) {
        Some(result) => result
        None => abort("interactive layered graph visitor missing pred target")
      }
      targets.push(
        interactive_layered_graph_visitor_require_elk_node(
          all_nodes, target_name,
        ),
      )
      vals.push(value + 1)
      interactive_layered_graph_visitor_clear_string_option(
        node, layered_options_crossing_minimization_in_layer_pred_of,
      )
    }

    if interactive_layered_graph_visitor_has_in_layer_succ_constraint(node) {
      let target_name = match
        interactive_layered_graph_visitor_string_option_value(
          node, layered_options_crossing_minimization_in_layer_succ_of,
        ) {
        Some(result) => result
        None => abort("interactive layered graph visitor missing succ target")
      }
      targets.push(
        interactive_layered_graph_visitor_require_elk_node(
          all_nodes, target_name,
        ),
      )
      vals.push(value - 1)
      interactive_layered_graph_visitor_clear_string_option(
        node, layered_options_crossing_minimization_in_layer_succ_of,
      )
    }

    for t in 0..<targets.length() {
      let target = targets[t]
      if !interactive_layered_graph_visitor_contains_node(
          nodes_with_position_constraint, target,
        ) {
        interactive_layered_graph_visitor_set_int_option(
          target,
          layered_options_crossing_minimization_position_choice_constraint,
          vals[t],
        )
        if !interactive_layered_graph_visitor_contains_node(
            nodes_with_rc, target,
          ) {
          nodes_with_position_constraint.push(target)
          ignore(interactive_layered_graph_visitor_remove_node(nodes, target))
        } else {
          nodes_with_pc_and_rc.push(target)
          ignore(
            interactive_layered_graph_visitor_remove_node(nodes_with_rc, target),
          )
        }
      }
    }

    i = i + 1
  }
}

///|
fn interactive_layered_graph_visitor_shift_other_nodes(
  moved_node : ElkNode,
  layer : Int,
  layer_nodes : Array[Array[ElkNode]],
  incoming : Bool,
) -> Unit {
  let nodes_of_layer = layer_nodes[layer]
  let edges = []

  let root = match node_parent(moved_node) {
    Some(value) => value
    None => return
  }
  if incoming {
    for edge in node_contained_edges(root) {
      for target in edge_targets(edge) {
        if interactive_layered_graph_visitor_shape_references_node(
            target, moved_node,
          ) {
          edges.push(edge)
        }
      }
    }
  } else {
    for edge in node_contained_edges(root) {
      for source in edge_sources(edge) {
        if interactive_layered_graph_visitor_shape_references_node(
            source, moved_node,
          ) {
          edges.push(edge)
        }
      }
    }
  }

  for edge in edges {
    let connected_node = if incoming {
      interactive_layered_graph_visitor_first_source_node(edge)
    } else {
      interactive_layered_graph_visitor_first_target_node(edge)
    }
    if connected_node is Some(node) {
      if interactive_layered_graph_visitor_contains_node(nodes_of_layer, node) {
        ignore(
          interactive_layered_graph_visitor_remove_node(nodes_of_layer, node),
        )
        interactive_layered_graph_visitor_set_int_option(
          node,
          layered_options_layering_layer_id,
          layer + 1,
        )
        if layer + 1 < layer_nodes.length() {
          let new_layer = layer_nodes[layer + 1]
          new_layer.push(node)
          interactive_layered_graph_visitor_shift_other_nodes(
            node,
            layer + 1,
            layer_nodes,
            false,
          )
          interactive_layered_graph_visitor_shift_other_nodes(
            node,
            layer + 1,
            layer_nodes,
            true,
          )
        } else {
          layer_nodes.push([node])
        }
      }
    }
  }
}

///|
fn interactive_layered_graph_visitor_assign_layers_to_nodes_with_property(
  nodes_with_layer_constraint : Array[ElkNode],
  layering : Array[Array[ElkNode]],
) -> Int {
  interactive_layered_graph_visitor_sort_nodes_by_int_option(
    nodes_with_layer_constraint, layered_options_layering_layer_choice_constraint,
  )

  let mut diff = 0
  for node in nodes_with_layer_constraint {
    let current_layer = interactive_layered_graph_visitor_int_option_value(
        node, layered_options_layering_layer_choice_constraint,
      ) -
      diff
    if current_layer < layering.length() && current_layer >= 0 {
      let nodes_of_layer = layering[current_layer]
      interactive_layered_graph_visitor_shift_other_nodes(
        node, current_layer, layering, true,
      )
      interactive_layered_graph_visitor_shift_other_nodes(
        node, current_layer, layering, false,
      )
      nodes_of_layer.push(node)
    } else if current_layer == -1 {
      ignore(layering.insert(0, [node]))
    } else {
      diff = diff + current_layer - layering.length()
      layering.push([node])
    }
  }
  diff
}

///|
fn interactive_layered_graph_visitor_assign_layers_to_nodes_with_rc(
  nodes_with_rc : Array[ElkNode],
  layering : Array[Array[ElkNode]],
  all_nodes : Array[ElkNode],
  diff : Int,
) -> Unit {
  for node in nodes_with_rc {
    let mut succ_node : ElkNode? = None
    let mut pred_node : ElkNode? = None
    let succ_name = interactive_layered_graph_visitor_string_option_value(
      node, layered_options_crossing_minimization_in_layer_pred_of,
    )
    let pred_name = interactive_layered_graph_visitor_string_option_value(
      node, layered_options_crossing_minimization_in_layer_succ_of,
    )

    if succ_name is Some(name) {
      succ_node = interactive_layered_graph_visitor_get_elk_node(
        all_nodes, name,
      )
    }
    if pred_name is Some(name) {
      pred_node = interactive_layered_graph_visitor_get_elk_node(
        all_nodes, name,
      )
    }

    if succ_node is Some(succ) && pred_node is Some(pred) {
      let chain = interactive_layered_graph_visitor_get_chain_by_all_nodes(
        node, all_nodes,
      )
      let succ_val = if interactive_layered_graph_visitor_has_layer_choice_constraint(
          succ,
        ) {
        interactive_layered_graph_visitor_int_option_value(
          succ, layered_options_layering_layer_choice_constraint,
        )
      } else {
        interactive_layered_graph_visitor_int_option_value(
          succ, layered_options_layering_layer_id,
        )
      }
      let pred_val = if interactive_layered_graph_visitor_has_layer_choice_constraint(
          pred,
        ) {
        interactive_layered_graph_visitor_int_option_value(
          pred, layered_options_layering_layer_choice_constraint,
        )
      } else {
        interactive_layered_graph_visitor_int_option_value(
          pred, layered_options_layering_layer_id,
        )
      }
      let value = if succ_val > pred_val { succ_val } else { pred_val }
      for chain_node in chain {
        let old_value = interactive_layered_graph_visitor_int_option_value(
          chain_node, layered_options_layering_layer_id,
        )
        if old_value != value {
          interactive_layered_graph_visitor_set_int_option(
            chain_node, layered_options_layering_layer_id, value,
          )
          interactive_layered_graph_visitor_shift_other_nodes(
            chain_node, value, layering, true,
          )
          interactive_layered_graph_visitor_shift_other_nodes(
            chain_node, value, layering, false,
          )
        }
        ignore(
          interactive_layered_graph_visitor_remove_node(
            layering[old_value],
            chain_node,
          ),
        )
        layering[value].push(chain_node)
      }
    } else {
      let mut succ_val = -1
      if succ_node is Some(succ) {
        succ_val = if interactive_layered_graph_visitor_has_layer_choice_constraint(
            succ,
          ) {
          interactive_layered_graph_visitor_int_option_value(
            succ, layered_options_layering_layer_choice_constraint,
          )
        } else {
          interactive_layered_graph_visitor_int_option_value(
            succ, layered_options_layering_layer_id,
          )
        }
      }

      let mut pred_val = -1
      if pred_node is Some(pred) {
        pred_val = if interactive_layered_graph_visitor_has_layer_choice_constraint(
            pred,
          ) {
          interactive_layered_graph_visitor_int_option_value(
            pred, layered_options_layering_layer_choice_constraint,
          )
        } else {
          interactive_layered_graph_visitor_int_option_value(
            pred, layered_options_layering_layer_id,
          )
        }
      }

      let value = if succ_val > pred_val { succ_val } else { pred_val }
      interactive_layered_graph_visitor_set_int_option(
        node,
        layered_options_layering_layer_id,
        value - diff,
      )
      interactive_layered_graph_visitor_shift_other_nodes(
        node,
        value - diff,
        layering,
        true,
      )
      interactive_layered_graph_visitor_shift_other_nodes(
        node,
        value - diff,
        layering,
        false,
      )
      layering[value - diff].push(node)
    }
  }
}

///|
fn interactive_layered_graph_visitor_initial_layers(
  nodes : Array[ElkNode],
) -> Array[Array[ElkNode]] {
  interactive_layered_graph_visitor_sort_nodes_by_layer_id(nodes)

  let layer_nodes = []
  let mut nodes_of_layer = []
  let mut layer_id = 0
  let mut current_layer = -1
  for node in nodes {
    let layer = interactive_layered_graph_visitor_int_option_value(
      node, layered_options_layering_layer_id,
    )
    if layer > current_layer {
      if !nodes_of_layer.is_empty() {
        layer_nodes.push(nodes_of_layer)
        layer_id = layer_id + 1
      }
      nodes_of_layer = []
      current_layer = layer
    }
    if !interactive_layered_graph_visitor_has_layer_choice_constraint(node) {
      interactive_layered_graph_visitor_set_int_option(
        node, layered_options_layering_layer_id, layer_id,
      )
      nodes_of_layer.push(node)
    }
  }
  if !nodes_of_layer.is_empty() {
    layer_nodes.push(nodes_of_layer)
  }
  layer_nodes
}

///|
fn interactive_layered_graph_visitor_update_lists_for_layer_assignment(
  nodes_with_rc_and_lc : Array[ElkNode],
  nodes : Array[ElkNode],
  nodes_with_layer_constraint : Array[ElkNode],
  nodes_with_rc : Array[ElkNode],
  nodes_without_constraint : Array[ElkNode],
) -> Unit {
  let mut i = 0
  while i < nodes_with_rc_and_lc.length() {
    let node = nodes_with_rc_and_lc[i]
    nodes_with_layer_constraint.push(node)
    let targets = []
    if interactive_layered_graph_visitor_has_in_layer_pred_constraint(node) {
      let target_name = match
        interactive_layered_graph_visitor_string_option_value(
          node, layered_options_crossing_minimization_in_layer_pred_of,
        ) {
        Some(value) => value
        None => abort("interactive layered graph visitor missing pred target")
      }
      targets.push(
        interactive_layered_graph_visitor_require_elk_node(nodes, target_name),
      )
    }
    if interactive_layered_graph_visitor_has_in_layer_succ_constraint(node) {
      let target_name = match
        interactive_layered_graph_visitor_string_option_value(
          node, layered_options_crossing_minimization_in_layer_succ_of,
        ) {
        Some(value) => value
        None => abort("interactive layered graph visitor missing succ target")
      }
      targets.push(
        interactive_layered_graph_visitor_require_elk_node(nodes, target_name),
      )
    }

    for target in targets {
      if !interactive_layered_graph_visitor_has_layer_choice_constraint(target) {
        let value = interactive_layered_graph_visitor_int_option_value(
          node, layered_options_layering_layer_choice_constraint,
        )
        interactive_layered_graph_visitor_set_int_option(
          target, layered_options_layering_layer_choice_constraint, value,
        )
        if !interactive_layered_graph_visitor_contains_node(
            nodes_with_rc, target,
          ) {
          nodes_with_layer_constraint.push(target)
          ignore(
            interactive_layered_graph_visitor_remove_node(
              nodes_without_constraint, target,
            ),
          )
        } else {
          nodes_with_rc_and_lc.push(target)
          ignore(
            interactive_layered_graph_visitor_remove_node(nodes_with_rc, target),
          )
        }
      }
    }

    i = i + 1
  }
}

///|
fn interactive_layered_graph_visitor_calc_layer_nodes(
  nodes : Array[ElkNode],
) -> Array[Array[ElkNode]] {
  let nodes_without_constraint = []
  let nodes_with_layer_constraint = []
  let nodes_with_rc = []
  let nodes_with_rc_and_lc = []

  for node in nodes {
    if interactive_layered_graph_visitor_has_layer_choice_constraint(node) &&
      interactive_layered_graph_visitor_has_relative_constraint(node) {
      nodes_with_rc_and_lc.push(node)
    } else if interactive_layered_graph_visitor_has_layer_choice_constraint(
        node,
      ) {
      nodes_with_layer_constraint.push(node)
    } else if interactive_layered_graph_visitor_has_relative_constraint(node) {
      nodes_with_rc.push(node)
    } else {
      nodes_without_constraint.push(node)
    }
  }

  interactive_layered_graph_visitor_update_lists_for_layer_assignment(
    nodes_with_rc_and_lc, nodes, nodes_with_layer_constraint, nodes_with_rc, nodes_without_constraint,
  )

  let sorted_nodes_with_rc = interactive_layered_graph_visitor_sort_rc_nodes(
    nodes_with_rc, nodes, nodes_without_constraint,
  )
  let layer_nodes = interactive_layered_graph_visitor_initial_layers(
    nodes_without_constraint,
  )
  let diff = interactive_layered_graph_visitor_assign_layers_to_nodes_with_property(
    nodes_with_layer_constraint, layer_nodes,
  )
  interactive_layered_graph_visitor_assign_layers_to_nodes_with_rc(
    sorted_nodes_with_rc, layer_nodes, nodes, diff,
  )
  layer_nodes
}

///|
fn interactive_layered_graph_visitor_set_coordinate_in_layout_direction(
  layers : Array[Array[ElkNode]],
  direction : Direction,
) -> Unit {
  let spacing = interactive_layered_graph_visitor_pseudo_position_spacing.to_double()
  let mut position = 0.0
  let mut next_position = 0.0
  for nodes_of_layer in layers {
    for node in nodes_of_layer {
      match direction {
        Direction::Undefined => {
          interactive_layered_graph_visitor_set_node_x(node, position)
          if position + node_width(node) / 2.0 >= next_position {
            next_position = node_x(node) + node_width(node) + spacing
          }
        }
        Direction::Rightward => {
          interactive_layered_graph_visitor_set_node_x(node, position)
          if position + node_width(node) / 2.0 >= next_position {
            next_position = node_x(node) + node_width(node) + spacing
          }
        }
        Direction::Leftward => {
          interactive_layered_graph_visitor_set_node_x(node, position)
          if node_x(node) <= next_position {
            next_position = node_x(node) - spacing
          }
        }
        Direction::Downward => {
          interactive_layered_graph_visitor_set_node_y(node, position)
          if position + node_height(node) >= next_position {
            next_position = node_y(node) + node_height(node) + spacing
          }
        }
        Direction::Upward => {
          interactive_layered_graph_visitor_set_node_y(node, position)
          if node_y(node) <= next_position {
            next_position = node_y(node) - spacing
          }
        }
      }
    }
    position = next_position
  }
}

///|
fn interactive_layered_graph_visitor_set_coordinates_orthogonal_to_layout_direction(
  nodes_of_layer : Array[ElkNode],
  layer_id : Int,
  direction : Direction,
) -> Unit {
  let spacing = interactive_layered_graph_visitor_pseudo_position_spacing.to_double()
  let all_nodes = []
  let nodes_without_constraint = []
  let nodes_with_pc_and_rc = []
  let nodes_with_pc = []
  let nodes_with_one_rc = []
  let nodes_with_both_rc = []

  for node in nodes_of_layer {
    all_nodes.push(node)
    if interactive_layered_graph_visitor_has_position_choice_constraint(node) &&
      interactive_layered_graph_visitor_has_relative_constraint(node) {
      nodes_with_pc_and_rc.push(node)
    } else if interactive_layered_graph_visitor_has_position_choice_constraint(
        node,
      ) {
      nodes_with_pc.push(node)
    } else if interactive_layered_graph_visitor_has_in_layer_pred_constraint(
        node,
      ) &&
      interactive_layered_graph_visitor_has_in_layer_succ_constraint(node) {
      nodes_with_both_rc.push(node)
    } else if interactive_layered_graph_visitor_has_relative_constraint(node) {
      nodes_with_one_rc.push(node)
    } else {
      nodes_without_constraint.push(node)
    }
  }

  interactive_layered_graph_visitor_sort_nodes_by_int_option(
    nodes_with_pc, layered_options_crossing_minimization_position_id,
  )

  let mut n = 0
  while n < nodes_with_both_rc.length() {
    let node = nodes_with_both_rc[n]
    let target_name = match
      interactive_layered_graph_visitor_string_option_value(
        node, layered_options_crossing_minimization_in_layer_pred_of,
      ) {
      Some(value) => value
      None => abort("interactive layered graph visitor missing pred target")
    }
    let target = interactive_layered_graph_visitor_require_elk_node(
      all_nodes, target_name,
    )
    interactive_layered_graph_visitor_clear_string_option(
      node, layered_options_crossing_minimization_in_layer_pred_of,
    )
    if interactive_layered_graph_visitor_has_position_choice_constraint(target) {
      let target_pos_constraint = interactive_layered_graph_visitor_int_option_value(
        target, layered_options_crossing_minimization_position_choice_constraint,
      )
      interactive_layered_graph_visitor_set_int_option(
        node,
        layered_options_crossing_minimization_position_choice_constraint,
        target_pos_constraint - 1,
      )
      nodes_with_pc_and_rc.push(node)
    } else {
      interactive_layered_graph_visitor_set_string_option(
        target,
        layered_options_crossing_minimization_in_layer_succ_of,
        node_identifier(node),
      )
      nodes_with_one_rc.push(node)
      if !interactive_layered_graph_visitor_has_in_layer_pred_constraint(target) {
        ignore(
          interactive_layered_graph_visitor_remove_node(
            nodes_without_constraint, target,
          ),
        )
        nodes_with_one_rc.push(target)
      } else {
        ignore(
          interactive_layered_graph_visitor_remove_node(
            nodes_with_one_rc, target,
          ),
        )
        ignore(nodes_with_both_rc.insert(n + 1, target))
      }
    }
    n = n + 1
  }

  interactive_layered_graph_visitor_handle_nodes_with_pc_and_rc(
    all_nodes, nodes_without_constraint, nodes_with_one_rc, nodes_with_pc, nodes_with_pc_and_rc,
  )

  let sorted_nodes_with_one_rc = interactive_layered_graph_visitor_sort_rc_nodes(
    nodes_with_one_rc, all_nodes, nodes_without_constraint,
  )
  interactive_layered_graph_visitor_sort_nodes_in_layer(
    nodes_with_pc, nodes_without_constraint, direction,
  )

  for node in sorted_nodes_with_one_rc {
    let targets : Array[ElkNode?] = [None, None]
    if interactive_layered_graph_visitor_has_in_layer_pred_constraint(node) {
      let property = layered_options_crossing_minimization_in_layer_pred_of
      let target_name = match
        interactive_layered_graph_visitor_string_option_value(node, property) {
        Some(value) => value
        None => abort("interactive layered graph visitor missing pred target")
      }
      targets[0] = interactive_layered_graph_visitor_get_elk_node(
        all_nodes, target_name,
      )
    } else {
      let property = layered_options_crossing_minimization_in_layer_succ_of
      let target_name = match
        interactive_layered_graph_visitor_string_option_value(node, property) {
        Some(value) => value
        None => abort("interactive layered graph visitor missing succ target")
      }
      targets[1] = interactive_layered_graph_visitor_get_elk_node(
        all_nodes, target_name,
      )
    }

    for t in 0..<targets.length() {
      if targets[t] is Some(target) {
        if !interactive_layered_graph_visitor_has_position_choice_constraint(
            target,
          ) {
          let index = if t == 0 {
            interactive_layered_graph_visitor_index_of_node(
              nodes_without_constraint, target,
            )
          } else {
            interactive_layered_graph_visitor_index_of_node(
              nodes_without_constraint, target,
            ) +
            1
          }
          ignore(nodes_without_constraint.insert(index, node))
        } else {
          let value = interactive_layered_graph_visitor_int_option_value(
            target, layered_options_crossing_minimization_position_choice_constraint,
          )
          let result = if t == 0 { value - 1 } else { value + 1 }
          let node_property = if t == 0 {
            layered_options_crossing_minimization_in_layer_pred_of
          } else {
            layered_options_crossing_minimization_in_layer_succ_of
          }
          interactive_layered_graph_visitor_set_int_option(
            node, layered_options_crossing_minimization_position_choice_constraint,
            result,
          )
          interactive_layered_graph_visitor_clear_string_option(
            node, node_property,
          )
          nodes_with_pc.push(node)
        }
      }
    }
  }

  interactive_layered_graph_visitor_sort_nodes_by_int_option(
    nodes_with_pc, layered_options_crossing_minimization_position_choice_constraint,
  )

  for node in nodes_with_pc {
    let position = interactive_layered_graph_visitor_int_option_value(
      node, layered_options_crossing_minimization_position_choice_constraint,
    )
    if position < nodes_without_constraint.length() {
      if position > 0 {
        interactive_layered_graph_visitor_swap_nodes(
          nodes_without_constraint, position,
        )
      }
      ignore(nodes_without_constraint.insert(position, node))
    } else {
      nodes_without_constraint.push(node)
    }
  }

  match direction {
    Direction::Undefined => {
      let mut y_position = node_y(nodes_without_constraint[0])
      for node in nodes_without_constraint {
        interactive_layered_graph_visitor_set_kvector_option(
          node,
          layered_options_position,
          new_kvector_xy(node_x(node), y_position),
        )
        y_position = y_position + node_height(node) + spacing
      }
    }
    Direction::Rightward => {
      let mut y_position = node_y(nodes_without_constraint[0])
      for node in nodes_without_constraint {
        interactive_layered_graph_visitor_set_kvector_option(
          node,
          layered_options_position,
          new_kvector_xy(node_x(node), y_position),
        )
        y_position = y_position + node_height(node) + spacing
      }
    }
    Direction::Leftward => {
      let mut y_position = node_y(nodes_without_constraint[0])
      for node in nodes_without_constraint {
        interactive_layered_graph_visitor_set_kvector_option(
          node,
          layered_options_position,
          new_kvector_xy(node_x(node), y_position),
        )
        y_position = y_position + node_height(node) + spacing
      }
    }
    Direction::Downward => {
      let mut x_position = node_x(nodes_without_constraint[0]) +
        2.0 * layer_id.to_double() * spacing
      for node in nodes_without_constraint {
        interactive_layered_graph_visitor_set_kvector_option(
          node,
          layered_options_position,
          new_kvector_xy(x_position, node_y(node)),
        )
        x_position = x_position + node_width(node) + spacing
      }
    }
    Direction::Upward => {
      let mut x_position = node_x(nodes_without_constraint[0]) +
        2.0 * layer_id.to_double() * spacing
      for node in nodes_without_constraint {
        interactive_layered_graph_visitor_set_kvector_option(
          node,
          layered_options_position,
          new_kvector_xy(x_position, node_y(node)),
        )
        x_position = x_position + node_width(node) + spacing
      }
    }
  }
}

///|
fn interactive_layered_graph_visitor_set_coordinates(root : ElkNode) -> Unit {
  let layers = interactive_layered_graph_visitor_calc_layer_nodes(
    node_children(root),
  )
  let direction_value = match
    interactive_layered_graph_visitor_string_option_value(root, direction) {
    Some(value) => value
    None => node_get_string_property(root, direction)
  }
  let parsed_direction = interactive_layered_graph_visitor_parse_direction(
    direction_value,
  )
  interactive_layered_graph_visitor_set_coordinate_in_layout_direction(
    layers, parsed_direction,
  )
  let mut layer_id = 0
  for layer in layers {
    if !layer.is_empty() {
      interactive_layered_graph_visitor_set_coordinates_orthogonal_to_layout_direction(
        layer, layer_id, parsed_direction,
      )
      layer_id = layer_id + 1
    }
  }
}

///|
fn interactive_layered_graph_visitor_translate_layer_constraint(
  node : ElkNode,
) -> Unit {
  match
    interactive_layered_graph_visitor_string_option_value(
      node, layered_options_layering_layer_constraint,
    ) {
    Some(constraint) => {
      interactive_layered_graph_visitor_set_string_option(
        node, layered_options_layering_layer_constraint, "NONE",
      )
      if constraint == "FIRST" {
        if !interactive_layered_graph_visitor_has_layer_choice_constraint(node) {
          interactive_layered_graph_visitor_set_int_option(
            node, layered_options_layering_layer_choice_constraint, 0,
          )
        }
      } else if constraint == "LAST" {
        if !interactive_layered_graph_visitor_has_layer_choice_constraint(node) {
          interactive_layered_graph_visitor_set_int_option(
            node, layered_options_layering_layer_choice_constraint, interactive_layered_graph_visitor_last_layer_index,
          )
        }
      }
    }
    None => ()
  }
}

///|
fn interactive_layered_graph_visitor_set_interactive_strategies(
  parent : ElkNode,
) -> Unit {
  interactive_layered_graph_visitor_set_bool_option(
    parent, layered_options_crossing_minimization_semi_interactive, true,
  )
  interactive_layered_graph_visitor_set_string_option(
    parent,
    layered_options_layering_strategy,
    layering_strategy_to_string(LayeringStrategy::LsInteractive),
  )
  interactive_layered_graph_visitor_set_string_option(
    parent,
    layered_options_cycle_breaking_strategy,
    cycle_breaking_strategy_to_string(CycleBreakingStrategy::CbsInteractive),
  )
  interactive_layered_graph_visitor_set_string_option(
    parent, layered_options_consider_model_order_strategy, "NONE",
  )
  interactive_layered_graph_visitor_set_bool_option(
    parent, layered_options_crossing_minimization_force_node_model_order, false,
  )
  interactive_layered_graph_visitor_set_string_option(
    parent,
    layered_options_crossing_minimization_strategy,
    crossing_minimization_strategy_to_string(
      CrossingMinimizationStrategy::CmsLayerSweep,
    ),
  )
}

///|
pub fn interactive_layered_graph_visitor_set_interactive_options_and_pseudo_positions(
  root : ElkNode,
) -> Unit {
  if node_children(root).is_empty() {
    return
  }
  let configured_algorithm = match
    node_layout_option_string_value(root, algorithm.get_id()) {
    Some(value) => value
    None => node_get_string_property(root, algorithm)
  }
  if configured_algorithm.is_empty() ||
    layered_algorithm_id.has_suffix(configured_algorithm) {
    for node in node_children(root) {
      interactive_layered_graph_visitor_translate_layer_constraint(node)
      interactive_layered_graph_visitor_set_coordinates(root)
      interactive_layered_graph_visitor_set_interactive_strategies(root)
    }
  }
}

///|
pub fn new_interactive_layered_graph_visitor() -> InteractiveLayeredGraphVisitor {
  { marker: 0 }
}

///|
pub fn InteractiveLayeredGraphVisitor::visit(
  self : InteractiveLayeredGraphVisitor,
  element : ElkNode,
) -> Unit {
  ignore(self)
  interactive_layered_graph_visitor_set_interactive_options_and_pseudo_positions(
    element,
  )
}

///|
pub fn new_interactive_layered_graph_element_visitor() -> IGraphElementVisitor {
  let visitor = new_interactive_layered_graph_visitor()
  new_graph_element_visitor(fn(element : ElkNode) { visitor.visit(element) })
}
