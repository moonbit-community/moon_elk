///|
pub struct UniqueTriple[F, S, T] {
  first : F
  second : S
  third : T
}

///|
pub fn[F, S, T] unique_triple_of(
  first : F,
  second : S,
  third : T,
) -> UniqueTriple[F, S, T] {
  { first, second, third }
}

///|
pub fn[F, S, T] UniqueTriple::get_first(self : UniqueTriple[F, S, T]) -> F {
  self.first
}

///|
pub fn[F, S, T] UniqueTriple::get_second(self : UniqueTriple[F, S, T]) -> S {
  self.second
}

///|
pub fn[F, S, T] UniqueTriple::get_third(self : UniqueTriple[F, S, T]) -> T {
  self.third
}

///|
pub fn[F : Show, S : Show, T : Show] UniqueTriple::to_string(
  self : UniqueTriple[F, S, T],
) -> String {
  "(\{self.first.to_string()}, \{self.second.to_string()}, \{self.third.to_string()})"
}
