///|
pub struct GreedySwitchMockRandom {
  mut seed : Int64
  mut use_mock_sequence : Bool
  mut current : Double
  mut change_by : Double
  mut next_boolean_override : Bool?
}

///|
let greedy_switch_mock_random_multiplier = 25214903917L

///|
let greedy_switch_mock_random_addend = 11L

///|
let greedy_switch_mock_random_mask = 281474976710655L

///|
fn greedy_switch_mock_random_scramble_seed(seed : Int64) -> Int64 {
  (seed ^ greedy_switch_mock_random_multiplier) & greedy_switch_mock_random_mask
}

///|
fn greedy_switch_mock_random_to_signed_int32(value : Int64) -> Int {
  let masked = value & 4294967295L
  if masked >= 2147483648L {
    (masked - 4294967296L).to_int()
  } else {
    masked.to_int()
  }
}

///|
fn greedy_switch_mock_random_system_seed() -> Int64 {
  let source = @random.Rand::new()
  let high = Int64::from_int(source.int(limit=@int.MAX_VALUE))
  let low = Int64::from_int(source.int(limit=@int.MAX_VALUE))
  (high << 31) ^ low
}

///|
pub fn new_greedy_switch_mock_random() -> GreedySwitchMockRandom {
  {
    seed: greedy_switch_mock_random_scramble_seed(
      greedy_switch_mock_random_system_seed(),
    ),
    use_mock_sequence: true,
    current: 0.01,
    change_by: 0.01,
    next_boolean_override: Some(true),
  }
}

///|
pub fn new_greedy_switch_mock_random_seeded(
  seed_value : Int,
) -> GreedySwitchMockRandom {
  {
    seed: greedy_switch_mock_random_scramble_seed(Int64::from_int(seed_value)),
    use_mock_sequence: false,
    current: 0.01,
    change_by: 0.01,
    next_boolean_override: None,
  }
}

///|
pub fn new_greedy_switch_mock_random_seeded_int64(
  seed_value : Int64,
) -> GreedySwitchMockRandom {
  {
    seed: greedy_switch_mock_random_scramble_seed(seed_value),
    use_mock_sequence: false,
    current: 0.01,
    change_by: 0.01,
    next_boolean_override: None,
  }
}

///|
fn GreedySwitchMockRandom::next_bits(
  self : GreedySwitchMockRandom,
  bits : Int,
) -> Int {
  self.seed = (
      self.seed * greedy_switch_mock_random_multiplier +
      greedy_switch_mock_random_addend
    ) &
    greedy_switch_mock_random_mask

  let value = self.seed >> (48 - bits)
  if bits == 32 && value >= 2147483648L {
    (value - 4294967296L).to_int()
  } else {
    value.to_int()
  }
}

///|
pub fn GreedySwitchMockRandom::next_boolean(
  self : GreedySwitchMockRandom,
) -> Bool {
  if self.next_boolean_override is Some(next_boolean) {
    next_boolean
  } else {
    self.next_bits(1) != 0
  }
}

///|
pub fn GreedySwitchMockRandom::next_float(
  self : GreedySwitchMockRandom,
) -> Float {
  if self.use_mock_sequence {
    self.current = self.current + self.change_by
    Float::from_double(self.current)
  } else {
    Float::from_double(self.next_bits(24).to_double() / 16777216.0)
  }
}

///|
pub fn GreedySwitchMockRandom::next_double(
  self : GreedySwitchMockRandom,
) -> Double {
  if self.use_mock_sequence {
    self.current = self.current + self.change_by
    self.current
  } else {
    let high = Int64::from_int(self.next_bits(26))
    let low = Int64::from_int(self.next_bits(27))
    ((high << 27) + low).to_double() / 9007199254740992.0
  }
}

///|
pub fn GreedySwitchMockRandom::next_int(
  self : GreedySwitchMockRandom,
  limit : Int,
) -> Int {
  if limit <= 0 {
    @core.layout_runtime_report_unsupported_configuration(
      "limit must be positive",
    )
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
    let probe = greedy_switch_mock_random_to_signed_int32(
      Int64::from_int(bits) -
      Int64::from_int(value) +
      Int64::from_int(limit - 1),
    )
    if probe >= 0 {
      return value
    }
  }
  @core.layout_runtime_report_unsupported_configuration("unreachable")
  0
}

///|
pub fn GreedySwitchMockRandom::int(
  self : GreedySwitchMockRandom,
  limit : Int,
) -> Int {
  self.next_int(limit)
}

///|
pub fn GreedySwitchMockRandom::next_long(
  self : GreedySwitchMockRandom,
) -> Int64 {
  (Int64::from_int(self.next_bits(32)) << 32) +
  Int64::from_int(self.next_bits(32))
}

///|
pub fn GreedySwitchMockRandom::set_seed(
  self : GreedySwitchMockRandom,
  seed : Int64,
) -> Unit {
  self.seed = greedy_switch_mock_random_scramble_seed(seed)
}

///|
pub fn GreedySwitchMockRandom::set_seed_int(
  self : GreedySwitchMockRandom,
  seed : Int,
) -> Unit {
  self.set_seed(Int64::from_int(seed))
}

///|
pub fn GreedySwitchMockRandom::set_next_boolean(
  self : GreedySwitchMockRandom,
  next_boolean : Bool,
) -> Unit {
  self.next_boolean_override = Some(next_boolean)
}

///|
pub fn GreedySwitchMockRandom::clear_next_boolean_override(
  self : GreedySwitchMockRandom,
) -> Unit {
  self.next_boolean_override = None
}

///|
pub fn GreedySwitchMockRandom::set_change_by(
  self : GreedySwitchMockRandom,
  change_by : Double,
) -> Unit {
  self.use_mock_sequence = true
  self.change_by = change_by
}

///|
pub fn GreedySwitchMockRandom::set_current(
  self : GreedySwitchMockRandom,
  current : Float,
) -> Unit {
  self.use_mock_sequence = true
  self.current = current.to_double()
}
