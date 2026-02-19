///|
fn inside_port_label_intersects(a : ElkLabel, b : ElkLabel) -> Bool {
  let ax1 = label_x(a)
  let ay1 = label_y(a)
  let ax2 = ax1 + label_width(a)
  let ay2 = ay1 + label_height(a)

  let bx1 = label_x(b)
  let by1 = label_y(b)
  let bx2 = bx1 + label_width(b)
  let by2 = by1 + label_height(b)

  ax1 < bx2 && bx1 < ax2 && ay1 < by2 && by1 < ay2
}

///|
fn inside_port_label_have_overlaps(labels : Array[ElkLabel]) -> Bool {
  for i = 0; i < labels.length(); i = i + 1 {
    for j = i + 1; j < labels.length(); j = j + 1 {
      if inside_port_label_intersects(labels[i], labels[j]) {
        return true
      }
    }
  }
  false
}

///|
fn inside_port_label_assemble_labels(node : ElkNode) -> Array[ElkLabel] {
  let labels = []

  for label in node_labels(node) {
    labels.push(label)
  }

  for port in node_ports(node) {
    for label in port_labels(port) {
      labels.push(label)
    }
  }

  labels
}

///|
test "InsidePortLabelTest no label overlaps" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let node = create_node(Some(graph))
  node_set_dimensions(node, 80.0, 40.0)

  let node_label = create_label(Some(make_node_label_parent(node)))
  label_set_location(node_label, 2.0, 2.0)
  label_set_dimensions(node_label, 18.0, 6.0)

  let port = create_port(Some(node))
  let port_label_a = create_label(Some(make_port_label_parent(port)))
  label_set_location(port_label_a, 2.0, 12.0)
  label_set_dimensions(port_label_a, 12.0, 4.0)

  let port_label_b = create_label(Some(make_port_label_parent(port)))
  label_set_location(port_label_b, 2.0, 20.0)
  label_set_dimensions(port_label_b, 10.0, 4.0)

  let overlaps = inside_port_label_have_overlaps(
    inside_port_label_assemble_labels(node),
  )
  assert_false(overlaps)
}
