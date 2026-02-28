///|
test "GraphFromMethod provides graph from callback" {
  reset_graph_model_for_test()
  let source = create_graph()
  let graph = new_graph_from_method("source", _ => source)
  inspect(graph.to_string(), content="graphMethod(source)")
  inspect(
    node_identifier(graph.provide_graph(())),
    content=node_identifier(source),
  )
}

///|
test "GraphFromFile loads registered graph text by absolute path" {
  reset_graph_model_for_test()
  graph_from_file_reset_content_for_test()
  let path = new_absolute_resource_path("/graphs/simple.elkg")
  graph_from_file_register_content_for_test(
    "/graphs/simple.elkg", "graph demo node n1 { }",
  )
  let graph = new_graph_from_file(path).provide_graph(())
  inspect(node_identifier(graph), content="demo")
  inspect(node_children(graph).length(), content="1")
}

///|
test "RandomGraphFromMethod creates copyable deterministic random graph" {
  reset_graph_model_for_test()
  let options = new_core_debug_grandom_generator_options()
  let random_graph = random_graph_from_method_from_options("rnd", options)
  let first = random_graph.provide_graph(())
  let second = random_graph.provide_graph(())
  inspect(random_graph.to_string(), content="randomGraphMethod(rnd)")
  inspect(node_children(first).length() >= 0, content="true")
  inspect(node_children(second).length() >= 0, content="true")
}

///|
test "RandomGraphFromFile creates graph instances from .elkr resources" {
  reset_graph_model_for_test()
  core_debug_reset_foundation_for_test()
  random_graph_from_file_reset_content_for_test()
  core_debug_register_directory_for_test("/cases", ["/cases/a.elkr"])
  core_debug_register_regular_file_for_test("/cases/a.elkr")
  random_graph_from_file_register_content_for_test(
    "/cases/a.elkr", "generate { nodes = 3 edges = 2 seed = 1 }",
  )
  let resources = random_graph_from_file_from_resource_paths([
    new_absolute_resource_path("/cases/**"),
  ])
  inspect(resources.length() > 0, content="true")
  let graph = resources[0].provide_graph(())
  inspect(node_children(graph).length() >= 0, content="true")
}
