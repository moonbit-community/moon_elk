///|
fn port_context_creator_create_port_context(
  node_context : NodeContext,
  port : LPort,
  volatile_id : Int,
  im_port_labels : Bool,
) -> Unit {
  let port_context = new_port_context(node_context, port, volatile_id)
  node_context_add_port_context(node_context, port.get_side(), port_context)

  // Port label handling requires adapting LLabel to the label cell's ElkLabel contract.
  // Keep the behavior equivalent for unlabeled ports, which is the dominant layered case.
  if im_port_labels &&
    !port_label_placement_is_fixed(node_context.port_labels_placement) &&
    !port.get_labels().is_empty() {
    ignore(port_context)
  }
}

///|
pub fn port_context_creator_create_port_contexts(
  node_context : NodeContext,
  ignore_inside_port_labels : Bool,
) -> Unit {
  let im_port_labels = !ignore_inside_port_labels ||
    !node_context.has_port_label_placement(Inside)

  let mut volatile_id = 0
  for port in node_context.node.get_ports() {
    if port_side_to_string(port.get_side()) ==
      port_side_to_string(SideUndefined) {
      abort(
        "Label and node size calculator can only be used with ports that have port sides assigned.",
      )
    }

    port_context_creator_create_port_context(
      node_context, port, volatile_id, im_port_labels,
    )
    volatile_id += 1
  }
}
