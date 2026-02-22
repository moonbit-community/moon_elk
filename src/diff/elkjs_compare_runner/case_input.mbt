///|
fn case_input_graph_json() -> String {
  "{\"id\":\"root\",\"layoutOptions\":{\"elk.algorithm\":\"layered\",\"elk.direction\":\"DOWN\",\"elk.layered.spacing.nodeNodeBetweenLayers\":\"50\"},\"children\":[{\"id\":\"a\",\"width\":40,\"height\":30},{\"id\":\"b\",\"width\":40,\"height\":30},{\"id\":\"c\",\"width\":40,\"height\":30},{\"id\":\"d\",\"width\":40,\"height\":30}],\"edges\":[{\"id\":\"e1\",\"sources\":[\"a\"],\"targets\":[\"b\"]},{\"id\":\"e2\",\"sources\":[\"a\"],\"targets\":[\"c\"]},{\"id\":\"e3\",\"sources\":[\"b\"],\"targets\":[\"d\"]},{\"id\":\"e4\",\"sources\":[\"c\"],\"targets\":[\"d\"]}]}"
}
