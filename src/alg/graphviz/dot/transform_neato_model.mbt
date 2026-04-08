///|
pub enum NeatoModel {
  Shortpath
  Circuit
  Subset
}

///|
pub(all) suberror NeatoModelException {
  IllegalArgumentException(String)
} derive(Debug, ToJson)

///|
fn[T] neato_model_raise_illegal_argument(
  message : String,
) -> T raise NeatoModelException {
  raise NeatoModelException::IllegalArgumentException(message)
}

///|
pub fn neato_model_parse(
  string : String,
) -> NeatoModel raise NeatoModelException {
  let normalized = string.to_upper()
  if normalized == "SHORTPATH" {
    Shortpath
  } else if normalized == "CIRCUIT" {
    Circuit
  } else if normalized == "SUBSET" {
    Subset
  } else {
    neato_model_raise_illegal_argument(
      "No enum constant org.eclipse.elk.alg.graphviz.dot.transform.NeatoModel.\{normalized}",
    )
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

///|
pub fn neato_model_default() -> NeatoModel {
  Shortpath
}
