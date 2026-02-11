///|
pub(all) enum GraphJsonTextSelectionItem {
  GraphJsonTextSelectionFile(String, String)
  GraphJsonTextSelectionOther
} derive(Show)

///|
pub let graph_json_text_target_ext_elkj : String = "elkj"

///|
pub let graph_json_text_target_ext_elkg : String = "elkg"

///|
pub struct GraphJsonTextProject {
  files : Map[String, String]
}

///|
pub fn new_graph_json_text_project() -> GraphJsonTextProject {
  { files: {} }
}

///|
pub fn GraphJsonTextProject::file_exists(
  self : GraphJsonTextProject,
  path : String,
) -> Bool {
  match self.files.get(path) {
    Some(_) => true
    None => false
  }
}

///|
pub fn GraphJsonTextProject::write_file(
  self : GraphJsonTextProject,
  path : String,
  content : String,
) -> Unit {
  self.files[path] = content
}

///|
pub fn GraphJsonTextProject::read_file(
  self : GraphJsonTextProject,
  path : String,
) -> String? {
  self.files.get(path)
}

///|
pub fn GraphJsonTextProject::list_files(
  self : GraphJsonTextProject,
) -> Array[String] {
  let paths : Array[String] = []
  for pair in self.files.to_array() {
    paths.push(pair.0)
  }
  paths
}

///|
fn graph_json_text_base_name(path : String) -> String {
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
fn graph_json_text_remove_extension(path : String) -> String {
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
pub struct GraphJsonTextConvertGraphHandler {
  project : GraphJsonTextProject
  mut target_extension : String
  errors : Array[String]
}

///|
pub fn new_graph_json_text_convert_graph_handler(
  project? : GraphJsonTextProject = new_graph_json_text_project(),
) -> GraphJsonTextConvertGraphHandler {
  { project, target_extension: "", errors: [] }
}

///|
pub fn GraphJsonTextConvertGraphHandler::is_valid_target_extension(
  self : GraphJsonTextConvertGraphHandler,
  target_extension : String,
) -> Bool {
  ignore(self)
  target_extension == graph_json_text_target_ext_elkj ||
  target_extension == graph_json_text_target_ext_elkg
}

///|
pub fn GraphJsonTextConvertGraphHandler::execute(
  self : GraphJsonTextConvertGraphHandler,
  selection : Array[GraphJsonTextSelectionItem],
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
      GraphJsonTextSelectionFile(path, content) => {
        self.convert(path, content)
        processed += 1
      }
      GraphJsonTextSelectionOther => ()
    }
  }
  processed
}

///|
pub fn GraphJsonTextConvertGraphHandler::convert(
  self : GraphJsonTextConvertGraphHandler,
  path : String,
  content : String,
) -> Unit {
  let source_model = self.read_model(content)
  let target_model = self.transform(source_model)
  let target_path = self.create_target(path)
  self.save_model(target_model, target_path)
}

///|
pub fn GraphJsonTextConvertGraphHandler::read_model(
  self : GraphJsonTextConvertGraphHandler,
  content : String,
) -> ElkNode {
  ignore(self)
  new_elk_graph_json_parser().parse(content)
}

///|
pub fn GraphJsonTextConvertGraphHandler::transform(
  self : GraphJsonTextConvertGraphHandler,
  model : ElkNode,
) -> ElkNode {
  if self.target_extension == graph_json_text_target_ext_elkj {
    graph_identifier_generator_for_graph(model)
    .assert_valid()
    .assert_exists()
    .assert_unique()
    .execute()
  }
  model
}

///|
pub fn GraphJsonTextConvertGraphHandler::create_target(
  self : GraphJsonTextConvertGraphHandler,
  source_path : String,
) -> String {
  let base = graph_json_text_remove_extension(
    graph_json_text_base_name(source_path),
  )
  let mut index = 0
  let mut candidate = base + "." + self.target_extension
  while self.project.file_exists(candidate) {
    candidate = base + index.to_string() + "." + self.target_extension
    index += 1
  }
  candidate
}

///|
pub fn GraphJsonTextConvertGraphHandler::save_model(
  self : GraphJsonTextConvertGraphHandler,
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
pub fn GraphJsonTextConvertGraphHandler::get_project(
  self : GraphJsonTextConvertGraphHandler,
) -> GraphJsonTextProject {
  self.project
}

///|
pub fn GraphJsonTextConvertGraphHandler::get_errors(
  self : GraphJsonTextConvertGraphHandler,
) -> Array[String] {
  self.errors
}

///|
pub fn GraphJsonTextConvertGraphHandler::remove_invalid_properties(
  self : GraphJsonTextConvertGraphHandler,
  graph : ElkNode,
) -> ElkNode {
  ignore(self)
  graph
}

///|
pub fn GraphJsonTextConvertGraphHandler::remove_unnecessary_layouts(
  self : GraphJsonTextConvertGraphHandler,
  graph : ElkNode,
) -> ElkNode {
  ignore(self)
  graph
}
