///|
pub let graphviz_tool_pref_graphviz_executable : String = "graphviz.executable"

///|
pub let graphviz_tool_pref_timeout : String = "graphviz.timeout"

///|
let graphviz_tool_process_def_timeout_ref : Ref[Int] = Ref::new(20000)

///|
pub let graphviz_tool_process_min_timeout : Int = 200

///|
pub fn graphviz_tool_get_process_default_timeout() -> Int {
  graphviz_tool_process_def_timeout_ref.val
}

///|
pub fn graphviz_tool_set_process_default_timeout_for_test(
  timeout : Int,
) -> Unit {
  graphviz_tool_process_def_timeout_ref.val = timeout
}

///|
pub fn graphviz_tool_reset_process_default_timeout_for_test() -> Unit {
  graphviz_tool_process_def_timeout_ref.val = 20000
}
