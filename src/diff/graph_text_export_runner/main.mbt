///|
fn parse_graph_text(content : String) -> @graph.ElkNode {
  let graph = @text.new_elk_graph_parser().parse(content)
  @graph.node_set_string_property(
    graph, @core.algorithm, "org.eclipse.elk.layered",
  )
  graph
}

///|
fn main {
  let content = "hierarchyHandling: INCLUDE_CHILDREN\n\nnode n1\n{\n    node n1a\n}\nnode n2\n{\n}\nnode n3\n{\n    node n3a\n}\n\nedge n1 -> n2\nedge n2 -> n3\nedge n3.n3a -> n1.n1a\n"
  let graph = parse_graph_text(content)
  println(
    @json.elk_graph_json_for_elk_graph(graph)
    .short_layout_option_keys(true)
    .to_json(),
  )
}
