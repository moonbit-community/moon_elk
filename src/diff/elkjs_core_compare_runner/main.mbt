///|
pub fn layout_json(input_graph : String) -> String raise {
  let graph = @json.parse(input_graph)
  let output = @core.new_elk_engine().layout(graph~)
  output.stringify()
}

///|
fn main {
  try layout_json(case_input_graph_json()) catch {
    err =>
      println(
        Json::object({ "_moon_error": Json::string(err.to_string()) }).stringify(),
      )
  } noraise {
    output => println(output)
  }
}
