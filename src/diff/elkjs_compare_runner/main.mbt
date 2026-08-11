///|
fn required_importer(
  maybe_importer : @core.Maybe[@json.JsonImporter],
) -> @json.JsonImporter {
  match maybe_importer.get() {
    Some(importer) => importer
    None => abort("missing importer")
  }
}

///|
pub fn layout_json(input_graph : String) -> String raise {
  let runtime = @json.new_layout_runtime()
  let session = @core.new_layout_session()

  let maybe_importer : @core.Maybe[@json.JsonImporter] = @core.maybe_create()
  let root = @test.elk_graph_json_for_graph(input_graph)
    .remember_importer(maybe_importer)
    .to_elk()
  let engine = @core.new_recursive_graph_layout_engine(runtime, session)
  engine.layout(root, @test.new_basic_progress_monitor())

  let importer = required_importer(maybe_importer)
  importer.transfer_layout(root)
  match importer.get_input_model() {
    Some(model) => Json::object(model).stringify()
    None => {
      @core.layout_runtime_raise_unsupported_configuration(
        "missing input model",
      )
      "{}"
    }
  }
}

///|
fn main raise {
  println(layout_json(case_input_graph_json()))
}
