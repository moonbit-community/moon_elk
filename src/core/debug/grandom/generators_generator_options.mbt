///|
pub(all) enum CoreDebugGRandomFileFormat {
  FileXmi
  FileXtext
}

///|
pub fn core_debug_grandom_file_format_xtext() -> CoreDebugGRandomFileFormat {
  FileXtext
}

///|
pub(all) enum CoreDebugGRandomGraphType {
  GraphCustom
  GraphTree
  GraphBiconnected
  GraphTriconnected
  GraphAcyclicNoTransitiveEdges
  GraphBipartite
}

///|
pub fn core_debug_grandom_graph_type_custom() -> CoreDebugGRandomGraphType {
  GraphCustom
}

///|
pub fn core_debug_grandom_graph_type_tree() -> CoreDebugGRandomGraphType {
  GraphTree
}

///|
pub fn core_debug_grandom_graph_type_acyclic_no_transitive_edges() -> CoreDebugGRandomGraphType {
  GraphAcyclicNoTransitiveEdges
}

///|
pub fn core_debug_grandom_graph_type_biconnected() -> CoreDebugGRandomGraphType {
  GraphBiconnected
}

///|
pub fn core_debug_grandom_graph_type_bipartite() -> CoreDebugGRandomGraphType {
  GraphBipartite
}

///|
pub fn core_debug_grandom_graph_type_triconnected() -> CoreDebugGRandomGraphType {
  GraphTriconnected
}

///|
pub fn core_debug_grandom_graph_type_equals(
  left : CoreDebugGRandomGraphType,
  right : CoreDebugGRandomGraphType,
) -> Bool {
  match (left, right) {
    (GraphCustom, GraphCustom) => true
    (GraphTree, GraphTree) => true
    (GraphBiconnected, GraphBiconnected) => true
    (GraphTriconnected, GraphTriconnected) => true
    (GraphAcyclicNoTransitiveEdges, GraphAcyclicNoTransitiveEdges) => true
    (GraphBipartite, GraphBipartite) => true
    _ => false
  }
}

///|
pub(all) enum CoreDebugGRandomEdgeDetermination {
  EdgeAbsolute
  EdgeOutgoing
  EdgeRelative
  EdgeDensity
}

///|
pub fn core_debug_grandom_edge_determination_absolute() -> CoreDebugGRandomEdgeDetermination {
  EdgeAbsolute
}

///|
pub fn core_debug_grandom_edge_determination_relative() -> CoreDebugGRandomEdgeDetermination {
  EdgeRelative
}

///|
pub fn core_debug_grandom_edge_determination_density() -> CoreDebugGRandomEdgeDetermination {
  EdgeDensity
}

///|
pub fn core_debug_grandom_edge_determination_outgoing() -> CoreDebugGRandomEdgeDetermination {
  EdgeOutgoing
}

///|
pub fn core_debug_grandom_edge_determination_equals(
  left : CoreDebugGRandomEdgeDetermination,
  right : CoreDebugGRandomEdgeDetermination,
) -> Bool {
  match (left, right) {
    (EdgeAbsolute, EdgeAbsolute) => true
    (EdgeOutgoing, EdgeOutgoing) => true
    (EdgeRelative, EdgeRelative) => true
    (EdgeDensity, EdgeDensity) => true
    _ => false
  }
}

///|
pub(all) struct CoreDebugGRandomRandVal {
  mut min : Double
  mut max : Double
  mut mean : Double
  mut stddv : Double
  exact : Double
  use_min_max : Bool
  use_exact : Bool
}

///|
fn core_debug_grandom_rand_val_box_muller(random : @random.Rand) -> Double {
  let mut u1 = random.double()
  if u1 <= 0.0 {
    u1 = 0.000000000001
  }
  let u2 = random.double()
  (-2.0 * @math.ln(u1)).sqrt() * @math.cos(2.0 * @math.PI * u2)
}

