///|
pub struct GraphJsonTextNumberValueConverter {
  marker : Unit
}

///|
pub fn new_graph_json_text_number_value_converter() -> GraphJsonTextNumberValueConverter {
  { marker: () }
}

///|
pub fn GraphJsonTextNumberValueConverter::to_string(
  self : GraphJsonTextNumberValueConverter,
  value : Double?,
) -> String {
  ignore(self)
  match value {
    None => abort("Double value may not be null.")
    Some(number) =>
      if number.to_int().to_double() == number {
        number.to_int().to_string()
      } else {
        number.to_string()
      }
  }
}

///|
pub fn GraphJsonTextNumberValueConverter::to_value(
  self : GraphJsonTextNumberValueConverter,
  text : String,
) -> Double {
  ignore(self)
  if text == "" {
    abort("Cannot convert empty string to a double value.")
  }
  let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    text,
  )
  match parsed {
    Ok(value) => value
    Err(_) => abort("Cannot convert '" + text + "' to a double value.")
  }
}
