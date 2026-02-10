///|
pub struct DisCoPolyominoCompactor {
  mut grid_cell_size_x : Double
  mut grid_cell_size_y : Double
  upper_bound : Double
  mut cmp_graph : DCGraph?
  polys : Array[DCPolyomino]
  mut grid : PlanarGrid?
  mut aspect_ratio : Double
  mut fill : Bool
}

///|
pub fn new_dis_co_polyomino_compactor() -> DisCoPolyominoCompactor {
  {
    grid_cell_size_x: 0.0,
    grid_cell_size_y: 0.0,
    upper_bound: 100.0,
    cmp_graph: None,
    polys: [],
    grid: None,
    aspect_ratio: 1.0,
    fill: false,
  }
}

///|
fn dis_co_compute_cell_size(
  compactor : DisCoPolyominoCompactor,
  graph : DCGraph,
) -> Double {
  let mut sum_term = 0.0
  let mut prod_term = 0.0
  let comps = graph.get_components()
  let num_of_comps = comps.length()

  for comp in comps {
    let bounds = comp.get_dimensions_of_bounding_rectangle()
    let width = bounds.x
    let height = bounds.y
    sum_term += width + height
    prod_term += width * height
  }

  if num_of_comps == 0 {
    return 1.0
  }

  let four = 4.0
  let num = num_of_comps.to_double()
  let numerator = (four * compactor.upper_bound * num * prod_term -
    four * prod_term +
    sum_term * sum_term).sqrt() +
    sum_term
  let denominator = 2.0 * (compactor.upper_bound * num - 1.0)

  if denominator == 0.0 {
    if numerator > 0.0 {
      numerator
    } else {
      1.0
    }
  } else {
    let result = numerator / denominator
    if result > 0.0 {
      result
    } else {
      1.0
    }
  }
}

///|
fn dis_co_create_polyominoes(compactor : DisCoPolyominoCompactor) -> Unit {
  let graph = match compactor.cmp_graph {
    Some(graph) => graph
    None => return
  }
  compactor.polys.clear()
  for comp in graph.get_components() {
    compactor.polys.push(
      new_dc_polyomino(
        comp,
        compactor.grid_cell_size_x,
        compactor.grid_cell_size_y,
      ),
    )
  }
}

///|
fn dis_co_pack_polyominoes(compactor : DisCoPolyominoCompactor) -> Unit {
  let mut id = 0
  for poly in compactor.polys {
    poly.set_id(id)
    id = id + 1
  }

  let raw_polys : Array[Polyomino] = []
  for poly in compactor.polys {
    raw_polys.push(poly.as_polyomino())
  }

  let holder = new_polyominoes(
    raw_polys,
    compactor.aspect_ratio,
    fill=compactor.fill,
  )
  let generic_compactor = new_polyomino_compactor()
  generic_compactor.pack_polyominoes(holder)
  compactor.grid = Some(holder.get_grid())
}

///|
fn dis_co_apply_to_dc_graph(compactor : DisCoPolyominoCompactor) -> Unit {
  let graph = match compactor.cmp_graph {
    Some(graph) => graph
    None => return
  }
  let grid = match compactor.grid {
    Some(grid) => grid
    None => return
  }

  let grid_crop = grid.get_filled_bounds()
  let padding = graph.get_padding()
  let parent_width = grid_crop.get_third().to_double() *
    compactor.grid_cell_size_x +
    padding.get_horizontal()
  let parent_height = grid_crop.get_fourth().to_double() *
    compactor.grid_cell_size_y +
    padding.get_vertical()
  graph.set_dimensions(new_kvector_xy(parent_width, parent_height))

  for poly in compactor.polys {
    let absolute_int_position_x = poly.get_x() - grid_crop.get_first()
    let absolute_int_position_y = poly.get_y() - grid_crop.get_second()

    let absolute_position_on_canvas = new_kvector_xy(
      absolute_int_position_x.to_double(),
      absolute_int_position_y.to_double(),
    )
    ignore(
      absolute_position_on_canvas
      .scale_xy(poly.get_cell_size_x(), poly.get_cell_size_y())
      .add(poly.get_offset()),
    )

    let original_coordinates = poly.get_representee().get_min_corner()
    poly
    .get_representee()
    .set_offset(absolute_position_on_canvas.sub(original_coordinates))
  }
}

///|
pub fn DisCoPolyominoCompactor::compact(
  self : DisCoPolyominoCompactor,
  graph : DCGraph,
) -> Unit {
  self.cmp_graph = Some(graph)
  self.polys.clear()

  let grid_cell_recommendation = dis_co_compute_cell_size(self, graph)
  self.grid_cell_size_x = grid_cell_recommendation
  self.grid_cell_size_y = grid_cell_recommendation

  self.fill = graph.get_polyomino_fill()
  self.aspect_ratio = match graph.get_aspect_ratio() {
    Some(value) => if value <= 0.0 { 1.0 } else { value }
    None => 1.0
  }

  if self.aspect_ratio > 1.0 {
    self.grid_cell_size_x = self.grid_cell_size_x * self.aspect_ratio
  } else {
    self.grid_cell_size_y = self.grid_cell_size_y / self.aspect_ratio
  }

  dis_co_create_polyominoes(self)
  dis_co_pack_polyominoes(self)
  dis_co_apply_to_dc_graph(self)
  graph.set_debug_disco_polys(self.polys)
}

///|
pub fn dis_co_polyomino_compactor_as_icompactor(
  compactor : DisCoPolyominoCompactor,
) -> ICompactor {
  new_icompactor(graph => compactor.compact(graph))
}
