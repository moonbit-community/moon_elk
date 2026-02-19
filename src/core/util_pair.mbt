///|
pub(all) struct Pair[F, S] {
  mut first : F?
  mut second : S?
}

///|
pub fn[F, S] pair_create() -> Pair[F, S] {
  { first: None, second: None }
}

///|
pub fn[F, S] pair_of(first : F, second : S) -> Pair[F, S] {
  { first: Some(first), second: Some(second) }
}

///|
pub fn[F, S] Pair::set_first(self : Pair[F, S], first : F?) -> Unit {
  self.first = first
}

///|
pub fn[F, S] Pair::get_first(self : Pair[F, S]) -> F? {
  self.first
}

///|
pub fn[F, S] Pair::set_second(self : Pair[F, S], second : S?) -> Unit {
  self.second = second
}

///|
pub fn[F, S] Pair::get_second(self : Pair[F, S]) -> S? {
  self.second
}

///|
pub fn[F, S] Pair::clear(self : Pair[F, S]) -> Unit {
  self.first = None
  self.second = None
}

///|
pub fn[F : Eq, S : Eq] Pair::equals(
  self : Pair[F, S],
  other : Pair[F, S],
) -> Bool {
  self.first == other.first && self.second == other.second
}

///|
pub fn[F : Hash, S : Hash] Pair::hash_code(self : Pair[F, S]) -> Int {
  let first_code = self.first.hash()
  let second_code = self.second.hash()
  let half_word = 16
  let mask1 = (1 << half_word) - 1
  let mask2 = -1 ^ mask1
  let first1 = first_code & mask1
  let first2 = first_code & mask2
  let second1 = second_code & mask1
  let second2 = second_code & mask2
  (first1 ^ ((second2 >> half_word) & mask1)) |
  (first2 ^ (second1 << half_word))
}

///|
pub fn[F : Show, S : Show] Pair::to_string(self : Pair[F, S]) -> String {
  match (self.first, self.second) {
    (None, None) => "pair(null,null)"
    (None, Some(second)) => "pair(null,\{second.to_string()})"
    (Some(first), None) => "pair(\{first.to_string()},null)"
    (Some(first), Some(second)) =>
      "pair(\{first.to_string()},\{second.to_string()})"
  }
}
