///|
let force_disp_bound_factor = 16.0

///|
let force_zero_factor = 100.0

///|
pub struct AbstractForceModelState {
  mut random : @core.JavaRandom
  mut graph : FGraph?
  mut disp_bound : Double
}

///|
pub fn new_abstract_force_model_state() -> AbstractForceModelState {
  { random: @core.new_java_random_seeded_int(1), graph: None, disp_bound: 0.0 }
}

///|
pub fn abstract_force_model_graph(state : AbstractForceModelState) -> FGraph {
  match state.graph {
    Some(graph) => graph
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "force model graph is not initialized",
      )
      new_fgraph()
    }
  }
}

///|
pub fn abstract_force_model_random(
  state : AbstractForceModelState,
) -> @core.JavaRandom {
  state.random
}

///|
pub fn abstract_force_model_disp_bound(
  state : AbstractForceModelState,
) -> Double {
  state.disp_bound
}

///|
pub fn abstract_force_model_initialize(
  state : AbstractForceModelState,
  graph : FGraph,
) -> Unit {
  state.graph = Some(graph)
  state.random = match
    graph.get_internal_random_property(force_internal_random) {
    Some(random_generator) => random_generator
    None => @core.new_java_random_seeded_int(1)
  }
  graph.calc_adjacency()
  let node_count = graph.get_nodes().length().to_double()
  let edge_count = graph.get_edges().length().to_double()
  state.disp_bound = force_max(
    node_count * force_disp_bound_factor + edge_count,
    force_disp_bound_factor * force_disp_bound_factor,
  )
  if !graph.get_property(force_interactive) {
    let position_scale = graph.get_nodes().length().to_double()
    for node in graph.get_nodes() {
      let position = fnode_position(node)
      position.x = state.random.double() * position_scale
      position.y = state.random.double() * position_scale
    }
  }
  let bendpoints = graph.get_bendpoints()
  for edge in graph.get_edges() {
    let count = fedge_get_int_property(edge, force_repulsive_power)
    if count > 0 {
      for _ in 0..<count {
        let bendpoint = new_fbendpoint(edge)
        bendpoints.push(bendpoint)
      }
      fedge_distribute_bendpoints(edge)
    }
  }
}

///|
pub fn abstract_force_model_iteration_done(
  state : AbstractForceModelState,
) -> Unit {
  for edge in abstract_force_model_graph(state).get_edges() {
    for label in fedge_labels(edge) {
      flabel_refresh_position(label)
    }
    fedge_distribute_bendpoints(edge)
  }
}

///|
pub fn abstract_force_model_layout(
  state : AbstractForceModelState,
  graph : FGraph,
  monitor : @core.IElkProgressMonitor,
  initialize_hook : () -> Unit,
  more_iterations : (Int) -> Bool,
  calc_displacement : (FParticle, FParticle) -> @core.KVector?,
  iteration_done_hook : () -> Unit,
) -> Unit {
  ignore(monitor.begin("Component Layout", 1.0))
  abstract_force_model_initialize(state, graph)
  initialize_hook()
  let mut iteration_count = 0
  while more_iterations(iteration_count) && !monitor.is_canceled() {
    abstract_force_model_iteration_done(state)
    iteration_done_hook()
    let particles = graph.get_particles()
    for forcee in particles {
      for forcer in particles {
        if force_particle_equals(forcer, forcee) {
          continue
        }
        match calc_displacement(forcer, forcee) {
          Some(displacement) =>
            ignore(fparticle_displacement(forcee).add(displacement))
          None => ()
        }
      }
    }
    for particle in particles {
      let displacement = fparticle_displacement(particle)
      ignore(
        displacement.bound(
          -state.disp_bound,
          -state.disp_bound,
          state.disp_bound,
          state.disp_bound,
        ),
      )
      ignore(fparticle_position(particle).add(displacement))
      ignore(displacement.reset())
    }
    iteration_count += 1
  }
  monitor.done()
}

///|
fn force_particle_equals(left : FParticle, right : FParticle) -> Bool {
  match (left, right) {
    (Node(left_node), Node(right_node)) => left_node == right_node
    (Label(left_label), Label(right_label)) => left_label == right_label
    (Bendpoint(left_bendpoint), Bendpoint(right_bendpoint)) =>
      left_bendpoint == right_bendpoint
    _ => false
  }
}

///|
pub fn abstract_force_model_avoid_same_position(
  random_generator : @core.JavaRandom,
  forcee : FParticle,
  forcer : FParticle,
) -> Unit {
  let forcee_position = fparticle_position(forcee)
  let forcer_position = fparticle_position(forcer)
  while forcee_position.x - forcer_position.x == 0.0 &&
        forcee_position.y - forcer_position.y == 0.0 {
    let mut tried_for_bendpoints = false
    match (forcee, forcer) {
      (Bendpoint(forcee_bendpoint), Bendpoint(forcer_bendpoint)) =>
        if !tried_for_bendpoints {
          let forcee_edge = fbendpoint_edge(forcee_bendpoint)
          let forcee_vector = @core.new_kvector_copy(
            fedge_target_point(forcee_edge),
          ).sub(fedge_source_point(forcee_edge))
          let forcee_length = forcee_vector.length()
          if forcee_length > 0.0 {
            let orthogonal_forcee = @core.new_kvector_xy(
              forcee_vector.x / forcee_length * 2.0,
              -(forcee_vector.y / forcee_length) * 2.0,
            )
            ignore(forcee_position.add(orthogonal_forcee))
          }
          let forcer_edge = fbendpoint_edge(forcer_bendpoint)
          let forcer_vector = @core.new_kvector_copy(
            fedge_target_point(forcer_edge),
          ).sub(fedge_source_point(forcer_edge))
          let forcer_length = forcer_vector.length()
          if forcer_length > 0.0 {
            let axis_factor = if forcee_vector.equals(forcer_vector) {
              -2.0
            } else {
              2.0
            }
            let orthogonal_forcer = @core.new_kvector_xy(
              forcer_vector.x / forcer_length * axis_factor,
              -(forcer_vector.y / forcer_length) * axis_factor,
            )
            ignore(forcee_position.add(orthogonal_forcer))
          }
          tried_for_bendpoints = true
        }
      _ => ()
    }
    if !tried_for_bendpoints {
      forcee_position.x = forcee_position.x + random_generator.double() - 0.5
      forcee_position.y = forcee_position.y + random_generator.double() - 0.5
      forcer_position.x = forcer_position.x + random_generator.double() - 0.5
      forcer_position.y = forcer_position.y + random_generator.double() - 0.5
    }
  }
}
