///|
pub type TestGraphCreator = GreedySwitchTestGraphCreator

///|
pub fn new_test_graph_creator() -> TestGraphCreator raise {
  new_greedy_switch_test_graph_creator()
}
