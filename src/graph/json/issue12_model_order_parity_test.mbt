///|
fn graph_json_issue12_animated_input_json() -> String {
  "{\"id\":\"\",\"layoutOptions\":{\"elk.algorithm\":\"layered\",\"elk.direction\":\"DOWN\",\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50},\"children\":[{\"id\":\"winter\",\"x\":0,\"y\":0,\"width\":136,\"height\":81,\"labels\":[{\"text\":\"winter\",\"x\":0,\"y\":0,\"width\":91,\"height\":36}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.crossingMinimization.forceNodeModelOrder\":true,\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.nodeSize.minimum\":\"(81, 136)\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"elk.padding\":\"[top=50,left=50,bottom=50,right=50]\"},\"children\":[{\"id\":\"winter.snow\",\"x\":0,\"y\":0,\"width\":88,\"height\":66,\"labels\":[{\"text\":\"snow\",\"x\":0,\"y\":0,\"width\":43,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"summer\",\"x\":0,\"y\":0,\"width\":152,\"height\":81,\"labels\":[{\"text\":\"summer\",\"x\":0,\"y\":0,\"width\":107,\"height\":36}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.crossingMinimization.forceNodeModelOrder\":true,\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.nodeSize.minimum\":\"(81, 152)\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"elk.padding\":\"[top=50,left=50,bottom=50,right=50]\"},\"children\":[{\"id\":\"summer.sun\",\"x\":0,\"y\":0,\"width\":75,\"height\":66,\"labels\":[{\"text\":\"sun\",\"x\":0,\"y\":0,\"width\":30,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"trees\",\"x\":0,\"y\":0,\"width\":85,\"height\":66,\"labels\":[{\"text\":\"trees\",\"x\":0,\"y\":0,\"width\":40,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}],\"edges\":[{\"id\":\"(winter.snow -> summer.sun)[0]\",\"sources\":[\"winter.snow\"],\"targets\":[\"summer.sun\"],\"container\":\"\"},{\"id\":\"(summer.sun -> trees)[0]\",\"sources\":[\"summer.sun\"],\"targets\":[\"trees\"],\"container\":\"\"},{\"id\":\"(trees -> winter.snow)[0]\",\"sources\":[\"trees\"],\"targets\":[\"winter.snow\"],\"container\":\"\"}]}"
}

///|
fn graph_json_issue12_c4_input_json() -> String {
  "{\"id\":\"\",\"layoutOptions\":{\"elk.algorithm\":\"layered\",\"elk.direction\":\"DOWN\",\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50},\"children\":[{\"id\":\"atm_system\",\"x\":0,\"y\":0,\"width\":537,\"height\":164,\"labels\":[{\"text\":\"## ATM Banking System\\n[Software System]\\n\\nAllows customers to perform financial transactions via physical terminals.\",\"x\":0,\"y\":0,\"width\":492,\"height\":119}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"notification_system\",\"x\":0,\"y\":0,\"width\":484,\"height\":164,\"labels\":[{\"text\":\"## Notification System\\n[Container: Java]\\n\\nSends alerts and notifications to customers via multiple channels.\",\"x\":0,\"y\":0,\"width\":439,\"height\":119}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"chatbot\",\"x\":0,\"y\":0,\"width\":375,\"height\":356,\"labels\":[{\"text\":\"## Customer Chatbot\\n[Container: Node.js & NLP]\\n\\nAI-powered chat interface for customer support.\",\"x\":0,\"y\":0,\"width\":322,\"height\":119}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"kyc_system\",\"x\":0,\"y\":0,\"width\":388,\"height\":369,\"labels\":[{\"text\":\"## KYC Verification\\n[Software System]\\n\\nKnow Your Customer identity verification process.\",\"x\":0,\"y\":0,\"width\":334,\"height\":119}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"investment_platform\",\"x\":0,\"y\":0,\"width\":490,\"height\":164,\"labels\":[{\"text\":\"## Investment Platform\\n[Software System]\\n\\nProvides trading and investment capabilities to customers.\",\"x\":0,\"y\":0,\"width\":393,\"height\":119}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"bill_payment\",\"x\":0,\"y\":0,\"width\":428,\"height\":164,\"labels\":[{\"text\":\"## Bill Payment Service\\n[Container: Node.js]\\n\\nAllows customers to schedule and pay bills electronically.\",\"x\":0,\"y\":0,\"width\":383,\"height\":119}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"mobile_banking_api\",\"x\":0,\"y\":0,\"width\":478,\"height\":164,\"labels\":[{\"text\":\"## Mobile Banking API\\n[Container: GraphQL & Node.js]\\n\\nAPI gateway specifically optimized for mobile client applications.\",\"x\":0,\"y\":0,\"width\":433,\"height\":119}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}],\"edges\":[{\"id\":\"(atm_system -> mobile_banking_api)[0]\",\"sources\":[\"atm_system\"],\"targets\":[\"mobile_banking_api\"],\"container\":\"\",\"labels\":[{\"text\":\"Integration\",\"x\":0,\"y\":0,\"width\":74,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(notification_system -> chatbot)[0]\",\"sources\":[\"notification_system\"],\"targets\":[\"chatbot\"],\"container\":\"\",\"labels\":[{\"text\":\"Sends alerts via\",\"x\":0,\"y\":0,\"width\":103,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(kyc_system -> investment_platform)[0]\",\"sources\":[\"kyc_system\"],\"targets\":[\"investment_platform\"],\"container\":\"\",\"labels\":[{\"text\":\"Verifies identity\",\"x\":0,\"y\":0,\"width\":101,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(mobile_banking_api -> bill_payment)[0]\",\"sources\":[\"mobile_banking_api\"],\"targets\":[\"bill_payment\"],\"container\":\"\",\"labels\":[{\"text\":\"Provides access\",\"x\":0,\"y\":0,\"width\":104,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(chatbot -> investment_platform)[0]\",\"sources\":[\"chatbot\"],\"targets\":[\"investment_platform\"],\"container\":\"\",\"labels\":[{\"text\":\"Answers questions\",\"x\":0,\"y\":0,\"width\":122,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(atm_system -> bill_payment)[0]\",\"sources\":[\"atm_system\"],\"targets\":[\"bill_payment\"],\"container\":\"\",\"labels\":[{\"text\":\"Allows payments\",\"x\":0,\"y\":0,\"width\":112,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(kyc_system -> mobile_banking_api)[0]\",\"sources\":[\"kyc_system\"],\"targets\":[\"mobile_banking_api\"],\"container\":\"\",\"labels\":[{\"text\":\"Authenticates\",\"x\":0,\"y\":0,\"width\":92,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(notification_system -> investment_platform)[0]\",\"sources\":[\"notification_system\"],\"targets\":[\"investment_platform\"],\"container\":\"\",\"labels\":[{\"text\":\"Sends alerts\",\"x\":0,\"y\":0,\"width\":81,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]}]}"
}

