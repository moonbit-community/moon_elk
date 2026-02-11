///|
fn shared_elk_reflect_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
test "ElkReflectTest simple property defaults are accessible" {
  shared_elk_reflect_test_setup_plain_java_layout()

  let double_properties : Array[IProperty[Double]] = [
    spacing_node_node, aspect_ratio, priority, rectpacking_width_approximation_target_width,
    radial_radius,
  ]
  for property in double_properties {
    assert_true(!property.get_id().is_empty())
    ignore(property.get_default())
  }

  let bool_properties : Array[IProperty[Bool]] = [
    interactive, no_layout, rectpacking_interactive, spore_compaction_orthogonal,
    vertiflex_consider_node_model_order,
  ]
  for property in bool_properties {
    assert_true(!property.get_id().is_empty())
    ignore(property.get_default())
  }

  let string_properties : Array[IProperty[String]] = [
    algorithm, direction, port_constraints, radial_compactor, spore_underlying_layout_algorithm,
  ]
  for property in string_properties {
    assert_true(!property.get_id().is_empty())
    ignore(property.get_default())
  }

  let string_set_properties : Array[IProperty[Array[String]]] = [
    content_alignment, node_size_constraints, node_size_options, node_labels_placement,
    port_labels_placement,
  ]
  for property in string_set_properties {
    assert_true(!property.get_id().is_empty())
    ignore(property.get_default())
  }
}

///|
test "ElkReflectTest layout option data parse does not fail for known types" {
  shared_elk_reflect_test_setup_plain_java_layout()

  let options = layout_meta_data_service_option_data_values()
  assert_true(!options.is_empty())
  for option in options {
    let sample = match option.get_type() {
      BoolType => "true"
      IntType => "42"
      DoubleType => "4.2"
      EnumSetType => "INSIDE,V_TOP"
      ObjectType => "sample"
      StringType => "sample"
    }
    let parsed = option.parse_value(sample)
    assert_true(!parsed.is_empty())
  }
}
