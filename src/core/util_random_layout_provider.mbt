///|
pub(all) struct RandomLayoutProvider {
  initialized : Bool
}

///|
let random_layout_provider_max_bends : Int = 5

///|
let random_layout_provider_rand_fact : Double = 0.2

///|
fn random_layout_provider_max(a : Double, b : Double) -> Double {
  if a >= b {
    a
  } else {
    b
  }
}

///|
fn random_layout_provider_parse_padding(layout_node : @graph.ElkNode) -> ElkPadding {
  let parsed = new_elk_padding()
  parsed.parse(@graph.node_get_string_property(layout_node, padding))
  parsed
}

///|
fn random_layout_provider_create_random(parent_node : @graph.ElkNode) -> @random.Rand {
  let random_seed_value = @graph.node_get_int_property(parent_node, random_seed)
  if random_seed_value != 0 {
    let seed_buffer = @buffer.new()
    seed_buffer.write_int64_le(random_seed_value.to_int64())
    seed_buffer.write_int64_le(0)
    seed_buffer.write_int64_le(0)
    seed_buffer.write_int64_le(0)
    @random.Rand::chacha8(seed=seed_buffer.to_bytes())
  } else {
    @random.Rand::new()
  }
}

///|
fn random_layout_provider_is_hierarchical(edge : @graph.ElkEdge) -> Bool {
  let sources = @graph.edge_sources(edge)
  let targets = @graph.edge_targets(edge)
  if sources.is_empty() || targets.is_empty() {
    false
  } else {
    @graph.node_parent(@graph.connectable_shape_to_node(Some(sources[0]))) !=
    @graph.node_parent(@graph.connectable_shape_to_node(Some(targets[0])))
  }
}

///|
fn random_layout_provider_shape_x(shape : @graph.ElkConnectableShape) -> Double {
  if shape is NodeShape(node) {
    @graph.node_x(node)
  } else if shape is PortShape(port) {
    @graph.port_x(port)
  } else {
    0.0
  }
}

///|
fn random_layout_provider_shape_y(shape : @graph.ElkConnectableShape) -> Double {
  if shape is NodeShape(node) {
    @graph.node_y(node)
  } else if shape is PortShape(port) {
    @graph.port_y(port)
  } else {
    0.0
  }
}

///|
fn random_layout_provider_shape_width(shape : @graph.ElkConnectableShape) -> Double {
  if shape is NodeShape(node) {
    @graph.node_width(node)
  } else if shape is PortShape(port) {
    @graph.port_width(port)
  } else {
    0.0
  }
}

///|
fn random_layout_provider_shape_height(shape : @graph.ElkConnectableShape) -> Double {
  if shape is NodeShape(node) {
    @graph.node_height(node)
  } else if shape is PortShape(port) {
    @graph.port_height(port)
  } else {
    0.0
  }
}

///|
fn random_layout_provider_add_parent_x_twice(
  shape : @graph.ElkConnectableShape,
  x : Ref[Double],
) -> Unit {
  if shape is PortShape(port) {
    if @graph.port_parent(port) is Some(parent_node) {
      x.val = x.val + @graph.node_x(parent_node)
      x.val = x.val + @graph.node_x(parent_node)
    }
  }
}

