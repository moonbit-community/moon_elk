///|
test "GmfMetaDataProvider registers Draw2D algorithm support" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  layout_meta_data_service_register_layout_meta_data_providers(
    gmf_layout_meta_data_providers(),
  )

  let draw2d = layout_meta_data_service_get_algorithm_data(
    gmf_draw2d_algorithm_id,
  )
  inspect(draw2d is Some(_), content="true")
  inspect(
    match draw2d {
      Some(algorithm) => algorithm.knows_option(spacing_node_node.get_id())
      None => false
    },
    content="true",
  )
  inspect(
    match draw2d {
      Some(algorithm) => algorithm.knows_option(padding.get_id())
      None => false
    },
    content="true",
  )
  inspect(
    match draw2d {
      Some(algorithm) => algorithm.knows_option(direction.get_id())
      None => false
    },
    content="true",
  )
  inspect(
    match draw2d {
      Some(algorithm) => algorithm.knows_option(node_size_constraints.get_id())
      None => false
    },
    content="true",
  )
}
