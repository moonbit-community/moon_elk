///|
test "graph feature string names match java enum constants" {
  let expected = [
    "SELF_LOOPS", "INSIDE_SELF_LOOPS", "MULTI_EDGES", "EDGE_LABELS", "PORTS", "COMPOUND",
    "CLUSTERS", "DISCONNECTED",
  ]
  let values = graph_feature_values()
  assert_eq(values.length(), expected.length())
  for i = 0; i < values.length(); i = i + 1 {
    assert_eq(values[i].to_string(), expected[i])
  }
}

///|
test "graph feature values order follows enum declaration" {
  let values = graph_feature_values()
  assert_eq(values.length(), 8)
  assert_eq(values[0].to_string(), "SELF_LOOPS")
  assert_eq(values[7].to_string(), "DISCONNECTED")
}

///|
test "graph feature descriptions are stable" {
  let values = graph_feature_values()
  assert_eq(values[0].get_description(), "Edges connecting a node with itself.")
  assert_eq(values[7].get_description(), "Multiple connected components.")
}