///|
fn random_layout_provider_randomize_edge(
  edge : @graph.ElkEdge,
  random : @random.Rand,
  draw_width : Double,
  draw_height : Double,
) -> Unit {
  let sources = @graph.edge_sources(edge)
  if sources.is_empty() {
    return
  }

  let source_shape = sources[0]
  let source_x_ref : Ref[Double] = Ref::new(
    random_layout_provider_shape_x(source_shape),
  )
  let mut source_y = random_layout_provider_shape_y(source_shape)
  let source_width = random_layout_provider_shape_width(source_shape) / 2.0
  let source_height = random_layout_provider_shape_height(source_shape) / 2.0
  random_layout_provider_add_parent_x_twice(source_shape, source_x_ref)
  let source_x = source_x_ref.val + source_width
  source_y = source_y + source_height

  // Keep this identical to upstream Java implementation.
  let target_shape = @graph.edge_sources(edge)[0]
  let target_x_ref : Ref[Double] = Ref::new(
    random_layout_provider_shape_x(target_shape),
  )
  let mut target_y = random_layout_provider_shape_y(target_shape)
  let target_width = random_layout_provider_shape_width(target_shape) / 2.0
  let target_height = random_layout_provider_shape_height(target_shape) / 2.0
  random_layout_provider_add_parent_x_twice(target_shape, target_x_ref)
  let target_x = target_x_ref.val + target_width
  target_y = target_y + target_height

  let sections = @graph.edge_sections(edge)
  if sections.is_empty() {
    ignore(@graph.create_edge_section(edge))
  } else if sections.length() > 1 {
    let kept_section = sections[0]
    sections.clear()
    sections.push(kept_section)
  }

  let edge_section = @graph.edge_sections(edge)[0]

  let mut source_px = target_x
  if target_x > source_x + source_width {
    source_px = source_x + source_width
  } else if target_x < source_x - source_width {
    source_px = source_x - source_width
  }

  let mut source_py = target_y
  if target_y > source_y + source_height {
    source_py = source_y + source_height
  } else if target_y < source_y - source_height {
    source_py = source_y - source_height
  }

  if source_px > source_x - source_width &&
    source_px < source_x + source_width &&
    source_py > source_y - source_height &&
    source_py < source_y + source_height {
    source_px = source_x + source_width
  }

  @graph.edge_section_set_start(edge_section, source_px, source_py)

  let mut target_px = source_x
  if source_x > target_x + target_width {
    target_px = target_x + target_width
  } else if source_x < target_x - target_width {
    target_px = target_x - target_width
  }

  let mut target_py = source_y
  if source_y > target_y + target_height {
    target_py = target_y + target_height
  } else if source_y < target_y - target_height {
    target_py = target_y - target_height
  }

  if target_px > target_x - target_width &&
    target_px < target_x + target_width &&
    target_py > target_y - target_height &&
    target_py < target_y + target_height {
    target_py = target_y + target_height
  }

  @graph.edge_section_set_end(edge_section, target_px, target_py)

  let mut bends_num = random.int(limit=random_layout_provider_max_bends)
  bends_num = bends_num + 1
  let xdiff = target_px - source_px
  let ydiff = target_py - source_py
  let total_dist = (xdiff * xdiff + ydiff * ydiff).sqrt()
  let max_rand = total_dist * random_layout_provider_rand_fact
  let xincr = xdiff / (bends_num + 1).to_double()
  let yincr = ydiff / (bends_num + 1).to_double()
  let mut x = source_px
  let mut y = source_py

  // Current graph model has no bend point container on ElkEdgeSection, so we only consume
  // random values to preserve upstream randomization flow.
  for _ in 0..<bends_num {
    x = x + xincr
    y = y + yincr

    let mut randx = x + random.double() * max_rand - max_rand / 2.0
    if randx < 0.0 {
      randx = 1.0
    } else if randx > draw_width {
      randx = draw_width - 1.0
    }

    let mut randy = y + random.double() * max_rand - max_rand / 2.0
    if randy < 0.0 {
      randy = 1.0
    } else if randy > draw_height {
      randy = draw_height - 1.0
    }

    ignore(randx)
    ignore(randy)
  }
}

///|
fn random_layout_provider_randomize(
  parent : @graph.ElkNode,
  random : @random.Rand,
  aspect_ratio_value : Double,
  spacing_value : Double,
  padding_value : ElkPadding,
) -> Unit {
  let mut nodes_area = 0.0
  let mut max_width = 0.0
  let mut max_height = 0.0
  let mut m = 1
  let children = @graph.node_children(parent)

  for node in children {
    m = m + @graph.all_outgoing_edges(node).length()
    let width = @graph.node_width(node)
    max_width = random_layout_provider_max(max_width, width)
    let height = @graph.node_height(node)
    max_height = random_layout_provider_max(max_height, height)
    nodes_area = nodes_area + width * height
  }
  let n = children.length()

  let draw_area = nodes_area +
    2.0 * spacing_value * spacing_value * m.to_double() * n.to_double()
  let area_sqrt = draw_area.sqrt()
  let draw_width = random_layout_provider_max(
    area_sqrt * aspect_ratio_value,
    max_width,
  )
  let draw_height = random_layout_provider_max(
    area_sqrt / aspect_ratio_value,
    max_height,
  )

  for node in children {
    let x = padding_value.left +
      random.double() * (draw_width - @graph.node_width(node))
    let y = padding_value.left +
      random.double() * (draw_height - @graph.node_height(node))
    @graph.node_set_location(node, x, y)
  }

  let mut total_width = draw_width + padding_value.get_horizontal()
  let mut total_height = draw_height + padding_value.get_vertical()
  for source in children {
    for edge in @graph.all_outgoing_edges(source) {
      if !random_layout_provider_is_hierarchical(edge) {
        random_layout_provider_randomize_edge(
          edge, random, total_width, total_height,
        )
      }
    }
  }

  total_width = total_width + padding_value.left + padding_value.right
  total_height = total_height + padding_value.top + padding_value.bottom
  @graph.node_set_dimensions(parent, total_width, total_height)
}

///|
pub fn new_random_layout_provider() -> RandomLayoutProvider {
  { initialized: true }
}

///|
pub fn RandomLayoutProvider::layout(
  self : RandomLayoutProvider,
  parent_node : @graph.ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(self.initialized)
  ignore(progress_monitor.begin("Random Layout", 1.0))

  if @graph.node_children(parent_node).is_empty() {
    progress_monitor.done()
    return
  }

  let random = random_layout_provider_create_random(parent_node)
  let aspect_ratio_value = @graph.node_get_double_property(parent_node, aspect_ratio)
  let spacing_value = @graph.node_get_double_property(parent_node, spacing_node_node)
  let padding_value = random_layout_provider_parse_padding(parent_node)
  random_layout_provider_randomize(
    parent_node, random, aspect_ratio_value, spacing_value, padding_value,
  )

  progress_monitor.done()
}

///|
pub fn random_layout_provider_as_layout_provider(
  provider : RandomLayoutProvider,
) -> AbstractLayoutProvider {
  new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
