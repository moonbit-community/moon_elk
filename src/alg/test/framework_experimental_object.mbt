///|
pub struct ExperimentalObject[T] {
  layout_algorithm : TestAlgorithm
  configuration : TestConfiguration[T]
  graph : TestGraph[T]
}

///|
pub fn[T] new_experimental_object(
  layout_algorithm : TestAlgorithm,
  configuration : TestConfiguration[T],
  graph : TestGraph[T],
) -> ExperimentalObject[T] {
  { layout_algorithm, configuration, graph }
}

///|
pub fn[T] experimental_object_inflate(
  algorithms : Array[TestAlgorithm],
  configurations : Array[TestConfiguration[T]],
  graphs : Array[TestGraph[T]],
) -> Array[ExperimentalObject[T]] {
  let objects : Array[ExperimentalObject[T]] = []
  for algorithm in algorithms {
    for configuration in configurations {
      for graph in graphs {
        objects.push(new_experimental_object(algorithm, configuration, graph))
      }
    }
  }
  objects
}

///|
pub fn[T] ExperimentalObject::realize(
  self : ExperimentalObject[T],
  test_instance : T,
) -> ElkNode {
  let test_graph = self.graph.provide_graph(test_instance)
  self.layout_algorithm.apply(test_graph)
  self.configuration.apply(test_instance, test_graph)
  test_graph
}

///|
pub fn[T] ExperimentalObject::get_layout_algorithm(
  self : ExperimentalObject[T],
) -> TestAlgorithm {
  self.layout_algorithm
}

///|
pub fn[T] ExperimentalObject::get_configuration(
  self : ExperimentalObject[T],
) -> TestConfiguration[T] {
  self.configuration
}

///|
pub fn[T] ExperimentalObject::get_graph(
  self : ExperimentalObject[T],
) -> TestGraph[T] {
  self.graph
}

///|
pub fn[T] ExperimentalObject::to_string(self : ExperimentalObject[T]) -> String {
  self.layout_algorithm.to_string() +
  " " +
  self.configuration.to_string() +
  " " +
  self.graph.to_string()
}
