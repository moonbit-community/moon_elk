///|
/// Compact identity used for property lookup inside graph and algorithm data.
///
/// The external string is fingerprinted once when a property descriptor is
/// created. Two independent hashes make accidental identity collisions
/// negligible without introducing a process-global string interning registry.
pub struct PropertyId {
  priv first : Int
  priv second : Int
} derive(Eq, Hash, Debug)

///|
pub type OptionId = PropertyId

///|
fn property_id_hash(text : String, base : Int64, modulus : Int64) -> Int {
  let mut hash = 0L
  for index in 0..<text.length() {
    let code_unit = Int64::from_int(text[index].to_int() + 1)
    hash = (hash * base + code_unit) % modulus
  }
  hash.to_int()
}

///|
pub fn property_id_from_string(id : String) -> PropertyId {
  {
    first: property_id_hash(id, 257L, 2147483647L),
    second: property_id_hash(id, 263L, 2147483629L),
  }
}

///|
pub fn option_id_from_string(id : String) -> OptionId {
  property_id_from_string(id)
}
