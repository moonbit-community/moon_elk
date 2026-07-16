///|
pub type ElkLabel = Int

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
let label_store : Ref[Array[LabelData]] = Ref([])

///|
let label_next_handle : Ref[Int] = Ref(0)

///|
let label_free_slots : Ref[Array[Int]] = Ref([])

///|
let label_handle_slots : Ref[Map[Int, Int]] = Ref(Map([]))

///|
let label_slot_handles : Ref[Array[Int]] = Ref([])

///|
fn label_allocated_slot(label : ElkLabel) -> Int {
  match label_handle_slots.val.get(label) {
    Some(slot) => slot
    None => abort("invalid or disposed label id")
  }
}

///|
fn label_slot(label : ElkLabel) -> Int {
  let slot = label_allocated_slot(label)
  if label_arena_store.val[slot] < 0 {
    abort("invalid or disposed label id")
  }
  slot
}

///|
fn checked_label(label : ElkLabel) -> Unit {
  ignore(label_slot(label))
}

///|
let disposed_label_data : LabelData = {
  parent: None,
  identifier: "",
  text: "",
  x: 0.0,
  y: 0.0,
  width: 0.0,
  height: 0.0,
  layout_option_string_values: Map([]),
}

///|
fn dispose_label_slot(label : ElkLabel) -> Unit {
  let slot = label_slot(label)
  label_store.val[slot] = disposed_label_data
  label_arena_store.val[slot] = -1
  graph_handle_release(
    label,
    slot,
    label_handle_slots.val,
    label_slot_handles.val,
    label_free_slots.val,
  )
}

///|
fn create_label_in_arena(parent : ElkLabelParent?, arena_id : Int) -> ElkLabel {
  if parent is Some(label_parent) {
    match label_parent {
      NodeLabelParent(node) => checked_node(node)
      PortLabelParent(port) => checked_port(port)
      EdgeLabelParent(edge) => checked_edge(edge)
      LabelLabelParent(label) => checked_label(label)
    }
  }
  let slot = match label_free_slots.val.pop() {
    Some(reused) => reused
    None => {
      let fresh = label_store.val.length()
      label_store.val.push(disposed_label_data)
      label_arena_store.val.push(-1)
      label_slot_handles.val.push(-1)
      fresh
    }
  }
  let id = graph_handle_allocate(
    slot,
    label_next_handle,
    label_handle_slots.val,
    label_slot_handles.val,
  )
  label_store.val[slot] = {
    parent,
    identifier: "",
    text: "",
    x: 0.0,
    y: 0.0,
    width: 0.0,
    height: 0.0,
    layout_option_string_values: Map([]),
  }
  graph_arena_register_label(arena_id, id)
  id
}

///|
pub fn GraphArena::create_label(self : GraphArena) -> ElkLabel {
  checked_graph_arena(self)
  create_label_in_arena(None, self.id)
}

