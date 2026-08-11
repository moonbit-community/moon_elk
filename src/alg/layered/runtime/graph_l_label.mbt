///|
pub struct LLabel {
  shape : LShape
  text : String
  priv mut bool_properties : Map[@graph.PropertyId, Bool]?
  priv mut string_properties : Map[@graph.PropertyId, String]?
  priv mut string_array_properties : Map[@graph.PropertyId, Array[String]]?
  priv mut label_side_properties : Map[@graph.PropertyId, @core.LabelSide]?
  priv mut l_edge_properties : Map[@graph.PropertyId, LEdge]?
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
    bool_properties: None,
    string_properties: None,
    string_array_properties: None,
    label_side_properties: None,
    l_edge_properties: None,
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
  self.bool_properties = Some(
    layered_property_bag_set(
      self.bool_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LLabel::get_property_bool(
  self : LLabel,
  property : @graph.IProperty[Bool],
) -> Bool {
  match
    layered_property_bag_get(self.bool_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_bool(
  self : LLabel,
  property : @graph.IProperty[Bool],
) -> Bool {
  layered_property_bag_has(self.bool_properties, property.get_property_id())
}

///|
pub fn LLabel::set_property_string(
  self : LLabel,
  property : @graph.IProperty[String],
  value : String,
) -> Unit {
  self.string_properties = Some(
    layered_property_bag_set(
      self.string_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LLabel::get_property_string(
  self : LLabel,
  property : @graph.IProperty[String],
) -> String {
  match
    layered_property_bag_get(self.string_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_string(
  self : LLabel,
  property : @graph.IProperty[String],
) -> Bool {
  layered_property_bag_has(self.string_properties, property.get_property_id())
}

///|
pub fn LLabel::set_property_string_array(
  self : LLabel,
  property : @graph.IProperty[Array[String]],
  value : Array[String],
) -> Unit {
  self.string_array_properties = Some(
    layered_property_bag_set(
      self.string_array_properties,
      property.get_property_id(),
      value.copy(),
    ),
  )
}

///|
pub fn LLabel::get_property_string_array(
  self : LLabel,
  property : @graph.IProperty[Array[String]],
) -> Array[String] {
  match
    layered_property_bag_get(
      self.string_array_properties,
      property.get_property_id(),
    ) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_string_array(
  self : LLabel,
  property : @graph.IProperty[Array[String]],
) -> Bool {
  layered_property_bag_has(
    self.string_array_properties,
    property.get_property_id(),
  )
}

///|
pub fn LLabel::set_property_label_side(
  self : LLabel,
  property : @graph.IProperty[@core.LabelSide],
  value : @core.LabelSide,
) -> Unit {
  self.label_side_properties = Some(
    layered_property_bag_set(
      self.label_side_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LLabel::get_property_label_side(
  self : LLabel,
  property : @graph.IProperty[@core.LabelSide],
) -> @core.LabelSide {
  match
    layered_property_bag_get(
      self.label_side_properties,
      property.get_property_id(),
    ) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_label_side(
  self : LLabel,
  property : @graph.IProperty[@core.LabelSide],
) -> Bool {
  layered_property_bag_has(
    self.label_side_properties,
    property.get_property_id(),
  )
}

///|
pub fn LLabel::set_property_l_edge(
  self : LLabel,
  property : @graph.IProperty[LEdge?],
  value : LEdge?,
) -> Unit {
  match value {
    Some(edge) =>
      self.l_edge_properties = Some(
        layered_property_bag_set(
          self.l_edge_properties,
          property.get_property_id(),
          edge,
        ),
      )
    None =>
      self.l_edge_properties = layered_property_bag_remove(
        self.l_edge_properties,
        property.get_property_id(),
      )
  }
}

///|
pub fn LLabel::get_property_l_edge(
  self : LLabel,
  property : @graph.IProperty[LEdge?],
) -> LEdge? {
  match
    layered_property_bag_get(self.l_edge_properties, property.get_property_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LLabel::has_property_l_edge(
  self : LLabel,
  property : @graph.IProperty[LEdge?],
) -> Bool {
  layered_property_bag_has(self.l_edge_properties, property.get_property_id())
}
