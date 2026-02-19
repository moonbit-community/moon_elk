///|
let network_simplex_compaction_separation_weight : Double = 1.0

///|
let network_simplex_compaction_edge_weight : Double = 100.0

///|
fn network_simplex_compaction_int_max(left : Int, right : Int) -> Int {
  if left > right {
    left
  } else {
    right
  }
}

///|
fn network_simplex_compaction_require_group(
  node : @common.CNode,
) -> @common.CGroup {
  match node.group() {
    Some(group) => group
    None => abort("Compaction node has no group.")
  }
}

///|
fn network_simplex_compaction_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(source) => source
    None => abort("Edge has no source port.")
  }
}

///|
fn network_simplex_compaction_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(target) => target
    None => abort("Edge has no target port.")
  }
}

///|
fn network_simplex_compaction_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(node) => node
    None => abort("Port has no owner node.")
  }
}

///|
fn network_simplex_compaction_group_node(
  n_nodes : Array[@common.NNode],
  group : @common.CGroup,
) -> @common.NNode {
  let id = group.id()
  if id < 0 || id >= n_nodes.length() {
    abort("Invalid group id for network simplex node lookup.")
  }
  n_nodes[id]
}

///|
fn network_simplex_compaction_lnode_map_put(
  mapping : Map[Int, @common.CNode],
  l_node : LNode,
  c_node : @common.CNode,
) -> Unit {
  mapping[l_node.get_handle()] = c_node
}

///|
fn network_simplex_compaction_lnode_map_get(
  mapping : Map[Int, @common.CNode],
  l_node : LNode,
) -> @common.CNode? {
  mapping.get(l_node.get_handle())
}

///|
fn network_simplex_compaction_edge_map_put(
  mapping : Map[Int, Array[@common.CNode]],
  l_edge : LEdge,
  c_node : @common.CNode,
) -> Unit {
  let edge_handle = l_edge.get_handle()
  match mapping.get(edge_handle) {
    Some(values) => values.push(c_node)
    None => mapping[edge_handle] = [c_node]
  }
}

///|
fn network_simplex_compaction_edge_map_get(
  mapping : Map[Int, Array[@common.CNode]],
  l_edge : LEdge,
) -> Array[@common.CNode] {
  match mapping.get(l_edge.get_handle()) {
    Some(values) => values
    None => []
  }
}

///|
fn network_simplex_compaction_same_nnode(
  source : @common.NNode,
  target : @common.NNode,
) -> Bool {
  source == target
}

