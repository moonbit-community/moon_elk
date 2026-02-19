///|
pub fn draw_hitboxes(c_graph : CGraph, file_name : String) -> String {
  ignore(file_name)

  let top_left = new_kvector_xy(@double.infinity, @double.infinity)
  let bottom_right = new_kvector_xy(-@double.infinity, -@double.infinity)

  for c_node in c_graph.c_nodes {
    let hitbox = c_node.hitbox()
    top_left.x = if top_left.x < hitbox.x { top_left.x } else { hitbox.x }
    top_left.y = if top_left.y < hitbox.y { top_left.y } else { hitbox.y }
    bottom_right.x = if bottom_right.x > hitbox.x + hitbox.width {
      bottom_right.x
    } else {
      hitbox.x + hitbox.width
    }
    bottom_right.y = if bottom_right.y > hitbox.y + hitbox.height {
      bottom_right.y
    } else {
      hitbox.y + hitbox.height
    }
  }

  let size = new_kvector_xy(
    bottom_right.x - top_left.x,
    bottom_right.y - top_left.y,
  )
  let output = @buffer.new()
  output.write_string("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  output.write_string(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"100%\" height=\"100%\" viewBox=\"\{top_left.x} \{top_left.y} \{size.x} \{size.y}\">\n",
  )
  output.write_string(
    "<defs><marker id=\"markerArrow\" markerWidth=\"10\" markerHeight=\"10\" refX=\"0\" refY=\"3\" orient=\"auto\"><path d=\"M0,0 L0,6 L9,3 z\" style=\"fill: #000000;\" /></marker></defs>\n",
  )

  for c_node in c_graph.c_nodes {
    let hitbox = c_node.hitbox()
    output.write_string(c_node.get_debug_svg())
    output.write_string("\n")
    for incoming in c_node.constraints() {
      let incoming_hitbox = incoming.hitbox()
      output.write_string(
        "<line x1=\"\{incoming_hitbox.x}\" y1=\"\{incoming_hitbox.y + incoming_hitbox.height / 2.0}\" x2=\"\{hitbox.x + hitbox.width}\" y2=\"\{hitbox.y + hitbox.height / 2.0}\" stroke=\"black\" opacity=\"0.4\" style=\"marker-end: url(#markerArrow);\" />\n",
      )
    }
  }

  output.write_string("</svg>\n")
  output.to_string()
}
