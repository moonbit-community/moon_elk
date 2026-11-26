///|
/// Mutable state shared by processors participating in one layered layout run.
///
/// The execution plan retains this object for the complete run. Split component
/// graphs carry the same reference so cycle breaking, crossing minimization,
/// and edge routing consume one deterministic random sequence without storing
/// the random object in a generic graph property map.
///
/// ELK keeps a `Random` of its own on every graph it configures. The graphs of
/// a hierarchical run are therefore keyed by their handle in `graph_randoms`;
/// `random` is the generator of the graph configured last, and the one handed
/// out for a graph that was never configured.
pub struct LayeredLayoutState {
  mut random : GreedySwitchMockRandom?
  graph_randoms : Map[Int32, GreedySwitchMockRandom]
  mut first_random_boolean : Bool?
}

///|
pub fn new_layered_layout_state() -> LayeredLayoutState {
  { random: None, graph_randoms: Map([]), first_random_boolean: None, }
}

///|
fn layered_layout_state_seeded_next_boolean(seed_value : Int32) -> Bool {
  let multiplier = 25214903917L
  let addend = 11L
  let mask = 281474976710655L
  let mut seed = (seed_value.to_int64() ^ multiplier) & mask
  seed = (seed * multiplier + addend) & mask
  ((seed >> 47) & 1L) == 1L
}

///|
fn layered_layout_state_random_for_seed(
  seed_value : Int32,
) -> GreedySwitchMockRandom {
  if seed_value == 0 {
    new_greedy_switch_mock_random_seeded(
      @random.Rand().int(limit=@int.MAX_VALUE),
    )
  } else {
    new_greedy_switch_mock_random_seeded(seed_value)
  }
}

///|
pub fn LayeredLayoutState::initialize_random(
  self : LayeredLayoutState,
  seed_value : Int32,
) -> Unit {
  self.random = Some(layered_layout_state_random_for_seed(seed_value))
  self.first_random_boolean = Some(
    if seed_value == 0 {
      @random.Rand().int(limit=2) == 0
    } else {
      layered_layout_state_seeded_next_boolean(seed_value)
    },
  )
}

///|
/// Gives the graph with the given handle a random number generator of its own,
/// as `GraphConfigurator` does when it configures a graph.
pub fn LayeredLayoutState::initialize_graph_random(
  self : LayeredLayoutState,
  graph_handle : Int32,
  seed_value : Int32,
) -> Unit {
  // A component of a graph that was configured before it was split keeps
  // drawing from that graph's generator.
  if self.graph_randoms.get(graph_handle) is Some(random) {
    self.random = Some(random)
    return
  }
  self.initialize_random(seed_value)
  if self.random is Some(random) {
    self.graph_randoms[graph_handle] = random
  }
}

///|
/// Makes the graph with handle `graph_handle` draw from the generator of
/// the graph with handle `owner_handle`.
pub fn LayeredLayoutState::share_graph_random(
  self : LayeredLayoutState,
  graph_handle : Int32,
  owner_handle : Int32,
) -> Unit {
  if self.graph_randoms.get(owner_handle) is Some(random) {
    self.graph_randoms[graph_handle] = random
  }
}

///|
/// The random number generator of the graph with the given handle.
pub fn LayeredLayoutState::graph_random(
  self : LayeredLayoutState,
  graph_handle : Int32,
  seed_value : Int32,
) -> GreedySwitchMockRandom {
  match self.graph_randoms.get(graph_handle) {
    Some(random) => random
    None => self.random(seed_value)
  }
}

///|
pub fn LayeredLayoutState::random(
  self : LayeredLayoutState,
  seed_value : Int32,
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
  self.graph_randoms.clear()
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
  self.graph_randoms.clear()
  self.first_random_boolean = None
}
