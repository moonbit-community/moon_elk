///|
pub struct TestConfiguration[T] {
  use_default_node_config : Bool
  use_default_port_config : Bool
  use_default_edge_config : Bool
  add_random_edge_labels : Bool
  apply_base_configuration_fn : (T, ElkNode) -> Unit
}

///|
pub fn[T] new_test_configuration(
  default_configuration? : DefaultConfiguration? = None,
  apply_base_configuration_fn? : (T, ElkNode) -> Unit = (_test_instance, _graph) => {
    ()
  },
) -> TestConfiguration[T] {
  let config = match default_configuration {
    Some(value) => value
    None => new_default_configuration()
  }
  {
    use_default_node_config: config.nodes_enabled(),
    use_default_port_config: config.ports_enabled(),
    use_default_edge_config: config.edges_enabled(),
    add_random_edge_labels: config.edge_labels_enabled(),
    apply_base_configuration_fn,
  }
}

///|
fn test_configuration_apply_default_node(elk_node : ElkNode) -> Unit {
  if node_width(elk_node) == 0.0 && node_height(elk_node) == 0.0 {
    node_set_dimensions(elk_node, 30.0, 30.0)
  }
}

///|
fn test_configuration_apply_default_port(elk_port : ElkPort) -> Unit {
  if port_width(elk_port) == 0.0 && port_height(elk_port) == 0.0 {
    port_set_dimensions(elk_port, 5.0, 5.0)
  }
}

///|
fn test_configuration_apply_default_edge(_elk_edge : ElkEdge) -> Unit {
  ()
}

///|
fn test_configuration_create_edge_label_if_absent(elk_edge : ElkEdge) -> Unit {
  if edge_labels(elk_edge).is_empty() {
    let label = create_label(Some(make_edge_label_parent(elk_edge)))
    label_set_text(label, edge_identifier(elk_edge))
  }
}

///|
fn[T] test_configuration_apply_default_configuration(
  config : TestConfiguration[T],
  graph : ElkNode,
) -> Unit {
  for elk_node in node_children(graph) {
    if config.use_default_node_config {
      test_configuration_apply_default_node(elk_node)
    }
    if config.use_default_port_config ||
      config.use_default_edge_config ||
      config.add_random_edge_labels {
      for elk_port in node_ports(elk_node) {
        if config.use_default_port_config {
          test_configuration_apply_default_port(elk_port)
        }
        if config.use_default_edge_config {
          for elk_edge in port_outgoing_edges(elk_port) {
            test_configuration_apply_default_edge(elk_edge)
          }
        }
        if config.add_random_edge_labels {
          for elk_edge in port_outgoing_edges(elk_port) {
            test_configuration_create_edge_label_if_absent(elk_edge)
          }
        }
      }
    }
    if config.use_default_edge_config {
      for elk_edge in node_outgoing_edges(elk_node) {
        test_configuration_apply_default_edge(elk_edge)
      }
    }
    if config.add_random_edge_labels {
      for elk_edge in node_outgoing_edges(elk_node) {
        test_configuration_create_edge_label_if_absent(elk_edge)
      }
    }
    test_configuration_apply_default_configuration(config, elk_node)
  }
}

///|
let default_label_font_size : Double = 10.0

///|
fn test_configuration_compute_label_size(label : ElkLabel) -> Unit {
  if label_height(label) == 0.0 && label_width(label) == 0.0 {
    let text = label_text(label)
    if !text.is_empty() {
      let width = text.length().to_double() * 0.6 * default_label_font_size
      label_set_dimensions(label, width, default_label_font_size)
    }
  }
}

///|
fn test_configuration_ensure_sensible_label_size(graph : ElkNode) -> Unit {
  for label in node_labels(graph) {
    test_configuration_compute_label_size(label)
  }
  for port in node_ports(graph) {
    for label in port_labels(port) {
      test_configuration_compute_label_size(label)
    }
    for edge in port_outgoing_edges(port) {
      for label in edge_labels(edge) {
        test_configuration_compute_label_size(label)
      }
    }
  }
  for edge in node_contained_edges(graph) {
    for label in edge_labels(edge) {
      test_configuration_compute_label_size(label)
    }
  }
  for child in node_children(graph) {
    test_configuration_ensure_sensible_label_size(child)
  }
}

///|
pub fn[T] TestConfiguration::apply(
  self : TestConfiguration[T],
  test_instance : T,
  graph : ElkNode,
) -> Unit {
  (self.apply_base_configuration_fn)(test_instance, graph)
  test_configuration_apply_default_configuration(self, graph)
  test_configuration_ensure_sensible_label_size(graph)
}

///|
pub fn[T] TestConfiguration::to_string(self : TestConfiguration[T]) -> String {
  let parts : Array[String] = []
  if self.use_default_node_config {
    parts.push("nodes")
  }
  if self.use_default_port_config {
    parts.push("ports")
  }
  if self.use_default_edge_config {
    parts.push("edges")
  }
  if self.add_random_edge_labels {
    parts.push("edgeLabels")
  }
  let body = if parts.is_empty() { "" } else { parts.join(", ") }
  "defaults(" + body + ")"
}
