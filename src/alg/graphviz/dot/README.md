# Graphviz DOT packages

The parent `dot` package owns the DOT syntax model, parser, formatter, and
serializer. The `transform` package owns conversion between that syntax model
and ELK graphs, including importer/exporter settings and transformation data.

The dependency points from `transform` to `dot`; the syntax model never depends
on transformation behavior. Graphviz layout integration imports both packages
and composes them explicitly.
