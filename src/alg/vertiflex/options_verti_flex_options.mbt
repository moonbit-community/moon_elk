///|
pub let vertiflex_algorithm_id = "org.eclipse.elk.vertiflex"

///|
pub let vertiflex_option_margins_id = "org.eclipse.elk.margins"

///|
pub let vertiflex_padding : @graph.IProperty[String] = @core.padding

///|
pub let vertiflex_spacing_node_node : @graph.IProperty[Double] = @core.spacing_node_node

///|
pub let vertiflex_omit_node_micro_layout : @graph.IProperty[Bool] = @core.omit_node_micro_layout

///|
pub let vertiflex_vertical_constraint : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.vertiflex.verticalConstraint", 0.0,
)

///|
pub let vertiflex_layout_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.vertiflex.layoutStrategy", "STRAIGHT",
)

///|
pub let vertiflex_layer_distance : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.vertiflex.layerDistance", 50.0,
)

///|
pub let vertiflex_consider_node_model_order : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.vertiflex.considerNodeModelOrder", true,
)
