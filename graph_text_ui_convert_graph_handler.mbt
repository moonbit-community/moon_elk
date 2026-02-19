///|
pub(all) enum GraphTextSelectionItem {
  GraphTextSelectionFile(String, String)
  GraphTextSelectionOther
} derive(Show)

///|
pub struct GraphTextProject {
  files : Map[String, String]
}

///|
pub fn new_graph_text_project() -> GraphTextProject {
  { files: {} }
}

///|
pub fn GraphTextProject::file_exists(
  self : GraphTextProject,
  path : String,
) -> Bool {
  match self.files.get(path) {
    Some(_) => true
    None => false
  }
}

///|
pub fn GraphTextProject::write_file(
  self : GraphTextProject,
  path : String,
  content : String,
) -> Unit {
  self.files[path] = content
}

///|
pub fn GraphTextProject::read_file(
  self : GraphTextProject,
  path : String,
) -> String? {
  self.files.get(path)
}

///|
pub fn GraphTextProject::list_files(self : GraphTextProject) -> Array[String] {
  let paths : Array[String] = []
  for pair in self.files.to_array() {
    paths.push(pair.0)
  }
  paths
}

///|
fn graph_text_base_name(path : String) -> String {
  let mut slash = -1
  for i = 0; i < path.length(); i = i + 1 {
    if path[i] == '/' {
      slash = i
    }
  }
  if slash >= 0 {
    path.unsafe_substring(start=slash + 1, end=path.length())
  } else {
    path
  }
}

///|
fn graph_text_remove_extension(path : String) -> String {
  let mut dot = -1
  for i = 0; i < path.length(); i = i + 1 {
    if path[i] == '.' {
      dot = i
    }
  }
  if dot <= 0 {
    path
  } else {
    path.unsafe_substring(start=0, end=dot)
  }
}

///|
pub struct ConvertGraphHandler {
  project : GraphTextProject
  mut target_extension : String
  errors : Array[String]
}

///|
pub fn new_convert_graph_handler(
  project? : GraphTextProject = new_graph_text_project(),
) -> ConvertGraphHandler {
  { project, target_extension: "", errors: [] }
}

///|
pub fn ConvertGraphHandler::is_valid_target_extension(
  self : ConvertGraphHandler,
  target_extension : String,
) -> Bool {
  ignore(self)
  target_extension == "elkt" || target_extension == "elkg"
}

///|
pub fn ConvertGraphHandler::execute(
  self : ConvertGraphHandler,
  selection : Array[GraphTextSelectionItem],
  target_extension : String,
) -> Int {
  self.target_extension = target_extension
  if !self.is_valid_target_extension(target_extension) {
    self.errors.push("Invalid target extension: " + target_extension)
    return 0
  }

  let mut processed = 0
  for item in selection {
    match item {
      GraphTextSelectionFile(path, content) => {
        self.convert(path, content)
        processed += 1
      }
      GraphTextSelectionOther => ()
    }
  }
  processed
}

///|
pub fn ConvertGraphHandler::convert(
  self : ConvertGraphHandler,
  path : String,
  content : String,
) -> Unit {
  let source_model = self.read_model(content)
  let target_model = self.transform(source_model)
  let target_path = self.create_target(path)
  self.save_model(target_model, target_path)
}

///|
pub fn ConvertGraphHandler::read_model(
  self : ConvertGraphHandler,
  content : String,
) -> ElkNode {
  ignore(self)
  new_elk_graph_parser().parse(content)
}

///|
pub fn ConvertGraphHandler::transform(
  self : ConvertGraphHandler,
  model : ElkNode,
) -> ElkNode {
  if self.target_extension == "elkt" {
    graph_identifier_generator_for_graph(model)
    .assert_valid()
    .assert_exists()
    .assert_unique()
    .execute()
  }
  model
}

///|
pub fn ConvertGraphHandler::create_target(
  self : ConvertGraphHandler,
  source_path : String,
) -> String {
  let base = graph_text_remove_extension(graph_text_base_name(source_path))
  let mut index = 0
  let mut candidate = base + "." + self.target_extension
  while self.project.file_exists(candidate) {
    candidate = base + index.to_string() + "." + self.target_extension
    index += 1
  }
  candidate
}

///|
pub fn ConvertGraphHandler::save_model(
  self : ConvertGraphHandler,
  model : ElkNode,
  target_path : String,
) -> Unit {
  let id = node_identifier(model)
  let summary = "graph " +
    id +
    " children=" +
    node_children(model).length().to_string()
  self.project.write_file(target_path, summary)
}

///|
pub fn ConvertGraphHandler::get_project(
  self : ConvertGraphHandler,
) -> GraphTextProject {
  self.project
}

///|
pub fn ConvertGraphHandler::get_errors(
  self : ConvertGraphHandler,
) -> Array[String] {
  self.errors
}

///|
pub fn ConvertGraphHandler::remove_invalid_properties(
  self : ConvertGraphHandler,
  graph : ElkNode,
) -> ElkNode {
  ignore(self)
  graph
}

///|
pub fn ConvertGraphHandler::remove_unnecessary_layouts(
  self : ConvertGraphHandler,
  graph : ElkNode,
) -> ElkNode {
  ignore(self)
  graph
}
