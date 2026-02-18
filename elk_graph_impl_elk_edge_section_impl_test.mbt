///|
test "edge section impl constructor maps to graph model creator" {
  reset_graph_model_for_test()

  let edge = new_elk_edge_impl()
  let section = new_elk_edge_section_impl(edge)
  let sections = edge_sections(edge)

  inspect(sections.length() == 1, content="true")
  inspect(sections[0] == section, content="true")
}
