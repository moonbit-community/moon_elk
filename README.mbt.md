# Milky2018/moon_elk

MoonBit port of Eclipse Layout Kernel (ELK).

- Repository: https://github.com/moonbit-community/moon_elk.git
- Keywords: `elk`, `layout`

## Add Imports

In your package `moon.pkg`, import the packages you need:

```moonbit
import {
  "Milky2018/moon_elk/graph" @elk_graph,
  "Milky2018/moon_elk/graph/json" @elk_graph_json,
}
```

## Quick Start

Build a graph and export it to ELK JSON:

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

Import ELK JSON into ELK graph model:

```moonbit
fn import_graph(text : String) -> Int {
  @elk_graph_json.elk_graph_json_for_graph(text).to_elk()
}
```

## Main Packages

- `Milky2018/moon_elk/graph`: ELK graph model (nodes, ports, edges, labels, properties).
- `Milky2018/moon_elk/graph/json`: JSON import/export for ELK graphs.
- `Milky2018/moon_elk/core`: layout options, metadata, and core layout infrastructure.
- `Milky2018/moon_elk/core/service`: service-style layout orchestration.
- `Milky2018/moon_elk/alg/layered`: layered layout algorithm.
- `Milky2018/moon_elk/alg/force`: force-directed layout algorithm.
- `Milky2018/moon_elk/alg/radial`: radial layout algorithm.
- `Milky2018/moon_elk/alg/mrtree`: tree layout algorithm.
- `Milky2018/moon_elk/alg/rectpacking`: rectangle packing layout algorithm.
- `Milky2018/moon_elk/alg/vertiflex`: y-constraint tree layout algorithm.
- `Milky2018/moon_elk/alg/disco`: disconnected components compaction.
- `Milky2018/moon_elk/graph/text` and `Milky2018/moon_elk/graph/json/text`: textual graph formats.
