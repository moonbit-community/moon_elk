///|
test "IInitializable traverses layers, nodes, ports, and edges in order" {
  let n00 = new_l_node()
  let n01 = new_l_node()
  let n10 = new_l_node()

  let p00 = new_l_port()
  p00.set_node(Some(n00))
  let p01 = new_l_port()
  p01.set_node(Some(n01))
  let p10 = new_l_port()
  p10.set_node(Some(n10))

  let e00 = new_l_edge()
  e00.set_id(100)
  e00.set_source(Some(p00))
  e00.set_target(Some(p10))

  let e01 = new_l_edge()
  e01.set_id(101)
  e01.set_source(Some(p01))
  e01.set_target(Some(p10))

  let order = [[n00, n01], [n10]]
  let events = []

  let initializable = new_i_initializable(
    init_at_layer_level=(l, _) => events.push("L" + l.to_string()),
    init_at_node_level=(l, n, _) => {
      events.push("N" + l.to_string() + "," + n.to_string())
    },
    init_at_port_level=(l, n, p, _) => {
      events.push(
        "P" + l.to_string() + "," + n.to_string() + "," + p.to_string(),
      )
    },
    init_at_edge_level=(l, n, p, e, edge, _) => {
      events.push(
        "E" +
        l.to_string() +
        "," +
        n.to_string() +
        "," +
        p.to_string() +
        "," +
        e.to_string() +
        "," +
        edge.get_id().to_string(),
      )
    },
    init_after_traversal=() => events.push("DONE"),
  )

  i_initializable_init([initializable], order)

  inspect(
    events,
    content="[\"L0\", \"N0,0\", \"P0,0,0\", \"E0,0,0,0,100\", \"N0,1\", \"P0,1,0\", \"E0,1,0,0,101\", \"L1\", \"N1,0\", \"P1,0,0\", \"E1,0,0,0,100\", \"E1,0,0,1,101\", \"DONE\"]",
  )
}

///|
test "ICrossingMinimizationHeuristic delegates behavior and init hooks" {
  let first_layer_order_calls : Ref[Int] = Ref(0)
  let minimized_free_layer_index : Ref[Int] = Ref(-1)
  let forward_sweep_seen : Ref[Bool] = Ref(false)
  let first_sweep_seen : Ref[Bool] = Ref(false)
  let init_events = []

  let heuristic = new_i_crossing_minimization_heuristic(
    () => true,
    (_, forward_sweep) => {
      first_layer_order_calls.val = first_layer_order_calls.val + 1
      forward_sweep
    },
    (_, free_layer_index, forward_sweep, is_first_sweep) => {
      minimized_free_layer_index.val = free_layer_index
      forward_sweep_seen.val = forward_sweep
      first_sweep_seen.val = is_first_sweep
      free_layer_index == 1 && forward_sweep && !is_first_sweep
    },
    () => false,
    init_at_layer_level=(l, _) => init_events.push("L" + l.to_string()),
    init_after_traversal=() => init_events.push("DONE"),
  )

  assert_eq(heuristic.always_improves(), true)

  let order = [[new_l_node()], [new_l_node()]]
  assert_eq(heuristic.set_first_layer_order(order, true), true)
  assert_eq(first_layer_order_calls.val, 1)

  assert_eq(heuristic.minimize_crossings(order, 1, true, false), true)
  assert_eq(minimized_free_layer_index.val, 1)
  assert_eq(forward_sweep_seen.val, true)
  assert_eq(first_sweep_seen.val, false)
  assert_eq(heuristic.is_deterministic(), false)

  i_crossing_minimization_heuristic_init([heuristic], order)
  inspect(init_events, content="[\"L0\", \"L1\", \"DONE\"]")
}
