///|
/// Installs one algorithm implementation into a layout runtime.
pub type LayoutAlgorithmInstaller = (@core.LayoutRuntime) -> Unit

///|
/// Composition root for a deliberately selected set of layout algorithms.
///
/// The builder owns one isolated runtime. Adding an algorithm records both its
/// public JSON name and its canonical metadata id, then invokes the package's
/// explicit installer. No package initialization side effect is involved.
pub struct EngineBuilder {
  runtime : @core.LayoutRuntime
  algorithms : Array[String]
  algorithm_aliases : Map[String, String]
}

///|
fn engine_layout_imported_graph(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  root : @graph.ElkNode,
  importer : @graph_json.JsonImporter,
) -> Map[String, Json]? raise {
  if session.has_error() {
    return None
  }
  @core.new_recursive_graph_layout_engine(runtime, session).layout(
    root,
    @core.new_null_elk_progress_monitor(),
  )
  if session.has_error() {
    return None
  }
  importer.transfer_layout(root)
  if session.has_error() {
    return None
  }
  match importer.get_input_model() {
    Some(model) => Some(model.copy())
    None => None
  }
}

///|
fn engine_json_layout_delegate(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Unit raise {
  graph_obj["layoutOptions"] = Json::object(options.copy())
  let importer = @graph_json.new_json_importer(
    runtime.option_metadata(),
    session,
  )
  let root = importer.transform(graph_obj)
  let updated_model = try
    engine_layout_imported_graph(runtime, session, root, importer)
  catch {
    error => {
      @graph.dispose_graph(root)
      raise error
    }
  } noraise {
    model => model
  }
  @graph.dispose_graph(root)
  match updated_model {
    Some(model) => {
      graph_obj.clear()
      model.each((key, value) => graph_obj[key] = value)
    }
    None => ()
  }
}

///|
pub fn new_engine_builder() -> EngineBuilder {
  let runtime = @core.new_layout_runtime()
  let metadata = runtime.option_metadata()
  metadata.register_default_options()
  metadata.register_default_algorithms()
  runtime.register_elk_engine_layout_delegate(engine_json_layout_delegate)
  {
    runtime,
    algorithms: ["fixed", "box", "random"],
    algorithm_aliases: Map::from_array([
      ("org.eclipse.elk.fixed", "fixed"),
      ("org.eclipse.elk.box", "box"),
      ("org.eclipse.elk.random", "random"),
    ]),
  }
}

///|
pub fn EngineBuilder::add_layout_algorithm(
  self : EngineBuilder,
  name : String,
  canonical_id : String,
  installer : LayoutAlgorithmInstaller,
) -> EngineBuilder {
  let metadata = self.runtime.option_metadata()
  if metadata.algorithm_data(canonical_id) is None {
    metadata.register_algorithm(@core.new_layout_algorithm_data(canonical_id))
  }
  installer(self.runtime)
  self.algorithm_aliases[canonical_id] = name
  if !self.algorithms.contains(name) {
    self.algorithms.push(name)
  }
  self
}

///|
pub fn EngineBuilder::runtime(self : EngineBuilder) -> @core.LayoutRuntime {
  self.runtime
}

///|
pub fn EngineBuilder::build_runtime(
  self : EngineBuilder,
) -> @core.LayoutRuntime {
  self.runtime
}

///|
pub fn EngineBuilder::build(self : EngineBuilder) -> @core.ElkEngine {
  @core.new_elk_engine(
    self.runtime,
    algorithms=self.algorithms,
    algorithm_aliases=self.algorithm_aliases,
  )
}
