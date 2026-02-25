///|
fn case_input_graph_text() -> String {
  "graph G {\n\tportConstraints: FREE\n\tnode N1 {\n\t\tlayout [ size: 40, 30 ]\n\t\tportConstraints: FIXED_ORDER\n\t\tport P1 {\n\t\t\tlayout [ size: 8, 8 ]\n\t\t\tindex: 0\n\t\t\tside: EAST\n\t\t}\n\t}\n\tnode N2 {\n\t\tlayout [ size: 40, 30 ]\n\t\tportConstraints: FIXED_ORDER\n\t\tport P2 {\n\t\t\tlayout [ size: 8, 8 ]\n\t\t\tindex: 0\n\t\t\tside: WEST\n\t\t}\n\t}\n\tedge E1: N1.P1 -> N2.P2\n}\n"
}
