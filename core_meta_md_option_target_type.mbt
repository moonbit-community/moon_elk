///|
pub enum CoreMetaMdOptionTargetType {
  CoreMetaMdOptionTargetTypeParents
  CoreMetaMdOptionTargetTypeNodes
  CoreMetaMdOptionTargetTypeEdges
  CoreMetaMdOptionTargetTypePorts
  CoreMetaMdOptionTargetTypeLabels
}

///|
pub fn core_meta_md_option_target_type_parents() -> CoreMetaMdOptionTargetType {
  CoreMetaMdOptionTargetTypeParents
}

///|
pub fn core_meta_md_option_target_type_nodes() -> CoreMetaMdOptionTargetType {
  CoreMetaMdOptionTargetTypeNodes
}

///|
pub fn core_meta_md_option_target_type_edges() -> CoreMetaMdOptionTargetType {
  CoreMetaMdOptionTargetTypeEdges
}

///|
pub fn core_meta_md_option_target_type_ports() -> CoreMetaMdOptionTargetType {
  CoreMetaMdOptionTargetTypePorts
}

///|
pub fn core_meta_md_option_target_type_labels() -> CoreMetaMdOptionTargetType {
  CoreMetaMdOptionTargetTypeLabels
}

///|
pub fn core_meta_md_option_target_type_value(
  target_type : CoreMetaMdOptionTargetType,
) -> Int {
  match target_type {
    CoreMetaMdOptionTargetTypeParents => 0
    CoreMetaMdOptionTargetTypeNodes => 1
    CoreMetaMdOptionTargetTypeEdges => 2
    CoreMetaMdOptionTargetTypePorts => 3
    CoreMetaMdOptionTargetTypeLabels => 4
  }
}

///|
pub fn core_meta_md_option_target_type_name(
  target_type : CoreMetaMdOptionTargetType,
) -> String {
  match target_type {
    CoreMetaMdOptionTargetTypeParents => "parents"
    CoreMetaMdOptionTargetTypeNodes => "nodes"
    CoreMetaMdOptionTargetTypeEdges => "edges"
    CoreMetaMdOptionTargetTypePorts => "ports"
    CoreMetaMdOptionTargetTypeLabels => "labels"
  }
}

///|
pub fn core_meta_md_option_target_type_literal(
  target_type : CoreMetaMdOptionTargetType,
) -> String {
  core_meta_md_option_target_type_name(target_type)
}

///|
pub fn core_meta_md_option_target_type_from_string(
  literal : String,
) -> CoreMetaMdOptionTargetType? {
  if literal == "parents" {
    Some(CoreMetaMdOptionTargetTypeParents)
  } else if literal == "nodes" {
    Some(CoreMetaMdOptionTargetTypeNodes)
  } else if literal == "edges" {
    Some(CoreMetaMdOptionTargetTypeEdges)
  } else if literal == "ports" {
    Some(CoreMetaMdOptionTargetTypePorts)
  } else if literal == "labels" {
    Some(CoreMetaMdOptionTargetTypeLabels)
  } else {
    None
  }
}

///|
pub fn core_meta_md_option_target_type_from_name(
  name : String,
) -> CoreMetaMdOptionTargetType? {
  core_meta_md_option_target_type_from_string(name)
}

///|
pub fn core_meta_md_option_target_type_from_int(
  value : Int,
) -> CoreMetaMdOptionTargetType? {
  if value == 0 {
    Some(CoreMetaMdOptionTargetTypeParents)
  } else if value == 1 {
    Some(CoreMetaMdOptionTargetTypeNodes)
  } else if value == 2 {
    Some(CoreMetaMdOptionTargetTypeEdges)
  } else if value == 3 {
    Some(CoreMetaMdOptionTargetTypePorts)
  } else if value == 4 {
    Some(CoreMetaMdOptionTargetTypeLabels)
  } else {
    None
  }
}

///|
pub fn core_meta_md_option_target_type_to_string(
  target_type : CoreMetaMdOptionTargetType,
) -> String {
  core_meta_md_option_target_type_literal(target_type)
}
