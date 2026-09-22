///|
pub fn layout_minimal_example() -> String raise {
  let input = "{\"id\":\"root\",\"layoutOptions\":{\"elk.algorithm\":\"layered\",\"elk.direction\":\"DOWN\"},\"children\":[{\"id\":\"n1\",\"width\":80,\"height\":40},{\"id\":\"n2\",\"width\":80,\"height\":40}],\"edges\":[{\"id\":\"e1\",\"sources\":[\"n1\"],\"targets\":[\"n2\"]}]}"
  @all_engine.new_elk_engine().layout(graph=@json.parse(input)).stringify()
}
