///|
pub struct DCPolyomino {
  polyomino : @common.Polyomino
  representee : DCComponent
  p_width : Int
  p_height : Int
  cell_size_x : Double
  cell_size_y : Double
}

///|
pub fn new_dc_polyomino(
  component : DCComponent,
  cell_size_x : Double,
  cell_size_y : Double,
) -> DCPolyomino {
  let dims = component.get_dimensions_of_bounding_rectangle()
  let p_width = compute_low_res_dimension(dims.x, cell_size_x)
  let p_height = compute_low_res_dimension(dims.y, cell_size_y)
  let polyomino = @common.new_polyomino(p_width, p_height)
  let dc_polyomino = {
    polyomino,
    representee: component,
    p_width,
    p_height,
    cell_size_x,
    cell_size_y,
  }
  dc_polyomino.fill_cells()
  for elem in component.get_elements() {
    if !elem.get_extensions().is_empty() {
      dc_polyomino.add_extensions_to_poly(elem)
    }
  }
  dc_polyomino
}

///|
fn compute_low_res_dimension(dim : Double, cell_size : Double) -> Int {
  let cell_fit = dim / cell_size
  let mut fit_truncated = cell_fit.to_int()
  if cell_fit > fit_truncated.to_double() {
    fit_truncated += 1
  }
  fit_truncated
}

///|
pub fn DCPolyomino::get_offset(self : DCPolyomino) -> @core.KVector {
  let offset = self.representee.get_dimensions_of_bounding_rectangle().clone()
  ignore(
    offset.sub_xy(
      self.p_width.to_double() * self.cell_size_x,
      self.p_height.to_double() * self.cell_size_y,
    ),
  )
  ignore(offset.scale(-0.5))
  offset
}

///|
pub fn DCPolyomino::get_min_corner_on_canvas(
  self : DCPolyomino,
) -> @core.KVector {
  self.representee.get_min_corner().clone().sub(self.get_offset())
}

///|
pub fn DCPolyomino::get_cell_size_x(self : DCPolyomino) -> Double {
  self.cell_size_x
}

///|
pub fn DCPolyomino::get_cell_size_y(self : DCPolyomino) -> Double {
  self.cell_size_y
}

///|
pub fn DCPolyomino::get_id(self : DCPolyomino) -> Int {
  self.representee.get_id()
}

///|
pub fn DCPolyomino::set_id(self : DCPolyomino, id : Int) -> Unit {
  self.representee.set_id(id)
}

///|
pub fn DCPolyomino::get_representee(self : DCPolyomino) -> DCComponent {
  self.representee
}

///|
pub fn DCPolyomino::as_polyomino(self : DCPolyomino) -> @common.Polyomino {
  self.polyomino
}

///|
pub fn DCPolyomino::width(self : DCPolyomino) -> Int {
  self.polyomino.width()
}

///|
pub fn DCPolyomino::height(self : DCPolyomino) -> Int {
  self.polyomino.height()
}

///|
pub fn DCPolyomino::is_blocked(self : DCPolyomino, x : Int, y : Int) -> Bool {
  self.polyomino.is_blocked(x, y)
}

///|
pub fn DCPolyomino::is_weakly_blocked(
  self : DCPolyomino,
  x : Int,
  y : Int,
) -> Bool {
  self.polyomino.is_weakly_blocked(x, y)
}

///|
pub fn DCPolyomino::get_center_x(self : DCPolyomino) -> Int {
  self.polyomino.get_center_x()
}

///|
pub fn DCPolyomino::get_center_y(self : DCPolyomino) -> Int {
  self.polyomino.get_center_y()
}

///|
pub fn DCPolyomino::get_polyomino_extensions(
  self : DCPolyomino,
) -> Array[@common.UniqueTriple[@common.PolyominoDirection, Int, Int]] {
  self.polyomino.get_polyomino_extensions()
}

///|
pub fn DCPolyomino::get_x(self : DCPolyomino) -> Int {
  self.polyomino.get_x()
}

///|
pub fn DCPolyomino::get_y(self : DCPolyomino) -> Int {
  self.polyomino.get_y()
}

///|
pub fn DCPolyomino::set_x(self : DCPolyomino, x : Int) -> Unit {
  self.polyomino.set_x(x)
}

///|
pub fn DCPolyomino::set_y(self : DCPolyomino, y : Int) -> Unit {
  self.polyomino.set_y(y)
}

///|
fn DCPolyomino::fill_cells(self : DCPolyomino) -> Unit {
  let comp_corner = self.representee.get_min_corner()
  let polyo_offset = self.get_offset()
  let base_x = comp_corner.x - polyo_offset.x
  let mut cur_y = comp_corner.y - polyo_offset.y

  for y = 0; y < self.p_height; y = y + 1 {
    let mut cur_x = base_x
    for x = 0; x < self.p_width; x = x + 1 {
      let rect = @core.new_elk_rectangle()
      rect.set_rect(cur_x, cur_y, self.cell_size_x, self.cell_size_y)
      if self.representee.intersects(rect) {
        self.polyomino.set_blocked(x, y)
      }
      cur_x += self.cell_size_x
    }
    cur_y += self.cell_size_y
  }
}

///|
fn DCPolyomino::add_extensions_to_poly(
  self : DCPolyomino,
  elem : DCElement,
) -> Unit {
  let extensions = elem.get_extensions()

  let comp_corner = self.representee.get_min_corner()
  let polyo_offset = self.get_offset()
  let mut base_x = comp_corner.x - polyo_offset.x
  let mut base_y = comp_corner.y - polyo_offset.y

  let elem_pos = elem.get_bounds()
  base_x = elem_pos.x - base_x
  base_y = elem_pos.y - base_y

  for extension in extensions {
    let pos = extension.get_offset()
    let xe = base_x + pos.x
    let ye = base_y + pos.y

    let xp = (xe / self.cell_size_x).to_int()
    let yp = (ye / self.cell_size_y).to_int()

    let dir = extension.get_direction()
    let poly_dirs = @common.polyomino_direction_values()
    let poly_dir = match dir {
      DCNorth => poly_dirs[0]
      DCEast => poly_dirs[1]
      DCSouth => poly_dirs[2]
      DCWest => poly_dirs[3]
    }

    if dir.is_horizontal() {
      let yp_plus_width = ((ye + extension.get_width()) / self.cell_size_y).to_int()
      self.polyomino.add_extension(poly_dir, yp, yp_plus_width)
      match dir {
        DCWest =>
          self.polyomino
          .as_planar_grid()
          .weakly_block_area(0, yp, xp, yp_plus_width)
        _ =>
          self.polyomino
          .as_planar_grid()
          .weakly_block_area(xp, yp, self.p_width - 1, yp_plus_width)
      }
    } else {
      let xp_plus_width = ((xe + extension.get_width()) / self.cell_size_x).to_int()
      self.polyomino.add_extension(poly_dir, xp, xp_plus_width)
      match dir {
        DCNorth =>
          self.polyomino
          .as_planar_grid()
          .weakly_block_area(xp, 0, xp_plus_width, yp)
        _ =>
          self.polyomino
          .as_planar_grid()
          .weakly_block_area(xp, yp, xp_plus_width, self.p_height - 1)
      }
    }
  }
}
