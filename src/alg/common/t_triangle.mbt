///|
fn fuzzy_compare(left : Double, right : Double, fuzziness : Double) -> Int {
  if (left - right).abs() <= fuzziness {
    0
  } else if left < right {
    -1
  } else {
    1
  }
}

///|
fn t_triangle_to_signed_int32(value : Int64) -> Int {
  let masked = value & 4294967295L
  if masked >= 2147483648L {
    (masked - 4294967296L).to_int()
  } else {
    masked.to_int()
  }
}

///|
let t_triangle_uid_counter : Ref[Int] = Ref::new(0)

///|
fn next_t_triangle_uid() -> Int {
  let uid = t_triangle_uid_counter.val
  t_triangle_uid_counter.val = uid + 1
  uid
}

///|
fn calculate_circumcenter(
  a : @core.KVector,
  b : @core.KVector,
  c : @core.KVector,
) -> @core.KVector {
  let ab = b.clone().sub(a)
  let ac = c.clone().sub(a)
  let bc = c.clone().sub(b)
  let e = ab.x * (a.x + b.x) + ab.y * (a.y + b.y)
  let f = ac.x * (a.x + c.x) + ac.y * (a.y + c.y)
  let g = 2.0 * (ab.x * bc.y - ab.y * bc.x)
  let px = (ac.y * e - ab.y * f) / g
  let py = (ab.x * f - ac.x * e) / g
  @core.new_kvector_xy(px, py)
}

///|
pub struct TTriangle {
  uid : Int
  a : @core.KVector
  b : @core.KVector
  c : @core.KVector
  t_edges : Array[TEdge]
  vertices : Array[@core.KVector]
  circumcenter : @core.KVector
}

///|
pub fn new_ttriangle(
  a : @core.KVector,
  b : @core.KVector,
  c : @core.KVector,
) -> TTriangle {
  {
    uid: next_t_triangle_uid(),
    a,
    b,
    c,
    t_edges: [new_tedge(a, b), new_tedge(b, c), new_tedge(c, a)],
    vertices: [a, b, c],
    circumcenter: calculate_circumcenter(a, b, c),
  }
}

///|
pub fn TTriangle::get_circumcenter(self : TTriangle) -> @core.KVector {
  self.circumcenter
}

///|
pub fn TTriangle::in_circumcircle(self : TTriangle, v : @core.KVector) -> Bool {
  fuzzy_compare(
    self.circumcenter.distance(v),
    self.circumcenter.distance(self.a),
    spore_fuzziness,
  ) <
  0
}

///|
pub fn TTriangle::equals(self : TTriangle, other : TTriangle) -> Bool {
  self.contains_vertex(other.a) &&
  self.contains_vertex(other.b) &&
  self.contains_vertex(other.c)
}

///|
pub fn TTriangle::hash_code(self : TTriangle) -> Int {
  t_triangle_to_signed_int32(
    Int64::from_int(self.a.hash_code()) +
    Int64::from_int(self.b.hash_code()) +
    Int64::from_int(self.c.hash_code()),
  )
}

///|
pub fn TTriangle::contains_edge(self : TTriangle, t_edge : TEdge) -> Bool {
  t_edge.equals(self.t_edges[0]) ||
  t_edge.equals(self.t_edges[1]) ||
  t_edge.equals(self.t_edges[2])
}

///|
pub fn TTriangle::contains_vertex(
  self : TTriangle,
  vertex : @core.KVector,
) -> Bool {
  vertex.equals(self.vertices[0]) ||
  vertex.equals(self.vertices[1]) ||
  vertex.equals(self.vertices[2])
}

///|
pub impl Eq for TTriangle with equal(self : TTriangle, other : TTriangle) -> Bool {
  self.equals(other)
}

///|
pub impl Hash for TTriangle with hash_combine(self : TTriangle, hasher) -> Unit {
  hasher.combine(self.hash_code())
}
