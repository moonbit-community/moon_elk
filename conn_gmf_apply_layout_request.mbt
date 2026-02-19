///|
pub let req_apply_layout : String = "apply layout"

///|
pub struct ApplyLayoutRequest {
  request_type : String
  mapping_list : Array[Pair[GmfElkGraphElement, GmfEditPart]]
  mut boundx : Double
  mut boundy : Double
  mut scale : Double
}

///|
pub fn new_apply_layout_request() -> ApplyLayoutRequest {
  {
    request_type: req_apply_layout,
    mapping_list: [],
    boundx: @double.max_value,
    boundy: @double.max_value,
    scale: 1.0,
  }
}

///|
pub fn ApplyLayoutRequest::get_type(self : ApplyLayoutRequest) -> String {
  self.request_type
}

///|
pub fn ApplyLayoutRequest::add_element(
  self : ApplyLayoutRequest,
  element : GmfElkGraphElement,
  edit_part : GmfEditPart,
) -> Unit {
  self.mapping_list.push(pair_of(element, edit_part))
}

///|
pub fn ApplyLayoutRequest::get_elements(
  self : ApplyLayoutRequest,
) -> Array[Pair[GmfElkGraphElement, GmfEditPart]] {
  self.mapping_list
}

///|
pub fn ApplyLayoutRequest::set_upper_bound(
  self : ApplyLayoutRequest,
  x : Double,
  y : Double,
) -> Unit {
  self.boundx = x
  self.boundy = y
}

///|
pub fn ApplyLayoutRequest::get_x_bound(self : ApplyLayoutRequest) -> Double {
  self.boundx
}

///|
pub fn ApplyLayoutRequest::get_y_bound(self : ApplyLayoutRequest) -> Double {
  self.boundy
}

///|
pub fn ApplyLayoutRequest::get_scale(self : ApplyLayoutRequest) -> Double {
  self.scale
}

///|
pub fn ApplyLayoutRequest::set_scale(
  self : ApplyLayoutRequest,
  the_scale : Double,
) -> Unit {
  self.scale = the_scale
}
