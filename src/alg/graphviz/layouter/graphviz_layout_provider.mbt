///|
pub let graphviz_layout_provider_pref_graphviz_reuse_process : String = "graphviz.reuseProcess"

///|
pub let graphviz_layout_provider_reuse_process_default : Bool = true

///|
pub let graphviz_layout_provider_debug_mode : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.debugMode", false,
)

///|
pub struct GraphvizLayoutDiagnostic {
  line : Int
  message : String
}

///|
pub fn new_graphviz_layout_diagnostic(
  line : Int,
  message : String,
) -> GraphvizLayoutDiagnostic {
  { line, message }
}

///|
pub fn GraphvizLayoutDiagnostic::get_line(
  self : GraphvizLayoutDiagnostic,
) -> Int {
  self.line
}

///|
pub fn GraphvizLayoutDiagnostic::get_message(
  self : GraphvizLayoutDiagnostic,
) -> String {
  self.message
}

///|
pub struct GraphvizLayoutParseResult {
  model : @dot.DotGraphvizModel?
  errors : Array[GraphvizLayoutDiagnostic]
}

///|
pub fn new_graphviz_layout_parse_result(
  model : @dot.DotGraphvizModel,
) -> GraphvizLayoutParseResult {
  { model: Some(model), errors: [] }
}

///|
pub fn new_graphviz_layout_parse_result_with_errors(
  errors : Array[GraphvizLayoutDiagnostic],
) -> GraphvizLayoutParseResult {
  { model: None, errors }
}

///|
pub fn GraphvizLayoutParseResult::get_model(
  self : GraphvizLayoutParseResult,
) -> @dot.DotGraphvizModel? {
  self.model
}

///|
pub fn GraphvizLayoutParseResult::get_errors(
  self : GraphvizLayoutParseResult,
) -> Array[GraphvizLayoutDiagnostic] {
  self.errors
}

///|
pub struct GraphvizLayoutResourceSet {
  serialize_fn : (@dot.DotGraphvizModel) -> Array[Int]
  parse_fn : (Array[Int]) -> GraphvizLayoutParseResult
}

///|
pub fn new_graphviz_layout_resource_set(
  serialize_fn : (@dot.DotGraphvizModel) -> Array[Int],
  parse_fn : (Array[Int]) -> GraphvizLayoutParseResult,
) -> GraphvizLayoutResourceSet {
  { serialize_fn, parse_fn }
}

///|
pub fn GraphvizLayoutResourceSet::serialize(
  self : GraphvizLayoutResourceSet,
  model : @dot.DotGraphvizModel,
) -> Array[Int] {
  (self.serialize_fn)(model)
}

///|
pub fn GraphvizLayoutResourceSet::parse(
  self : GraphvizLayoutResourceSet,
  bytes : Array[Int],
) -> GraphvizLayoutParseResult {
  (self.parse_fn)(bytes)
}

///|
pub fn graphviz_layout_provider_test_default_graph_bytes_for_test() -> Array[
  Int,
] {
  [100, 105, 103, 114, 97, 112, 104, 32, 123, 125, 10]
}

///|
fn graphviz_layout_provider_default_serializer(
  _model : @dot.DotGraphvizModel,
) -> Array[Int] {
  graphviz_layout_provider_test_default_graph_bytes_for_test()
}

///|
fn graphviz_layout_provider_default_parser(
  bytes : Array[Int],
) -> GraphvizLayoutParseResult {
  if bytes.is_empty() {
    new_graphviz_layout_parse_result_with_errors([])
  } else {
    let model = @dot.dot_create_graphviz_model()
    model.get_graphs().push(@dot.dot_create_graph())
    new_graphviz_layout_parse_result(model)
  }
}

///|
let graphviz_layout_provider_serializer_ref : Ref[
  (@dot.DotGraphvizModel) -> Array[Int],
] = Ref::new(graphviz_layout_provider_default_serializer)

///|
let graphviz_layout_provider_parser_ref : Ref[
  (Array[Int]) -> GraphvizLayoutParseResult,
] = Ref::new(graphviz_layout_provider_default_parser)

