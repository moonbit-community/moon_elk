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
fn calculate_circumcenter(a : KVector, b : KVector, c : KVector) -> KVector {
  let ab = b.clone().sub(a)
  let ac = c.clone().sub(a)
  let bc = c.clone().sub(b)
  let e = ab.x * (a.x + b.x) + ab.y * (a.y + b.y)
  let f = ac.x * (a.x + c.x) + ac.y * (a.y + c.y)
  let g = 2.0 * (ab.x * bc.y - ab.y * bc.x)
  let px = (ac.y * e - ab.y * f) / g
  let py = (ab.x * f - ac.x * e) / g
  new_kvector_xy(px, py)
}

///|
pub struct TTriangle {
  a : KVector
  b : KVector
  c : KVector
  t_edges : Array[TEdge]
  vertices : Array[KVector]
  circumcenter : KVector
}

///|
pub fn new_ttriangle(a : KVector, b : KVector, c : KVector) -> TTriangle {
  {
    a,
    b,
    c,
    t_edges: [new_tedge(a, b), new_tedge(b, c), new_tedge(c, a)],
    vertices: [a, b, c],
    circumcenter: calculate_circumcenter(a, b, c),
  }
}

///|
pub fn TTriangle::get_circumcenter(self : TTriangle) -> KVector {
  self.circumcenter
}

///|
pub fn TTriangle::in_circumcircle(self : TTriangle, v : KVector) -> Bool {
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
  self.a.hash_code() + self.b.hash_code() + self.c.hash_code()
}

///|
pub fn TTriangle::contains_edge(self : TTriangle, t_edge : TEdge) -> Bool {
  t_edge.equals(self.t_edges[0]) ||
  t_edge.equals(self.t_edges[1]) ||
  t_edge.equals(self.t_edges[2])
}

///|
pub fn TTriangle::contains_vertex(self : TTriangle, vertex : KVector) -> Bool {
  vertex.equals(self.vertices[0]) ||
  vertex.equals(self.vertices[1]) ||
  vertex.equals(self.vertices[2])
}