///|
fn network_simplex_compaction_add_separation_constraints(
  compactor : @common.OneDimensionalCompactor,
  network_graph : @common.NGraph,
  n_nodes : Array[@common.NNode],
) -> Unit {
  for c_node in compactor.c_graph.c_nodes {
    for inc_node in c_node.constraints() {
      let c_group = network_simplex_compaction_require_group(c_node)
      let inc_group = network_simplex_compaction_require_group(inc_node)
      if c_group == inc_group {
        continue
      }

      let spacing = if compactor.direction.is_horizontal() {
        (compactor.spacings_handler.get_horizontal_spacing)(c_node, inc_node)
      } else {
        (compactor.spacings_handler.get_vertical_spacing)(c_node, inc_node)
      }

      let c_offset = c_node.c_group_offset()
      let inc_offset = inc_node.c_group_offset()
      let c_hitbox = c_node.hitbox()

      let mut delta = c_offset.x + c_hitbox.width + spacing - inc_offset.x
      delta = delta.ceil()
      delta = if delta < 0.0 { 0.0 } else { delta }

      if !horizontal_graph_compactor_is_vertical_segments_of_same_edge(
          c_node, inc_node,
        ) {
        let mut weight = network_simplex_compaction_separation_weight
        let c_is_vs = horizontal_graph_compactor_get_vertical_segment_or_null(
            c_node,
          )
          is Some(_)
        let inc_is_vs = horizontal_graph_compactor_get_vertical_segment_or_null(
            inc_node,
          )
          is Some(_)
        let c_is_node = horizontal_graph_compactor_get_lnode_or_null(c_node)
          is Some(_)
        let inc_is_node = horizontal_graph_compactor_get_lnode_or_null(inc_node)
          is Some(_)
        if (c_is_vs && inc_is_node) || (inc_is_vs && c_is_node) {
          weight = 2.0
        }

        ignore(
          @common.nedge_of()
          .delta(delta.to_int())
          .weight(weight)
          .source(network_simplex_compaction_group_node(n_nodes, c_group))
          .target(network_simplex_compaction_group_node(n_nodes, inc_group))
          .create(),
        )
      } else {
        let helper = @common.nnode_of().create(network_graph)
        let offset_delta = (inc_offset.x - c_offset.x).ceil().to_int()

        let mut adjust = offset_delta.to_double() - (inc_offset.x - c_offset.x)
        let mut alter_offset = c_node

        let mut port : LPort? = None
        match horizontal_graph_compactor_get_vertical_segment_or_null(c_node) {
          Some(segment) => port = segment.get_a_port()
          None => ()
        }
        if port is None {
          match
            horizontal_graph_compactor_get_vertical_segment_or_null(inc_node) {
            Some(segment) => {
              port = segment.get_a_port()
              adjust = -adjust
              alter_offset = inc_node
            }
            None => ()
          }
        }

        match port {
          Some(value) => {
            let new_offset = alter_offset.c_group_offset()
            new_offset.x = new_offset.x - adjust
            alter_offset.set_c_group_offset(new_offset)
            value.get_position().x = value.get_position().x - adjust
          }
          None => ()
        }

        ignore(
          @common.nedge_of()
          .delta(network_simplex_compaction_int_max(0, offset_delta))
          .weight(network_simplex_compaction_separation_weight)
          .source(helper)
          .target(network_simplex_compaction_group_node(n_nodes, c_group))
          .create(),
        )
        ignore(
          @common.nedge_of()
          .delta(network_simplex_compaction_int_max(0, -offset_delta))
          .weight(network_simplex_compaction_separation_weight)
          .source(helper)
          .target(network_simplex_compaction_group_node(n_nodes, inc_group))
          .create(),
        )
      }
    }
  }
}