///|
fn graph_json_issue12_classes_input_json() -> String {
  "{\"id\":\"\",\"layoutOptions\":{\"elk.algorithm\":\"layered\",\"elk.direction\":\"DOWN\",\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50},\"children\":[{\"id\":\"DebitCard\",\"x\":0,\"y\":0,\"width\":246,\"height\":230,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"Bank\",\"x\":0,\"y\":0,\"width\":278,\"height\":276,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"ATMInfo\",\"x\":0,\"y\":0,\"width\":314,\"height\":276,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"Customer\",\"x\":0,\"y\":0,\"width\":218,\"height\":276,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"Account\",\"x\":0,\"y\":0,\"width\":206,\"height\":184,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"ATMTransaction\",\"x\":0,\"y\":0,\"width\":320,\"height\":276,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"CurrentAccount\",\"x\":0,\"y\":0,\"width\":320,\"height\":276,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"SavingAccount\",\"x\":0,\"y\":0,\"width\":306,\"height\":276,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"WidthdrawlTransaction\",\"x\":0,\"y\":0,\"width\":407,\"height\":184,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"QueryTransaction\",\"x\":0,\"y\":0,\"width\":350,\"height\":230,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"TransferTransaction\",\"x\":0,\"y\":0,\"width\":391,\"height\":184,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"PinValidation\",\"x\":0,\"y\":0,\"width\":477,\"height\":230,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}],\"edges\":[{\"id\":\"(DebitCard -- Bank)[0]\",\"sources\":[\"DebitCard\"],\"targets\":[\"Bank\"],\"container\":\"\",\"labels\":[{\"text\":\"manages\",\"x\":0,\"y\":0,\"width\":62,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(Bank -- ATMInfo)[0]\",\"sources\":[\"Bank\"],\"targets\":[\"ATMInfo\"],\"container\":\"\",\"labels\":[{\"text\":\"maintains\",\"x\":0,\"y\":0,\"width\":67,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(Bank -- Customer)[0]\",\"sources\":[\"Bank\"],\"targets\":[\"Customer\"],\"container\":\"\",\"labels\":[{\"text\":\"+has\",\"x\":0,\"y\":0,\"width\":32,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(DebitCard -- Customer)[0]\",\"sources\":[\"DebitCard\"],\"targets\":[\"Customer\"],\"container\":\"\",\"labels\":[{\"text\":\"+owns\",\"x\":0,\"y\":0,\"width\":43,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(DebitCard -- Account)[0]\",\"sources\":[\"DebitCard\"],\"targets\":[\"Account\"],\"container\":\"\",\"labels\":[{\"text\":\"+provides access to\",\"x\":0,\"y\":0,\"width\":127,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(Customer -- Account)[0]\",\"sources\":[\"Customer\"],\"targets\":[\"Account\"],\"container\":\"\",\"labels\":[{\"text\":\"owns\",\"x\":0,\"y\":0,\"width\":35,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(ATMInfo -- ATMTransaction)[0]\",\"sources\":[\"ATMInfo\"],\"targets\":[\"ATMTransaction\"],\"container\":\"\",\"labels\":[{\"text\":\"+identifies\",\"x\":0,\"y\":0,\"width\":69,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(ATMTransaction -> Account)[0]\",\"sources\":[\"ATMTransaction\"],\"targets\":[\"Account\"],\"container\":\"\",\"labels\":[{\"text\":\"modifies\",\"x\":0,\"y\":0,\"width\":57,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(CurrentAccount -> Account)[0]\",\"sources\":[\"CurrentAccount\"],\"targets\":[\"Account\"],\"container\":\"\"},{\"id\":\"(SavingAccount -> Account)[0]\",\"sources\":[\"SavingAccount\"],\"targets\":[\"Account\"],\"container\":\"\"},{\"id\":\"(WidthdrawlTransaction -> ATMTransaction)[0]\",\"sources\":[\"WidthdrawlTransaction\"],\"targets\":[\"ATMTransaction\"],\"container\":\"\"},{\"id\":\"(QueryTransaction -> ATMTransaction)[0]\",\"sources\":[\"QueryTransaction\"],\"targets\":[\"ATMTransaction\"],\"container\":\"\"},{\"id\":\"(TransferTransaction -> ATMTransaction)[0]\",\"sources\":[\"TransferTransaction\"],\"targets\":[\"ATMTransaction\"],\"container\":\"\"},{\"id\":\"(PinValidation -> ATMTransaction)[0]\",\"sources\":[\"PinValidation\"],\"targets\":[\"ATMTransaction\"],\"container\":\"\"}]}"
}

