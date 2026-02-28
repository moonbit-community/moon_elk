///|
let java_random_multiplier = 25214903917L

///|
let java_random_addend = 11L

///|
let java_random_mask = 281474976710655L

///|
priv suberror JavaRandomException {
  JavaRandomException(String)
} derive(Show, ToJson)

///|
fn java_random_raise_unit(message : String) -> Unit raise JavaRandomException {
  raise JavaRandomException(message)
}

///|
fn java_random_exception_message(err : JavaRandomException) -> String {
  match err {
    JavaRandomException(message) => message
  }
}

///|
fn java_random_scramble_seed(seed : Int64) -> Int64 {
  (seed ^ java_random_multiplier) & java_random_mask
}

///|
fn java_random_to_signed_int32(value : Int64) -> Int {
  let masked = value & 4294967295L
  if masked >= 2147483648L {
    (masked - 4294967296L).to_int()
  } else {
    masked.to_int()
  }
}

///|
fn java_random_system_seed() -> Int64 {
  let source = @random.Rand::new()
  let high = Int64::from_int(source.int(limit=@int.max_value))
  let low = Int64::from_int(source.int(limit=@int.max_value))
  (high << 31) ^ low
}

///|
pub struct JavaRandom {
  mut seed : Int64
}

///|
pub fn new_java_random() -> JavaRandom {
  { seed: java_random_scramble_seed(java_random_system_seed()) }
}

///|
pub fn new_java_random_seeded(seed : Int64) -> JavaRandom {
  { seed: java_random_scramble_seed(seed) }
}

///|
pub fn new_java_random_seeded_int(seed : Int) -> JavaRandom {
  new_java_random_seeded(Int64::from_int(seed))
}

///|
fn JavaRandom::next_bits(self : JavaRandom, bits : Int) -> Int {
  self.seed = (self.seed * java_random_multiplier + java_random_addend) &
    java_random_mask
  let value = self.seed >> (48 - bits)
  if bits == 32 && value >= 2147483648L {
    (value - 4294967296L).to_int()
  } else {
    value.to_int()
  }
}

///|
pub fn JavaRandom::double(self : JavaRandom) -> Double {
  let high = Int64::from_int(self.next_bits(26))
  let low = Int64::from_int(self.next_bits(27))
  ((high << 27) + low).to_double() / 9007199254740992.0
}

///|
pub fn JavaRandom::int(self : JavaRandom, limit : Int) -> Int {
  if limit <= 0 {
    try java_random_raise_unit("bound must be positive") catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          java_random_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return 0
  }
  if (limit & -limit) == limit {
    let product = Int64::from_int(limit) * Int64::from_int(self.next_bits(31))
    return (product >> 31).to_int()
  }
  let mut bits = 0
  let mut value = 0
  while true {
    bits = self.next_bits(31)
    value = bits % limit
    let probe = java_random_to_signed_int32(
      Int64::from_int(bits) -
      Int64::from_int(value) +
      Int64::from_int(limit - 1),
    )
    if probe >= 0 {
      return value
    }
  }
  0
}
