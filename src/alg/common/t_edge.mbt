///|
pub struct TEdge {
  u : @core.KVector
  v : @core.KVector
}

///|
fn t_edge_to_signed_int32(value : Int64) -> Int {
  let masked = value & 4294967295L
  if masked >= 2147483648L {
    (masked - 4294967296L).to_int()
  } else {
    masked.to_int()
  }
}

///|
pub fn new_tedge(u : @core.KVector, v : @core.KVector) -> TEdge {
  { u, v }
}

///|
pub fn TEdge::equals(self : TEdge, other : TEdge) -> Bool {
  (self.u.equals(other.u) && self.v.equals(other.v)) ||
  (self.u.equals(other.v) && self.v.equals(other.u))
}

///|
pub fn TEdge::hash_code(self : TEdge) -> Int {
  t_edge_to_signed_int32(
    Int64::from_int(self.u.hash_code()) + Int64::from_int(self.v.hash_code()),
  )
}

///|
pub impl Eq for TEdge with equal(self : TEdge, other : TEdge) -> Bool {
  self.equals(other)
}

///|
pub impl Hash for TEdge with hash_combine(self : TEdge, hasher) -> Unit {
  hasher.combine(self.hash_code())
}
