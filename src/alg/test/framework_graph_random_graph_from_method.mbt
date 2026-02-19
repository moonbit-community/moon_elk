///|
fn random_graph_from_method_seeded_random() -> @random.Rand {
  let seed_buffer = @buffer.new()
  seed_buffer.write_int64_le(1337)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  @random.Rand::chacha8(seed=seed_buffer.to_bytes())
}

///|
fn random_graph_from_method_clone(graph : ElkNode) -> ElkNode {
  let serialized = elk_graph_json_for_elk_graph(graph).to_json()
  elk_graph_json_for_graph(serialized).to_elk()
}

///|
pub struct RandomGraphFromMethod {
  configurator_method_name : String
  graph : ElkNode
}

///|
pub fn new_random_graph_from_method(
  configurator_method_name : String,
  graph : ElkNode,
) -> RandomGraphFromMethod {
  { configurator_method_name, graph }
}

///|
pub fn random_graph_from_method_from_options(
  method_name : String,
  options : CoreDebugGRandomGeneratorOptions,
) -> RandomGraphFromMethod {
  let generator = new_core_debug_grandom_random_graph_generator(
    Some(random_graph_from_method_seeded_random()),
  )
  new_random_graph_from_method(
    method_name,
    core_debug_grandom_random_graph_generator_generate(generator, options),
  )
}

///|
pub fn RandomGraphFromMethod::provide_graph(
  self : RandomGraphFromMethod,
  _test : Unit,
) -> ElkNode {
  random_graph_from_method_clone(self.graph)
}

///|
pub fn RandomGraphFromMethod::to_test_graph(
  self : RandomGraphFromMethod,
) -> TestGraph[Unit] {
  new_test_graph(instance => self.provide_graph(instance), self.to_string())
}

///|
pub fn RandomGraphFromMethod::to_string(self : RandomGraphFromMethod) -> String {
  "randomGraphMethod(" + self.configurator_method_name + ")"
}
