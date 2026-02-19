///|
pub(all) enum CoreDebugGRandomFormats {
  FormatElkt
  FormatElkg
}

///|
pub fn core_debug_grandom_format_elkt() -> CoreDebugGRandomFormats {
  FormatElkt
}

///|
pub fn core_debug_grandom_format_elkg() -> CoreDebugGRandomFormats {
  FormatElkg
}

///|
pub(all) enum CoreDebugGRandomForm {
  FormTrees
  FormCustom
  FormBipartite
  FormBiconnected
  FormTriconnected
  FormAcyclic
}

///|
pub fn core_debug_grandom_form_trees() -> CoreDebugGRandomForm {
  FormTrees
}

///|
pub fn core_debug_grandom_form_custom() -> CoreDebugGRandomForm {
  FormCustom
}

///|
pub fn core_debug_grandom_form_bipartite() -> CoreDebugGRandomForm {
  FormBipartite
}

///|
pub(all) enum CoreDebugGRandomConstraintType {
  ConstraintFree
  ConstraintSide
  ConstraintPosition
  ConstraintOrder
  ConstraintRatio
}

///|
pub fn core_debug_grandom_constraint_free() -> CoreDebugGRandomConstraintType {
  ConstraintFree
}

///|
pub fn core_debug_grandom_constraint_position() -> CoreDebugGRandomConstraintType {
  ConstraintPosition
}

///|
pub(all) enum CoreDebugGRandomFlowType {
  FlowIncoming
  FlowOutgoing
}

///|
pub fn core_debug_grandom_flow_incoming() -> CoreDebugGRandomFlowType {
  FlowIncoming
}

///|
pub(all) enum CoreDebugGRandomSide {
  SideNorth
  SideEast
  SideSouth
  SideWest
}

///|
pub fn core_debug_grandom_side_east() -> CoreDebugGRandomSide {
  SideEast
}

///|
pub(all) struct CoreDebugGRandomDoubleQuantity {
  quant : Double?
  min : Double?
  min_max : Bool
  max : Double?
  mean : Double?
  gaussian : Bool
  stddv : Double?
}

///|
pub fn new_core_debug_grandom_double_quantity() -> CoreDebugGRandomDoubleQuantity {
  {
    quant: None,
    min: None,
    min_max: false,
    max: None,
    mean: None,
    gaussian: false,
    stddv: None,
  }
}

///|
pub fn core_debug_grandom_double_quantity_exact(
  quant : Double,
) -> CoreDebugGRandomDoubleQuantity {
  {
    quant: Some(quant),
    min: None,
    min_max: false,
    max: None,
    mean: None,
    gaussian: false,
    stddv: None,
  }
}

///|
pub fn core_debug_grandom_double_quantity_min_max(
  min : Double,
  max : Double,
) -> CoreDebugGRandomDoubleQuantity {
  {
    quant: None,
    min: Some(min),
    min_max: true,
    max: Some(max),
    mean: None,
    gaussian: false,
    stddv: None,
  }
}

///|
pub fn core_debug_grandom_double_quantity_gaussian(
  mean : Double,
  stddv : Double,
) -> CoreDebugGRandomDoubleQuantity {
  {
    quant: None,
    min: None,
    min_max: false,
    max: None,
    mean: Some(mean),
    gaussian: true,
    stddv: Some(stddv),
  }
}

