///|
pub struct EadesModel {
  state : AbstractForceModelState
  mut max_iterations : Int
  mut spring_length : Double
  mut repulsion_factor : Double
}

///|
pub fn new_eades_model() -> EadesModel {
  {
    state: new_abstract_force_model_state(),
    max_iterations: force_iterations.get_default(),
    spring_length: force_spacing_node_node.get_default(),
    repulsion_factor: force_repulsion.get_default(),
  }
}

///|
pub fn EadesModel::initialize(self : EadesModel, graph : FGraph) -> Unit {
  self.max_iterations = graph.get_int_property(force_iterations)
  self.spring_length = graph.get_double_property(force_spacing_node_node)
  self.repulsion_factor = graph.get_double_property(force_repulsion)
}

///|
pub fn EadesModel::more_iterations(self : EadesModel, count : Int) -> Bool {
  count < self.max_iterations
}

///|
pub fn EadesModel::calc_displacement(
  self : EadesModel,
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
  let connection = abstract_force_model_graph(self.state).get_connection(
    forcer, forcee,
  )
  let force = if connection > 0 {
    -eades_model_attractive(distance, self.spring_length) *
    connection.to_double()
  } else {
    eades_model_repulsive(distance, self.repulsion_factor) *
    fparticle_get_int_property(forcer, force_priority).to_double()
  }
  ignore(displacement.scale(force / length))
  displacement
}

///|
pub fn EadesModel::layout(
  self : EadesModel,
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
    () => (),
  )
}

///|
pub fn eades_model_repulsive(distance : Double, repulsion : Double) -> Double {
  if distance > 0.0 {
    repulsion / (distance * distance)
  } else {
    repulsion * force_zero_factor
  }
}

///|
pub fn eades_model_attractive(distance : Double, spring : Double) -> Double {
  if distance > 0.0 {
    @math.ln(distance / spring)
  } else {
    -force_zero_factor
  }
}
