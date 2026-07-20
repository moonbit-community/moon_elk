///|
/// Mutable state shared by processors participating in one layered layout run.
///
/// The execution plan retains this object for the complete run. Split component
/// graphs carry the same reference so cycle breaking, crossing minimization,
/// and edge routing consume one deterministic random sequence without storing
/// the random object in a generic graph property map.
pub struct LayeredLayoutState {
  mut random : GreedySwitchMockRandom?
  mut first_random_boolean : Bool?
}

///|
pub fn new_layered_layout_state() -> LayeredLayoutState {
  { random: None, first_random_boolean: None }
}

///|
fn layered_layout_state_seeded_next_boolean(seed_value : Int) -> Bool {
  let multiplier = 25214903917L
  let addend = 11L
  let mask = 281474976710655L
  let mut seed = (Int64::from_int(seed_value) ^ multiplier) & mask
  seed = (seed * multiplier + addend) & mask
  ((seed >> 47) & 1L) == 1L
}

///|
fn layered_layout_state_random_for_seed(
  seed_value : Int,
) -> GreedySwitchMockRandom {
  if seed_value == 0 {
    new_greedy_switch_mock_random_seeded(
      @random.Rand::new().int(limit=@int.MAX_VALUE),
    )
  } else {
    new_greedy_switch_mock_random_seeded(seed_value)
  }
}

///|
pub fn LayeredLayoutState::initialize_random(
  self : LayeredLayoutState,
  seed_value : Int,
) -> Unit {
  self.random = Some(layered_layout_state_random_for_seed(seed_value))
  self.first_random_boolean = Some(
    if seed_value == 0 {
      @random.Rand::new().int(limit=2) == 0
    } else {
      layered_layout_state_seeded_next_boolean(seed_value)
    },
  )
}

///|
pub fn LayeredLayoutState::random(
  self : LayeredLayoutState,
  seed_value : Int,
) -> GreedySwitchMockRandom {
  match self.random {
    Some(random) => random
    None => {
      let random = layered_layout_state_random_for_seed(seed_value)
      self.random = Some(random)
      random
    }
  }
}

///|
pub fn LayeredLayoutState::install_random(
  self : LayeredLayoutState,
  random : GreedySwitchMockRandom,
  first_boolean : Bool?,
) -> Unit {
  self.random = Some(random)
  self.first_random_boolean = first_boolean
}

///|
pub fn LayeredLayoutState::first_random_boolean(
  self : LayeredLayoutState,
) -> Bool? {
  self.first_random_boolean
}

///|
pub fn LayeredLayoutState::clear(self : LayeredLayoutState) -> Unit {
  self.random = None
  self.first_random_boolean = None
}
