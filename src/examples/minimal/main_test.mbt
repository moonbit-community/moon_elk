///|
test "minimal example returns laid out graph" {
  let output = layout_minimal_example()
  let graph = @json.parse(output)
  match graph {
    Object(fields) =>
      match fields.get("children") {
        Some(Array(children)) => {
          assert_eq(children.length(), 2)
          match children[0] {
            Object(node) => assert_true(node.get("x") is Some(Number(_, ..)))
            _ => fail("expected first child object")
          }
        }
        _ => fail("expected children array")
      }
    _ => fail("expected graph object")
  }
}
