///|
fn enable_layered_features(metadata : @core.OptionMetadata) -> Unit {
  match metadata.algorithm_data(@options.layered_algorithm_id) {
    Some(algorithm_data) =>
      for
        feature in [
          @graph.GraphFeature::SelfLoops,
          InsideSelfLoops,
          MultiEdges,
          EdgeLabels,
          Ports,
          Compound,
          Clusters,
          Disconnected,
        ] {
        algorithm_data.add_supported_feature(feature)
      }
    None => ()
  }
}

///|
/// Builds an engine configuration containing the core algorithms and layered.
/// No other algorithm package is linked by this composition root.
pub fn new_engine_builder() -> @engine_builder.EngineBuilder {
  let phase_registry = @layered_phases.new_layered_phase_registry()
  let builder = @engine_builder.new_engine_builder().add_layout_algorithm(
    "layered",
    @options.layered_algorithm_id,
    runtime => {
      @pipeline.register_layered_layout_algorithm(runtime, phase_registry)
    },
  )
  enable_layered_features(builder.runtime().option_metadata())
  builder
}

///|
pub fn new_layout_runtime() -> @core.LayoutRuntime {
  new_engine_builder().build_runtime()
}

///|
pub fn new_elk_engine() -> @core.ElkEngine {
  new_engine_builder().build()
}
