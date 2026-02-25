///|
let elk_graph_json_core_delegate_initialized : Ref[Bool] = Ref::new(false)

///|
fn elk_graph_json_core_delegate_register_algorithm_if_missing(
  algorithm_id : String,
) -> Unit {
  match @core.layout_meta_data_service_get_algorithm_data(algorithm_id) {
    Some(_) => ()
    None =>
      @core.layout_meta_data_service_register_algorithm(
        @core.new_layout_algorithm_data(algorithm_id),
      )
  }
}

///|
fn elk_graph_json_core_delegate_register_additional_algorithms() -> Unit {
  let additional_algorithm_ids = [
    @mrtree.mrtree_algorithm_id,
    @force.force_algorithm_id,
    @force.stress_algorithm_id,
    @radial.radial_algorithm_id,
    @rectpacking.rectpacking_algorithm_id,
    @spore.spore_compaction_algorithm_id,
    @spore.spore_overlap_removal_algorithm_id,
    @vertiflex.vertiflex_algorithm_id,
  ]
  for algorithm_id in additional_algorithm_ids {
    elk_graph_json_core_delegate_register_algorithm_if_missing(algorithm_id)
  }
}

///|
fn elk_graph_json_core_delegate_initialize_runtime() -> Unit {
  if elk_graph_json_core_delegate_initialized.val {
    return
  }
  @core.layout_meta_data_service_register_default_options()
  @core.layout_meta_data_service_register_default_algorithms()
  @core.layout_meta_data_service_register_layout_meta_data_providers(
    @force.force_layout_meta_data_providers(),
  )
  elk_graph_json_core_delegate_register_additional_algorithms()
  elk_graph_json_core_delegate_initialized.val = true
}

///|
fn elk_graph_json_core_delegate_required_importer(
  maybe_importer : @core.Maybe[JsonImporter],
) -> JsonImporter {
  match maybe_importer.get() {
    Some(importer) => importer
    None => abort("missing importer")
  }
}

///|
fn elk_graph_json_core_layout_delegate(
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Unit {
  elk_graph_json_core_delegate_initialize_runtime()

  graph_obj["layoutOptions"] = Json::object(options.copy())

  let maybe_importer : @core.Maybe[JsonImporter] = @core.maybe_create()
  let root = elk_graph_json_for_json_graph(Json::object(graph_obj))
    .remember_importer(maybe_importer)
    .to_elk()

  let recursive_engine = @core.new_recursive_graph_layout_engine()
  recursive_engine.layout(root, @core.new_null_elk_progress_monitor())

  let importer = elk_graph_json_core_delegate_required_importer(maybe_importer)
  importer.transfer_layout(root)

  if importer.get_input_model() is Some(model) {
    let updated_model = model.copy()
    graph_obj.clear()
    updated_model.each((key, value) => graph_obj[key] = value)
  }
}

///|
fn init {
  @core.elk_engine_register_layout_delegate(elk_graph_json_core_layout_delegate)
}
