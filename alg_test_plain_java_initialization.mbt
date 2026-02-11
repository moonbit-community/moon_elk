///|
let plain_java_initialization_initialized : Ref[Bool] = Ref::new(false)

///|
fn plain_java_initialization_register_algorithm_if_missing(
  algorithm_id : String,
) -> Unit {
  match layout_meta_data_service_get_algorithm_data(algorithm_id) {
    Some(_) => ()
    None =>
      layout_meta_data_service_register_algorithm(
        new_layout_algorithm_data(algorithm_id),
      )
  }
}

///|
fn plain_java_initialization_register_additional_algorithms() -> Unit {
  let additional_algorithm_ids = [
    "org.eclipse.elk.disco", "org.eclipse.elk.force", "org.eclipse.elk.stress", "org.eclipse.elk.radial",
    rectpacking_algorithm_id, spore_compaction_algorithm_id, spore_overlap_removal_algorithm_id,
    vertiflex_algorithm_id,
  ]
  for algorithm_id in additional_algorithm_ids {
    plain_java_initialization_register_algorithm_if_missing(algorithm_id)
  }
}

///|
pub fn plain_java_initialization_initialize_plain_java_layout() -> Unit {
  if plain_java_initialization_initialized.val {
    return
  }
  layout_meta_data_service_register_default_options()
  layout_meta_data_service_register_default_algorithms()
  layout_meta_data_service_register_layout_meta_data_providers(
    force_layout_meta_data_providers(),
  )
  plain_java_initialization_register_additional_algorithms()
  plain_java_initialization_initialized.val = true
}

///|
pub fn plain_java_initialization_reset_for_test() -> Unit {
  plain_java_initialization_initialized.val = false
}
