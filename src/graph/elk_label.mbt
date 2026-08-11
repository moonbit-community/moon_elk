///|
pub struct ElkLabel {
  priv mut arena : GraphArena
  priv mut slot : Int
  priv mut generation : Int
  priv id : Int
}

///|
pub impl Eq for ElkLabel with fn equal(self, other) {
  physical_equal(self, other)
}

///|
pub impl Hash for ElkLabel with fn hash(self) {
  self.id
}

///|
pub impl Hash for ElkLabel with fn hash_combine(self, hasher) {
  hasher.combine_int(self.id)
}

///|
pub impl @debug.Debug for ElkLabel with fn to_repr(self) {
  Repr(self.id)
}

///|
pub impl Show for ElkLabel with fn output(self, logger) {
  logger.write_string(self.id.to_string())
}

///|
pub enum ElkLabelParent {
  NodeLabelParent(ElkNode)
  PortLabelParent(ElkPort)
  EdgeLabelParent(ElkEdge)
  LabelLabelParent(ElkLabel)
}

///|
pub fn make_node_label_parent(node : ElkNode) -> ElkLabelParent {
  NodeLabelParent(node)
}

///|
pub fn make_port_label_parent(port : ElkPort) -> ElkLabelParent {
  PortLabelParent(port)
}

///|
pub fn make_edge_label_parent(edge : ElkEdge) -> ElkLabelParent {
  EdgeLabelParent(edge)
}

///|
pub fn make_label_label_parent(label : ElkLabel) -> ElkLabelParent {
  LabelLabelParent(label)
}

///|
priv struct LabelData {
  parent : ElkLabelParent?
  identifier : String
  text : String
  x : Double
  y : Double
  width : Double
  height : Double
  layout_option_string_values : Map[String, String]
}

///|
priv struct LabelSlot {
  mut generation : Int
  handle : ElkLabel
  mut data : LabelData?
}

///|
fn checked_label_slot(label : ElkLabel) -> LabelSlot {
  let arena = label.arena
  checked_graph_arena(arena)
  if label.slot < 0 || label.slot >= arena.labels.length() {
    abort("invalid or disposed label id")
  }
  let slot = arena.labels[label.slot]
  if slot.generation != label.generation || slot.data is None {
    abort("invalid or disposed label id")
  }
  slot
}

///|
fn checked_label(label : ElkLabel) -> Unit {
  ignore(checked_label_slot(label))
}

///|
fn label_data(label : ElkLabel) -> LabelData {
  match checked_label_slot(label).data {
    Some(data) => data
    None => abort("invalid or disposed label id")
  }
}

///|
fn set_label_data(label : ElkLabel, data : LabelData) -> Unit {
  checked_label_slot(label).data = Some(data)
}

///|
fn label_graph_arena(label : ElkLabel) -> GraphArena {
  checked_label(label)
  label.arena
}

///|
pub fn ElkLabel::graph_arena(self : ElkLabel) -> GraphArena {
  label_graph_arena(self)
}

///|
fn dispose_label_slot(label : ElkLabel) -> Unit {
  let slot = checked_label_slot(label)
  slot.data = None
  slot.generation += 1
}

///|
fn create_label_in_arena(
  parent : ElkLabelParent?,
  arena : GraphArena,
) -> ElkLabel {
  if parent is Some(label_parent) {
    match label_parent {
      NodeLabelParent(node) => checked_node(node)
      PortLabelParent(port) => checked_port(port)
      EdgeLabelParent(edge) => checked_edge(edge)
      LabelLabelParent(label) => checked_label(label)
    }
  }
  checked_graph_arena(arena)
  let slot = arena.labels.length()
  let label : ElkLabel = {
    arena,
    slot,
    generation: 0,
    id: arena.allocate_object_id(),
  }
  arena.labels.push({
    generation: 0,
    handle: label,
    data: Some({
      parent,
      identifier: "",
      text: "",
      x: 0.0,
      y: 0.0,
      width: 0.0,
      height: 0.0,
      layout_option_string_values: Map([]),
    }),
  })
  label
}

///|
pub fn GraphArena::create_label(self : GraphArena) -> ElkLabel {
  checked_graph_arena(self)
  create_label_in_arena(None, self)
}

