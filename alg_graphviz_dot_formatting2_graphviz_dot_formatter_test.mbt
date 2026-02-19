///|
test "GraphvizDotFormatter normalizes text whitespace" {
  let formatter = new_graphviz_dot_formatter()
  inspect(
    formatter.format_text("digraph   {  a  ->  b ;\n\n c -> d; }"),
    content="digraph { a -> b ; c -> d; }",
  )
}

///|
test "GraphvizDotFormatter2 respects undefined-hidden-region-only flag" {
  let formatter2 = new_graphviz_dot_formatter2()
  let request = new_graphviz_dot_formatter_request()
  request.set_text("graph   { a -- b ; }")

  request.set_format_undefined_hidden_regions_only(true)
  inspect(formatter2(request), content="graph   { a -- b ; }")

  request.set_format_undefined_hidden_regions_only(false)
  inspect(formatter2(request), content="graph { a -- b ; }")
}
