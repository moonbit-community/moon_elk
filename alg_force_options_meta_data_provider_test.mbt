///|
fn option_targets_contain_parent(option_data : LayoutOptionData) -> Bool {
  for target in option_data.get_targets() {
    match target {
      ParentsTarget => return true
      _ => ()
    }
  }
  false
}

///|
fn option_targets_contain_edge(option_data : LayoutOptionData) -> Bool {
  for target in option_data.get_targets() {
    match target {
      EdgesTarget => return true
      _ => ()
    }
  }
  false
}

///|
test "ForceMetaDataProvider registers algorithms and category" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  layout_meta_data_service_register_layout_meta_data_providers(
    force_layout_meta_data_providers(),
  )
  let force_algorithm = layout_meta_data_service_get_algorithm_data(
    force_algorithm_id,
  )
  inspect(force_algorithm is Some(_), content="true")
  inspect(
    match force_algorithm {
      Some(algorithm) => algorithm.knows_option(force_model.get_id())
      None => false
    },
    content="true",
  )
  inspect(
    match force_algorithm {
      Some(algorithm) => algorithm.knows_option(force_repulsive_power.get_id())
      None => false
    },
    content="true",
  )
  let stress_algorithm = layout_meta_data_service_get_algorithm_data(
    stress_algorithm_id,
  )
  inspect(stress_algorithm is Some(_), content="true")
  inspect(
    match stress_algorithm {
      Some(algorithm) =>
        algorithm.knows_option(stress_desired_edge_length.get_id())
      None => false
    },
    content="true",
  )
  let force_category = layout_meta_data_service_get_category_data(
    force_category_id,
  )
  inspect(force_category is Some(_), content="true")
}

///|
test "ForceMetaDataProvider registers option metadata types and targets" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  layout_meta_data_service_register_layout_meta_data_providers(
    force_layout_meta_data_providers(),
  )
  let force_iterations_option = layout_meta_data_service_get_option_data(
    force_iterations.get_id(),
  )
  inspect(
    match force_iterations_option.get_type() {
      IntType => true
      _ => false
    },
    content="true",
  )
  inspect(
    option_targets_contain_parent(force_iterations_option),
    content="true",
  )
  let stress_edge_length_option = layout_meta_data_service_get_option_data(
    stress_desired_edge_length.get_id(),
  )
  inspect(
    match stress_edge_length_option.get_type() {
      DoubleType => true
      _ => false
    },
    content="true",
  )
  inspect(
    option_targets_contain_parent(stress_edge_length_option),
    content="true",
  )
  inspect(
    option_targets_contain_edge(stress_edge_length_option),
    content="true",
  )
  let stress_dimension_option = layout_meta_data_service_get_option_data_by_suffix(
    "stress.dimension",
  )
  inspect(stress_dimension_option is Some(_), content="true")
}