///|
pub fn core_debug_grandom_double_quantity_exists(
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> Bool {
  quantity is Some(_)
}

///|
pub(all) struct CoreDebugGRandomSize {
  height : CoreDebugGRandomDoubleQuantity?
  width : CoreDebugGRandomDoubleQuantity?
}

///|
pub fn new_core_debug_grandom_size() -> CoreDebugGRandomSize {
  { height: None, width: None }
}

///|
pub fn core_debug_grandom_size_exists(size : CoreDebugGRandomSize?) -> Bool {
  size is Some(_)
}

///|
pub fn CoreDebugGRandomSize::set_height(
  self : CoreDebugGRandomSize,
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomSize {
  { height: quantity, width: self.width }
}

///|
pub fn CoreDebugGRandomSize::set_width(
  self : CoreDebugGRandomSize,
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomSize {
  { height: self.height, width: quantity }
}

///|
pub(all) struct CoreDebugGRandomFlow {
  flow_type : CoreDebugGRandomFlowType
  side : CoreDebugGRandomSide
  amount : CoreDebugGRandomDoubleQuantity?
}

///|
pub fn new_core_debug_grandom_flow(
  flow_type : CoreDebugGRandomFlowType,
  side : CoreDebugGRandomSide,
  amount? : CoreDebugGRandomDoubleQuantity? = None,
) -> CoreDebugGRandomFlow {
  { flow_type, side, amount }
}

///|
pub(all) struct CoreDebugGRandomPorts {
  labels : Bool
  re_use : CoreDebugGRandomDoubleQuantity?
  size : CoreDebugGRandomSize?
  constraint : CoreDebugGRandomConstraintType?
  flow : Array[CoreDebugGRandomFlow]
}

///|
pub fn new_core_debug_grandom_ports() -> CoreDebugGRandomPorts {
  { labels: false, re_use: None, size: None, constraint: None, flow: [] }
}

///|
pub fn core_debug_grandom_ports_exists(ports : CoreDebugGRandomPorts?) -> Bool {
  ports is Some(_)
}

///|
pub fn CoreDebugGRandomPorts::set_labels(
  self : CoreDebugGRandomPorts,
  labels : Bool,
) -> CoreDebugGRandomPorts {
  {
    labels,
    re_use: self.re_use,
    size: self.size,
    constraint: self.constraint,
    flow: self.flow,
  }
}

///|
pub fn CoreDebugGRandomPorts::set_re_use(
  self : CoreDebugGRandomPorts,
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomPorts {
  {
    labels: self.labels,
    re_use: quantity,
    size: self.size,
    constraint: self.constraint,
    flow: self.flow,
  }
}

///|
pub fn CoreDebugGRandomPorts::set_size(
  self : CoreDebugGRandomPorts,
  size : CoreDebugGRandomSize?,
) -> CoreDebugGRandomPorts {
  {
    labels: self.labels,
    re_use: self.re_use,
    size,
    constraint: self.constraint,
    flow: self.flow,
  }
}

///|
pub fn CoreDebugGRandomPorts::set_constraint(
  self : CoreDebugGRandomPorts,
  constraint : CoreDebugGRandomConstraintType?,
) -> CoreDebugGRandomPorts {
  {
    labels: self.labels,
    re_use: self.re_use,
    size: self.size,
    constraint,
    flow: self.flow,
  }
}

///|
pub fn CoreDebugGRandomPorts::set_flow(
  self : CoreDebugGRandomPorts,
  flow : Array[CoreDebugGRandomFlow],
) -> CoreDebugGRandomPorts {
  {
    labels: self.labels,
    re_use: self.re_use,
    size: self.size,
    constraint: self.constraint,
    flow: flow.copy(),
  }
}

///|
pub(all) struct CoreDebugGRandomNodes {
  n_nodes : CoreDebugGRandomDoubleQuantity?
  ports : CoreDebugGRandomPorts?
  labels : Bool
  size : CoreDebugGRandomSize?
  remove_isolated : Bool
}

///|
pub fn new_core_debug_grandom_nodes() -> CoreDebugGRandomNodes {
  {
    n_nodes: None,
    ports: None,
    labels: false,
    size: None,
    remove_isolated: false,
  }
}

///|
pub fn core_debug_grandom_nodes_exists(nodes : CoreDebugGRandomNodes?) -> Bool {
  nodes is Some(_)
}

///|
pub fn CoreDebugGRandomNodes::set_n_nodes(
  self : CoreDebugGRandomNodes,
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomNodes {
  {
    n_nodes: quantity,
    ports: self.ports,
    labels: self.labels,
    size: self.size,
    remove_isolated: self.remove_isolated,
  }
}

///|
pub fn CoreDebugGRandomNodes::set_ports(
  self : CoreDebugGRandomNodes,
  ports : CoreDebugGRandomPorts?,
) -> CoreDebugGRandomNodes {
  {
    n_nodes: self.n_nodes,
    ports,
    labels: self.labels,
    size: self.size,
    remove_isolated: self.remove_isolated,
  }
}

///|
pub fn CoreDebugGRandomNodes::set_labels(
  self : CoreDebugGRandomNodes,
  labels : Bool,
) -> CoreDebugGRandomNodes {
  {
    n_nodes: self.n_nodes,
    ports: self.ports,
    labels,
    size: self.size,
    remove_isolated: self.remove_isolated,
  }
}

///|
pub fn CoreDebugGRandomNodes::set_size(
  self : CoreDebugGRandomNodes,
  size : CoreDebugGRandomSize?,
) -> CoreDebugGRandomNodes {
  {
    n_nodes: self.n_nodes,
    ports: self.ports,
    labels: self.labels,
    size,
    remove_isolated: self.remove_isolated,
  }
}

///|
pub fn CoreDebugGRandomNodes::set_remove_isolated(
  self : CoreDebugGRandomNodes,
  remove_isolated : Bool,
) -> CoreDebugGRandomNodes {
  {
    n_nodes: self.n_nodes,
    ports: self.ports,
    labels: self.labels,
    size: self.size,
    remove_isolated,
  }
}

///|
pub(all) struct CoreDebugGRandomEdges {
  density : Bool
  total : Bool
  relative : Bool
  outbound : Bool
  n_edges : CoreDebugGRandomDoubleQuantity?
  labels : Bool
  self_loops : Bool
}

///|
pub fn new_core_debug_grandom_edges() -> CoreDebugGRandomEdges {
  {
    density: false,
    total: false,
    relative: false,
    outbound: false,
    n_edges: None,
    labels: false,
    self_loops: false,
  }
}

///|
pub fn core_debug_grandom_edges_exists(edges : CoreDebugGRandomEdges?) -> Bool {
  edges is Some(_)
}

///|
pub fn CoreDebugGRandomEdges::set_total(
  self : CoreDebugGRandomEdges,
  total : Bool,
) -> CoreDebugGRandomEdges {
  {
    density: self.density,
    total,
    relative: self.relative,
    outbound: self.outbound,
    n_edges: self.n_edges,
    labels: self.labels,
    self_loops: self.self_loops,
  }
}

///|
pub fn CoreDebugGRandomEdges::set_n_edges(
  self : CoreDebugGRandomEdges,
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomEdges {
  {
    density: self.density,
    total: self.total,
    relative: self.relative,
    outbound: self.outbound,
    n_edges: quantity,
    labels: self.labels,
    self_loops: self.self_loops,
  }
}

///|
pub fn CoreDebugGRandomEdges::set_labels(
  self : CoreDebugGRandomEdges,
  labels : Bool,
) -> CoreDebugGRandomEdges {
  {
    density: self.density,
    total: self.total,
    relative: self.relative,
    outbound: self.outbound,
    n_edges: self.n_edges,
    labels,
    self_loops: self.self_loops,
  }
}

///|
pub fn CoreDebugGRandomEdges::set_self_loops(
  self : CoreDebugGRandomEdges,
  self_loops : Bool,
) -> CoreDebugGRandomEdges {
  {
    density: self.density,
    total: self.total,
    relative: self.relative,
    outbound: self.outbound,
    n_edges: self.n_edges,
    labels: self.labels,
    self_loops,
  }
}

///|
pub(all) struct CoreDebugGRandomHierarchy {
  levels : CoreDebugGRandomDoubleQuantity?
  edges : CoreDebugGRandomDoubleQuantity?
  num_hierarch_nodes : CoreDebugGRandomDoubleQuantity?
  cross_hierarch_rel : CoreDebugGRandomDoubleQuantity?
}

///|
pub fn new_core_debug_grandom_hierarchy() -> CoreDebugGRandomHierarchy {
  {
    levels: None,
    edges: None,
    num_hierarch_nodes: None,
    cross_hierarch_rel: None,
  }
}

///|
pub fn core_debug_grandom_hierarchy_exists(
  hierarchy : CoreDebugGRandomHierarchy?,
) -> Bool {
  hierarchy is Some(_)
}

///|
pub fn CoreDebugGRandomHierarchy::set_levels(
  self : CoreDebugGRandomHierarchy,
  levels : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomHierarchy {
  {
    levels,
    edges: self.edges,
    num_hierarch_nodes: self.num_hierarch_nodes,
    cross_hierarch_rel: self.cross_hierarch_rel,
  }
}

///|
pub fn CoreDebugGRandomHierarchy::set_edges(
  self : CoreDebugGRandomHierarchy,
  edges : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomHierarchy {
  {
    levels: self.levels,
    edges,
    num_hierarch_nodes: self.num_hierarch_nodes,
    cross_hierarch_rel: self.cross_hierarch_rel,
  }
}

///|
pub fn CoreDebugGRandomHierarchy::set_num_hierarch_nodes(
  self : CoreDebugGRandomHierarchy,
  num_hierarch_nodes : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomHierarchy {
  {
    levels: self.levels,
    edges: self.edges,
    num_hierarch_nodes,
    cross_hierarch_rel: self.cross_hierarch_rel,
  }
}

///|
pub fn CoreDebugGRandomHierarchy::set_cross_hierarch_rel(
  self : CoreDebugGRandomHierarchy,
  cross_hierarch_rel : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomHierarchy {
  {
    levels: self.levels,
    edges: self.edges,
    num_hierarch_nodes: self.num_hierarch_nodes,
    cross_hierarch_rel,
  }
}

///|
pub(all) struct CoreDebugGRandomConfiguration {
  samples : Int
  form : CoreDebugGRandomForm
  nodes : CoreDebugGRandomNodes?
  edges : CoreDebugGRandomEdges?
  m_w : Bool
  max_width : Int?
  m_d : Bool
  max_degree : Int?
  p_f : Bool
  fraction : CoreDebugGRandomDoubleQuantity?
  hierarchy : CoreDebugGRandomHierarchy?
  seed : Int?
  format : CoreDebugGRandomFormats?
  filename : String?
}

///|
pub fn new_core_debug_grandom_configuration() -> CoreDebugGRandomConfiguration {
  {
    samples: 1,
    form: FormCustom,
    nodes: None,
    edges: None,
    m_w: false,
    max_width: None,
    m_d: false,
    max_degree: None,
    p_f: false,
    fraction: None,
    hierarchy: None,
    seed: None,
    format: None,
    filename: None,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_samples(
  self : CoreDebugGRandomConfiguration,
  samples : Int,
) -> CoreDebugGRandomConfiguration {
  {
    samples,
    form: self.form,
    nodes: self.nodes,
    edges: self.edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy: self.hierarchy,
    seed: self.seed,
    format: self.format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_form(
  self : CoreDebugGRandomConfiguration,
  form : CoreDebugGRandomForm,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form,
    nodes: self.nodes,
    edges: self.edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy: self.hierarchy,
    seed: self.seed,
    format: self.format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_nodes(
  self : CoreDebugGRandomConfiguration,
  nodes : CoreDebugGRandomNodes?,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form: self.form,
    nodes,
    edges: self.edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy: self.hierarchy,
    seed: self.seed,
    format: self.format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_edges(
  self : CoreDebugGRandomConfiguration,
  edges : CoreDebugGRandomEdges?,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form: self.form,
    nodes: self.nodes,
    edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy: self.hierarchy,
    seed: self.seed,
    format: self.format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_tree_limits(
  self : CoreDebugGRandomConfiguration,
  max_width : Int?,
  max_degree : Int?,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form: self.form,
    nodes: self.nodes,
    edges: self.edges,
    m_w: max_width is Some(_),
    max_width,
    m_d: max_degree is Some(_),
    max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy: self.hierarchy,
    seed: self.seed,
    format: self.format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_fraction(
  self : CoreDebugGRandomConfiguration,
  fraction : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form: self.form,
    nodes: self.nodes,
    edges: self.edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: fraction is Some(_),
    fraction,
    hierarchy: self.hierarchy,
    seed: self.seed,
    format: self.format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_hierarchy(
  self : CoreDebugGRandomConfiguration,
  hierarchy : CoreDebugGRandomHierarchy?,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form: self.form,
    nodes: self.nodes,
    edges: self.edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy,
    seed: self.seed,
    format: self.format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_seed(
  self : CoreDebugGRandomConfiguration,
  seed : Int?,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form: self.form,
    nodes: self.nodes,
    edges: self.edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy: self.hierarchy,
    seed,
    format: self.format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_format(
  self : CoreDebugGRandomConfiguration,
  format : CoreDebugGRandomFormats?,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form: self.form,
    nodes: self.nodes,
    edges: self.edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy: self.hierarchy,
    seed: self.seed,
    format,
    filename: self.filename,
  }
}

///|
pub fn CoreDebugGRandomConfiguration::set_filename(
  self : CoreDebugGRandomConfiguration,
  filename : String?,
) -> CoreDebugGRandomConfiguration {
  {
    samples: self.samples,
    form: self.form,
    nodes: self.nodes,
    edges: self.edges,
    m_w: self.m_w,
    max_width: self.max_width,
    m_d: self.m_d,
    max_degree: self.max_degree,
    p_f: self.p_f,
    fraction: self.fraction,
    hierarchy: self.hierarchy,
    seed: self.seed,
    format: self.format,
    filename,
  }
}

///|
pub(all) struct CoreDebugGRandomRandGraph {
  configs : Array[CoreDebugGRandomConfiguration]
}

///|
pub fn new_core_debug_grandom_rand_graph(
  configs? : Array[CoreDebugGRandomConfiguration] = [],
) -> CoreDebugGRandomRandGraph {
  { configs: configs.copy() }
}

///|
pub fn CoreDebugGRandomRandGraph::add_config(
  self : CoreDebugGRandomRandGraph,
  config : CoreDebugGRandomConfiguration,
) -> CoreDebugGRandomRandGraph {
  let next_configs = self.configs.copy()
  next_configs.push(config)
  { configs: next_configs }
}
