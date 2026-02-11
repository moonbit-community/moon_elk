///|
pub struct NumberValueConverter {
  marker : Unit
}

///|
pub fn new_number_value_converter() -> NumberValueConverter {
  { marker: () }
}

///|
pub fn NumberValueConverter::to_string(
  self : NumberValueConverter,
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
pub fn NumberValueConverter::to_value(
  self : NumberValueConverter,
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