///|
fn graph_json_issue12_layout(input : String) -> @graph.ElkNode {
  @graph.reset_graph_model_for_test()
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_algorithms()

  let root = elk_graph_json_for_graph(input).to_elk()
  @core.new_recursive_graph_layout_engine().layout(
    root,
    @core.new_null_elk_progress_monitor(),
  )
  root
}

///|
fn graph_json_issue12_find_node(
  node : @graph.ElkNode,
  node_id : String,
) -> @graph.ElkNode? {
  if @graph.node_identifier(node) == node_id {
    return Some(node)
  }
  for child in @graph.node_children(node) {
    if graph_json_issue12_find_node(child, node_id) is Some(found) {
      return Some(found)
    }
  }
  None
}

///|
fn graph_json_issue12_required_node(
  root : @graph.ElkNode,
  node_id : String,
) -> @graph.ElkNode {
  match graph_json_issue12_find_node(root, node_id) {
    Some(node) => node
    None => abort("missing node: " + node_id)
  }
}

///|
fn graph_json_issue12_assert_close(
  context : String,
  actual : Double,
  expected : Double,
) -> Unit {
  if (actual - expected).abs() > 0.0001 {
    abort(
      context +
      ": expected=" +
      expected.to_string() +
      ", actual=" +
      actual.to_string(),
    )
  }
}

///|
test "issue12 diago model-order layouts match elkjs 0.8.2" {
  let animated = graph_json_issue12_layout(
    graph_json_issue12_animated_input_json(),
  )
  graph_json_issue12_assert_close(
    "animated.width",
    @graph.node_width(animated),
    252.0,
  )
  let winter = graph_json_issue12_required_node(animated, "winter")
  graph_json_issue12_assert_close("winter.x", @graph.node_x(winter), 52.0)

  let c4 = graph_json_issue12_layout(graph_json_issue12_c4_input_json())
  graph_json_issue12_assert_close(
    "c4.width",
    @graph.node_width(c4),
    1470.4166666666665,
  )
  let atm_system = graph_json_issue12_required_node(c4, "atm_system")
  graph_json_issue12_assert_close(
    "atm_system.x",
    @graph.node_x(atm_system),
    12.0,
  )

  let classes = graph_json_issue12_layout(
    graph_json_issue12_classes_input_json(),
  )
  graph_json_issue12_assert_close(
    "classes.width",
    @graph.node_width(classes),
    2290.5,
  )
  let debit_card = graph_json_issue12_required_node(classes, "DebitCard")
  graph_json_issue12_assert_close(
    "DebitCard.x",
    @graph.node_x(debit_card),
    740.25,
  )
  let widthdrawl = graph_json_issue12_required_node(
    classes, "WidthdrawlTransaction",
  )
  let transfer = graph_json_issue12_required_node(
    classes, "TransferTransaction",
  )
  if @graph.node_x(widthdrawl) >= @graph.node_x(transfer) {
    abort("WidthdrawlTransaction must remain left of TransferTransaction")
  }
}
