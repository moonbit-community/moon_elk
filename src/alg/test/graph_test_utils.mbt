///|
pub enum GraphTestShape {
  GraphTestNode(ElkNode)
  GraphTestPort(ElkPort)
  GraphTestLabel(ElkLabel)
}

///|
pub fn graph_test_shape_node(node : ElkNode) -> GraphTestShape {
  GraphTestNode(node)
}

///|
pub fn graph_test_shape_port(port : ElkPort) -> GraphTestShape {
  GraphTestPort(port)
}

///|
pub fn graph_test_shape_label(label : ElkLabel) -> GraphTestShape {
  GraphTestLabel(label)
}

///|
priv struct GraphTestRectangle {
  x : Double
  y : Double
  width : Double
  height : Double
}

///|
fn graph_test_rectangles_intersect(
  first : GraphTestRectangle,
  second : GraphTestRectangle,
) -> Bool {
  first.x < second.x + second.width &&
  first.x + first.width > second.x &&
  first.y < second.y + second.height &&
  first.y + first.height > second.y
}

///|
fn graph_test_utils_absolute_node_position(node : ElkNode) -> KVector {
  let absolute = new_kvector_xy(node_x(node), node_y(node))
  match node_parent(node) {
    Some(parent) =>
      ignore(absolute.add(graph_test_utils_absolute_node_position(parent)))
    None => ()
  }
  absolute
}

///|
fn graph_test_utils_absolute_port_position(port : ElkPort) -> KVector {
  match port_parent(port) {
    Some(parent_node) =>
      graph_test_utils_absolute_node_position(parent_node).add_xy(
        port_x(port),
        port_y(port),
      )
    None => new_kvector_xy(port_x(port), port_y(port))
  }
}

///|
fn graph_test_utils_absolute_label_parent_position(
  parent : ElkLabelParent,
) -> KVector {
  match parent {
    NodeLabelParent(node) => graph_test_utils_absolute_node_position(node)
    PortLabelParent(port) => graph_test_utils_absolute_port_position(port)
    EdgeLabelParent(edge) =>
      match edge_containing_node(edge) {
        Some(node) => graph_test_utils_absolute_node_position(node)
        None => new_kvector()
      }
    LabelLabelParent(label) => graph_test_utils_absolute_label_position(label)
  }
}

///|
fn graph_test_utils_absolute_label_position(label : ElkLabel) -> KVector {
  let absolute = new_kvector_xy(label_x(label), label_y(label))
  match label_parent(label) {
    Some(parent) =>
      ignore(
        absolute.add(graph_test_utils_absolute_label_parent_position(parent)),
      )
    None => ()
  }
  absolute
}

///|
fn graph_test_utils_shape_rectangle(
  shape : GraphTestShape,
) -> GraphTestRectangle {
  match shape {
    GraphTestNode(node) => {
      let position = graph_test_utils_absolute_node_position(node)
      {
        x: position.x,
        y: position.y,
        width: node_width(node),
        height: node_height(node),
      }
    }
    GraphTestPort(port) => {
      let position = graph_test_utils_absolute_port_position(port)
      {
        x: position.x,
        y: position.y,
        width: port_width(port),
        height: port_height(port),
      }
    }
    GraphTestLabel(label) => {
      let position = graph_test_utils_absolute_label_position(label)
      {
        x: position.x,
        y: position.y,
        width: label_width(label),
        height: label_height(label),
      }
    }
  }
}

///|
pub fn graph_test_utils_all_nodes(
  graph : ElkNode,
  include_graph : Bool,
) -> Array[ElkNode] {
  let nodes : Array[ElkNode] = []
  if include_graph {
    nodes.push(graph)
  } else {
    for child in node_children(graph) {
      nodes.push(child)
    }
  }
  let mut index = 0
  while index < nodes.length() {
    for child in node_children(nodes[index]) {
      nodes.push(child)
    }
    index += 1
  }
  nodes
}

