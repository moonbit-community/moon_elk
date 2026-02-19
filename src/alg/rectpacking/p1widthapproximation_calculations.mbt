///|
pub fn rectpacking_calculations_width_lpr_or_lpb(
  drawing_width : Double,
  x : Double,
  width : Double,
) -> Double {
  @cmp.maximum(drawing_width, x + width)
}

///|
pub fn rectpacking_calculations_height_lpr_or_lpb(
  drawing_height : Double,
  y : Double,
  height : Double,
) -> Double {
  @cmp.maximum(drawing_height, y + height)
}

///|
fn rectpacking_calculations_vertical_order_constraint(
  placed_rect : @graph.ElkNode,
  x : Double,
  node_node_spacing : Double,
) -> Bool {
  x <
  @graph.node_x(placed_rect) +
  @graph.node_width(placed_rect) +
  node_node_spacing
}

///|
fn rectpacking_calculations_horizontal_order_constraint(
  placed_rect : @graph.ElkNode,
  y_coord_rect_to_place : Double,
  node_node_spacing : Double,
) -> Bool {
  y_coord_rect_to_place <
  @graph.node_y(placed_rect) +
  @graph.node_height(placed_rect) +
  node_node_spacing
}

///|
pub fn rectpacking_calculations_y_for_lpr(
  x : Double,
  placed_rects : Array[@graph.ElkNode],
  last_placed : @graph.ElkNode,
  node_node_spacing : Double,
) -> Double {
  let mut closest_upper_neighbor : @graph.ElkNode? = None
  let mut closest_neighbor_bottom_border = 0.0

  for placed_rect in placed_rects {
    let placed_rect_bottom_border = @graph.node_y(placed_rect) +
      @graph.node_height(placed_rect)
    if rectpacking_calculations_vertical_order_constraint(
        placed_rect, x, node_node_spacing,
      ) {
      match closest_upper_neighbor {
        None => closest_upper_neighbor = Some(placed_rect)
        Some(_) =>
          if @graph.node_y(last_placed) - placed_rect_bottom_border <
            @graph.node_y(last_placed) - closest_neighbor_bottom_border {
            closest_upper_neighbor = Some(placed_rect)
          }
      }
      match closest_upper_neighbor {
        Some(closest) =>
          closest_neighbor_bottom_border = @graph.node_y(closest) +
            @graph.node_height(closest)
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
  placed_rects : Array[@graph.ElkNode],
  last_placed : @graph.ElkNode,
  node_node_spacing : Double,
) -> Double {
  let mut closest_left_neighbor : @graph.ElkNode? = None
  let mut closest_neighbor_right_border = 0.0

  for placed_rect in placed_rects {
    let placed_rect_right_border = @graph.node_x(placed_rect) +
      @graph.node_width(placed_rect)
    if rectpacking_calculations_horizontal_order_constraint(
        placed_rect, y, node_node_spacing,
      ) {
      match closest_left_neighbor {
        None => closest_left_neighbor = Some(placed_rect)
        Some(_) =>
          if @graph.node_x(last_placed) - placed_rect_right_border <
            @graph.node_x(last_placed) - closest_neighbor_right_border {
            closest_left_neighbor = Some(placed_rect)
          }
      }
      match closest_left_neighbor {
        Some(closest) =>
          closest_neighbor_right_border = @graph.node_x(closest) +
            @graph.node_width(closest)
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
  last_placed : @graph.ElkNode,
  to_place : @graph.ElkNode,
  lpr_opt : RectpackingDrawingData,
) -> Double {
  let last_placed_bottom_border = @graph.node_y(last_placed) +
    @graph.node_height(last_placed)
  let to_place_bottom_border = lpr_opt.next_y_coordinate +
    @graph.node_height(to_place)
  let max_y_lpr = @cmp.maximum(
    last_placed_bottom_border, to_place_bottom_border,
  )

  let height_lpr = max_y_lpr -
    @cmp.minimum(@graph.node_y(last_placed), lpr_opt.next_y_coordinate)
  let width_lpr = lpr_opt.next_x_coordinate +
    @graph.node_width(to_place) -
    @graph.node_x(last_placed)

  width_lpr * height_lpr
}

///|
pub fn rectpacking_calculations_area_lpb(
  last_placed : @graph.ElkNode,
  to_place : @graph.ElkNode,
  lpb_opt : RectpackingDrawingData,
) -> Double {
  let last_placed_right_border = @graph.node_x(last_placed) +
    @graph.node_width(last_placed)
  let to_place_right_border = lpb_opt.next_x_coordinate +
    @graph.node_width(to_place)
  let max_x_lpb = @cmp.maximum(last_placed_right_border, to_place_right_border)

  let width_lpb = max_x_lpb -
    @cmp.minimum(@graph.node_x(last_placed), lpb_opt.next_x_coordinate)
  let height_lpb = lpb_opt.next_y_coordinate +
    @graph.node_height(to_place) -
    @graph.node_y(last_placed)

  width_lpb * height_lpb
}
