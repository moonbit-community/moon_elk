///|
pub struct TestAlgorithm {
  algorithm_data : LayoutAlgorithmData?
}

///|
pub fn new_test_algorithm(
  algorithm_data : LayoutAlgorithmData?,
) -> TestAlgorithm {
  { algorithm_data, }
}

///|
pub fn test_algorithm_identity() -> TestAlgorithm {
  new_test_algorithm(None)
}

///|
pub fn TestAlgorithm::get_algorithm_data(
  self : TestAlgorithm,
) -> LayoutAlgorithmData? {
  self.algorithm_data
}

///|
fn test_algorithm_insert_sorted(
  values : Array[LayoutAlgorithmData],
  value : LayoutAlgorithmData,
) -> Unit {
  let value_id = value.get_id()
  let mut index = 0
  while index < values.length() {
    if value_id <= values[index].get_id() {
      break
    }
    index = index + 1
  }
  values.insert(index, value)
}

///|
pub fn test_algorithm_from_annotations(
  algorithm_annotations : Array[Algorithm],
  include_all_algorithms : Bool,
  errors : Array[String],
) -> Array[TestAlgorithm] {
  let algorithm_data : Array[LayoutAlgorithmData] = []
  if include_all_algorithms && !algorithm_annotations.is_empty() {
    errors.push(
      "If @AllAlgorithms is specified, @Algorithm cannot be used anymore.",
    )
    return []
  }
  if include_all_algorithms {
    for data in layout_meta_data_service_algorithm_data_values() {
      test_algorithm_insert_sorted(algorithm_data, data)
    }
  } else {
    for annotation in algorithm_annotations {
      let id = annotation.get_value()
      match layout_meta_data_service_get_algorithm_data(id) {
        Some(data) => test_algorithm_insert_sorted(algorithm_data, data)
        None => errors.push("Unknown layout algorithm: " + id)
      }
    }
  }
  let algorithms : Array[TestAlgorithm] = []
  for data in algorithm_data {
    algorithms.push(new_test_algorithm(Some(data)))
  }
  algorithms
}

///|
pub fn TestAlgorithm::apply(self : TestAlgorithm, graph : ElkNode) -> Unit {
  match self.algorithm_data {
    Some(data) => {
      let visitor = new_graph_element_visitor(node => {
        node_set_string_property(node, algorithm, data.get_id())
      })
      apply_visitors(graph, [visitor])
    }
    None => ()
  }
}

///|
pub fn TestAlgorithm::to_string(self : TestAlgorithm) -> String {
  match self.algorithm_data {
    None => "algorithm(as in test graph)"
    Some(data) => "algorithm(" + data.get_id() + ")"
  }
}
