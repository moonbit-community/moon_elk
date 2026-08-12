///|
test "all composition advertises every installed in-process algorithm" {
  debug_inspect(
    @all.new_elk_engine().known_layout_algorithms(),
    content=(
      #|[
      #|  "fixed",
      #|  "box",
      #|  "random",
      #|  "layered",
      #|  "force",
      #|  "stress",
      #|  "radial",
      #|  "mrtree",
      #|  "rectpacking",
      #|  "sporeOverlap",
      #|  "sporeCompaction",
      #|  "vertiflex",
      #|  "disco",
      #|]
    ),
  )
}

///|
test "all composition executes advertised VertiFlex algorithm" {
  let graph = Json::object({
    "id": Json::string("root"),
    "layoutOptions": Json::object({ "elk.algorithm": Json::string("vertiflex") }),
    "children": Json::array([
      Json::object({
        "id": Json::string("parent"),
        "width": Json::number(20),
        "height": Json::number(10),
      }),
      Json::object({
        "id": Json::string("child"),
        "width": Json::number(10),
        "height": Json::number(10),
      }),
    ]),
    "edges": Json::array([
      Json::object({
        "id": Json::string("edge"),
        "sources": Json::array([Json::string("parent")]),
        "targets": Json::array([Json::string("child")]),
      }),
    ]),
  })
  let result = try @all.new_elk_engine().layout(graph~) catch {
    error => Err(error)
  } noraise {
    output => Ok(output)
  }
  guard result is Ok(Object(output)) else {
    fail("advertised VertiFlex algorithm must execute through ElkEngine")
  }
  guard output.get("children") is Some(Array(children)) else {
    fail("layout output must contain children")
  }
  guard children is [Object(parent), Object(child)] else {
    fail("layout output must preserve the input tree")
  }
  guard parent.get("y") is Some(Number(parent_y, repr~)) else {
    fail("VertiFlex must place the parent node")
  }
  ignore(repr)
  guard child.get("y") is Some(Number(child_y, repr~)) else {
    fail("VertiFlex must place the child node")
  }
  ignore(repr)
  assert_true(child_y > parent_y)
  guard output.get("edges") is Some(Array([Object(edge)])) else {
    fail("layout output must preserve the tree edge")
  }
  guard edge.get("sections") is Some(Array(sections)) else {
    fail("VertiFlex must route the tree edge")
  }
  assert_true(!sections.is_empty())
}
