///|
pub(all) struct CoreDebugGRandomProject {
  files : Map[String, String]
}

///|
pub fn new_core_debug_grandom_project() -> CoreDebugGRandomProject {
  { files: {} }
}

///|
pub fn CoreDebugGRandomProject::file_exists(
  self : CoreDebugGRandomProject,
  path : String,
) -> Bool {
  match self.files.get(path) {
    Some(_) => true
    None => false
  }
}

///|
pub fn CoreDebugGRandomProject::write_file(
  self : CoreDebugGRandomProject,
  path : String,
  content : String,
) -> Unit {
  self.files[path] = content
}

///|
pub fn CoreDebugGRandomProject::read_file(
  self : CoreDebugGRandomProject,
  path : String,
) -> String? {
  self.files.get(path)
}

///|
pub fn CoreDebugGRandomProject::list_files(
  self : CoreDebugGRandomProject,
) -> Array[String] {
  let paths : Array[String] = []
  for pair in self.files.to_array() {
    paths.push(pair.0)
  }
  paths
}

///|
fn core_debug_grandom_graph_maker_format_to_string(
  format : @grandom.CoreDebugGRandomFormats?,
) -> String {
  match format {
    Some(FormatElkg) => "elkg"
    Some(FormatElkt) => "elkt"
    None => "elkt"
  }
}

///|
fn core_debug_grandom_graph_maker_serialize(
  graph : @graph.ElkNode,
  file_path : String,
  project : CoreDebugGRandomProject,
) -> Unit {
  let summary = "ElkNode(children=" +
    @graph.node_children(graph).length().to_string() +
    ")"
  project.write_file(file_path, summary)
}

///|
pub(all) struct CoreDebugGRandomGraphMaker {
  configs : Array[@grandom.CoreDebugGRandomConfiguration]
}

///|
pub fn new_core_debug_grandom_graph_maker(
  rand_graph : @grandom.CoreDebugGRandomRandGraph,
) -> CoreDebugGRandomGraphMaker {
  { configs: rand_graph.configs }
}

///|
pub fn CoreDebugGRandomGraphMaker::gen(
  self : CoreDebugGRandomGraphMaker,
  project : CoreDebugGRandomProject,
) -> Unit {
  let generator = @grandom.new_core_debug_grandom_random_graph_generator(None)
  for config in self.configs {
    let filename = match config.filename {
      Some(value) => value
      None => "random"
    }
    let format = core_debug_grandom_graph_maker_format_to_string(config.format)
    let graphs = @grandom.core_debug_grandom_random_graph_generator_generate_from_configuration(
      generator, config,
    )
    let mut file_num = 0
    let mut index = 0
    while index < graphs.length() {
      let mut target_name = filename + file_num.to_string() + "." + format
      while project.file_exists(target_name) {
        file_num += 1
        target_name = filename + file_num.to_string() + "." + format
      }
      core_debug_grandom_graph_maker_serialize(
        graphs[index],
        target_name,
        project,
      )
      index += 1
    }
  }
}

///|
pub fn CoreDebugGRandomGraphMaker::load_graph(
  self : CoreDebugGRandomGraphMaker,
) -> Array[@graph.ElkNode] {
  let graphs : Array[@graph.ElkNode] = []
  let generator = @grandom.new_core_debug_grandom_random_graph_generator(None)
  for config in self.configs {
    let generated = @grandom.core_debug_grandom_random_graph_generator_generate_from_configuration(
      generator, config,
    )
    for graph in generated {
      graphs.push(graph)
    }
  }
  graphs
}
