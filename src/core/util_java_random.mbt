///|
let java_random_multiplier = 25214903917L

///|
let java_random_addend = 11L

///|
let java_random_mask = 281474976710655L

///|
#derive(Debug, ToJson)
priv suberror JavaRandomException {
  JavaRandomException(String)
}

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
fn java_random_to_signed_int32(value : Int64) -> Int32 {
  let masked = value & 4294967295L
  if masked >= 2147483648L {
    (masked - 4294967296L).to_int()
  } else {
    masked.to_int()
  }
}

///|
fn java_random_system_seed() -> Int64 {
  let source = @random.Rand()
  let high = source.int(limit=@int.MAX_VALUE).to_int64()
  let low = source.int(limit=@int.MAX_VALUE).to_int64()
  (high << 31) ^ low
}

///|
pub struct JavaRandom {
  mut seed : Int64
}

///|
pub fn new_java_random() -> JavaRandom {
  { seed: java_random_scramble_seed(java_random_system_seed()), }
}

///|
pub fn new_java_random_seeded(seed : Int64) -> JavaRandom {
  { seed: java_random_scramble_seed(seed), }
}

///|
pub fn new_java_random_seeded_int(seed : Int32) -> JavaRandom {
  new_java_random_seeded(seed.to_int64())
}

///|
fn JavaRandom::next_bits(self : JavaRandom, bits : Int32) -> Int32 {
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
  let high = self.next_bits(26).to_int64()
  let low = self.next_bits(27).to_int64()
  ((high << 27) + low).to_double() / 9007199254740992.0
}

///|
pub fn JavaRandom::int(self : JavaRandom, limit : Int32) -> Int32 raise {
  if limit <= 0 {
    try java_random_raise_unit("bound must be positive") catch {
      err =>
        layout_runtime_raise_unsupported_configuration(
          java_random_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return 0
  }
  if (limit & -limit) == limit {
    let product = limit.to_int64() * self.next_bits(31).to_int64()
    return (product >> 31).to_int()
  }
  let mut bits = 0
  let mut value = 0
  while true {
    bits = self.next_bits(31)
    value = bits % limit
    let probe = java_random_to_signed_int32(
      bits.to_int64() - value.to_int64() + (limit - 1).to_int64(),
    )
    if probe >= 0 {
      return value
    }
  }
  0
}