///|
pub fn core_debug_grandom_rand_val_all_nil() -> CoreDebugGRandomRandVal {
  {
    min: 0.0,
    max: 0.0,
    mean: 0.0,
    stddv: 0.0,
    exact: 0.0,
    use_min_max: false,
    use_exact: false,
  }
}

///|
pub fn core_debug_grandom_rand_val_min_max(
  min : Double,
  max : Double,
) -> CoreDebugGRandomRandVal {
  {
    min,
    max,
    mean: 0.0,
    stddv: 0.0,
    exact: 0.0,
    use_min_max: true,
    use_exact: false,
  }
}

///|
pub fn core_debug_grandom_rand_val_exact(
  exact : Double,
) -> CoreDebugGRandomRandVal {
  {
    min: 0.0,
    max: 0.0,
    mean: 0.0,
    stddv: 0.0,
    exact,
    use_min_max: false,
    use_exact: true,
  }
}

///|
pub fn core_debug_grandom_rand_val_gaussian(
  mean : Double,
  stddv : Double,
) -> CoreDebugGRandomRandVal {
  {
    min: 0.0,
    max: 0.0,
    mean,
    stddv,
    exact: 0.0,
    use_min_max: false,
    use_exact: false,
  }
}

///|
pub fn CoreDebugGRandomRandVal::val(
  self : CoreDebugGRandomRandVal,
  random : @random.Rand,
) -> Double {
  let mut result = 0.0
  if self.use_exact {
    result = self.exact
  } else if self.use_min_max {
    if self.max < self.min {
      abort("max must be greater than or equal to min")
    }
    result = random.double() * (self.max - self.min) + self.min
  } else {
    result = core_debug_grandom_rand_val_box_muller(random) * self.stddv +
      self.mean
  }
  if result < 0.0 {
    0.0
  } else {
    result
  }
}

///|
pub fn CoreDebugGRandomRandVal::int_val(
  self : CoreDebugGRandomRandVal,
  random : @random.Rand,
) -> Int {
  self.val(random).round().to_int()
}

///|
pub fn CoreDebugGRandomRandVal::default_int(
  self : CoreDebugGRandomRandVal,
) -> Int {
  self.exact.round().to_int()
}

///|
pub fn CoreDebugGRandomRandVal::float_val(
  self : CoreDebugGRandomRandVal,
  random : @random.Rand,
) -> Double {
  self.val(random)
}

///|
pub fn CoreDebugGRandomRandVal::set_mean(
  self : CoreDebugGRandomRandVal,
  value : Double,
) -> Unit {
  self.mean = value
}

///|
pub fn CoreDebugGRandomRandVal::set_stddv(
  self : CoreDebugGRandomRandVal,
  value : Double,
) -> Unit {
  self.stddv = value
}

///|
pub fn CoreDebugGRandomRandVal::set_min(
  self : CoreDebugGRandomRandVal,
  value : Int,
) -> Unit {
  self.min = value.to_double()
}

///|
pub fn CoreDebugGRandomRandVal::set_max(
  self : CoreDebugGRandomRandVal,
  value : Int,
) -> Unit {
  self.max = value.to_double()
}

///|
pub fn CoreDebugGRandomRandVal::min(self : CoreDebugGRandomRandVal) -> Double {
  self.min
}

///|
pub fn CoreDebugGRandomRandVal::max(self : CoreDebugGRandomRandVal) -> Double {
  self.max
}

///|
pub fn CoreDebugGRandomRandVal::default_val(
  self : CoreDebugGRandomRandVal,
) -> Double {
  self.exact
}

///|
pub let core_debug_grandom_number_of_graphs : @graph.IProperty[Int] = @graph.new_property(
  "randomWizard.numberOfGraphs", 1,
)

///|
pub let core_debug_grandom_file_name : @graph.IProperty[String] = @graph.new_property(
  "randomWizard.filename", "random.kgt",
)

///|
pub let core_debug_grandom_file_format : @graph.IProperty[CoreDebugGRandomFileFormat] = @graph.new_property(
  "randomWizard.fileFormat",
  FileXtext,
)