///|
pub fn create_label(parent : ElkLabelParent?) -> ElkLabel {
  match parent {
    Some(NodeLabelParent(node)) => {
      checked_node(node)
      create_label_in_arena(parent, node_graph_arena(node))
    }
    Some(PortLabelParent(port)) => {
      checked_port(port)
      create_label_in_arena(parent, port_graph_arena(port))
    }
    Some(EdgeLabelParent(edge)) => {
      checked_edge(edge)
      create_label_in_arena(parent, edge_graph_arena(edge))
    }
    Some(LabelLabelParent(label)) => {
      checked_label(label)
      create_label_in_arena(parent, label_graph_arena(label))
    }
    None => new_graph_arena().create_label()
  }
}

///|
pub fn label_set_layout_option_string_by_id(
  label : ElkLabel,
  option_id : String,
  value : String,
) -> Unit {
  let data = label_data(label)
  data.layout_option_string_values[option_id] = value
  set_label_data(label, data)
}

///|
pub fn label_layout_option_string_entries(
  label : ElkLabel,
) -> Array[(String, String)] {
  label_data(label).layout_option_string_values.to_array()
}

///|
pub fn label_layout_option_string_value(
  label : ElkLabel,
  option_id : String,
) -> String? {
  label_data(label).layout_option_string_values.get(option_id)
}

///|
pub fn label_set_identifier(label : ElkLabel, identifier : String) -> Unit {
  let data = label_data(label)
  set_label_data(label, {
    parent: data.parent,
    identifier,
    text: data.text,
    x: data.x,
    y: data.y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn label_identifier(label : ElkLabel) -> String {
  label_data(label).identifier
}

///|
pub fn label_set_text(label : ElkLabel, text : String) -> Unit {
  let data = label_data(label)
  set_label_data(label, {
    parent: data.parent,
    identifier: data.identifier,
    text,
    x: data.x,
    y: data.y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn label_text(label : ElkLabel) -> String {
  label_data(label).text
}

///|
pub fn label_set_location(label : ElkLabel, x : Double, y : Double) -> Unit {
  let data = label_data(label)
  set_label_data(label, {
    parent: data.parent,
    identifier: data.identifier,
    text: data.text,
    x,
    y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn label_x(label : ElkLabel) -> Double {
  label_data(label).x
}

///|
pub fn label_y(label : ElkLabel) -> Double {
  label_data(label).y
}

///|
pub fn label_set_dimensions(
  label : ElkLabel,
  width : Double,
  height : Double,
) -> Unit {
  let data = label_data(label)
  set_label_data(label, {
    parent: data.parent,
    identifier: data.identifier,
    text: data.text,
    x: data.x,
    y: data.y,
    width,
    height,
    layout_option_string_values: data.layout_option_string_values,
  })
}

///|
pub fn label_width(label : ElkLabel) -> Double {
  label_data(label).width
}

///|
pub fn label_height(label : ElkLabel) -> Double {
  label_data(label).height
}

///|
pub fn label_parent(label : ElkLabel) -> ElkLabelParent? {
  label_data(label).parent
}

///|
pub fn node_labels(node : ElkNode) -> Array[ElkLabel] {
  let labels = []
  for slot in node_graph_arena(node).labels {
    if slot.data is None {
      continue
    }
    let label = slot.handle
    match label_data(label).parent {
      Some(NodeLabelParent(parent_node)) =>
        if parent_node == node {
          labels.push(label)
        }
      Some(_) => ()
      None => ()
    }
  }
  labels
}

///|
pub fn port_labels(port : ElkPort) -> Array[ElkLabel] {
  let labels = []
  for slot in port_graph_arena(port).labels {
    if slot.data is None {
      continue
    }
    let label = slot.handle
    match label_data(label).parent {
      Some(PortLabelParent(parent_port)) =>
        if parent_port == port {
          labels.push(label)
        }
      Some(_) => ()
      None => ()
    }
  }
  labels
}

///|
pub fn edge_labels(edge : ElkEdge) -> Array[ElkLabel] {
  let labels = []
  for slot in edge_graph_arena(edge).labels {
    if slot.data is None {
      continue
    }
    let label = slot.handle
    match label_data(label).parent {
      Some(EdgeLabelParent(parent_edge)) =>
        if parent_edge == edge {
          labels.push(label)
        }
      Some(_) => ()
      None => ()
    }
  }
  labels
}

///|
pub fn label_labels(parent : ElkLabel) -> Array[ElkLabel] {
  let labels = []
  for slot in label_graph_arena(parent).labels {
    if slot.data is None {
      continue
    }
    let label = slot.handle
    match label_data(label).parent {
      Some(LabelLabelParent(parent_label)) =>
        if parent_label == parent {
          labels.push(label)
        }
      Some(_) => ()
      None => ()
    }
  }
  labels
}
