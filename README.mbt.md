# Milky2018/moon_elk

A MoonBit port of Eclipse Layout Kernel (ELK).

- Repository: https://github.com/moonbit-community/moon_elk.git
- Keywords: elk, layout

## Package Layout

This module uses a `src/` layered package layout aligned to ELK reference package tails.

- Core packages: `core`, `graph`, `shared`
- Algorithm packages: `alg/common`, `alg/layered`, `alg/force`, `alg/mrtree`, `alg/radial`, `alg/rectpacking`, `alg/vertiflex`, `alg/disco`, `alg/graphviz/*`, ...
- Text/JSON stacks: `graph/text/*`, `graph/json/*`

## Breaking Changes

- Root flat package implementation is removed.
- CLI (`cmd/main`) is removed.
- Import concrete packages directly, for example:

```moonbit
import "Milky2018/moon_elk/core"
import "Milky2018/moon_elk/alg/layered"
import "Milky2018/moon_elk/graph/json"
```

## Development

```bash
moon check
moon test --no-render
```
