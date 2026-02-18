///|
pub type DotPackage = String

///|
pub let alg_graphviz_dot_dot_ename : String = "dot"

///|
pub let alg_graphviz_dot_dot_ens_uri : String = "http://www.eclipse.org/elk/GraphvizDot"

///|
pub let alg_graphviz_dot_dot_ens_prefix : String = "dot"

///|
pub let alg_graphviz_dot_dot_graphviz_model_classifier_id : Int = 0

///|
pub let alg_graphviz_dot_dot_graphviz_model_graphs_feature_id : Int = 0

///|
pub let alg_graphviz_dot_dot_graphviz_model_feature_count : Int = 1

///|
pub let alg_graphviz_dot_dot_graph_classifier_id : Int = 1

///|
pub let alg_graphviz_dot_dot_graph_strict_feature_id : Int = 0

///|
pub let alg_graphviz_dot_dot_graph_type_feature_id : Int = 1

///|
pub let alg_graphviz_dot_dot_graph_name_feature_id : Int = 2

///|
pub let alg_graphviz_dot_dot_graph_statements_feature_id : Int = 3

///|
pub let alg_graphviz_dot_dot_graph_feature_count : Int = 4

///|
pub let alg_graphviz_dot_dot_statement_classifier_id : Int = 2

///|
pub let alg_graphviz_dot_dot_statement_feature_count : Int = 0

///|
pub let alg_graphviz_dot_dot_attribute_classifier_id : Int = 3

///|
pub let alg_graphviz_dot_dot_attribute_name_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  0

///|
pub let alg_graphviz_dot_dot_attribute_value_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  1

///|
pub let alg_graphviz_dot_dot_attribute_feature_count : Int = alg_graphviz_dot_dot_statement_feature_count +
  2

///|
pub let alg_graphviz_dot_dot_node_statement_classifier_id : Int = 4

///|
pub let alg_graphviz_dot_dot_node_statement_node_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  0

///|
pub let alg_graphviz_dot_dot_node_statement_attributes_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  1

///|
pub let alg_graphviz_dot_dot_node_statement_feature_count : Int = alg_graphviz_dot_dot_statement_feature_count +
  2

///|
pub let alg_graphviz_dot_dot_node_classifier_id : Int = 5

///|
pub let alg_graphviz_dot_dot_node_name_feature_id : Int = 0

///|
pub let alg_graphviz_dot_dot_node_port_feature_id : Int = 1

///|
pub let alg_graphviz_dot_dot_node_feature_count : Int = 2

///|
pub let alg_graphviz_dot_dot_edge_statement_classifier_id : Int = 6

///|
pub let alg_graphviz_dot_dot_edge_statement_source_node_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  0

///|
pub let alg_graphviz_dot_dot_edge_statement_edge_targets_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  1

///|
pub let alg_graphviz_dot_dot_edge_statement_attributes_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  2

///|
pub let alg_graphviz_dot_dot_edge_statement_feature_count : Int = alg_graphviz_dot_dot_statement_feature_count +
  3

///|
pub let alg_graphviz_dot_dot_edge_target_classifier_id : Int = 7

///|
pub let alg_graphviz_dot_dot_edge_target_operator_feature_id : Int = 0

///|
pub let alg_graphviz_dot_dot_edge_target_target_subgraph_feature_id : Int = 1

///|
pub let alg_graphviz_dot_dot_edge_target_targetnode_feature_id : Int = 2

///|
pub let alg_graphviz_dot_dot_edge_target_feature_count : Int = 3

///|
pub let alg_graphviz_dot_dot_attribute_statement_classifier_id : Int = 8

///|
pub let alg_graphviz_dot_dot_attribute_statement_type_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  0

///|
pub let alg_graphviz_dot_dot_attribute_statement_attributes_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  1

///|
pub let alg_graphviz_dot_dot_attribute_statement_feature_count : Int = alg_graphviz_dot_dot_statement_feature_count +
  2

///|
pub let alg_graphviz_dot_dot_subgraph_classifier_id : Int = 9

///|
pub let alg_graphviz_dot_dot_subgraph_name_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  0

///|
pub let alg_graphviz_dot_dot_subgraph_statements_feature_id : Int = alg_graphviz_dot_dot_statement_feature_count +
  1

///|
pub let alg_graphviz_dot_dot_subgraph_feature_count : Int = alg_graphviz_dot_dot_statement_feature_count +
  2

///|
pub let alg_graphviz_dot_dot_port_classifier_id : Int = 10

///|
pub let alg_graphviz_dot_dot_port_name_feature_id : Int = 0

///|
pub let alg_graphviz_dot_dot_port_compass_pt_feature_id : Int = 1

///|
pub let alg_graphviz_dot_dot_port_feature_count : Int = 2

///|
pub let alg_graphviz_dot_dot_edge_operator_classifier_id : Int = 11

///|
pub let alg_graphviz_dot_dot_graph_type_classifier_id : Int = 12

///|
pub let alg_graphviz_dot_dot_attribute_type_classifier_id : Int = 13

///|
pub let dot_package_instance : DotPackage = alg_graphviz_dot_dot_ens_uri

///|
pub fn dot_package_id() -> String {
  dot_package_instance
}
