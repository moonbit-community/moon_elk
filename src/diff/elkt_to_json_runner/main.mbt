///|
pub fn convert_elkt_to_json(input_graph_text : String) -> String {
  let graph = @text.new_elk_graph_parser(@graph_json.new_codec_metadata()).parse(
    input_graph_text,
  )
  @graph_json.elk_graph_json_for_elk_graph(graph)
  .short_layout_option_keys(true)
  .to_json()
}

///|
fn main {
  println(convert_elkt_to_json(case_input_graph_text()))
}
