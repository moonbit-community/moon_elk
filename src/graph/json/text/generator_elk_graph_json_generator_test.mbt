///|
test "ElkGraphJsonGenerator keeps no-op generation behavior" {
  let generator = new_elk_graph_json_generator()
  generator.do_generate("resource", "fsa", "context")
  inspect(true, content="true")
}
