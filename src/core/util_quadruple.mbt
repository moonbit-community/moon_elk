///|
pub(all) struct Quadruple[A, B, C, D] {
  first : A
  second : B
  third : C
  fourth : D
}

///|
pub fn[A, B, C, D] quadruple_of(
  first : A,
  second : B,
  third : C,
  fourth : D,
) -> Quadruple[A, B, C, D] {
  { first, second, third, fourth }
}

///|
pub fn[A, B, C, D] Quadruple::get_first(self : Quadruple[A, B, C, D]) -> A {
  self.first
}

///|
pub fn[A, B, C, D] Quadruple::get_second(self : Quadruple[A, B, C, D]) -> B {
  self.second
}

///|
pub fn[A, B, C, D] Quadruple::get_third(self : Quadruple[A, B, C, D]) -> C {
  self.third
}

///|
pub fn[A, B, C, D] Quadruple::get_fourth(self : Quadruple[A, B, C, D]) -> D {
  self.fourth
}

///|
pub fn[A : Eq, B : Eq, C : Eq, D : Eq] Quadruple::equals(
  self : Quadruple[A, B, C, D],
  other : Quadruple[A, B, C, D],
) -> Bool {
  self.first == other.first &&
  self.second == other.second &&
  self.third == other.third &&
  self.fourth == other.fourth
}

///|
pub fn[A : Hash, B : Hash, C : Hash, D : Hash] Quadruple::hash_code(
  self : Quadruple[A, B, C, D],
) -> Int {
  self.first.hash() ^
  self.second.hash() ^
  self.third.hash() ^
  self.fourth.hash()
}

///|
pub fn[A : Show, B : Show, C : Show, D : Show] Quadruple::to_string(
  self : Quadruple[A, B, C, D],
) -> String {
  "(\{self.first.to_string()}, \{self.second.to_string()}, \{self.third.to_string()}, \{self.fourth.to_string()})"
}
