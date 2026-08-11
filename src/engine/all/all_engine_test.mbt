///|
test "all composition advertises every installed in-process algorithm" {
  debug_inspect(
    @all.new_elk_engine().known_layout_algorithms(),
    content=(
      #|[
      #|  "fixed",
      #|  "box",
      #|  "random",
      #|  "layered",
      #|  "force",
      #|  "stress",
      #|  "radial",
      #|  "mrtree",
      #|  "rectpacking",
      #|  "sporeOverlap",
      #|  "sporeCompaction",
      #|  "vertiflex",
      #|  "disco",
      #|]
    ),
  )
}
