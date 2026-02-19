///|
pub(all) struct IDataObject {
  parse_fn : (String) -> Unit
}

///|
pub fn new_data_object(parse_fn : (String) -> Unit) -> IDataObject {
  { parse_fn, }
}

///|
pub fn IDataObject::parse(self : IDataObject, string : String) -> Unit {
  (self.parse_fn)(string)
}
