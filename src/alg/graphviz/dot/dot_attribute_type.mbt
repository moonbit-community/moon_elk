///|
pub enum DotAttributeType {
  DotAttributeTypeGraph
  DotAttributeTypeNode
  DotAttributeTypeEdge
}

///|
pub fn dot_attribute_type_graph() -> DotAttributeType {
  DotAttributeTypeGraph
}

///|
pub fn dot_attribute_type_node() -> DotAttributeType {
  DotAttributeTypeNode
}

///|
pub fn dot_attribute_type_edge() -> DotAttributeType {
  DotAttributeTypeEdge
}

///|
pub fn dot_attribute_type_value(attribute_type : DotAttributeType) -> Int {
  match attribute_type {
    DotAttributeTypeGraph => 0
    DotAttributeTypeNode => 1
    DotAttributeTypeEdge => 2
  }
}

///|
pub fn dot_attribute_type_name(attribute_type : DotAttributeType) -> String {
  match attribute_type {
    DotAttributeTypeGraph => "graph"
    DotAttributeTypeNode => "node"
    DotAttributeTypeEdge => "edge"
  }
}

///|
pub fn dot_attribute_type_literal(attribute_type : DotAttributeType) -> String {
  dot_attribute_type_name(attribute_type)
}

///|
pub fn dot_attribute_type_from_string(literal : String) -> DotAttributeType? {
  if literal == "graph" {
    Some(DotAttributeTypeGraph)
  } else if literal == "node" {
    Some(DotAttributeTypeNode)
  } else if literal == "edge" {
    Some(DotAttributeTypeEdge)
  } else {
    None
  }
}

///|
pub fn dot_attribute_type_from_name(name : String) -> DotAttributeType? {
  dot_attribute_type_from_string(name)
}

///|
pub fn dot_attribute_type_from_int(value : Int) -> DotAttributeType? {
  if value == 0 {
    Some(DotAttributeTypeGraph)
  } else if value == 1 {
    Some(DotAttributeTypeNode)
  } else if value == 2 {
    Some(DotAttributeTypeEdge)
  } else {
    None
  }
}

///|
pub fn dot_attribute_type_to_string(
  attribute_type : DotAttributeType,
) -> String {
  dot_attribute_type_literal(attribute_type)
}
