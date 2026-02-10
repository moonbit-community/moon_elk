///|
pub let gmf_draw2d_algorithm_id : String = "org.eclipse.elk.conn.gmf.draw2d"

///|
fn gmf_register_draw2d_algorithm(registry : LayoutMetaDataRegistry) -> Unit {
  registry.register_algorithm(
    new_layout_algorithm_data(
      gmf_draw2d_algorithm_id,
      name="Draw2D Layout",
      description="'Directed Graph Layout' provided by the Draw2D framework.",
    ),
  )
  registry.add_option_support(
    gmf_draw2d_algorithm_id,
    spacing_node_node.get_id(),
    Some("16"),
  )
  registry.add_option_support(
    gmf_draw2d_algorithm_id,
    padding.get_id(),
    Some("[left=16, top=16, right=16, bottom=16]"),
  )
  registry.add_option_support(
    gmf_draw2d_algorithm_id,
    direction.get_id(),
    Some("RIGHT"),
  )
  registry.add_option_support(
    gmf_draw2d_algorithm_id,
    node_size_constraints.get_id(),
    None,
  )
}

///|
pub fn new_gmf_meta_data_provider() -> ILayoutMetaDataProvider {
  new_layout_meta_data_provider(registry => {
    gmf_register_draw2d_algorithm(registry)
  })
}

///|
pub fn gmf_layout_meta_data_providers() -> Array[ILayoutMetaDataProvider] {
  [new_gmf_meta_data_provider()]
}
