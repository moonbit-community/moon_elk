///|
pub fn core_debug_grandom_configuration_parser_parse(
  config : CoreDebugGRandomConfiguration,
  random : @random.Rand,
) -> CoreDebugGRandomGeneratorOptions {
  let options = new_core_debug_grandom_generator_options()
  core_debug_grandom_configuration_parser_set_graph_type(config, options)
  core_debug_grandom_configuration_parser_nodes(config.nodes, random, options)
  core_debug_grandom_configuration_parser_edges(config, options)
  core_debug_grandom_configuration_parser_hierarchy(config, options)

  options.set_quantities(config.fraction, core_debug_grandom_partition_frac)
  ignore(
    core_debug_grandom_configuration_parser_set_if_exists_int(
      options,
      config.max_width,
      core_debug_grandom_max_width,
    ),
  )
  ignore(
    core_debug_grandom_configuration_parser_set_if_exists_int(
      options,
      config.max_degree,
      core_debug_grandom_max_degree,
    ),
  )
  options
}

///|
fn core_debug_grandom_configuration_parser_hierarchy(
  configuration : CoreDebugGRandomConfiguration,
  options : CoreDebugGRandomGeneratorOptions,
) -> Unit {
  match configuration.hierarchy {
    Some(hierarchy) => {
      let hierarch = hierarchy.num_hierarch_nodes
      options.set_optional_rand_property(
        core_debug_grandom_exact_relative_hier,
        core_debug_grandom_configuration_parser_to_optional_rand_val(
          hierarchy.cross_hierarch_rel,
        ),
      )
      options.set_bool_property(
        core_debug_grandom_small_hierarchy,
        core_debug_grandom_double_quantity_exists(hierarch),
      )
      options.set_quantities(
        hierarchy.levels,
        core_debug_grandom_max_hierarchy_level,
      )
      options.set_quantities(
        hierarch, core_debug_grandom_number_hierarchical_nodes,
      )
      options.set_quantities(hierarchy.edges, core_debug_grandom_cross_hier)
    }
    None => ()
  }
}

///|
fn core_debug_grandom_configuration_parser_edges(
  config : CoreDebugGRandomConfiguration,
  options : CoreDebugGRandomGeneratorOptions,
) -> Unit {
  match config.edges {
    Some(edges) => {
      if edges.total {
        options.set_edge_determination_property(
          core_debug_grandom_edge_determination,
          EdgeAbsolute,
        )
        options.set_quantities(edges.n_edges, core_debug_grandom_edges_absolute)
      } else if edges.density {
        options.set_quantities(edges.n_edges, core_debug_grandom_density)
        options.set_edge_determination_property(
          core_debug_grandom_edge_determination,
          EdgeDensity,
        )
      } else if edges.relative {
        options.set_edge_determination_property(
          core_debug_grandom_edge_determination,
          EdgeRelative,
        )
        options.set_quantities(edges.n_edges, core_debug_grandom_relative_edges)
      } else {
        options.set_edge_determination_property(
          core_debug_grandom_edge_determination,
          EdgeOutgoing,
        )
        options.set_quantities(edges.n_edges, core_debug_grandom_outgoing_edges)
      }
      options.set_bool_property(core_debug_grandom_edge_labels, edges.labels)
      options.set_bool_property(core_debug_grandom_self_loops, edges.self_loops)
    }
    None => ()
  }
}

///|
fn core_debug_grandom_configuration_parser_nodes(
  nodes : CoreDebugGRandomNodes?,
  random : @random.Rand,
  options : CoreDebugGRandomGeneratorOptions,
) -> Unit {
  ignore(random)
  match nodes {
    Some(node_settings) => {
      options.set_quantities(
        node_settings.n_nodes,
        core_debug_grandom_number_of_nodes,
      )
      options.set_bool_property(
        core_debug_grandom_create_node_labels,
        node_settings.labels,
      )
      core_debug_grandom_configuration_parser_ports(node_settings, options)
      core_debug_grandom_configuration_parser_size(node_settings, options)
      options.set_bool_property(
        core_debug_grandom_isolated_nodes,
        !node_settings.remove_isolated,
      )
    }
    None => ()
  }
}

///|
fn core_debug_grandom_configuration_parser_size(
  nodes : CoreDebugGRandomNodes,
  options : CoreDebugGRandomGeneratorOptions,
) -> Unit {
  match nodes.size {
    Some(size) => {
      options.set_quantities(size.width, core_debug_grandom_node_width)
      options.set_quantities(size.height, core_debug_grandom_node_height)
    }
    None => ()
  }
}

