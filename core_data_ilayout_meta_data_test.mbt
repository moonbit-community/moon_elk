///|
test "ILayoutMetaData adapters expose common fields" {
  let algorithm_data = new_layout_algorithm_data(
    "org.eclipse.elk.test.algorithm.meta",
    name="Meta Algorithm",
    description="meta description",
  )
  let algorithm_meta = layout_meta_data_for_algorithm(algorithm_data)
  inspect(
    algorithm_meta.get_id(),
    content="org.eclipse.elk.test.algorithm.meta",
  )
  inspect(algorithm_meta.get_name(), content="Meta Algorithm")
  inspect(algorithm_meta.get_description(), content="meta description")
  let option_data = new_layout_option_data(
    "org.eclipse.elk.test.option.meta",
    name="Meta Option",
    description="option description",
    group="meta",
  )
  let option_meta = layout_meta_data_for_option(option_data)
  inspect(option_meta.get_name(), content="Meta Option")
  inspect(option_meta.get_description(), content="option description")
}