///|
fn graphviz_layout_provider_default_resource_set_provider() -> GraphvizLayoutResourceSet {
  new_graphviz_layout_resource_set(
    model => (graphviz_layout_provider_serializer_ref.val)(model),
    bytes => (graphviz_layout_provider_parser_ref.val)(bytes),
  )
}

///|
let graphviz_layout_provider_resource_set_provider_ref : Ref[
  () -> GraphvizLayoutResourceSet,
] = Ref::new(graphviz_layout_provider_default_resource_set_provider)

///|
let graphviz_layout_provider_serial_call_no_ref : Ref[Int] = Ref::new(0)

///|
let graphviz_layout_provider_debug_bytes_ref : Ref[Map[String, Array[Int]]] = Ref::new({},
)

///|
pub fn graphviz_layout_provider_set_serializer_for_test(
  serializer : (@dot.DotGraphvizModel) -> Array[Int],
) -> Unit {
  graphviz_layout_provider_serializer_ref.val = serializer
}

///|
pub fn graphviz_layout_provider_set_parser_for_test(
  parser : (Array[Int]) -> GraphvizLayoutParseResult,
) -> Unit {
  graphviz_layout_provider_parser_ref.val = parser
}

///|
pub fn graphviz_layout_provider_set_resource_set_provider_for_test(
  provider : () -> GraphvizLayoutResourceSet,
) -> Unit {
  graphviz_layout_provider_resource_set_provider_ref.val = provider
}

///|
pub fn graphviz_layout_provider_get_debug_bytes_for_test(
  file_name : String,
) -> Array[Int]? {
  graphviz_layout_provider_debug_bytes_ref.val.get(file_name)
}

///|
pub fn graphviz_layout_provider_reset_runtime_for_test() -> Unit {
  graphviz_layout_provider_serializer_ref.val = graphviz_layout_provider_default_serializer
  graphviz_layout_provider_parser_ref.val = graphviz_layout_provider_default_parser
  graphviz_layout_provider_resource_set_provider_ref.val = graphviz_layout_provider_default_resource_set_provider
  graphviz_layout_provider_serial_call_no_ref.val = 0
  graphviz_layout_provider_debug_bytes_ref.val.clear()
}

///|
pub struct GraphvizLayoutProvider {
  mut command : @dot.Command
  mut graphviz_tool : GraphvizTool?
  mut dot_resource_set_provider : @dot.DotResourceSetProvider[
    GraphvizLayoutResourceSet,
  ]
  mut my_call_no : Int
}

///|
pub fn new_graphviz_layout_provider() -> GraphvizLayoutProvider {
  {
    command: @dot.command_parse("invalid"),
    graphviz_tool: None,
    dot_resource_set_provider: @dot.new_dot_resource_set_provider(() => {
      (graphviz_layout_provider_resource_set_provider_ref.val)()
    }),
    my_call_no: 0,
  }
}

///|
fn graphviz_layout_provider_sub_monitor(
  monitor : @core.IElkProgressMonitor,
  work : Double,
) -> @core.IElkProgressMonitor {
  match monitor.sub_task(work) {
    Some(sub_monitor) => sub_monitor
    None => monitor
  }
}

///|
fn graphviz_layout_provider_tool_of(
  provider : GraphvizLayoutProvider,
) -> GraphvizTool raise GraphvizException {
  match provider.graphviz_tool {
    Some(tool) => tool
    None =>
      raise new_graphviz_exception(
        "The Graphviz layout provider is not initialized.",
      )
  }
}

///|
fn graphviz_layout_provider_store_debug_bytes(
  key : String,
  value : Array[Int],
) -> Unit {
  graphviz_layout_provider_debug_bytes_ref.val[key] = value
}

///|
fn graphviz_layout_provider_read_all(
  stream : GraphvizInputStream,
) -> Array[Int] {
  let bytes : Array[Int] = []
  let mut next = stream.read()
  while next >= 0 {
    bytes.push(next)
    next = stream.read()
  }
  bytes
}

///|
fn graphviz_layout_provider_command_is_invalid(command : @dot.Command) -> Bool {
  match command {
    @dot.Invalid => true
    _ => false
  }
}