///|
pub let core_debug_grandom_graph_type : @graph.IProperty[CoreDebugGRandomGraphType] = @graph.new_property(
  "basic.graphType",
  GraphCustom,
)

///|
pub let core_debug_grandom_number_of_nodes : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.numNodes",
  core_debug_grandom_rand_val_exact(10.0),
)

///|
pub let core_debug_grandom_edge_determination : @graph.IProperty[
  CoreDebugGRandomEdgeDetermination,
] = @graph.new_property("basic.edgeDetermination", EdgeAbsolute)

///|
pub let core_debug_grandom_edges_absolute : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.numberOfEdges",
  core_debug_grandom_rand_val_exact(20.0),
)

///|
pub let core_debug_grandom_relative_edges : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.relEdges",
  core_debug_grandom_rand_val_all_nil(),
)

///|
pub let core_debug_grandom_density : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.density",
  core_debug_grandom_rand_val_all_nil(),
)

///|
pub let core_debug_grandom_enable_hierarchy : @graph.IProperty[Bool] = @graph.new_property(
  "basic.enableHierarchy", false,
)

///|
pub let core_debug_grandom_hierarchy_chance : @graph.IProperty[Double] = @graph.new_property(
  "basic.hierarchyChance", 0.05,
)

///|
pub let core_debug_grandom_max_hierarchy_level : @graph.IProperty[
  CoreDebugGRandomRandVal,
] = @graph.new_property(
  "basic.maxHierarchyLevel",
  core_debug_grandom_rand_val_exact(3.0),
)

///|
pub let core_debug_grandom_hierarchy_nodes_factor : @graph.IProperty[Double] = @graph.new_property(
  "basic.hierarchyNodesFactor", 0.5,
)

///|
pub let core_debug_grandom_hypernode_chance : @graph.IProperty[Double] = @graph.new_property(
  "basic.hypernodeChance", 0.0,
)

///|
pub let core_debug_grandom_enable_ports : @graph.IProperty[Bool] = @graph.new_property(
  "basic.ports", false,
)

///|
pub let core_debug_grandom_use_existing_ports_chance : @graph.IProperty[
  CoreDebugGRandomRandVal,
] = @graph.new_property(
  "basic.useExistingPortsChance",
  core_debug_grandom_rand_val_exact(0.3),
)

///|
pub let core_debug_grandom_cross_hierarchy_edges : @graph.IProperty[Bool] = @graph.new_property(
  "basic.crossHierarchyEdges", false,
)

///|
pub let core_debug_grandom_time_based_randomization : @graph.IProperty[Bool] = @graph.new_property(
  "basic.timeBasedRandomization", true,
)

///|
pub let core_debug_grandom_randomization_seed : @graph.IProperty[Int] = @graph.new_property(
  "basic.randomizationSeed", 0,
)

///|
pub let core_debug_grandom_set_node_size : @graph.IProperty[Bool] = @graph.new_property(
  "basic.setNodeSize", true,
)

///|
pub let core_debug_grandom_node_width : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.minNodeWidth",
  core_debug_grandom_rand_val_exact(30.0),
)

///|
pub let core_debug_grandom_node_height : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.minNodeHeight",
  core_debug_grandom_rand_val_exact(30.0),
)

///|
pub let core_debug_grandom_create_node_labels : @graph.IProperty[Bool] = @graph.new_property(
  "basic.createNodeLabels", false,
)

///|
pub let core_debug_grandom_set_port_size : @graph.IProperty[Bool] = @graph.new_property(
  "basic.setPortSize", true,
)

///|
pub let core_debug_grandom_port_width : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.portWidth",
  core_debug_grandom_rand_val_exact(4.0),
)

///|
pub let core_debug_grandom_port_height : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.portHeight",
  core_debug_grandom_rand_val_exact(4.0),
)

///|
pub let core_debug_grandom_create_port_labels : @graph.IProperty[Bool] = @graph.new_property(
  "basic.createPortLabels", false,
)

///|
pub let core_debug_grandom_port_constraints : @graph.IProperty[@core.PortConstraints] = @graph.new_property(
  "layout.portConstraints",
  Undefined,
)

