///|
pub(all) enum CoreDebugGRandomSelectionItem {
  CoreDebugGRandomSelectionFile(String)
  CoreDebugGRandomSelectionOther
} derive(Show)

///|
pub struct CoreDebugGRandomHandler {
  project : CoreDebugGRandomProject
  errors : Array[String]
}

///|
pub fn new_core_debug_grandom_handler(
  project? : CoreDebugGRandomProject = new_core_debug_grandom_project(),
) -> CoreDebugGRandomHandler {
  { project, errors: [] }
}

///|
pub fn CoreDebugGRandomHandler::execute(
  self : CoreDebugGRandomHandler,
  selection : Array[CoreDebugGRandomSelectionItem],
) -> Int {
  let parser = new_core_debug_grandom_parser()
  let mut processed = 0
  for item in selection {
    match item {
      CoreDebugGRandomSelectionFile(content) => {
        let rand_graph = parser.parse(content)
        if rand_graph.configs.length() > 0 {
          new_core_debug_grandom_graph_maker(rand_graph).gen(self.project)
          processed += 1
        }
      }
      CoreDebugGRandomSelectionOther => ()
    }
  }
  processed
}

///|
pub fn CoreDebugGRandomHandler::get_project(
  self : CoreDebugGRandomHandler,
) -> CoreDebugGRandomProject {
  self.project
}

///|
pub fn CoreDebugGRandomHandler::record_error(
  self : CoreDebugGRandomHandler,
  message : String,
) -> Unit {
  self.errors.push(message)
}

///|
pub fn CoreDebugGRandomHandler::get_errors(
  self : CoreDebugGRandomHandler,
) -> Array[String] {
  self.errors
}