///|
fn graphviz_layout_provider_read_all_forwarding(
  stream : ForwardingInputStream,
) -> Array[Int] {
  let bytes : Array[Int] = []
  let mut next = stream.read()
  while next >= 0 {
    bytes.push(next)
    next = stream.read()
  }
  bytes
}

///|
pub fn GraphvizLayoutProvider::initialize(
  self : GraphvizLayoutProvider,
  parameter : String?,
) -> Unit {
  self.command = @dot.command_parse(
    match parameter {
      Some(value) => value
      None => ""
    },
  )
  try new_graphviz_tool(self.command) catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(err.to_string())
      self.graphviz_tool = None
    }
  } noraise {
    tool => self.graphviz_tool = Some(tool)
  }
  self.dot_resource_set_provider = @dot.new_dot_resource_set_provider(() => {
    (graphviz_layout_provider_resource_set_provider_ref.val)()
  })
}

///|
pub fn GraphvizLayoutProvider::dispose(self : GraphvizLayoutProvider) -> Unit {
  match self.graphviz_tool {
    Some(tool) =>
      try tool.cleanup(graphviz_cleanup_stop()) catch {
        err =>
          @core.layout_runtime_report_unsupported_configuration(err.to_string())
      } noraise {
        _ => ()
      }
    None => ()
  }
}

///|
fn graphviz_layout_provider_render_errors(
  errors : Array[GraphvizLayoutDiagnostic],
) -> String {
  let output = @buffer.new()
  output.write_string("Errors in Graphviz output:")
  for diagnostic in errors {
    output.write_string(
      "\n" + diagnostic.get_line().to_string() + ": " + diagnostic.get_message(),
    )
  }
  output.to_string()
}

///|
pub fn GraphvizLayoutProvider::write_dot_graph(
  self : GraphvizLayoutProvider,
  graphviz_model : @dot.DotGraphvizModel,
  monitor : @core.IElkProgressMonitor,
  debug_mode : Bool,
  resource_set : GraphvizLayoutResourceSet,
) -> Unit raise GraphvizException {
  ignore(monitor.begin("Serialize model", 1.0))
  let tool = graphviz_layout_provider_tool_of(self)
  let output_stream = tool.input()
  let bytes = resource_set.serialize(graphviz_model)

  let debug_sink = if debug_mode {
    Some(new_graphviz_byte_array_output_stream())
  } else {
    None
  }

  for byte in bytes {
    output_stream.write(byte)
    match debug_sink {
      Some(sink) => sink.as_output_stream().write(byte)
      None => ()
    }
  }
  output_stream.write(10)
  output_stream.flush()
  match debug_sink {
    Some(sink) => {
      sink.as_output_stream().write(10)
      graphviz_layout_provider_store_debug_bytes(
        self.debug_file_base() + "-in.dot",
        sink.get_bytes(),
      )
    }
    None => ()
  }
  monitor.done()
}

///|
pub fn GraphvizLayoutProvider::read_dot_graph(
  self : GraphvizLayoutProvider,
  monitor : @core.IElkProgressMonitor,
  debug_mode : Bool,
  resource_set : GraphvizLayoutResourceSet,
) -> @dot.DotGraphvizModel raise GraphvizException {
  ignore(monitor.begin("Parse output", 1.0))
  let tool = graphviz_layout_provider_tool_of(self)
  let input_stream = tool.output()

  let bytes = if debug_mode {
    let sink = new_graphviz_byte_array_output_stream()
    let forwarding = new_forwarding_input_stream(
      input_stream,
      sink.as_output_stream(),
    )
    let read_bytes = graphviz_layout_provider_read_all_forwarding(forwarding)
    graphviz_layout_provider_store_debug_bytes(
      self.debug_file_base() + "-out.dot",
      sink.get_bytes(),
    )
    read_bytes
  } else {
    graphviz_layout_provider_read_all(input_stream)
  }

  let parse_result = resource_set.parse(bytes)
  let errors = parse_result.get_errors()
  if !errors.is_empty() {
    tool.cleanup(graphviz_cleanup_error())
    raise new_graphviz_exception(graphviz_layout_provider_render_errors(errors))
  }

  let no_output_message = "No output from the Graphviz process. Try increasing the timeout value in the Eclipse Diagram Layout preferences."
  let graphviz_model = parse_result.get_model()
  match graphviz_model {
    Some(model) =>
      if model.get_graphs().is_empty() {
        tool.cleanup(graphviz_cleanup_error())
        raise new_graphviz_exception(no_output_message)
      } else {
        monitor.done()
        model
      }
    None => {
      tool.cleanup(graphviz_cleanup_error())
      raise new_graphviz_exception(no_output_message)
    }
  }
}

