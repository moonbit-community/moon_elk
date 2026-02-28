///|
pub struct RectpackingDrawingData {
  mut scale_measure : Double
  mut drawing_width : Double
  mut drawing_height : Double
  mut area : Double
  mut aspect_ratio : Double
  desired_aspect_ratio : Double
  mut placement_option : RectpackingDrawingDataDescriptor
  next_x_coordinate : Double
  next_y_coordinate : Double
}

///|
fn rectpacking_drawing_data_calc(drawing : RectpackingDrawingData) -> Unit {
  if drawing.drawing_width > 0.0 && drawing.drawing_height > 0.0 {
    drawing.area = drawing.drawing_width * drawing.drawing_height
    drawing.aspect_ratio = drawing.drawing_width / drawing.drawing_height
    drawing.scale_measure = rectpacking_compute_scale_measure(
      drawing.drawing_width,
      drawing.drawing_height,
      drawing.desired_aspect_ratio,
    )
  }
}

///|
pub fn new_rectpacking_drawing_data(
  desired_aspect_ratio : Double,
  drawing_width : Double,
  drawing_height : Double,
  placement_option : RectpackingDrawingDataDescriptor,
  next_x_coordinate? : Double = 0.0,
  next_y_coordinate? : Double = 0.0,
) -> RectpackingDrawingData {
  let data = {
    scale_measure: 0.0,
    drawing_width,
    drawing_height,
    area: 0.0,
    aspect_ratio: 0.0,
    desired_aspect_ratio,
    placement_option,
    next_x_coordinate,
    next_y_coordinate,
  }
  rectpacking_drawing_data_calc(data)
  data
}

///|
pub fn RectpackingDrawingData::set_drawing_width(
  self : RectpackingDrawingData,
  drawing_width : Double,
) -> Unit {
  self.drawing_width = drawing_width
  rectpacking_drawing_data_calc(self)
}

///|
pub fn RectpackingDrawingData::set_drawing_height(
  self : RectpackingDrawingData,
  drawing_height : Double,
) -> Unit {
  self.drawing_height = drawing_height
  rectpacking_drawing_data_calc(self)
}
