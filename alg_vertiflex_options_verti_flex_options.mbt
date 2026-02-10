///|
pub let vertiflex_algorithm_id = "org.eclipse.elk.vertiflex"

///|
pub let vertiflex_option_margins_id = "org.eclipse.elk.margins"

///|
pub let vertiflex_padding : IProperty[String] = padding

///|
pub let vertiflex_spacing_node_node : IProperty[Double] = spacing_node_node

///|
pub let vertiflex_omit_node_micro_layout : IProperty[Bool] = omit_node_micro_layout

///|
pub let vertiflex_vertical_constraint : IProperty[Double] = new_property(
  "org.eclipse.elk.vertiflex.verticalConstraint", 0.0,
)

///|
pub let vertiflex_layout_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.vertiflex.layoutStrategy", "STRAIGHT",
)

///|
pub let vertiflex_layer_distance : IProperty[Double] = new_property(
  "org.eclipse.elk.vertiflex.layerDistance", 50.0,
)

///|
pub let vertiflex_consider_node_model_order : IProperty[Bool] = new_property(
  "org.eclipse.elk.vertiflex.considerNodeModelOrder", true,
)
