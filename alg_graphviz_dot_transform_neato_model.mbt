///|
pub enum NeatoModel {
  Shortpath
  Circuit
  Subset
}

///|
pub fn neato_model_parse(string : String) -> NeatoModel {
  let normalized = string.to_upper()
  if normalized == "SHORTPATH" {
    Shortpath
  } else if normalized == "CIRCUIT" {
    Circuit
  } else if normalized == "SUBSET" {
    Subset
  } else {
    abort("invalid neato model")
  }
}

///|
pub fn neato_model_to_string(model : NeatoModel) -> String {
  match model {
    Shortpath => "shortpath"
    Circuit => "circuit"
    Subset => "subset"
  }
}

///|
pub fn neato_model_literal(model : NeatoModel) -> String {
  neato_model_to_string(model)
}
