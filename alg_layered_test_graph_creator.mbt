///|
pub type TestGraphCreator = GreedySwitchTestGraphCreator

///|
pub type MockRandom = GreedySwitchMockRandom

///|
pub fn new_test_graph_creator() -> TestGraphCreator {
  new_greedy_switch_test_graph_creator()
}

///|
pub fn new_mock_random() -> MockRandom {
  new_greedy_switch_mock_random()
}