///|
pub fn create_label(parent : ElkLabelParent?) -> ElkLabel {
  match parent {
    Some(NodeLabelParent(node)) => {
      checked_node(node)
      create_label_in_arena(parent, node_arena_store.val[node_slot(node)])
    }
    Some(PortLabelParent(port)) => {
      checked_port(port)
      create_label_in_arena(parent, port_arena_store.val[port_slot(port)])
    }
    Some(EdgeLabelParent(edge)) => {
      checked_edge(edge)
      create_label_in_arena(parent, edge_arena_store.val[edge_slot(edge)])
    }
    Some(LabelLabelParent(label)) => {
      checked_label(label)
      create_label_in_arena(parent, label_arena_store.val[label_slot(label)])
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
  checked_label(label)
  let data = label_store.val[label_slot(label)]
  data.layout_option_string_values[option_id] = value
  label_store.val[label_slot(label)] = data
}

///|
pub fn label_layout_option_string_entries(
  label : ElkLabel,
) -> Array[(String, String)] {
  checked_label(label)
  label_store.val[label_slot(label)].layout_option_string_values.to_array()
}

///|
pub fn label_layout_option_string_value(
  label : ElkLabel,
  option_id : String,
) -> String? {
  checked_label(label)
  label_store.val[label_slot(label)].layout_option_string_values.get(option_id)
}

///|
pub fn label_set_identifier(label : ElkLabel, identifier : String) -> Unit {
  checked_label(label)
  let data = label_store.val[label_slot(label)]
  label_store.val[label_slot(label)] = {
    parent: data.parent,
    identifier,
    text: data.text,
    x: data.x,
    y: data.y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn label_identifier(label : ElkLabel) -> String {
  checked_label(label)
  label_store.val[label_slot(label)].identifier
}

///|
pub fn label_set_text(label : ElkLabel, text : String) -> Unit {
  checked_label(label)
  let data = label_store.val[label_slot(label)]
  label_store.val[label_slot(label)] = {
    parent: data.parent,
    identifier: data.identifier,
    text,
    x: data.x,
    y: data.y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn label_text(label : ElkLabel) -> String {
  checked_label(label)
  label_store.val[label_slot(label)].text
}

///|
pub fn label_set_location(label : ElkLabel, x : Double, y : Double) -> Unit {
  checked_label(label)
  let data = label_store.val[label_slot(label)]
  label_store.val[label_slot(label)] = {
    parent: data.parent,
    identifier: data.identifier,
    text: data.text,
    x,
    y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn label_x(label : ElkLabel) -> Double {
  checked_label(label)
  label_store.val[label_slot(label)].x
}

///|
pub fn label_y(label : ElkLabel) -> Double {
  checked_label(label)
  label_store.val[label_slot(label)].y
}

///|
pub fn label_set_dimensions(
  label : ElkLabel,
  width : Double,
  height : Double,
) -> Unit {
  checked_label(label)
  let data = label_store.val[label_slot(label)]
  label_store.val[label_slot(label)] = {
    parent: data.parent,
    identifier: data.identifier,
    text: data.text,
    x: data.x,
    y: data.y,
    width,
    height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn label_width(label : ElkLabel) -> Double {
  checked_label(label)
  label_store.val[label_slot(label)].width
}

///|
pub fn label_height(label : ElkLabel) -> Double {
  checked_label(label)
  label_store.val[label_slot(label)].height
}

///|
pub fn label_parent(label : ElkLabel) -> ElkLabelParent? {
  checked_label(label)
  label_store.val[label_slot(label)].parent
}

///|
pub fn node_labels(node : ElkNode) -> Array[ElkLabel] {
  checked_node(node)
  let labels = []
  for i = 0; i < label_store.val.length(); i = i + 1 {
    match label_store.val[i].parent {
      Some(NodeLabelParent(parent_node)) =>
        if parent_node == node {
          labels.push(label_slot_handles.val[i])
        }
      Some(_) => ()
      None => ()
    }
  }
  labels
}

///|
pub fn port_labels(port : ElkPort) -> Array[ElkLabel] {
  checked_port(port)
  let labels = []
  for i = 0; i < label_store.val.length(); i = i + 1 {
    match label_store.val[i].parent {
      Some(PortLabelParent(parent_port)) =>
        if parent_port == port {
          labels.push(label_slot_handles.val[i])
        }
      Some(_) => ()
      None => ()
    }
  }
  labels
}

///|
pub fn edge_labels(edge : ElkEdge) -> Array[ElkLabel] {
  checked_edge(edge)
  let labels = []
  for i = 0; i < label_store.val.length(); i = i + 1 {
    match label_store.val[i].parent {
      Some(EdgeLabelParent(parent_edge)) =>
        if parent_edge == edge {
          labels.push(label_slot_handles.val[i])
        }
      Some(_) => ()
      None => ()
    }
  }
  labels
}

///|
pub fn label_labels(parent : ElkLabel) -> Array[ElkLabel] {
  checked_label(parent)
  let labels = []
  for i = 0; i < label_store.val.length(); i = i + 1 {
    match label_store.val[i].parent {
      Some(LabelLabelParent(parent_label)) =>
        if parent_label == parent {
          labels.push(label_slot_handles.val[i])
        }
      Some(_) => ()
      None => ()
    }
  }
  labels
}
