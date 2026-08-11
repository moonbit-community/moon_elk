///|
fn elk_graph_json_core_delegate_register_algorithm_if_missing(
  metadata : @core.OptionMetadata,
  algorithm_id : String,
) -> Unit {
  match metadata.algorithm_data(algorithm_id) {
    Some(_) => ()
    None =>
      metadata.register_algorithm(@core.new_layout_algorithm_data(algorithm_id))
  }
}

///|
fn elk_graph_json_core_delegate_register_additional_algorithms(
  metadata : @core.OptionMetadata,
) -> Unit {
  let additional_algorithm_ids = [
    @disco.disco_algorithm_id, @mrtree_options.mrtree_algorithm_id, @force.force_algorithm_id,
    @force.stress_algorithm_id, @radial_options.radial_algorithm_id, @rectpacking_options.rectpacking_algorithm_id,
    @spore.spore_compaction_algorithm_id, @spore.spore_overlap_removal_algorithm_id,
  ]
  for algorithm_id in additional_algorithm_ids {
    elk_graph_json_core_delegate_register_algorithm_if_missing(
      metadata, algorithm_id,
    )
  }
}

///|
fn elk_graph_json_core_delegate_enable_layered_features(
  metadata : @core.OptionMetadata,
) -> Unit {
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
fn elk_graph_json_core_delegate_initialize_runtime(
  runtime : @core.LayoutRuntime,
) -> Unit {
  let metadata = runtime.option_metadata()
  metadata.register_default_options()
  metadata.register_default_algorithms()
  metadata.register_providers(@force.force_layout_meta_data_providers())
  elk_graph_json_core_delegate_register_additional_algorithms(metadata)
  elk_graph_json_core_delegate_enable_layered_features(metadata)

  @pipeline.register_layered_layout_algorithm(
    runtime,
    @engine.new_layered_phase_registry(),
  )
  @force.register_force_layout_algorithm(runtime)
  @force.register_stress_layout_algorithm(runtime)
  @radial.register_radial_layout_algorithm(runtime)
  @mrtree.register_mrtree_layout_algorithm(runtime)
  @rectpacking.register_rectpacking_layout_algorithm(runtime)
  @spore.register_spore_compaction_layout_algorithm(runtime)
  @spore.register_spore_overlap_layout_algorithm(runtime)
  @vertiflex.register_vertiflex_layout_algorithm(runtime)
  @disco.register_disco_layout_algorithm(runtime)
}

///|
fn elk_graph_json_core_delegate_required_importer(
  session : @core.LayoutSession,
  maybe_importer : @core.Maybe[JsonImporter],
) -> JsonImporter? {
  match maybe_importer.get() {
    Some(importer) => Some(importer)
    None => {
      session.report_json_import("missing importer")
      None
    }
  }
}

///|
fn elk_graph_json_core_delegate_layout_imported_graph(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  root : @graph.ElkNode,
  maybe_importer : @core.Maybe[JsonImporter],
) -> Map[String, Json]? raise {
  if session.has_error() {
    return None
  }

  let recursive_engine = @core.new_recursive_graph_layout_engine(
    runtime, session,
  )
  recursive_engine.layout(root, @core.new_null_elk_progress_monitor())
  if session.has_error() {
    return None
  }

  let importer = match
    elk_graph_json_core_delegate_required_importer(session, maybe_importer) {
    Some(importer) => importer
    None => return None
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
fn elk_graph_json_core_layout_delegate(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Unit raise {
  graph_obj["layoutOptions"] = Json::object(options.copy())

  let maybe_importer : @core.Maybe[JsonImporter] = @core.maybe_create()
  let root = elk_graph_json_for_json_graph(Json::object(graph_obj))
    .remember_importer(maybe_importer)
    .to_elk()
  let updated_model = elk_graph_json_core_delegate_layout_imported_graph(
    runtime, session, root, maybe_importer,
  )
  // The JSON API returns copied layout data, so its imported graph has no owner
  // after this call. Dispose it on every reported-error path as well as success.
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
pub fn new_layout_runtime() -> @core.LayoutRuntime {
  let runtime = @core.new_layout_runtime()
  elk_graph_json_core_delegate_initialize_runtime(runtime)
  runtime.register_elk_engine_layout_delegate(
    elk_graph_json_core_layout_delegate,
  )
  runtime
}
