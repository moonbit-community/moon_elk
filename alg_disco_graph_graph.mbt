///|
pub struct DCGraph {
  components : Array[DCComponent]
  mut dimensions : KVector
  inset : Double
  mut polyomino_fill : Bool
  mut aspect_ratio : Double?
  mut padding : ElkPadding
  mut debug_disco_polys : Array[DCPolyomino]?
}

///|
pub fn new_dc_graph(
  components : Array[Array[DCElement]],
  inset? : Double = 0.0,
) -> DCGraph {
  let dc_components : Array[DCComponent] = []
  for elements in components {
    let component = new_dc_component()
    component.add_elements(elements)
    dc_components.push(component)
  }
  {
    components: dc_components,
    dimensions: new_kvector(),
    inset,
    polyomino_fill: false,
    aspect_ratio: None,
    padding: new_elk_padding(),
    debug_disco_polys: None,
  }
}

///|
pub fn DCGraph::get_components(self : DCGraph) -> Array[DCComponent] {
  self.components
}

///|
pub fn DCGraph::get_dimensions(self : DCGraph) -> KVector {
  self.dimensions
}

///|
pub fn DCGraph::set_dimensions(self : DCGraph, dimensions : KVector) -> Unit {
  self.dimensions = dimensions
}

///|
pub fn DCGraph::get_inset(self : DCGraph) -> Double {
  self.inset
}

///|
pub fn DCGraph::set_polyomino_fill(self : DCGraph, fill : Bool) -> Unit {
  self.polyomino_fill = fill
}

///|
pub fn DCGraph::get_polyomino_fill(self : DCGraph) -> Bool {
  self.polyomino_fill
}

///|
pub fn DCGraph::set_aspect_ratio(self : DCGraph, ratio : Double?) -> Unit {
  self.aspect_ratio = ratio
}

///|
pub fn DCGraph::get_aspect_ratio(self : DCGraph) -> Double? {
  self.aspect_ratio
}

///|
pub fn DCGraph::set_padding(self : DCGraph, padding : ElkPadding) -> Unit {
  self.padding = padding
}

///|
pub fn DCGraph::get_padding(self : DCGraph) -> ElkPadding {
  self.padding
}

///|
pub fn DCGraph::set_debug_disco_polys(
  self : DCGraph,
  polys : Array[DCPolyomino],
) -> Unit {
  self.debug_disco_polys = Some(polys)
}

///|
pub fn DCGraph::get_debug_disco_polys(self : DCGraph) -> Array[DCPolyomino]? {
  self.debug_disco_polys
}
