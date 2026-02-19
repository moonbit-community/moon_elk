///|
pub(all) struct Triple[F, S, T] {
  first : F
  second : S
  third : T
}

///|
pub fn[F, S, T] triple_of(first : F, second : S, third : T) -> Triple[F, S, T] {
  { first, second, third }
}

///|
pub fn[F, S, T] Triple::get_first(self : Triple[F, S, T]) -> F {
  self.first
}

///|
pub fn[F, S, T] Triple::get_second(self : Triple[F, S, T]) -> S {
  self.second
}

///|
pub fn[F, S, T] Triple::get_third(self : Triple[F, S, T]) -> T {
  self.third
}

///|
pub fn[F : Eq, S : Eq, T : Eq] Triple::equals(
  self : Triple[F, S, T],
  other : Triple[F, S, T],
) -> Bool {
  self.first == other.first &&
  self.second == other.second &&
  self.third == other.third
}

///|
pub fn[F : Hash, S : Hash, T : Hash] Triple::hash_code(
  self : Triple[F, S, T],
) -> Int {
  self.first.hash() ^ self.second.hash() ^ self.third.hash()
}

///|
pub fn[F : Show, S : Show, T : Show] Triple::to_string(
  self : Triple[F, S, T],
) -> String {
  "(\{self.first.to_string()}, \{self.second.to_string()}, \{self.third.to_string()})"
}
