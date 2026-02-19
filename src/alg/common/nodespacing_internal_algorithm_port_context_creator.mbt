///|
fn port_context_creator_create_port_context(
  node_context : NodeContext,
  port : @core.ElkPortAdapter,
  volatile_id : Int,
  im_port_labels : Bool,
) -> Unit {
  let port_context = new_port_context(node_context, port, volatile_id)
  node_context_add_port_context(node_context, port.get_side(), port_context)

  if im_port_labels &&
    !@core.port_label_placement_is_fixed(node_context.port_labels_placement) {
    let port_label_cell = new_label_cell(node_context.label_label_spacing)
    for label in port.get_labels() {
      port_label_cell.add_l_label(label)
    }
    port_context.port_label_cell = Some(port_label_cell)
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
    if @core.port_side_to_string(port.get_side()) ==
      @core.port_side_to_string(SideUndefined) {
      abort(
        "Label and node size calculator can only be used with ports that have port sides assigned.",
      )
    }

    port.set_volatile_id(volatile_id)
    port_context_creator_create_port_context(
      node_context, port, volatile_id, im_port_labels,
    )
    volatile_id += 1
  }
}
