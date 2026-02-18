///|
pub type ElkGraphPackage = String

///|
pub let elk_graph_ename : String = "graph"

///|
pub let elk_graph_ens_uri : String = "http://www.eclipse.org/elk/ElkGraph"

///|
pub let elk_graph_ens_prefix : String = "graph"

///|
pub let elk_graph_iproperty_holder_classifier_id : Int = 0

///|
pub let elk_graph_emap_property_holder_classifier_id : Int = 1

///|
pub let elk_graph_elk_graph_element_classifier_id : Int = 2

///|
pub let elk_graph_elk_shape_classifier_id : Int = 3

///|
pub let elk_graph_elk_label_classifier_id : Int = 4

///|
pub let elk_graph_elk_connectable_shape_classifier_id : Int = 5

///|
pub let elk_graph_elk_node_classifier_id : Int = 6

///|
pub let elk_graph_elk_port_classifier_id : Int = 7

///|
pub let elk_graph_elk_edge_classifier_id : Int = 8

///|
pub let elk_graph_elk_bend_point_classifier_id : Int = 9

///|
pub let elk_graph_elk_edge_section_classifier_id : Int = 10

///|
pub let elk_graph_elk_property_to_value_map_entry_classifier_id : Int = 11

///|
pub let elk_graph_iproperty_classifier_id : Int = 12

///|
pub let elk_graph_property_value_classifier_id : Int = 13

///|
pub let elk_graph_package_instance : ElkGraphPackage = elk_graph_ens_uri

///|
pub fn elk_graph_package_id() -> String {
  elk_graph_package_instance
}
