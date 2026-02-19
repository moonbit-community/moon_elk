///|
pub fn rectpacking_calculations_width_lpr_or_lpb(
  drawing_width : Double,
  x : Double,
  width : Double,
) -> Double {
  @math.maximum(drawing_width, x + width)
}

///|
pub fn rectpacking_calculations_height_lpr_or_lpb(
  drawing_height : Double,
  y : Double,
  height : Double,
) -> Double {
  @math.maximum(drawing_height, y + height)
}

///|
fn rectpacking_calculations_vertical_order_constraint(
  placed_rect : ElkNode,
  x : Double,
  node_node_spacing : Double,
) -> Bool {
  x < node_x(placed_rect) + node_width(placed_rect) + node_node_spacing
}

///|
fn rectpacking_calculations_horizontal_order_constraint(
  placed_rect : ElkNode,
  y_coord_rect_to_place : Double,
  node_node_spacing : Double,
) -> Bool {
  y_coord_rect_to_place <
  node_y(placed_rect) + node_height(placed_rect) + node_node_spacing
}

///|
pub fn rectpacking_calculations_y_for_lpr(
  x : Double,
  placed_rects : Array[ElkNode],
  last_placed : ElkNode,
  node_node_spacing : Double,
) -> Double {
  let mut closest_upper_neighbor : ElkNode? = None
  let mut closest_neighbor_bottom_border = 0.0

  for placed_rect in placed_rects {
    let placed_rect_bottom_border = node_y(placed_rect) +
      node_height(placed_rect)
    if rectpacking_calculations_vertical_order_constraint(
        placed_rect, x, node_node_spacing,
      ) {
      match closest_upper_neighbor {
        None => closest_upper_neighbor = Some(placed_rect)
        Some(_) =>
          if node_y(last_placed) - placed_rect_bottom_border <
            node_y(last_placed) - closest_neighbor_bottom_border {
            closest_upper_neighbor = Some(placed_rect)
          }
      }
      match closest_upper_neighbor {
        Some(closest) =>
          closest_neighbor_bottom_border = node_y(closest) +
            node_height(closest)
        None => ()
      }
    }
  }

  match closest_upper_neighbor {
    None => 0.0
    Some(_) => closest_neighbor_bottom_border + node_node_spacing
  }
}

///|
pub fn rectpacking_calculations_x_for_lpb(
  y : Double,
  placed_rects : Array[ElkNode],
  last_placed : ElkNode,
  node_node_spacing : Double,
) -> Double {
  let mut closest_left_neighbor : ElkNode? = None
  let mut closest_neighbor_right_border = 0.0

  for placed_rect in placed_rects {
    let placed_rect_right_border = node_x(placed_rect) + node_width(placed_rect)
    if rectpacking_calculations_horizontal_order_constraint(
        placed_rect, y, node_node_spacing,
      ) {
      match closest_left_neighbor {
        None => closest_left_neighbor = Some(placed_rect)
        Some(_) =>
          if node_x(last_placed) - placed_rect_right_border <
            node_x(last_placed) - closest_neighbor_right_border {
            closest_left_neighbor = Some(placed_rect)
          }
      }
      match closest_left_neighbor {
        Some(closest) =>
          closest_neighbor_right_border = node_x(closest) + node_width(closest)
        None => ()
      }
    }
  }

  match closest_left_neighbor {
    None => 0.0
    Some(_) => closest_neighbor_right_border + node_node_spacing
  }
}

///|
pub fn rectpacking_calculations_area_lpr(
  last_placed : ElkNode,
  to_place : ElkNode,
  lpr_opt : RectpackingDrawingData,
) -> Double {
  let last_placed_bottom_border = node_y(last_placed) + node_height(last_placed)
  let to_place_bottom_border = lpr_opt.next_y_coordinate + node_height(to_place)
  let max_y_lpr = @math.maximum(
    last_placed_bottom_border, to_place_bottom_border,
  )

  let height_lpr = max_y_lpr -
    @math.minimum(node_y(last_placed), lpr_opt.next_y_coordinate)
  let width_lpr = lpr_opt.next_x_coordinate +
    node_width(to_place) -
    node_x(last_placed)

  width_lpr * height_lpr
}

///|
pub fn rectpacking_calculations_area_lpb(
  last_placed : ElkNode,
  to_place : ElkNode,
  lpb_opt : RectpackingDrawingData,
) -> Double {
  let last_placed_right_border = node_x(last_placed) + node_width(last_placed)
  let to_place_right_border = lpb_opt.next_x_coordinate + node_width(to_place)
  let max_x_lpb = @math.maximum(last_placed_right_border, to_place_right_border)

  let width_lpb = max_x_lpb -
    @math.minimum(node_x(last_placed), lpb_opt.next_x_coordinate)
  let height_lpb = lpb_opt.next_y_coordinate +
    node_height(to_place) -
    node_y(last_placed)

  width_lpb * height_lpb
}
