///|
fn network_simplex_test_create_edge_or_abort(builder : NEdgeBuilder) -> NEdge {
  try builder.create() catch {
    err => abort(err.to_string())
  } noraise {
    edge => edge
  }
}

///|
fn generate_random_graph(random : @random.Rand) -> NGraph {
  let graph = new_ngraph()
  let n = 4000
  let e = 8000
  for i in 0..<n {
    ignore(nnode_of().id(i).create(graph))
  }
  for _ in 0..<e {
    let src = random.int(limit=n)
    let mut tgt = random.int(limit=n)
    while src == tgt {
      tgt = random.int(limit=n)
    }
    ignore(
      network_simplex_test_create_edge_or_abort(
        nedge_of()
        .delta(random.int(limit=50))
        .weight(random.double() * 50.0)
        .source(graph.nodes[src])
        .target(graph.nodes[tgt]),
      ),
    )
  }
  // Keep a long deterministic path in every graph. It guards the explicit
  // NetworkSimplex traversal stacks against regressions to recursion, which
  // overflows the legacy Wasm host call stack at this depth.
  for i in 0..<(n - 1) {
    ignore(
      network_simplex_test_create_edge_or_abort(
        nedge_of()
        .delta(random.int(limit=50))
        .weight(random.double() * 50.0)
        .source(graph.nodes[i])
        .target(graph.nodes[i + 1]),
      ),
    )
  }
  for node in graph.nodes {
    let outgoing = []
    for edge in node.get_outgoing_edges() {
      outgoing.push(edge)
    }
    for edge in outgoing {
      if edge.get_source().get_id() > edge.get_target().get_id() {
        ignore(edge.reverse())
      }
    }
  }
  graph
}

///|
test "NetworkSimplex deltas" {
  let seed_buffer = Buffer()
  seed_buffer.write_int64_le(1)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  let random = @random.Rand::chacha8(seed=seed_buffer.to_bytes())
  for _ in 0..<5 {
    for _ in 0..<5 {
      let graph = generate_random_graph(random)
      assert_true(graph.is_acyclic())
      network_simplex_for_graph(graph).execute()
      for node in graph.nodes {
        for edge in node.get_outgoing_edges() {
          assert_true(
            edge.get_target().get_layer() - edge.get_source().get_layer() >=
            edge.get_delta(),
          )
        }
      }
    }
  }
}
