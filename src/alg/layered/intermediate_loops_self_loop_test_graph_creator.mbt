///|
pub fn self_loop_test_graph_creator_basic_graph_without_self_loops() -> LGraph {
  let l_graph = new_l_graph()

  let n1 = self_loop_test_graph_creator_node(l_graph)
  self_loop_test_graph_creator_ports(n1, 0, 1, 0, 0)

  let n2 = self_loop_test_graph_creator_node(l_graph)
  self_loop_test_graph_creator_ports(n2, 0, 0, 0, 1)

  ignore(
    self_loop_test_graph_creator_edge(n1.get_ports()[0], n2.get_ports()[0]),
  )

  l_graph
}

///|
pub fn self_loop_test_graph_creator_basic_graph_with_self_loops() -> LGraph {
  let l_graph = self_loop_test_graph_creator_basic_graph_without_self_loops()

  let l_node = l_graph.get_layerless_nodes()[1]
  self_loop_test_graph_creator_ports(l_node, 2, 2, 2, 1)

  for i in 1..<l_node.get_ports().length() {
    if i % 2 == 1 {
      ignore(
        self_loop_test_graph_creator_edge(
          l_node.get_ports()[i - 1],
          l_node.get_ports()[i],
        ),
      )
    }
  }

  l_graph
}

///|
pub fn self_loop_test_graph_creator_node(l_graph : LGraph) -> LNode {
  let l_node = new_l_node(graph=Some(l_graph))
  l_graph.get_layerless_nodes().push(l_node)
  l_node
}

///|
pub fn self_loop_test_graph_creator_edge(
  source : LPort,
  target : LPort,
) -> LEdge {
  let l_edge = new_l_edge()
  l_edge.set_source(Some(source))
  l_edge.set_target(Some(target))
  l_edge
}

///|
pub fn self_loop_test_graph_creator_ports(
  l_node : LNode,
  north : Int,
  east : Int,
  south : Int,
  west : Int,
) -> Unit {
  for _ in 0..<north {
    let l_port = new_l_port()
    l_port.set_node(Some(l_node))
    l_port.set_side(North)
  }

  for _ in 0..<east {
    let l_port = new_l_port()
    l_port.set_node(Some(l_node))
    l_port.set_side(East)
  }

  for _ in 0..<south {
    let l_port = new_l_port()
    l_port.set_node(Some(l_node))
    l_port.set_side(South)
  }

  for _ in 0..<west {
    let l_port = new_l_port()
    l_port.set_node(Some(l_node))
    l_port.set_side(West)
  }
}
