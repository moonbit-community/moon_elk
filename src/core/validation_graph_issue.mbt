///|
pub type GraphIssueSeverity = Int

///|
pub let issue_error : GraphIssueSeverity = 1

///|
pub let issue_warning : GraphIssueSeverity = 2

///|
pub(all) enum GraphIssueTarget {
  NodeIssueTarget(@graph.ElkNode)
  EdgeIssueTarget(@graph.ElkEdge)
}

///|
pub(all) struct GraphIssue {
  target : GraphIssueTarget
  message : String
  severity : GraphIssueSeverity
}

///|
pub fn new_graph_issue_node(
  node : @graph.ElkNode,
  message : String,
  severity : GraphIssueSeverity,
) -> GraphIssue {
  { target: NodeIssueTarget(node), message, severity }
}

///|
pub fn new_graph_issue_edge(
  edge : @graph.ElkEdge,
  message : String,
  severity : GraphIssueSeverity,
) -> GraphIssue {
  { target: EdgeIssueTarget(edge), message, severity }
}

///|
fn graph_issue_severity_to_string(severity : GraphIssueSeverity) -> String {
  if severity == issue_warning {
    "WARNING"
  } else {
    "ERROR"
  }
}

///|
pub fn graph_issue_severity_get_user_string(
  severity : GraphIssueSeverity,
) -> String {
  if severity == issue_warning {
    "Warning"
  } else {
    "Error"
  }
}

///|
fn describe_node_for_path(node : @graph.ElkNode) -> String {
  match @graph.node_parent(node) {
    None => "Root Node"
    Some(_) => {
      let identifier = @graph.node_identifier(node)
      if identifier.is_empty() {
        "Node"
      } else {
        "Node \{identifier}"
      }
    }
  }
}

///|
fn append_node_path(node : @graph.ElkNode, parts : Array[String]) -> Unit {
  match @graph.node_parent(node) {
    Some(parent) => append_node_path(parent, parts)
    None => ()
  }
  parts.push(describe_node_for_path(node))
}

///|
fn join_strings(parts : Array[String], delimiter : String) -> String {
  let mut first = true
  let mut result = ""
  for part in parts {
    if first {
      result = part
      first = false
    } else {
      result = "\{result}\{delimiter}\{part}"
    }
  }
  result
}

///|
fn element_path_for_node(node : @graph.ElkNode) -> String {
  let parts = []
  append_node_path(node, parts)
  join_strings(parts, " > ")
}

///|
fn element_path_for_edge(edge : @graph.ElkEdge) -> String {
  match @graph.edge_containing_node(edge) {
    Some(parent) => "\{element_path_for_node(parent)} > Edge"
    None => "Edge"
  }
}

///|
fn graph_issue_path(target : GraphIssueTarget) -> String {
  match target {
    NodeIssueTarget(node) => element_path_for_node(node)
    EdgeIssueTarget(edge) => element_path_for_edge(edge)
  }
}

///|
pub fn GraphIssue::to_string(self : GraphIssue) -> String {
  "\{graph_issue_severity_to_string(self.severity)}: \{self.message} (\{graph_issue_path(self.target)})"
}

///|
pub fn GraphIssue::get_message(self : GraphIssue) -> String {
  self.message
}

///|
pub fn GraphIssue::get_severity(self : GraphIssue) -> GraphIssueSeverity {
  self.severity
}

///|
pub fn graph_issue_list_to_string(issues : Array[GraphIssue]) -> String {
  let rendered = []
  for issue in issues {
    rendered.push(issue.to_string())
  }
  let body = join_strings(rendered, ", ")
  "[\{body}]"
}
