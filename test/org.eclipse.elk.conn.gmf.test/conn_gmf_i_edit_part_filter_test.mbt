///|
test "IEditPartFilter default implementation accepts all edit parts" {
  reset_conn_gmf_foundation_for_test()
  let filter = new_i_edit_part_filter_default_impl()
  let edit_part = new_gmf_edit_part(GenericEditPart)
  inspect(filter.filter(edit_part), content="true")
}

///|
test "IEditPartFilter custom callback is honored" {
  reset_conn_gmf_foundation_for_test()
  let shape = new_gmf_edit_part(ShapeNodeEditPart)
  let border = new_gmf_edit_part(AbstractBorderItemEditPart)
  let filter = new_i_edit_part_filter(edit_part => {
    gmf_edit_part_kind(edit_part) == ShapeNodeEditPart
  })
  inspect(filter.filter(shape), content="true")
  inspect(filter.filter(border), content="false")
}
