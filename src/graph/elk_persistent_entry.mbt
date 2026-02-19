///|
pub struct ElkPersistentEntry {
  mut key : String
  mut value : String?
}

///|
pub fn new_elk_persistent_entry(
  key? : String = "",
  value? : String? = None,
) -> ElkPersistentEntry {
  { key, value }
}

///|
pub fn ElkPersistentEntry::get_key(self : ElkPersistentEntry) -> String {
  self.key
}

///|
pub fn ElkPersistentEntry::set_key(
  self : ElkPersistentEntry,
  key : String,
) -> Unit {
  self.key = key
}

///|
pub fn ElkPersistentEntry::get_value(self : ElkPersistentEntry) -> String? {
  self.value
}

///|
pub fn ElkPersistentEntry::set_value(
  self : ElkPersistentEntry,
  value : String?,
) -> Unit {
  self.value = value
}
