///|
pub(all) struct BPInfo {
  start : LNode
  end : LNode
  node_start_edge : LEdge
  start_end_edge : LEdge
  original_edge : LEdge
  mut start_in_layer_dummy : LNode?
  mut start_in_layer_edge : LEdge?
  mut end_in_layer_dummy : LNode?
  mut end_in_layer_edge : LEdge?
  mut prev : BPInfo?
  mut next : BPInfo?
}

///|
pub fn new_bp_info(
  start : LNode,
  end : LNode,
  node_start_edge : LEdge,
  start_end_edge : LEdge,
  original_edge : LEdge,
) -> BPInfo {
  {
    start,
    end,
    node_start_edge,
    start_end_edge,
    original_edge,
    start_in_layer_dummy: None,
    start_in_layer_edge: None,
    end_in_layer_dummy: None,
    end_in_layer_edge: None,
    prev: None,
    next: None,
  }
}

///|
pub fn BPInfo::set_start_in_layer_dummy(self : BPInfo, value : LNode?) -> Unit {
  self.start_in_layer_dummy = value
}

///|
pub fn BPInfo::set_start_in_layer_edge(self : BPInfo, value : LEdge?) -> Unit {
  self.start_in_layer_edge = value
}

///|
pub fn BPInfo::set_end_in_layer_dummy(self : BPInfo, value : LNode?) -> Unit {
  self.end_in_layer_dummy = value
}

///|
pub fn BPInfo::set_end_in_layer_edge(self : BPInfo, value : LEdge?) -> Unit {
  self.end_in_layer_edge = value
}

///|
pub fn BPInfo::set_prev(self : BPInfo, value : BPInfo?) -> Unit {
  self.prev = value
}

///|
pub fn BPInfo::set_next(self : BPInfo, value : BPInfo?) -> Unit {
  self.next = value
}
