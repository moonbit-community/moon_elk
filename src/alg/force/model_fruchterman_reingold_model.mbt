///|
let fr_spacing_factor = 0.01

///|
pub struct FruchtermanReingoldModel {
  state : AbstractForceModelState
  mut temperature : Double
  mut threshold : Double
  mut k : Double
}

///|
pub fn new_fruchterman_reingold_model() -> FruchtermanReingoldModel {
  {
    state: new_abstract_force_model_state(),
    temperature: force_temperature.get_default(),
    threshold: 0.0,
    k: 0.0,
  }
}

///|
pub fn FruchtermanReingoldModel::initialize(
  self : FruchtermanReingoldModel,
  graph : FGraph,
) -> Unit {
  self.temperature = graph.get_double_property(force_temperature)
  self.threshold = self.temperature /
    graph.get_int_property(force_iterations).to_double()
  let node_count = graph.get_nodes().length()
  if node_count <= 0 {
    self.k = 0.0
    return
  }
  let mut total_width = 0.0
  let mut total_height = 0.0
  for node in graph.get_nodes() {
    total_width += fnode_size(node).x
    total_height += fnode_size(node).y
  }
  let area = total_width * total_height
  let c = graph.get_double_property(force_spacing_node_node) * fr_spacing_factor
  self.k = (area / (2.0 * node_count.to_double())).sqrt() * c
}

///|
pub fn FruchtermanReingoldModel::more_iterations(
  self : FruchtermanReingoldModel,
  count : Int,
) -> Bool {
  ignore(count)
  self.temperature > 0.0
}

///|
pub fn FruchtermanReingoldModel::calc_displacement(
  self : FruchtermanReingoldModel,
  forcer : FParticle,
  forcee : FParticle,
) -> @core.KVector {
  abstract_force_model_avoid_same_position(
    abstract_force_model_random(self.state),
    forcer,
    forcee,
  )
  let displacement = fparticle_position(forcee)
    .clone()
    .sub(fparticle_position(forcer))
  let length = displacement.length()
  let distance = force_max(
    0.0,
    length - fparticle_radius(forcer) - fparticle_radius(forcee),
  )
  let mut force = fr_model_repulsive(distance, self.k) *
    fparticle_get_int_property(forcer, force_priority).to_double()
  let connection = abstract_force_model_graph(self.state).get_connection(
    forcer, forcee,
  )
  if connection > 0 {
    force -= fr_model_attractive(distance, self.k) * connection.to_double()
  }
  ignore(displacement.scale(force * self.temperature / length))
  displacement
}

///|
pub fn FruchtermanReingoldModel::iteration_done(
  self : FruchtermanReingoldModel,
) -> Unit {
  self.temperature -= self.threshold
}

///|
pub fn FruchtermanReingoldModel::layout(
  self : FruchtermanReingoldModel,
  graph : FGraph,
  monitor : @core.IElkProgressMonitor,
) -> Unit {
  abstract_force_model_layout(
    self.state,
    graph,
    monitor,
    () => self.initialize(graph),
    count => self.more_iterations(count),
    (forcer, forcee) => Some(self.calc_displacement(forcer, forcee)),
    () => self.iteration_done(),
  )
}

///|
pub fn fr_model_repulsive(distance : Double, k : Double) -> Double {
  if distance > 0.0 {
    k * k / distance
  } else {
    k * k * force_zero_factor
  }
}

///|
pub fn fr_model_attractive(distance : Double, k : Double) -> Double {
  distance * distance / k
}
