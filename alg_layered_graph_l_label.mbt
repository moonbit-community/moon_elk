///|
pub struct LLabel {
  shape : LShape
  text : String
}

///|
pub fn new_l_label() -> LLabel {
  new_l_label_text("")
}

///|
pub fn new_l_label_text(thetext : String) -> LLabel {
  { shape: new_l_shape(), text: thetext }
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
pub fn LLabel::get_id(self : LLabel) -> Int {
  self.shape.get_id()
}

///|
pub fn LLabel::set_id(self : LLabel, id : Int) -> Unit {
  self.shape.set_id(id)
}

///|
pub fn LLabel::get_position(self : LLabel) -> KVector {
  self.shape.get_position()
}

///|
pub fn LLabel::get_size(self : LLabel) -> KVector {
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
