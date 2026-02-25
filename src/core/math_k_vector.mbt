///|
pub(all) struct KVector {
  mut x : Double
  mut y : Double
}

///|
let default_fuzzyness = 0.05

///|
pub fn new_kvector() -> KVector {
  { x: 0.0, y: 0.0 }
}

///|
pub fn new_kvector_xy(thex : Double, they : Double) -> KVector {
  { x: thex, y: they }
}

///|
pub fn new_kvector_copy(v : KVector) -> KVector {
  { x: v.x, y: v.y }
}

///|
pub fn new_kvector_between(start : KVector, end : KVector) -> KVector {
  { x: end.x - start.x, y: end.y - start.y }
}

///|
pub fn new_kvector_angle(angle : Double) -> KVector {
  { x: @math.cos(angle), y: @math.sin(angle) }
}

///|
pub fn KVector::clone(self : KVector) -> KVector {
  new_kvector_xy(self.x, self.y)
}

///|
pub fn KVector::to_string(self : KVector) -> String {
  "(\{self.x},\{self.y})"
}

///|
pub fn KVector::equals(self : KVector, other : KVector) -> Bool {
  self.x == other.x && self.y == other.y
}

///|
pub fn KVector::equals_fuzzily(
  self : KVector,
  other : KVector,
  fuzzyness? : Double = default_fuzzyness,
) -> Bool {
  (self.x - other.x).abs() <= fuzzyness && (self.y - other.y).abs() <= fuzzyness
}

///|
fn kvector_to_signed_int32(value : Int64) -> Int {
  let masked = value & 4294967295L
  if masked >= 2147483648L {
    (masked - 4294967296L).to_int()
  } else {
    masked.to_int()
  }
}

///|
fn kvector_java_double_hash(value : Double) -> Int {
  let bits = value.reinterpret_as_int64()
  let mixed = bits ^ (bits >> 32)
  kvector_to_signed_int32(mixed)
}

///|
fn kvector_reverse_bits32(value : Int) -> Int {
  let mut x = Int64::from_int(value) & 4294967295L
  x = ((x & 1431655765L) << 1) | ((x >> 1) & 1431655765L)
  x = ((x & 858993459L) << 2) | ((x >> 2) & 858993459L)
  x = ((x & 252645135L) << 4) | ((x >> 4) & 252645135L)
  x = ((x & 16711935L) << 8) | ((x >> 8) & 16711935L)
  x = (x << 16) | (x >> 16)
  kvector_to_signed_int32(x)
}

///|
pub fn KVector::hash_code(self : KVector) -> Int {
  let x_hash = kvector_java_double_hash(self.x)
  let y_hash = kvector_java_double_hash(self.y)
  kvector_to_signed_int32(
    Int64::from_int(x_hash) + Int64::from_int(kvector_reverse_bits32(y_hash)),
  )
}

///|
pub impl Eq for KVector with equal(self : KVector, other : KVector) -> Bool {
  self.equals(other)
}

///|
pub impl Hash for KVector with hash_combine(self : KVector, hasher) -> Unit {
  hasher.combine(self.hash_code())
}

///|
pub fn KVector::length(self : KVector) -> Double {
  (self.x * self.x + self.y * self.y).sqrt()
}

///|
pub fn KVector::square_length(self : KVector) -> Double {
  self.x * self.x + self.y * self.y
}

///|
pub fn KVector::reset(self : KVector) -> KVector {
  self.x = 0.0
  self.y = 0.0
  self
}

///|
pub fn KVector::set(self : KVector, other : KVector) -> KVector {
  self.x = other.x
  self.y = other.y
  self
}

///|
pub fn KVector::set_xy(
  self : KVector,
  new_x : Double,
  new_y : Double,
) -> KVector {
  self.x = new_x
  self.y = new_y
  self
}

///|
pub fn KVector::add(self : KVector, v : KVector) -> KVector {
  self.x = self.x + v.x
  self.y = self.y + v.y
  self
}

///|
pub fn KVector::add_xy(self : KVector, dx : Double, dy : Double) -> KVector {
  self.x = self.x + dx
  self.y = self.y + dy
  self
}

///|
pub fn kvector_sum(vs : Array[KVector]) -> KVector {
  let sum = new_kvector()
  for v in vs {
    sum.x = sum.x + v.x
    sum.y = sum.y + v.y
  }
  sum
}

///|
pub fn KVector::sub(self : KVector, v : KVector) -> KVector {
  self.x = self.x - v.x
  self.y = self.y - v.y
  self
}