///|
pub fn graph_test_utils_have_overlaps(shapes : Array[GraphTestShape]) -> Bool {
  let rectangles : Array[GraphTestRectangle] = []
  for shape in shapes {
    rectangles.push(graph_test_utils_shape_rectangle(shape))
  }
  for first in 0..<rectangles.length() {
    let mut second = first + 1
    while second < rectangles.length() {
      if graph_test_rectangles_intersect(rectangles[first], rectangles[second]) {
        return true
      }
      second += 1
    }
  }
  false
}

///|
fn graph_test_utils_create_port_edge(
  source_port : ElkPort,
  target_port : ElkPort,
) -> ElkEdge {
  let source_node = match port_parent(source_port) {
    Some(node) => node
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "Source port has no parent node.",
      )
      create_graph()
    }
  }
  let target_node = match port_parent(target_port) {
    Some(node) => node
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "Target port has no parent node.",
      )
      create_graph()
    }
  }
  let containing_node = match
    find_lowest_common_ancestor(source_node, target_node) {
    Some(common_parent) => common_parent
    None => source_node
  }
  let edge = create_edge(Some(containing_node))
  edge_add_source(edge, make_port_shape(source_port))
  edge_add_target(edge, make_port_shape(target_port))
  edge
}

///|
fn graph_test_utils_populate_simple_graph(parent_node : ElkNode) -> Unit {
  let child_node1 = create_node(Some(parent_node))
  let child_node1_label = create_label(
    Some(make_node_label_parent(child_node1)),
  )
  label_set_text(child_node1_label, "node1")

  let child_node2 = create_node(Some(parent_node))
  let child_node2_label = create_label(
    Some(make_node_label_parent(child_node2)),
  )
  label_set_text(child_node2_label, "node2")

  let port1 = create_port(Some(child_node1))
  let port2 = create_port(Some(child_node2))
  ignore(graph_test_utils_create_port_edge(port1, port2))
}

///|
pub fn graph_test_utils_create_simple_graph() -> ElkNode {
  let parent_node = create_graph()
  graph_test_utils_populate_simple_graph(parent_node)
  parent_node
}

///|
pub fn graph_test_utils_create_three_node_graph() -> ElkNode {
  let layout_graph = create_graph()
  let node1 = create_node(Some(layout_graph))
  let node2 = create_node(Some(layout_graph))
  let node3 = create_node(Some(layout_graph))

  ignore(create_simple_edge(node1, node3))
  ignore(create_simple_edge(node2, node3))

  for node in node_children(layout_graph) {
    node_set_dimensions(node, 50.0, 50.0)
  }

  layout_graph
}

///|
pub fn graph_test_utils_create_hierarchical_graph() -> ElkNode {
  let parent_node = create_graph()

  let child1 = create_node(Some(parent_node))
  let child1_label = create_label(Some(make_node_label_parent(child1)))
  label_set_text(child1_label, "child1")
  graph_test_utils_populate_simple_graph(child1)

  let child2 = create_node(Some(parent_node))
  let child2_label = create_label(Some(make_node_label_parent(child2)))
  label_set_text(child2_label, "child2")
  graph_test_utils_populate_simple_graph(child2)

  parent_node
}

///|
pub fn graph_test_utils_get_child(
  parent : ElkNode,
  child_path : Array[String],
) -> ElkNode {
  let mut current_parent = parent
  let mut result = parent
  for identifier in child_path {
    let mut found : ElkNode? = None
    for child in node_children(current_parent) {
      if node_identifier(child) == identifier {
        found = Some(child)
        break
      }
    }
    match found {
      Some(child) => {
        result = child
        current_parent = child
      }
      None => {
        @core.layout_runtime_report_unsupported_configuration(
          "The node \"" +
          node_identifier(current_parent) +
          "\" has no child with identifier \"" +
          identifier +
          "\".",
        )
        return current_parent
      }
    }
  }
  result
}

///|
pub fn graph_test_utils_get_port(node : ElkNode, port_id : String) -> ElkPort {
  for port in node_ports(node) {
    if port_identifier(port) == port_id {
      return port
    }
  }
  @core.layout_runtime_report_unsupported_configuration(
    "The node \"" +
    node_identifier(node) +
    "\" has no port with identifier \"" +
    port_id +
    "\".",
  )
  match node_ports(node) {
    [first, ..] => first
    [] => create_port(Some(node))
  }
}
