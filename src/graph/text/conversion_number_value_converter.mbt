///|
pub struct NumberValueConverter {
  marker : Unit
}

///|
pub suberror NumberValueConverterException {
  NumberValueConverterException(String)
} derive(Show, ToJson)

///|
fn number_value_converter_raise_unit(
  message : String,
) -> Unit raise NumberValueConverterException {
  raise NumberValueConverterException(message)
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
    None => {
      try
        number_value_converter_raise_unit("Double value may not be null.")
      catch {
        NumberValueConverterException(message) =>
          @core.layout_runtime_report_unsupported_configuration(
            "org.eclipse.elk.graph.text.conversion.NumberValueConverter: " +
            message,
          )
      } noraise {
        _ => ()
      }
      ""
    }
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
    try
      number_value_converter_raise_unit(
        "Cannot convert empty string to a double value.",
      )
    catch {
      NumberValueConverterException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.graph.text.conversion.NumberValueConverter: " +
          message,
        )
    } noraise {
      _ => ()
    }
    return 0.0
  }
  let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    text,
  )
  match parsed {
    Ok(value) => value
    Err(_) => {
      try
        number_value_converter_raise_unit(
          "Cannot convert '" + text + "' to a double value.",
        )
      catch {
        NumberValueConverterException(message) =>
          @core.layout_runtime_report_unsupported_configuration(
            "org.eclipse.elk.graph.text.conversion.NumberValueConverter: " +
            message,
          )
      } noraise {
        _ => ()
      }
      0.0
    }
  }
}
