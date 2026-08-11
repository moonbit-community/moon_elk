///|
test "EngineBuilder links only explicitly installed algorithms" {
  let builder = @engine.new_engine_builder().add_layout_algorithm(
    "demo",
    "org.example.demo",
    runtime => {
      runtime.register_layout_algorithm("org.example.demo", (
        _runtime,
        _session,
        _graph,
        _monitor,
      ) => ())
    },
  )
  debug_inspect(
    builder.build().known_layout_algorithms(),
    content="[\"fixed\", \"box\", \"random\", \"demo\"]",
  )
  assert_true(
    builder.runtime().option_metadata().algorithm_data("org.example.demo")
    is Some(_),
  )
  let graph = Json::object({
    "id": Json::string("root"),
    "layoutOptions": Json::object({
      "elk.algorithm": Json::string("org.example.demo"),
    }),
  })
  let output = builder.build().layout(graph~)
  match output {
    Object(fields) => assert_eq(fields["id"], Json::string("root"))
    _ => fail("expected object output")
  }
}
