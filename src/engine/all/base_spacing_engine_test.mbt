// Expected coordinates are what elkjs 0.9.3 produces for the same graphs.

///|
fn base_spacing_positions(layout_options : Map[String, Json]) -> String raise {
  let node = (id : String) => {
    Json::object({
      "id": Json::string(id),
      "width": Json::number(80.0),
      "height": Json::number(40.0),
    })
  }
  let edge = (id : String, source : String, target : String) => {
    Json::object({
      "id": Json::string(id),
      "sources": Json::array([Json::string(source)]),
      "targets": Json::array([Json::string(target)]),
    })
  }
  let graph = Json::object({
    "id": Json::string("root"),
    "layoutOptions": Json::object(layout_options),
    "children": Json::array([node("n1"), node("n2"), node("n3")]),
    "edges": Json::array([edge("e1", "n1", "n2"), edge("e2", "n1", "n3")]),
  })
  let result = @all.new_elk_engine().layout(graph~)
  guard result is Object({ "children": Array(children), .. }) else {
    fail("expected a laid out graph")
  }
  let positions = []
  for child in children {
    guard child
      is Object(
        { "id": String(id), "x": Number(x, ..), "y": Number(y, ..), .. },
      ) else {
      fail("expected a positioned node")
    }
    positions.push("\{id}: \{x}, \{y}")
  }
  positions.join("\n")
}

///|
test "spacing.baseValue scales the spacings a graph does not set itself" {
  inspect(
    base_spacing_positions({
      "elk.algorithm": Json::string("layered"),
      "elk.direction": Json::string("DOWN"),
      "spacing.baseValue": Json::number(40.0),
    }),
    content=(
      #|n1: 25.333333333333332, 12
      #|n2: 12, 92
      #|n3: 132, 92
    ),
  )
}

///|
test "an explicit spacing wins over spacing.baseValue" {
  inspect(
    base_spacing_positions({
      "elk.algorithm": Json::string("layered"),
      "elk.direction": Json::string("DOWN"),
      "spacing.baseValue": Json::number(40.0),
      "elk.spacing.nodeNode": Json::number(15.0),
    }),
    content=(
      #|n1: 25.333333333333332, 12
      #|n2: 12, 92
      #|n3: 107, 92
    ),
  )
}
