///|
pub struct JavaTEdgeSet {
  mut values : @set.Set[TEdge]
}

///|
pub fn new_java_tedge_set() -> JavaTEdgeSet {
  { values: @set.Set([]) }
}

///|
pub fn JavaTEdgeSet::contains(self : JavaTEdgeSet, edge : TEdge) -> Bool {
  self.values.contains(edge)
}

///|
pub fn JavaTEdgeSet::add(self : JavaTEdgeSet, edge : TEdge) -> Bool {
  if self.values.contains(edge) {
    false
  } else {
    self.values.add(edge)
    true
  }
}

///|
pub fn JavaTEdgeSet::remove(self : JavaTEdgeSet, edge : TEdge) -> Bool {
  if self.values.contains(edge) {
    self.values.remove(edge)
    true
  } else {
    false
  }
}

///|
pub fn JavaTEdgeSet::clear(self : JavaTEdgeSet) -> Unit {
  self.values = @set.Set([])
}

///|
pub fn JavaTEdgeSet::is_empty(self : JavaTEdgeSet) -> Bool {
  self.values.is_empty()
}

///|
pub fn JavaTEdgeSet::to_array(self : JavaTEdgeSet) -> Array[TEdge] {
  self.values.to_array()
}
