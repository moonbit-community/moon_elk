///|
test "LayeredPhases keep upstream constant names and order" {
  debug_inspect(
    layered_phase_values(),
    content=(
      #|[
      #|  "P1_CYCLE_BREAKING",
      #|  "P2_LAYERING",
      #|  "P3_NODE_ORDERING",
      #|  "P4_NODE_PLACEMENT",
      #|  "P5_EDGE_ROUTING",
      #|]
    ),
  )
}

///|
test "LayeredIGraphTransformer delegates import and apply" {
  let seen_input : Ref[String] = Ref("")
  let seen_applied_id : Ref[Int] = Ref(-1)

  let imported_graph = new_l_graph()
  imported_graph.set_id(17)

  let transformer = new_layered_igraph_transformer(
    graph_name => {
      seen_input.val = graph_name
      if graph_name == "supported" {
        Some(imported_graph)
      } else {
        None
      }
    },
    layered_graph => seen_applied_id.val = layered_graph.get_id(),
  )

  match transformer.import_graph("supported") {
    Some(graph) => @core_debug.assert_eq(graph.get_id(), 17)
    None => fail("expected graph to be imported")
  }
  @core_debug.assert_eq(seen_input.val, "supported")

  match transformer.import_graph("unsupported") {
    Some(_) => fail("unsupported graph must return None")
    None => ()
  }

  transformer.apply_layout(imported_graph)
  @core_debug.assert_eq(seen_applied_id.val, 17)
}

///|
test "Layered hierarchy-aware marker is constructible" {
  debug_inspect(new_layered_hierarchy_aware_layout_processor(), content="()")
}