///|
pub let core_debug_grandom_incoming_north_side : @graph.IProperty[Int] = @graph.new_property(
  "layout.incomingNorthSide", 10,
)

///|
pub let core_debug_grandom_incoming_east_side : @graph.IProperty[Int] = @graph.new_property(
  "layout.incomingEastSide", 5,
)

///|
pub let core_debug_grandom_incoming_south_side : @graph.IProperty[Int] = @graph.new_property(
  "layout.incomingSouthSide", 10,
)

///|
pub let core_debug_grandom_incoming_west_side : @graph.IProperty[Int] = @graph.new_property(
  "layout.incomingWestSide", 75,
)

///|
pub let core_debug_grandom_outgoing_north_side : @graph.IProperty[Int] = @graph.new_property(
  "layout.outgoingNorthSide", 10,
)

///|
pub let core_debug_grandom_outgoing_east_side : @graph.IProperty[Int] = @graph.new_property(
  "layout.outgoingEastSide", 75,
)

///|
pub let core_debug_grandom_outgoing_south_side : @graph.IProperty[Int] = @graph.new_property(
  "layout.outgoingSouthSide", 10,
)

///|
pub let core_debug_grandom_outgoing_west_side : @graph.IProperty[Int] = @graph.new_property(
  "layout.outgoingWestSide", 5,
)

///|
pub let core_debug_grandom_outgoing_edges : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.minOutgoingEdges",
  core_debug_grandom_rand_val_all_nil(),
)

///|
pub let core_debug_grandom_self_loops : @graph.IProperty[Bool] = @graph.new_property(
  "basic.selfLoops", false,
)

///|
pub let core_debug_grandom_multi_edges : @graph.IProperty[Bool] = @graph.new_property(
  "basic.multiEdges", true,
)

///|
pub let core_debug_grandom_cycles : @graph.IProperty[Bool] = @graph.new_property(
  "basic.cycles", true,
)

///|
pub let core_debug_grandom_isolated_nodes : @graph.IProperty[Bool] = @graph.new_property(
  "basic.isolatedNodes", true,
)

///|
pub let core_debug_grandom_edge_labels : @graph.IProperty[Bool] = @graph.new_property(
  "basic.edgeLabels", false,
)

///|
pub let core_debug_grandom_max_width : @graph.IProperty[Int] = @graph.new_property(
  "basic.maxWidth", 0,
)

///|
pub let core_debug_grandom_max_degree : @graph.IProperty[Int] = @graph.new_property(
  "basic.maxDegree", 0,
)

///|
pub let core_debug_grandom_planar : @graph.IProperty[Bool] = @graph.new_property(
  "basic.planar", false,
)

///|
pub let core_debug_grandom_partition_frac : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.minPartitionFraction",
  core_debug_grandom_rand_val_exact(0.4),
)

///|
pub let core_debug_grandom_small_hierarchy : @graph.IProperty[Bool] = @graph.new_property(
  "basic.SMALL_HIERARCHY", false,
)

///|
pub let core_debug_grandom_number_hierarchical_nodes : @graph.IProperty[
  CoreDebugGRandomRandVal,
] = @graph.new_property("basic.HIERARCH_NODE", core_debug_grandom_rand_val_all_nil())

///|
pub let core_debug_grandom_cross_hier : @graph.IProperty[CoreDebugGRandomRandVal] = @graph.new_property(
  "basic.CROSS_HIER",
  core_debug_grandom_rand_val_all_nil(),
)

///|
pub let core_debug_grandom_exact_relative_hier : @graph.IProperty[
  CoreDebugGRandomRandVal?,
] = @graph.new_property("basic.EXACT_RELATIVE_HIER", None)

