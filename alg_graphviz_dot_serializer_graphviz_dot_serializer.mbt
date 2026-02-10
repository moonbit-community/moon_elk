///|
pub let graphviz_dot_serializer_max_line_length : Int = 255

///|
pub struct GraphvizDotSaveOptions {
  formatting : Bool
}

///|
pub fn new_graphviz_dot_save_options(
  formatting? : Bool = false,
) -> GraphvizDotSaveOptions {
  { formatting, }
}

///|
pub fn GraphvizDotSaveOptions::is_formatting(
  self : GraphvizDotSaveOptions,
) -> Bool {
  self.formatting
}

///|
pub struct GraphvizDotFormatterRequest {
  mut max_line_width : Int
  mut format_undefined_hidden_regions_only : Bool
  mut text : String
}

///|
pub type GraphvizDotFormatter2 = (GraphvizDotFormatterRequest) -> String

///|
pub fn new_graphviz_dot_formatter_request() -> GraphvizDotFormatterRequest {
  { max_line_width: 0, format_undefined_hidden_regions_only: true, text: "" }
}

///|
pub fn GraphvizDotFormatterRequest::set_max_line_width(
  self : GraphvizDotFormatterRequest,
  value : Int,
) -> Unit {
  self.max_line_width = value
}

///|
pub fn GraphvizDotFormatterRequest::get_max_line_width(
  self : GraphvizDotFormatterRequest,
) -> Int {
  self.max_line_width
}

///|
pub fn GraphvizDotFormatterRequest::set_format_undefined_hidden_regions_only(
  self : GraphvizDotFormatterRequest,
  value : Bool,
) -> Unit {
  self.format_undefined_hidden_regions_only = value
}

///|
pub fn GraphvizDotFormatterRequest::is_format_undefined_hidden_regions_only(
  self : GraphvizDotFormatterRequest,
) -> Bool {
  self.format_undefined_hidden_regions_only
}

///|
pub fn GraphvizDotFormatterRequest::set_text(
  self : GraphvizDotFormatterRequest,
  value : String,
) -> Unit {
  self.text = value
}

///|
pub fn GraphvizDotFormatterRequest::get_text(
  self : GraphvizDotFormatterRequest,
) -> String {
  self.text
}

///|
pub struct GraphvizDotSerializer {
  formatter2_provider : () -> GraphvizDotFormatter2
  formatter_request_provider : () -> GraphvizDotFormatterRequest
}

///|
fn graphviz_dot_serializer_default_formatter(
  request : GraphvizDotFormatterRequest,
) -> String {
  request.get_text()
}

///|
fn graphviz_dot_serializer_default_formatter_provider() -> GraphvizDotFormatter2 {
  graphviz_dot_serializer_default_formatter
}

///|
pub fn new_graphviz_dot_serializer(
  formatter2_provider? : () -> GraphvizDotFormatter2 = graphviz_dot_serializer_default_formatter_provider,
  formatter_request_provider? : () -> GraphvizDotFormatterRequest = new_graphviz_dot_formatter_request,
) -> GraphvizDotSerializer {
  { formatter2_provider, formatter_request_provider }
}

///|
pub fn GraphvizDotSerializer::serialize(
  self : GraphvizDotSerializer,
  text : String,
  options : GraphvizDotSaveOptions,
) -> String {
  let request = (self.formatter_request_provider)()
  request.set_max_line_width(graphviz_dot_serializer_max_line_length)
  request.set_format_undefined_hidden_regions_only(!options.is_formatting())
  request.set_text(text)
  let formatter2 = (self.formatter2_provider)()
  formatter2(request)
}
