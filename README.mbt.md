# Milky2018/moon_elk

A MoonBit port of Eclipse Layout Kernel (ELK).

- Repository: https://github.com/moonbit-community/moon_elk.git
- Current version: `0.1.11`
- Keywords: `elk`, `layout`

## Imports

In `moon.pkg`, import the packages you use:

```moonbit
import {
  "moonbitlang/core/json" @json,
  "Milky2018/moon_elk/core" @elk_core,
  "Milky2018/moon_elk/graph" @elk_graph,
  "Milky2018/moon_elk/graph/json" @elk_graph_json,
}
```

## Layout JSON with Core Engine

```moonbit
pub fn layout_json(input : String) -> String raise {
  let graph = @json.parse(input)
  @elk_core.new_elk_engine().layout(graph~).stringify()
}
```

### Minimal Input Example

```json
{
  "id": "root",
  "layoutOptions": {
    "elk.algorithm": "layered",
    "elk.direction": "DOWN"
  },
  "children": [
    { "id": "n1", "width": 80, "height": 40 },
    { "id": "n2", "width": 80, "height": 40 }
  ],
  "edges": [
    { "id": "e1", "sources": ["n1"], "targets": ["n2"] }
  ]
}
```

```moonbit
pub fn run_minimal_example() -> String raise {
  let input =
    "{\"id\":\"root\",\"layoutOptions\":{\"elk.algorithm\":\"layered\",\"elk.direction\":\"DOWN\"},\"children\":[{\"id\":\"n1\",\"width\":80,\"height\":40},{\"id\":\"n2\",\"width\":80,\"height\":40}],\"edges\":[{\"id\":\"e1\",\"sources\":[\"n1\"],\"targets\":[\"n2\"]}]}"
  layout_json(input)
}
```

## Build Graph Model and Export JSON

```moonbit
fn build_and_export() -> String {
  let root = @elk_graph.create_graph()
  let n1 = @elk_graph.create_node(Some(root))
  let n2 = @elk_graph.create_node(Some(root))
  ignore(@elk_graph.create_simple_edge(n1, n2))

  @elk_graph_json
    .elk_graph_json_for_elk_graph(root)
    .pretty_print(true)
    .to_json()
}
```

## Import JSON into Graph Model

```moonbit
fn import_graph(text : String) -> Int {
  @elk_graph_json.elk_graph_json_for_graph(text).to_elk()
}
```

## Algorithm Support (Core Engine)

Supported by `new_elk_engine().layout`:

- `layered`
- `force`
- `stress`
- `radial`
- `mrtree`
- `rectpacking`
- `sporeOverlap`
- `sporeCompaction`
- `fixed`
- `box`
- `random`
- `vertiflex`

Not supported (returns algorithm-not-found style errors):

- `disco`
- `topdownpacking`
- `libavoid`
- Graphviz family (`dot`, `neato`, `fdp`, `sfdp`, `twopi`, `circo`)

## Coordinate Semantics for Edges

ELK edge `sections[*].startPoint/endPoint/bendPoints` are in the coordinate system of `edge.container` (local coordinates), not always root-absolute coordinates.

When rendering, convert edge points to absolute coordinates by adding the accumulated parent offsets of `edge.container`.