///|
pub(all) struct CoreDebugGRandomGeneratorOptions {
  bool_values : Map[String, Bool]
  int_values : Map[String, Int]
  double_values : Map[String, Double]
  string_values : Map[String, String]
  rand_values : Map[String, CoreDebugGRandomRandVal]
  rand_opt_values : Map[String, CoreDebugGRandomRandVal?]
  port_constraint_values : Map[String, @core.PortConstraints]
  file_format_values : Map[String, CoreDebugGRandomFileFormat]
  graph_type_values : Map[String, CoreDebugGRandomGraphType]
  edge_determination_values : Map[String, CoreDebugGRandomEdgeDetermination]
}

///|
pub fn new_core_debug_grandom_generator_options() -> CoreDebugGRandomGeneratorOptions {
  {
    bool_values: {},
    int_values: {},
    double_values: {},
    string_values: {},
    rand_values: {},
    rand_opt_values: {},
    port_constraint_values: {},
    file_format_values: {},
    graph_type_values: {},
    edge_determination_values: {},
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_bool_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_bool_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[Bool],
) -> Bool {
  match self.bool_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_int_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[Int],
  value : Int,
) -> Unit {
  self.int_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_int_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[Int],
) -> Int {
  match self.int_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_double_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[Double],
  value : Double,
) -> Unit {
  self.double_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_double_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[Double],
) -> Double {
  match self.double_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_string_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[String],
  value : String,
) -> Unit {
  self.string_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_string_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[String],
) -> String {
  match self.string_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_rand_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomRandVal],
  value : CoreDebugGRandomRandVal,
) -> Unit {
  self.rand_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_rand_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomRandVal],
) -> CoreDebugGRandomRandVal {
  match self.rand_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_optional_rand_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomRandVal?],
  value : CoreDebugGRandomRandVal?,
) -> Unit {
  self.rand_opt_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_optional_rand_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomRandVal?],
) -> CoreDebugGRandomRandVal? {
  match self.rand_opt_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_port_constraints_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[@core.PortConstraints],
  value : @core.PortConstraints,
) -> Unit {
  self.port_constraint_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_port_constraints_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[@core.PortConstraints],
) -> @core.PortConstraints {
  match self.port_constraint_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_file_format_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomFileFormat],
  value : CoreDebugGRandomFileFormat,
) -> Unit {
  self.file_format_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_file_format_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomFileFormat],
) -> CoreDebugGRandomFileFormat {
  match self.file_format_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_graph_type_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomGraphType],
  value : CoreDebugGRandomGraphType,
) -> Unit {
  self.graph_type_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_graph_type_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomGraphType],
) -> CoreDebugGRandomGraphType {
  match self.graph_type_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_edge_determination_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomEdgeDetermination],
  value : CoreDebugGRandomEdgeDetermination,
) -> Unit {
  self.edge_determination_values[property.get_id()] = value
}

///|
pub fn CoreDebugGRandomGeneratorOptions::get_edge_determination_property(
  self : CoreDebugGRandomGeneratorOptions,
  property : @graph.IProperty[CoreDebugGRandomEdgeDetermination],
) -> CoreDebugGRandomEdgeDetermination {
  match self.edge_determination_values.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn CoreDebugGRandomGeneratorOptions::set_quantities(
  self : CoreDebugGRandomGeneratorOptions,
  quantity : CoreDebugGRandomDoubleQuantity?,
  property : @graph.IProperty[CoreDebugGRandomRandVal],
) -> Unit {
  if core_debug_grandom_double_quantity_exists(quantity) {
    self.set_rand_property(
      property,
      core_debug_grandom_quantity_to_rand_val(quantity),
    )
  }
}

///|
fn core_debug_grandom_quantity_to_rand_val(
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomRandVal {
  match quantity {
    Some(quant) =>
      if quant.min_max {
        core_debug_grandom_rand_val_min_max(
          quant.min.unwrap_or(0.0),
          quant.max.unwrap_or(0.0),
        )
      } else if quant.gaussian {
        core_debug_grandom_rand_val_gaussian(
          quant.mean.unwrap_or(0.0),
          quant.stddv.unwrap_or(0.0),
        )
      } else {
        core_debug_grandom_rand_val_exact(quant.quant.unwrap_or(0.0))
      }
    None => core_debug_grandom_rand_val_all_nil()
  }
}