///|
fn core_debug_grandom_configuration_parser_ports(
  nodes : CoreDebugGRandomNodes,
  options : CoreDebugGRandomGeneratorOptions,
) -> Unit {
  match nodes.ports {
    Some(ports) => {
      options.set_bool_property(core_debug_grandom_enable_ports, true)
      options.set_bool_property(
        core_debug_grandom_create_port_labels,
        ports.labels,
      )
      options.set_port_constraints_property(
        core_debug_grandom_port_constraints,
        core_debug_grandom_configuration_parser_get_constraint(
          ports.constraint.unwrap_or(ConstraintFree),
        ),
      )
      options.set_quantities(
        ports.re_use,
        core_debug_grandom_use_existing_ports_chance,
      )
      for flow in ports.flow {
        core_debug_grandom_configuration_parser_set_flow_side(
          options,
          flow.flow_type,
          flow.side,
          flow.amount,
        )
      }
      options.set_bool_property(core_debug_grandom_set_port_size, true)
      match ports.size {
        Some(size) => {
          options.set_quantities(size.height, core_debug_grandom_port_height)
          options.set_quantities(size.width, core_debug_grandom_port_width)
        }
        None => ()
      }
    }
    None => ()
  }
}

///|
fn core_debug_grandom_configuration_parser_to_optional_rand_val(
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> CoreDebugGRandomRandVal? {
  if core_debug_grandom_double_quantity_exists(quantity) {
    Some(
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
      },
    )
  } else {
    None
  }
}

///|
fn core_debug_grandom_configuration_parser_set_flow_side(
  options : CoreDebugGRandomGeneratorOptions,
  flow_type : CoreDebugGRandomFlowType,
  side : CoreDebugGRandomSide,
  quantity : CoreDebugGRandomDoubleQuantity?,
) -> Unit {
  let amount = match
    core_debug_grandom_configuration_parser_to_optional_rand_val(quantity) {
    Some(rand_val) => rand_val.int_val(@random.Rand::new())
    None => 0
  }
  match flow_type {
    FlowIncoming =>
      match side {
        SideEast =>
          options.set_int_property(
            core_debug_grandom_incoming_east_side, amount,
          )
        SideNorth =>
          options.set_int_property(
            core_debug_grandom_incoming_north_side, amount,
          )
        SideSouth =>
          options.set_int_property(
            core_debug_grandom_incoming_south_side, amount,
          )
        SideWest =>
          options.set_int_property(
            core_debug_grandom_incoming_west_side, amount,
          )
      }
    FlowOutgoing =>
      match side {
        SideEast =>
          options.set_int_property(
            core_debug_grandom_outgoing_east_side, amount,
          )
        SideNorth =>
          options.set_int_property(
            core_debug_grandom_outgoing_north_side, amount,
          )
        SideSouth =>
          options.set_int_property(
            core_debug_grandom_outgoing_south_side, amount,
          )
        SideWest =>
          options.set_int_property(
            core_debug_grandom_outgoing_west_side, amount,
          )
      }
  }
}

///|
fn core_debug_grandom_configuration_parser_get_constraint(
  constraint : CoreDebugGRandomConstraintType,
) -> PortConstraints {
  match constraint {
    ConstraintFree => Free
    ConstraintOrder => FixedOrder
    ConstraintPosition => FixedPos
    ConstraintSide => FixedSide
    ConstraintRatio => FixedRatio
  }
}

///|
fn core_debug_grandom_configuration_parser_set_graph_type(
  configuration : CoreDebugGRandomConfiguration,
  options : CoreDebugGRandomGeneratorOptions,
) -> Unit {
  match configuration.form {
    FormAcyclic =>
      options.set_graph_type_property(
        core_debug_grandom_graph_type,
        GraphAcyclicNoTransitiveEdges,
      )
    FormBiconnected =>
      options.set_graph_type_property(
        core_debug_grandom_graph_type,
        GraphBiconnected,
      )
    FormBipartite =>
      options.set_graph_type_property(
        core_debug_grandom_graph_type,
        GraphBipartite,
      )
    FormCustom =>
      options.set_graph_type_property(
        core_debug_grandom_graph_type,
        GraphCustom,
      )
    FormTrees =>
      options.set_graph_type_property(core_debug_grandom_graph_type, GraphTree)
    FormTriconnected =>
      options.set_graph_type_property(
        core_debug_grandom_graph_type,
        GraphTriconnected,
      )
  }
}

///|
fn core_debug_grandom_configuration_parser_set_if_exists_int(
  options : CoreDebugGRandomGeneratorOptions,
  value : Int?,
  property : IProperty[Int],
) -> Bool {
  match value {
    Some(number) => {
      options.set_int_property(property, number)
      true
    }
    None => false
  }
}
