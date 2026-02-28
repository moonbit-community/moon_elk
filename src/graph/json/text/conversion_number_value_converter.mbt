///|
pub struct GraphJsonTextNumberValueConverter {
  marker : Unit
}

///|
pub suberror GraphJsonTextNumberValueConverterException {
  GraphJsonTextNumberValueConverterException(String)
} derive(Show, ToJson)

///|
fn graph_json_text_number_value_converter_raise_unit(
  message : String,
) -> Unit raise GraphJsonTextNumberValueConverterException {
  raise GraphJsonTextNumberValueConverterException(message)
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
    None => {
      try
        graph_json_text_number_value_converter_raise_unit(
          "Double value may not be null.",
        )
      catch {
        GraphJsonTextNumberValueConverterException(message) =>
          @core.layout_runtime_report_unsupported_configuration(
            "org.eclipse.elk.graph.json.text.conversion.NumberValueConverter: " +
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
pub fn GraphJsonTextNumberValueConverter::to_value(
  self : GraphJsonTextNumberValueConverter,
  text : String,
) -> Double {
  ignore(self)
  if text == "" {
    try
      graph_json_text_number_value_converter_raise_unit(
        "Cannot convert empty string to a double value.",
      )
    catch {
      GraphJsonTextNumberValueConverterException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.graph.json.text.conversion.NumberValueConverter: " +
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
        graph_json_text_number_value_converter_raise_unit(
          "Cannot convert '" + text + "' to a double value.",
        )
      catch {
        GraphJsonTextNumberValueConverterException(message) =>
          @core.layout_runtime_report_unsupported_configuration(
            "org.eclipse.elk.graph.json.text.conversion.NumberValueConverter: " +
            message,
          )
      } noraise {
        _ => ()
      }
      0.0
    }
  }
}
