///|
test "GraphValidationException carries message and issues" {
  reset_graph_model_for_test()
  let root = create_graph()
  let issue = new_graph_issue_node(root, "invalid", issue_error)
  let exception = new_graph_validation_exception_message_issues(
    "graph invalid",
    [issue],
  )
  inspect(exception.get_message(), content="Some(\"graph invalid\")")
  let issues = exception.get_issues()
  inspect(
    match issues {
      Some(list) => list.length()
      None => 0
    },
    content="1",
  )
}

///|
test "IValidatingGraphElementVisitor exposes collected issues" {
  reset_graph_model_for_test()
  let root = create_graph()
  let visitor = new_validating_graph_element_visitor(_ => (), () => [
    new_graph_issue_node(root, "warn", issue_warning),
  ])
  visitor.visit(root)
  inspect(visitor.get_issues().length(), content="1")
}
