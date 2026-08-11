///|
test "layered composition does not advertise unrelated algorithms" {
  debug_inspect(
    @layered.new_elk_engine().known_layout_algorithms(),
    content="[\"fixed\", \"box\", \"random\", \"layered\"]",
  )
}
