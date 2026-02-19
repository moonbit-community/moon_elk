///|
pub struct LLabel {
  shape : LShape
  text : String
  bool_properties : Map[String, Bool]
  string_properties : Map[String, String]
  string_array_properties : Map[String, Array[String]]
  label_side_properties : Map[String, @core.LabelSide]
  l_edge_properties : Map[String, LEdge]
}

///|
pub fn new_l_label() -> LLabel {
  new_l_label_text("")
}

///|
pub fn new_l_label_text(thetext : String) -> LLabel {
  {
    shape: new_l_shape(),
    text: thetext,
    bool_properties: {},
    string_properties: {},
    string_array_properties: {},
    label_side_properties: {},
    l_edge_properties: {},
  }
}

///|
pub fn LLabel::get_text(self : LLabel) -> String {
  self.text
}

///|
pub fn LLabel::set_origin_identifier(
  self : LLabel,
  identifier : String?,
) -> Unit {
  self.shape.set_origin_identifier(identifier)
}

///|
pub fn LLabel::get_origin_identifier(self : LLabel) -> String? {
  self.shape.get_origin_identifier()
}

///|
pub fn LLabel::get_id(self : LLabel) -> Int {
  self.shape.get_id()
}

///|
pub fn LLabel::set_id(self : LLabel, id : Int) -> Unit {
  self.shape.set_id(id)
}

///|
pub fn LLabel::get_position(self : LLabel) -> @core.KVector {
  self.shape.get_position()
}

///|
pub fn LLabel::get_size(self : LLabel) -> @core.KVector {
  self.shape.get_size()
}

///|
pub fn LLabel::get_designation(self : LLabel) -> String? {
  if self.text.length() > 0 {
    Some(self.text)
  } else {
    self.shape.get_designation()
  }
}

///|
pub fn LLabel::to_string(self : LLabel) -> String {
  match self.get_designation() {
    Some(designation) => "l_" + designation
    None => "label"
  }
}

///|
pub fn LLabel::set_property_bool(
  self : LLabel,
  property : @graph.IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties[property.get_id()] = value
}

///|
pub fn LLabel::get_property_bool(
  self : LLabel,
  property : @graph.IProperty[Bool],
) -> Bool {
  match self.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_bool(
  self : LLabel,
  property : @graph.IProperty[Bool],
) -> Bool {
  self.bool_properties.contains(property.get_id())
}

///|
pub fn LLabel::set_property_string(
  self : LLabel,
  property : @graph.IProperty[String],
  value : String,
) -> Unit {
  self.string_properties[property.get_id()] = value
}

///|
pub fn LLabel::get_property_string(
  self : LLabel,
  property : @graph.IProperty[String],
) -> String {
  match self.string_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_string(
  self : LLabel,
  property : @graph.IProperty[String],
) -> Bool {
  self.string_properties.contains(property.get_id())
}

///|
pub fn LLabel::set_property_string_array(
  self : LLabel,
  property : @graph.IProperty[Array[String]],
  value : Array[String],
) -> Unit {
  self.string_array_properties[property.get_id()] = value.copy()
}

///|
pub fn LLabel::get_property_string_array(
  self : LLabel,
  property : @graph.IProperty[Array[String]],
) -> Array[String] {
  match self.string_array_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_string_array(
  self : LLabel,
  property : @graph.IProperty[Array[String]],
) -> Bool {
  self.string_array_properties.contains(property.get_id())
}

///|
pub fn LLabel::set_property_label_side(
  self : LLabel,
  property : @graph.IProperty[@core.LabelSide],
  value : @core.LabelSide,
) -> Unit {
  self.label_side_properties[property.get_id()] = value
}

///|
pub fn LLabel::get_property_label_side(
  self : LLabel,
  property : @graph.IProperty[@core.LabelSide],
) -> @core.LabelSide {
  match self.label_side_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_label_side(
  self : LLabel,
  property : @graph.IProperty[@core.LabelSide],
) -> Bool {
  self.label_side_properties.contains(property.get_id())
}

///|
pub fn LLabel::set_property_l_edge(
  self : LLabel,
  property : @graph.IProperty[LEdge?],
  value : LEdge?,
) -> Unit {
  match value {
    Some(edge) => self.l_edge_properties[property.get_id()] = edge
    None => ignore(self.l_edge_properties.remove(property.get_id()))
  }
}

///|
pub fn LLabel::get_property_l_edge(
  self : LLabel,
  property : @graph.IProperty[LEdge?],
) -> LEdge? {
  match self.l_edge_properties.get(property.get_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_l_edge(
  self : LLabel,
  property : @graph.IProperty[LEdge?],
) -> Bool {
  self.l_edge_properties.contains(property.get_id())
}
