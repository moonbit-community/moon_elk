///|
fn setup_content_assist_test_registry() -> Unit {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()
  layout_meta_data_service_register_default_options()
}

///|
fn option_proposals_have_id(
  proposals : Array[LayoutDataProposal[LayoutOptionData]],
  option_id : String,
) -> Bool {
  for proposal in proposals {
    if proposal.get_data().get_id() == option_id {
      return true
    }
  }
  false
}

///|
fn option_proposal_text_by_id(
  proposals : Array[LayoutDataProposal[LayoutOptionData]],
  option_id : String,
) -> String? {
  for proposal in proposals {
    if proposal.get_data().get_id() == option_id {
      return Some(proposal.get_proposal())
    }
  }
  None
}

///|
fn algorithm_proposals_have_id(
  proposals : Array[LayoutDataProposal[LayoutAlgorithmData]],
  algorithm_id : String,
) -> Bool {
  for proposal in proposals {
    if proposal.get_data().get_id() == algorithm_id {
      return true
    }
  }
  false
}

///|
test "LayoutDataContentAssist supports node option id/name prefixes" {
  reset_graph_model_for_test()
  setup_content_assist_test_registry()
  let root = create_graph()
  ignore(create_node(Some(root)))
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals(
        root, "org.eclipse.elk.portConstraints",
      ),
      port_constraints.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals(
        root, "eclipse.elk.portConstraints",
      ),
      port_constraints.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals(
        root, "elk.portConstraints",
      ),
      port_constraints.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals(
        root, "portConstraints",
      ),
      port_constraints.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals(root, "portCo"),
      port_constraints.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals(root, "rt Constr"),
      port_constraints.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals(root, ""),
      padding.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals(root, ""),
      alignment.get_id(),
    ),
    content="true",
  )
}

///|
test "LayoutDataContentAssist supports edge and port option prefixes" {
  reset_graph_model_for_test()
  setup_content_assist_test_registry()
  let root = create_graph()
  let child = create_node(Some(root))
  let edge = create_edge(Some(root))
  let port = create_port(Some(child))
  let label = create_label(Some(make_node_label_parent(child)))
  ignore(edge)
  ignore(port)
  ignore(label)
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals_for_edge(
        edge, "prio",
      ),
      priority.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals_for_port(
        port, "port.sid",
      ),
      port_side.get_id(),
    ),
    content="true",
  )
  inspect(
    option_proposals_have_id(
      layout_data_content_assist_get_layout_option_proposals_for_label(
        label, "nodeLabels.pla",
      ),
      node_labels_placement.get_id(),
    ),
    content="true",
  )
}

///|
test "LayoutDataContentAssist respects parent and child node targets" {
  reset_graph_model_for_test()
  setup_content_assist_test_registry()
  let root = create_graph()
  let child = create_node(Some(root))
  let parent_proposals = layout_data_content_assist_get_layout_option_proposals(
    root,
    algorithm.get_id(),
  )
  inspect(
    option_proposals_have_id(parent_proposals, algorithm.get_id()),
    content="true",
  )
  let child_proposals = layout_data_content_assist_get_layout_option_proposals(
    child,
    algorithm.get_id(),
  )
  inspect(
    option_proposals_have_id(child_proposals, algorithm.get_id()),
    content="false",
  )
}

///|
test "LayoutDataContentAssist respects algorithm specific known options" {
  reset_graph_model_for_test()
  setup_content_assist_test_registry()
  let root = create_graph()
  ignore(create_node(Some(root)))
  node_set_layout_option_string_by_id(
    root,
    algorithm.get_id(),
    "org.eclipse.elk.box",
  )
  let proposals = layout_data_content_assist_get_layout_option_proposals(
    root,
    expand_nodes.get_id(),
  )
  inspect(
    option_proposals_have_id(proposals, expand_nodes.get_id()),
    content="true",
  )
}

///|
test "LayoutDataContentAssist hides unknown options for selected algorithm" {
  reset_graph_model_for_test()
  setup_content_assist_test_registry()
  let root = create_graph()
  ignore(create_node(Some(root)))
  node_set_layout_option_string_by_id(
    root,
    algorithm.get_id(),
    "org.eclipse.elk.fixed",
  )
  let proposals = layout_data_content_assist_get_layout_option_proposals(
    root,
    expand_nodes.get_id(),
  )
  inspect(
    option_proposals_have_id(proposals, expand_nodes.get_id()),
    content="false",
  )
}

///|
test "LayoutDataContentAssist keeps option group in proposal suffix" {
  reset_graph_model_for_test()
  setup_content_assist_test_registry()
  let root = create_graph()
  ignore(create_node(Some(root)))
  let proposals = layout_data_content_assist_get_layout_option_proposals(
    root, "nodeN",
  )
  let proposal_text = option_proposal_text_by_id(
    proposals,
    spacing_node_node.get_id(),
  )
  inspect(proposal_text is Some(_), content="true")
  inspect(
    match proposal_text {
      Some(text) => text.contains("spacing")
      None => false
    },
    content="true",
  )
}

///|
test "LayoutDataContentAssist suggests algorithms by suffix" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()
  let proposals = layout_data_content_assist_get_layout_algorithm_proposals(
    "layer",
  )
  inspect(
    algorithm_proposals_have_id(proposals, "org.eclipse.elk.layered"),
    content="true",
  )
}
