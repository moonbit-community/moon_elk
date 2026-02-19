///|
pub struct TEdge {
  u : KVector
  v : KVector
}

///|
pub fn new_tedge(u : KVector, v : KVector) -> TEdge {
  { u, v }
}

///|
pub fn TEdge::equals(self : TEdge, other : TEdge) -> Bool {
  (self.u.equals(other.u) && self.v.equals(other.v)) ||
  (self.u.equals(other.v) && self.v.equals(other.u))
}

///|
pub fn TEdge::hash_code(self : TEdge) -> Int {
  self.u.hash_code() + self.v.hash_code()
}
