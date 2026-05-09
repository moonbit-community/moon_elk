///|
test "layout_option_proxy set_proxy_value stores proxy by key" {
  let holder : Map[String, LayoutOptionProxy] = {}
  layout_option_proxy_set_proxy_value(holder, "org.eclipse.elk.test.opt", "42")
  inspect(
    match holder.get("org.eclipse.elk.test.opt") {
      Some(proxy) => proxy.to_string()
      None => ""
    },
    content="42",
  )
}

///|
test "layout_option_proxy resolve_value resolves by property metadata" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  let property : @graph.IProperty[String] = @graph.new_property(
    no_layout.get_id(),
    "",
  )
  let proxy = new_layout_option_proxy("1")
  debug_inspect(proxy.resolve_value(Some(property)), content="Some(\"true\")")
  debug_inspect(proxy.resolve_value(None), content="None")
}

///|
test "layout_option_proxy resolve_value_with_option mirrors parse_value" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  let option_data = match
    layout_meta_data_service_get_option_data_opt(content_alignment.get_id()) {
    Some(value) => value
    None => abort("expected default option metadata for content alignment")
  }
  let proxy = new_layout_option_proxy("A, B  C")
  debug_inspect(
    proxy.resolve_value_with_option(Some(option_data)),
    content="Some(\"A B C\")",
  )
  debug_inspect(proxy.resolve_value_with_option(None), content="None")
}

///|
test "layout_option_proxy equals and hash_code are value based" {
  let first = new_layout_option_proxy("sample")
  let second = new_layout_option_proxy("sample")
  let different = new_layout_option_proxy("other")
  inspect(first.equals(second), content="true")
  inspect(first.equals(different), content="false")
  inspect(first.hash_code() == second.hash_code(), content="true")
}
