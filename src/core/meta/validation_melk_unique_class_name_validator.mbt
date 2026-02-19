///|
pub(all) struct MelkUniqueClassNameValidator {
  src_segment : String
}

///|
pub fn new_melk_unique_class_name_validator() -> MelkUniqueClassNameValidator {
  { src_segment: "src" }
}

///|
pub fn MelkUniqueClassNameValidator::do_check_unique_name(
  self : MelkUniqueClassNameValidator,
  name : String,
  type_resource_segments : Array[String],
  others : Array[(String, Array[String])],
) -> Bool {
  ignore(type_resource_segments)
  for other in others {
    if other.0 == name {
      for segment in other.1 {
        if segment.contains(self.src_segment) {
          return false
        }
      }
    }
  }
  true
}
