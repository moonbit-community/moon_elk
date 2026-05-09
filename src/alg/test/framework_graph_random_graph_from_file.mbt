///|
let random_graph_from_file_contents_ref : Ref[Map[String, String]] = Ref({})

///|
pub fn random_graph_from_file_register_content_for_test(
  path : String,
  content : String,
) -> Unit {
  random_graph_from_file_contents_ref.val[path] = content
}

///|
pub fn random_graph_from_file_reset_content_for_test() -> Unit {
  random_graph_from_file_contents_ref.val.clear()
}

///|
pub fn random_graph_from_file_filter() -> FileExtensionFilter {
  new_file_extension_filter(".elkr")
}

///|
fn random_graph_from_file_clone(graph : ElkNode) -> ElkNode {
  let serialized = elk_graph_json_for_elk_graph(graph).to_json()
  elk_graph_json_for_graph(serialized).to_elk()
}

///|
fn random_graph_from_file_random_graphs(
  path : AbsoluteResourcePath,
) -> Array[ElkNode] {
  let file_name = path.get_file()
  let content = match random_graph_from_file_contents_ref.val.get(file_name) {
    Some(value) => value
    None => return []
  }
  let rand_graph = new_core_debug_grandom_parser().parse(content)
  let generator = new_core_debug_grandom_random_graph_generator(None)
  let graphs : Array[ElkNode] = []
  for config in rand_graph.configs {
    for
      graph in core_debug_grandom_random_graph_generator_generate_from_configuration(
        generator, config,
      ) {
      graphs.push(graph)
    }
  }
  graphs
}

///|
pub struct RandomGraphFromFile {
  resource_path : AbsoluteResourcePath
  graph : ElkNode
}

///|
pub fn new_random_graph_from_file(
  resource_path : AbsoluteResourcePath,
  graph : ElkNode,
) -> RandomGraphFromFile {
  { resource_path, graph }
}

///|
pub fn random_graph_from_file_from_resource_paths(
  resource_paths : Array[AbstractResourcePath],
) -> Array[RandomGraphFromFile] {
  let graphs : Array[RandomGraphFromFile] = []
  for abstract_path in resource_paths {
    abstract_path.set_filter(Some(random_graph_from_file_filter().to_filter()))
    for absolute_path in abstract_path.list_resources() {
      for graph in random_graph_from_file_random_graphs(absolute_path) {
        graphs.push(new_random_graph_from_file(absolute_path, graph))
      }
    }
  }
  graphs
}

///|
pub fn RandomGraphFromFile::provide_graph(
  self : RandomGraphFromFile,
  _test : Unit,
) -> ElkNode {
  random_graph_from_file_clone(self.graph)
}

///|
pub fn RandomGraphFromFile::to_test_graph(
  self : RandomGraphFromFile,
) -> TestGraph[Unit] {
  new_test_graph(instance => self.provide_graph(instance), self.to_string())
}

///|
pub fn RandomGraphFromFile::to_string(self : RandomGraphFromFile) -> String {
  "randomGraphFile(" + self.resource_path.get_file() + ")"
}