///|
fn graphviz_layout_provider_layout_impl(
  provider : GraphvizLayoutProvider,
  parent_node : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise GraphvizException {
  if graphviz_layout_provider_command_is_invalid(provider.command) {
    raise new_graphviz_exception(
      "The Graphviz layout provider is not initialized.",
    )
  }

  ignore(
    progress_monitor.begin(
      "Graphviz layout (" + @dot.command_to_string(provider.command) + ")",
      2.0,
    ),
  )
  if @graph.node_children(parent_node).is_empty() {
    progress_monitor.done()
    return
  }

  let debug_mode = @graph.node_get_bool_property(
    parent_node, graphviz_layout_provider_debug_mode,
  )
  graphviz_layout_provider_serial_call_no_ref.val = graphviz_layout_provider_serial_call_no_ref.val +
    1
  provider.my_call_no = graphviz_layout_provider_serial_call_no_ref.val

  let tool = graphviz_layout_provider_tool_of(provider)
  tool.initialize()

  let resource_set = provider.dot_resource_set_provider.create_resource_set()
  let dot_exporter = new_layout_dot_exporter()
  let trans_data : @dot.DotTransformationData[
    @graph.ElkNode,
    @dot.DotGraphvizModel,
  ] = @dot.new_dot_transformation_data()
  trans_data.set_source_graph(parent_node)
  trans_data.set_command_property(@dot.dot_exporter_command, provider.command)
  dot_exporter.transform(trans_data)

  let target_graphs = trans_data.get_target_graphs()
  if target_graphs.is_empty() {
    tool.cleanup(graphviz_cleanup_stop())
    progress_monitor.done()
    return
  }

  provider.write_dot_graph(
    target_graphs[0],
    graphviz_layout_provider_sub_monitor(progress_monitor, 1.0),
    debug_mode,
    resource_set,
  )

  let graphviz_output = provider.read_dot_graph(
    graphviz_layout_provider_sub_monitor(progress_monitor, 1.0),
    debug_mode,
    resource_set,
  )
  target_graphs[0] = graphviz_output
  dot_exporter.base.transfer_layout(trans_data)

  let mut reuse_process = false
  if graphviz_layouter_is_eclipse_running() {
    reuse_process = graphviz_layouter_preference_store_access_get_ui_save_boolean(
      graphviz_layout_provider_pref_graphviz_reuse_process, graphviz_layout_provider_reuse_process_default,
    )
  }
  tool.cleanup(
    if reuse_process {
      graphviz_cleanup_normal()
    } else {
      graphviz_cleanup_stop()
    },
  )
  progress_monitor.done()
}

///|
pub fn GraphvizLayoutProvider::layout(
  self : GraphvizLayoutProvider,
  parent_node : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  try
    graphviz_layout_provider_layout_impl(self, parent_node, progress_monitor)
  catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(err.to_string())
      if progress_monitor.is_running() {
        progress_monitor.done()
      }
    }
  } noraise {
    _ => ()
  }
}

///|
pub fn GraphvizLayoutProvider::debug_file_base(
  self : GraphvizLayoutProvider,
) -> String {
  let no = self.my_call_no.to_string()
  if no.length() == 1 {
    "debug00" + no
  } else if no.length() == 2 {
    "debug0" + no
  } else {
    "debug" + no
  }
}

///|
pub fn graphviz_layout_provider_as_layout_provider(
  provider : GraphvizLayoutProvider,
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider(
    (graph, monitor) => provider.layout(graph, monitor),
    initialize_fn=parameter => provider.initialize(parameter),
    dispose_fn=() => provider.dispose(),
  )
}
