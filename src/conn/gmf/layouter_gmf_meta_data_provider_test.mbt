///|
test "GmfMetaDataProvider registers Draw2D algorithm support" {
  let metadata = @core.new_layout_runtime().option_metadata()
  metadata.register_default_options()
  metadata.register_providers(gmf_layout_meta_data_providers())

  let draw2d = metadata.algorithm_data(gmf_draw2d_algorithm_id)
  inspect(draw2d is Some(_), content="true")
  inspect(
    match draw2d {
      Some(algorithm) =>
        algorithm.knows_option(@core.spacing_node_node.get_id())
      None => false
    },
    content="true",
  )
  inspect(
    match draw2d {
      Some(algorithm) => algorithm.knows_option(@core.padding.get_id())
      None => false
    },
    content="true",
  )
  inspect(
    match draw2d {
      Some(algorithm) => algorithm.knows_option(@core.direction.get_id())
      None => false
    },
    content="true",
  )
  inspect(
    match draw2d {
      Some(algorithm) =>
        algorithm.knows_option(@core.node_size_constraints.get_id())
      None => false
    },
    content="true",
  )
}
