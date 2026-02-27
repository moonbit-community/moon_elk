///|
fn required_importer(
  maybe_importer : @core.Maybe[@json.JsonImporter],
) -> @json.JsonImporter {
  match maybe_importer.get() {
    Some(importer) => importer
    None => {
      @core.layout_runtime_report_unsupported_configuration("missing importer")
      @json.new_json_importer()
    }
  }
}

///|
pub fn layout_json(input_graph : String) -> String {
  @test.reset_graph_model_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()

  let maybe_importer : @core.Maybe[@json.JsonImporter] = @core.maybe_create()
  let root = @test.elk_graph_json_for_graph(input_graph)
    .remember_importer(maybe_importer)
    .to_elk()
  let engine = @test.new_recursive_graph_layout_engine()
  engine.layout(root, @test.new_basic_progress_monitor())

  let importer = required_importer(maybe_importer)
  importer.transfer_layout(root)
  match importer.get_input_model() {
    Some(model) => Json::object(model).stringify()
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "missing input model",
      )
      "{}"
    }
  }
}

///|
fn main {
  println(layout_json(case_input_graph_json()))
}
