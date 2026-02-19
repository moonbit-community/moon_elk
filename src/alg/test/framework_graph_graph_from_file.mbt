///|
let graph_from_file_contents_ref : Ref[Map[String, String]] = Ref::new({})

///|
pub fn graph_from_file_register_content_for_test(
  path : String,
  content : String,
) -> Unit {
  graph_from_file_contents_ref.val[path] = content
}

///|
pub fn graph_from_file_reset_content_for_test() -> Unit {
  graph_from_file_contents_ref.val.clear()
}

///|
pub fn graph_from_file_filter() -> FileExtensionFilter {
  new_file_extension_filter_with_extensions([".elkt", ".elkg"])
}

///|
fn graph_from_file_parse(path : String, content : String) -> ElkNode {
  if path.has_suffix(".json") {
    return elk_graph_json_for_graph(content).to_elk()
  }
  new_elk_graph_parser().parse(content)
}

///|
pub struct GraphFromFile {
  resource_path : AbsoluteResourcePath
}

///|
pub fn new_graph_from_file(
  resource_path : AbsoluteResourcePath,
) -> GraphFromFile {
  { resource_path, }
}

///|
pub fn graph_from_file_from_resource_paths(
  resource_paths : Array[AbstractResourcePath],
) -> Array[GraphFromFile] {
  let result : Array[GraphFromFile] = []
  for resource_path in resource_paths {
    if resource_path.get_filter() is None {
      resource_path.set_filter(Some(graph_from_file_filter().to_filter()))
    }
    for absolute in resource_path.list_resources() {
      result.push(new_graph_from_file(absolute))
    }
  }
  result
}

///|
pub fn GraphFromFile::provide_graph(
  self : GraphFromFile,
  _test : Unit,
) -> ElkNode {
  let path = self.resource_path.get_file()
  match graph_from_file_contents_ref.val.get(path) {
    Some(content) => graph_from_file_parse(path, content)
    None => abort("Unable to load graph from " + path)
  }
}

///|
pub fn GraphFromFile::to_test_graph(self : GraphFromFile) -> TestGraph[Unit] {
  new_test_graph(instance => self.provide_graph(instance), self.to_string())
}

///|
pub fn GraphFromFile::to_string(self : GraphFromFile) -> String {
  "graphFile(" + self.resource_path.get_file() + ")"
}