///|
pub fn KVector::sub_xy(self : KVector, dx : Double, dy : Double) -> KVector {
  self.x = self.x - dx
  self.y = self.y - dy
  self
}

///|
pub fn kvector_diff(v1 : KVector, v2 : KVector) -> KVector {
  new_kvector_xy(v1.x - v2.x, v1.y - v2.y)
}

///|
pub fn KVector::scale(self : KVector, scale : Double) -> KVector {
  self.x = self.x * scale
  self.y = self.y * scale
  self
}

///|
pub fn KVector::scale_xy(
  self : KVector,
  scalex : Double,
  scaley : Double,
) -> KVector {
  self.x = self.x * scalex
  self.y = self.y * scaley
  self
}

///|
pub fn KVector::normalize(self : KVector) -> KVector {
  let len = self.length()
  if len > 0.0 {
    self.x = self.x / len
    self.y = self.y / len
  }
  self
}

///|
pub fn KVector::scale_to_length(self : KVector, length : Double) -> KVector {
  ignore(self.normalize())
  ignore(self.scale(length))
  self
}

///|
pub fn KVector::negate(self : KVector) -> KVector {
  self.x = -self.x
  self.y = -self.y
  self
}

///|
pub fn KVector::to_degrees(self : KVector) -> Double {
  self.to_radians() * 180.0 / @math.PI
}

///|
pub fn KVector::to_radians(self : KVector) -> Double {
  let len = self.length()
  if len <= 0.0 {
    abort("The length of the vector must not be 0")
  }
  if self.x >= 0.0 && self.y >= 0.0 {
    @math.asin(self.y / len)
  } else if self.x < 0.0 {
    @math.PI - @math.asin(self.y / len)
  } else {
    2.0 * @math.PI + @math.asin(self.y / len)
  }
}

///|
pub fn KVector::wiggle(
  self : KVector,
  random : @random.Rand,
  amount : Double,
) -> Unit {
  self.x = self.x + random.double() * amount - amount / 2.0
  self.y = self.y + random.double() * amount - amount / 2.0
}

///|
pub fn KVector::distance(self : KVector, v2 : KVector) -> Double {
  let dx = self.x - v2.x
  let dy = self.y - v2.y
  (dx * dx + dy * dy).sqrt()
}

///|
pub fn KVector::dot_product(self : KVector, v2 : KVector) -> Double {
  self.x * v2.x + self.y * v2.y
}

///|
pub fn kvector_cross_product(v : KVector, w : KVector) -> Double {
  v.x * w.y - v.y * w.x
}

///|
pub fn KVector::rotate(self : KVector, angle : Double) -> KVector {
  let new_x = self.x * @math.cos(angle) - self.y * @math.sin(angle)
  self.y = self.x * @math.sin(angle) + self.y * @math.cos(angle)
  self.x = new_x
  self
}

///|
pub fn KVector::angle(self : KVector, other : KVector) -> Double {
  @math.acos(self.dot_product(other) / (self.length() * other.length()))
}

///|
pub fn KVector::bound(
  self : KVector,
  lowx : Double,
  lowy : Double,
  highx : Double,
  highy : Double,
) -> KVector {
  if highx < lowx || highy < lowy {
    abort(
      "The highx must be bigger then lowx and the highy must be bigger then lowy",
    )
  }
  if self.x < lowx {
    self.x = lowx
  } else if self.x > highx {
    self.x = highx
  }
  if self.y < lowy {
    self.y = lowy
  } else if self.y > highy {
    self.y = highy
  }
  self
}

///|
pub fn KVector::is_nan(self : KVector) -> Bool {
  self.x.is_nan() || self.y.is_nan()
}

///|
pub fn KVector::is_infinite(self : KVector) -> Bool {
  self.x.is_inf() || self.y.is_inf()
}

///|
pub fn KVector::parse(self : KVector, string : String) -> Unit {
  let (start, end) = _trim_delim_bounds(
    string, "([{\"' \t\r\n", ")]}\"' \t\r\n",
  )
  if start >= end {
    abort("The given string does not contain any numbers.")
  }
  let body = _substring_chars(string, start, end)
  let tokens = _split_by_any_delims_drop_trailing_empty(body, ",;\r\n")
  if tokens.length() != 2 {
    abort("Exactly two numbers are expected, \{tokens.length()} were found.")
  }
  self.x = _parse_double_or_abort(
    tokens[0],
    "The given string contains parts that cannot be parsed as numbers.",
  )
  self.y = _parse_double_or_abort(
    tokens[1],
    "The given string contains parts that cannot be parsed as numbers.",
  )
}