///|
fn network_simplex_compaction_add_edge_constraints(
  compactor : @common.OneDimensionalCompactor,
  n_nodes : Array[@common.NNode],
) -> Unit {
  let lnode_map : Map[Int, @common.CNode] = {}
  let ledge_map : Map[Int, Array[@common.CNode]] = {}

  for c_node in compactor.c_graph.c_nodes {
    match horizontal_graph_compactor_get_lnode_or_null(c_node) {
      Some(l_node) =>
        network_simplex_compaction_lnode_map_put(lnode_map, l_node, c_node)
      None =>
        match horizontal_graph_compactor_get_vertical_segment_or_null(c_node) {
          Some(vs) =>
            for edge in vs.represented_l_edges {
              network_simplex_compaction_edge_map_put(ledge_map, edge, c_node)
            }
          None => ()
        }
    }
  }

  for c_node in compactor.c_graph.c_nodes {
    let l_node = match horizontal_graph_compactor_get_lnode_or_null(c_node) {
      Some(value) => value
      None => continue
    }

    for l_edge in l_node.get_outgoing_edges() {
      if l_edge.is_self_loop() {
        continue
      }

      let src_port = network_simplex_compaction_require_source(l_edge)
      let tgt_port = network_simplex_compaction_require_target(l_edge)

      if @core.port_side_is_vertical(src_port.get_side()) &&
        @core.port_side_is_vertical(tgt_port.get_side()) {
        continue
      }

      let target_l_node = network_simplex_compaction_require_port_node(tgt_port)
      let target = match
        network_simplex_compaction_lnode_map_get(lnode_map, target_l_node) {
        Some(value) => value
        None => continue
      }

      ignore(
        @common.nedge_of()
        .delta(0)
        .weight(network_simplex_compaction_edge_weight)
        .source(
          network_simplex_compaction_group_node(
            n_nodes,
            network_simplex_compaction_require_group(c_node),
          ),
        )
        .target(
          network_simplex_compaction_group_node(
            n_nodes,
            network_simplex_compaction_require_group(target),
          ),
        )
        .create(),
      )

      if horizontal_graph_compactor_port_side_is(
          src_port.get_side(),
          @core.PortSide::West,
        ) &&
        horizontal_graph_compactor_port_is_output(src_port) {
        for mapped in network_simplex_compaction_edge_map_get(ledge_map, l_edge) {
          if mapped.hitbox().x < c_node.hitbox().x {
            let src = network_simplex_compaction_group_node(
              n_nodes,
              network_simplex_compaction_require_group(mapped),
            )
            let tgt = network_simplex_compaction_group_node(
              n_nodes,
              network_simplex_compaction_require_group(c_node),
            )
            if network_simplex_compaction_same_nnode(src, tgt) {
              continue
            }
            ignore(
              @common.nedge_of()
              .delta(1)
              .weight(network_simplex_compaction_edge_weight)
              .source(src)
              .target(tgt)
              .create(),
            )
          }
        }
      }

      if horizontal_graph_compactor_port_side_is(
          tgt_port.get_side(),
          @core.PortSide::East,
        ) &&
        horizontal_graph_compactor_port_is_input(tgt_port) {
        for mapped in network_simplex_compaction_edge_map_get(ledge_map, l_edge) {
          if mapped.hitbox().x > c_node.hitbox().x {
            let src = network_simplex_compaction_group_node(
              n_nodes,
              network_simplex_compaction_require_group(c_node),
            )
            let tgt = network_simplex_compaction_group_node(
              n_nodes,
              network_simplex_compaction_require_group(mapped),
            )
            if network_simplex_compaction_same_nnode(src, tgt) {
              continue
            }
            ignore(
              @common.nedge_of()
              .delta(1)
              .weight(network_simplex_compaction_edge_weight)
              .source(src)
              .target(tgt)
              .create(),
            )
          }
        }
      }
    }
  }
}

///|
fn network_simplex_compaction_add_artificial_source_node(
  network_graph : @common.NGraph,
  index : Int,
) -> Int {
  let sources : Array[@common.NNode] = []
  for node in network_graph.nodes {
    if node.get_incoming_edges().is_empty() {
      sources.push(node)
    }
  }

  if sources.length() > 1 {
    let dummy_source = @common.nnode_of().id(index).create(network_graph)
    for source in sources {
      ignore(
        @common.nedge_of()
        .delta(1)
        .weight(0.0)
        .source(dummy_source)
        .target(source)
        .create(),
      )
    }
    index + 1
  } else {
    index
  }
}

///|
pub fn network_simplex_compaction(
  compactor : @common.OneDimensionalCompactor,
) -> Unit {
  let network_graph = @common.new_ngraph()
  let n_nodes : Array[@common.NNode] = []
  let mut index = 0

  for c_group in compactor.c_graph.c_groups {
    c_group.set_id(index)
    let n_node = @common.nnode_of().id(index).create(network_graph)
    n_nodes.push(n_node)
    index = index + 1
  }

  network_simplex_compaction_add_separation_constraints(
    compactor, network_graph, n_nodes,
  )
  network_simplex_compaction_add_edge_constraints(compactor, n_nodes)
  ignore(
    network_simplex_compaction_add_artificial_source_node(network_graph, index),
  )

  @common.network_simplex_for_graph(network_graph).execute()

  for c_node in compactor.c_graph.c_nodes {
    let group = network_simplex_compaction_require_group(c_node)
    let group_node = network_simplex_compaction_group_node(n_nodes, group)
    let offset = c_node.c_group_offset()
    let hitbox = c_node.hitbox()
    hitbox.x = group_node.get_layer().to_double() + offset.x
    c_node.set_hitbox(hitbox)
  }
}
