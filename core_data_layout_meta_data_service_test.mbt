///|
test "LayoutMetaDataService registers expanded core options" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  let algorithm_option = layout_meta_data_service_get_option_data(
    algorithm.get_id(),
  )
  inspect(algorithm_option.get_name(), content="Algorithm")
  inspect(algorithm_option.get_group(), content="algorithm")
  inspect(
    match algorithm_option.get_type() {
      StringType => true
      _ => false
    },
    content="true",
  )
  let port_constraints_option = layout_meta_data_service_get_option_data(
    port_constraints.get_id(),
  )
  inspect(port_constraints_option.get_group(), content="port")
  inspect(
    match port_constraints_option.get_type() {
      StringType => true
      _ => false
    },
    content="true",
  )
  let node_size_constraints_option = layout_meta_data_service_get_option_data(
    node_size_constraints.get_id(),
  )
  inspect(node_size_constraints_option.get_group(), content="nodeSize")
  inspect(
    match node_size_constraints_option.get_type() {
      EnumSetType => true
      _ => false
    },
    content="true",
  )
  let expand_nodes_option = layout_meta_data_service_get_option_data(
    expand_nodes.get_id(),
  )
  inspect(
    match expand_nodes_option.get_type() {
      BoolType => true
      _ => false
    },
    content="true",
  )
}

///|
test "LayoutMetaDataService resolves option metadata by suffix" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  let full = layout_meta_data_service_get_option_data_by_suffix(
    "org.eclipse.elk.portConstraints",
  )
  inspect(full is Some(_), content="true")
  let short = layout_meta_data_service_get_option_data_by_suffix(
    "portConstraints",
  )
  inspect(short is Some(_), content="true")
  let unknown = layout_meta_data_service_get_option_data_by_suffix(
    "notExisting",
  )
  inspect(unknown is None, content="true")
}

///|
test "LayoutMetaDataService exposes algorithm/option collections" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()
  layout_meta_data_service_register_default_options()
  inspect(
    layout_meta_data_service_algorithm_data_values().length() >= 2,
    content="true",
  )
  inspect(
    layout_meta_data_service_option_data_values().length() >= 10,
    content="true",
  )
}

///|
test "LayoutMetaDataService registers and returns categories" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_category(
    new_layout_category_data(
      "org.eclipse.elk.category.layered",
      name="Layered",
      description="Layer-based category",
    ),
  )
  let layered = layout_meta_data_service_get_category_data(
    "org.eclipse.elk.category.layered",
  )
  inspect(layered is Some(_), content="true")
  inspect(
    match layered {
      Some(category) => category.get_name()
      None => ""
    },
    content="Layered",
  )
  inspect(layout_meta_data_service_category_data_values().length(), content="1")
}

///|
test "LayoutMetaDataService applies provider registry hooks" {
  layout_meta_data_service_reset_for_test()
  let provider = new_layout_meta_data_provider(registry => {
    registry.register_option(
      new_layout_option_data(
        "org.eclipse.elk.test.option",
        name="Test Option",
        description="provider option",
        group="test",
      ),
    )
    registry.register_algorithm(
      new_layout_algorithm_data(
        "org.eclipse.elk.test.algorithm",
        name="Test Algorithm",
        description="provider algorithm",
      ),
    )
    registry.register_category(
      new_layout_category_data(
        "org.eclipse.elk.test.category",
        name="Test Category",
        description="provider category",
      ),
    )
    registry.add_option_support(
      "org.eclipse.elk.test.algorithm",
      "org.eclipse.elk.test.option",
      None,
    )
  })
  layout_meta_data_service_register_layout_meta_data_provider(provider)
  let option_data = layout_meta_data_service_get_option_data(
    "org.eclipse.elk.test.option",
  )
  inspect(option_data.get_description(), content="provider option")
  let algorithm_data = layout_meta_data_service_get_algorithm_data(
    "org.eclipse.elk.test.algorithm",
  )
  inspect(algorithm_data is Some(_), content="true")
  inspect(
    match algorithm_data {
      Some(data) => data.knows_option("org.eclipse.elk.test.option")
      None => false
    },
    content="true",
  )
  let category_data = layout_meta_data_service_get_category_data(
    "org.eclipse.elk.test.category",
  )
  inspect(category_data is Some(_), content="true")
}
