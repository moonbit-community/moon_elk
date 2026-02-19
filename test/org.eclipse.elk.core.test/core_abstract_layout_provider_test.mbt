///|
test "AbstractLayoutProvider forwards lifecycle and layout calls" {
  let initialized = Ref::new("")
  let disposed = Ref::new(false)
  let laid_out_node = Ref::new(-1)
  let provider = new_abstract_layout_provider(
    (node, monitor) => {
      ignore(monitor)
      laid_out_node.val = node
    },
    initialize_fn=parameter => {
      initialized.val = match parameter {
        Some(value) => value
        None => ""
      }
    },
    dispose_fn=() => disposed.val = true,
  )
  provider.initialize(Some("box"))
  let root = create_graph()
  let monitor = new_elk_progress_monitor()
  provider.layout(root, monitor)
  provider.dispose()
  inspect(initialized.val, content="box")
  inspect(laid_out_node.val == root, content="true")
  inspect(disposed.val, content="true")
}

///|
test "IGraphLayoutEngine adapter forwards layout call" {
  let touched = Ref::new(false)
  let engine = new_graph_layout_engine((node, monitor) => {
    ignore(node)
    ignore(monitor)
    touched.val = true
  })
  engine.layout(create_graph(), new_elk_progress_monitor())
  inspect(touched.val, content="true")
}

///|
test "ITopdownLayoutProvider returns predicted size" {
  let provider = new_topdown_layout_provider(_ => new_kvector_xy(12.0, 8.0))
  let size = provider.get_predicted_graph_size(create_graph())
  inspect(size.to_string(), content="(12,8)")
}
