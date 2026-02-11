///|
pub struct LayoutOptionValidator {
  issues : Array[GraphIssue]
}

///|
pub fn new_layout_option_validator() -> LayoutOptionValidator {
  { issues: [] }
}

///|
fn format_double_for_issue(value : Double) -> String {
  let rendered = value.to_string()
  if rendered.contains(".") || rendered.contains("e") || rendered.contains("E") {
    rendered
  } else {
    "\{rendered}.0"
  }
}

///|
fn check_string_override(
  validator : LayoutOptionValidator,
  node : ElkNode,
  option_id : String,
  value : String,
) -> Unit {
  match layout_meta_data_service_get_option_data_opt(option_id) {
    Some(option_data) =>
      match option_data.get_type() {
        DoubleType => {
          let message = "The assigned value \{value} of the option '\{option_data.get_name()}' does not match the type Double."
          validator.issues.push(
            new_graph_issue_node(node, message, issue_error),
          )
        }
        _ => ()
      }
    None => ()
  }
}

///|
fn check_double_assignment(
  validator : LayoutOptionValidator,
  node : ElkNode,
  option_id : String,
  value : Double,
) -> Unit {
  match layout_meta_data_service_get_option_data_opt(option_id) {
    Some(option_data) =>
      match option_data.get_lower_bound() {
        Some(lower_bound) => {
          let lower_bound_violated = if option_data.is_lower_bound_exclusive() {
            value <= lower_bound
          } else {
            value < lower_bound
          }
          if lower_bound_violated {
            let suffix = if option_data.is_lower_bound_exclusive() {
              " (exclusive)"
            } else {
              ""
            }
            let message = "The assigned value \{format_double_for_issue(value)} of the option '\{option_id}' is less than the lower bound \{format_double_for_issue(lower_bound)}\{suffix}."
            validator.issues.push(
              new_graph_issue_node(node, message, issue_error),
            )
          }
        }
        None => ()
      }
    None => ()
  }
}

///|
pub fn LayoutOptionValidator::visit(
  self : LayoutOptionValidator,
  node : ElkNode,
) -> Unit {
  for entry in node_layout_option_string_entries(node) {
    let (option_id, value) = entry
    check_string_override(self, node, option_id, value)
  }
  for entry in node_double_property_entries(node) {
    let (option_id, value) = entry
    check_double_assignment(self, node, option_id, value)
  }
}

///|
pub fn LayoutOptionValidator::get_issues(
  self : LayoutOptionValidator,
) -> Array[GraphIssue] {
  self.issues.copy()
}

///|
pub fn LayoutOptionValidator::to_visitor(
  self : LayoutOptionValidator,
) -> IGraphElementVisitor {
  new_graph_element_visitor(node => self.visit(node))
}

///|
fn layout_option_validator_issue_for_property(message : String) -> GraphIssue {
  let root = create_graph()
  let node = create_node(Some(root))
  new_graph_issue_node(node, message, issue_error)
}

///|
fn layout_option_validator_parse_bool(value : StringView) -> Bool? {
  let normalized = value.trim().to_lower()
  if normalized == "true" || normalized == "false" {
    Some(normalized == "true")
  } else {
    None
  }
}

///|
pub fn LayoutOptionValidator::check_property(
  self : LayoutOptionValidator,
  option_data : LayoutOptionData,
  value : String,
  _context? : Unit? = None,
) -> Array[GraphIssue] {
  ignore(self)
  let trimmed = value.trim()
  let issues : Array[GraphIssue] = []
  match option_data.get_type() {
    IntType => {
      let parsed : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
        trimmed,
      )
      match parsed {
        Ok(_) => ()
        Err(_) =>
          issues.push(
            layout_option_validator_issue_for_property(
              "The assigned value \{value} of the option '\{option_data.get_name()}' does not match the type Int.",
            ),
          )
      }
    }
    DoubleType => {
      let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
        trimmed,
      )
      match parsed {
        Ok(parsed) =>
          match option_data.get_lower_bound() {
            Some(lower_bound) => {
              let violated = if option_data.is_lower_bound_exclusive() {
                parsed <= lower_bound
              } else {
                parsed < lower_bound
              }
              if violated {
                let suffix = if option_data.is_lower_bound_exclusive() {
                  " (exclusive)"
                } else {
                  ""
                }
                issues.push(
                  layout_option_validator_issue_for_property(
                    "The assigned value \{format_double_for_issue(parsed)} of the option '\{option_data.get_name()}' is less than the lower bound \{format_double_for_issue(lower_bound)}\{suffix}.",
                  ),
                )
              }
            }
            None => ()
          }
        Err(_) =>
          issues.push(
            layout_option_validator_issue_for_property(
              "The assigned value \{value} of the option '\{option_data.get_name()}' does not match the type Double.",
            ),
          )
      }
    }
    BoolType =>
      if layout_option_validator_parse_bool(trimmed) is None {
        issues.push(
          layout_option_validator_issue_for_property(
            "The assigned value \{value} of the option '\{option_data.get_name()}' does not match the type Boolean.",
          ),
        )
      }
    _ => ()
  }
  issues
}
