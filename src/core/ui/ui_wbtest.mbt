///|
fn core_ui_test_reset_environment() -> @service.LayoutConnectorsService {
  @service.layout_connectors_service_unload()
  let service = @service.layout_connectors_service_get_instance()
  service.clear_setups_for_test()
  service.clear_listeners_for_test()
  elk_ui_plugin_reset_for_test()
  let ui_plugin = elk_ui_plugin_get_instance()
  ui_plugin.start()
  @service.elk_service_plugin_unload()
  ignore(@service.elk_service_plugin_get_instance())
  core_ui_layout_view_part_reset_for_test()
  core_ui_layout_preference_page_reset_for_test()
  core_ui_elk_ui_util_reset_for_test()
  @core.layout_meta_data_service_reset_for_test()
  @graph.reset_graph_model_for_test()
  service
}

///|
fn core_ui_test_make_setup(
  workbench_id : Int,
  connector : @service.IDiagramLayoutConnector,
) -> @service.ILayoutSetup {
  @service.new_layout_setup(
    obj => {
      match obj {
        @service.WorkbenchPartObject(value) => value == workbench_id
        @service.DiagramPartObject(_) => true
        @service.SelectionObject(_) => false
        @service.OtherObject => false
      }
    },
    default_module => {
      let injector = default_module.copy()
      injector.set_connector(Some(connector))
      injector
    },
  )
}

///|
fn core_ui_test_register_algorithm_and_category() -> (
  @core.LayoutCategoryData,
  @core.LayoutAlgorithmData,
) {
  let category = @core.new_layout_category_data(
    "org.eclipse.elk.category.layered",
    name="Layered Family",
  )
  let algorithm_data = @core.new_layout_algorithm_data(
    "org.eclipse.elk.layered",
    name="Layered",
    description="Layered algorithm",
    category_id=category.get_id(),
    bundle_name="ELK",
    preview_image_path="preview/layered.png",
    defining_bundle_id="bundle.layered",
  )
  category.add_layouter(algorithm_data)
  @core.layout_meta_data_service_register_category(category)
  @core.layout_meta_data_service_register_algorithm(algorithm_data)
  (category, algorithm_data)
}

///|
test "core.ui messages and plugin registry behavior" {
  ignore(core_ui_test_reset_environment())

  debug_inspect(
    core_ui_messages_get_string("elk.ui.58"),
    content=(
      #|"Select Layout Algorithm or Type"
    ),
  )
  debug_inspect(
    core_ui_messages_get_string("elk.ui.missing"),
    content=(
      #|"!elk.ui.missing!"
    ),
  )

  let plugin = elk_ui_plugin_get_instance()
  debug_inspect(plugin.is_started(), content="true")
  let registry = plugin.get_image_registry()
  debug_inspect(registry.size(), content="6")
  debug_inspect(
    match registry.get(elk_ui_img_text) {
      Some(descriptor) => descriptor.to_string()
      None => ""
    },
    content=(
      #|"org.eclipse.elk.core.ui:icons/obj16/prop_text.gif"
    ),
  )
}

///|
test "ActiveEditorSupportedTester delegates to connector service" {
  let service = core_ui_test_reset_environment()
  let connector = @service.new_diagram_layout_connector(
    id="core-ui-test-connector",
  )
  service.register_setup(core_ui_test_make_setup(7, connector), priority=1)

  let tester = new_active_editor_supported_tester()
  debug_inspect(tester.is_supported(Some(7)), content="true")
  debug_inspect(tester.is_supported(Some(8)), content="false")
  debug_inspect(tester.is_supported(None), content="false")
}

///|
test "AlgorithmContentProvider and selection dialog filtering" {
  ignore(core_ui_test_reset_environment())
  let (category, algorithm_data) = core_ui_test_register_algorithm_and_category()
  let other = @core.new_layout_category_data("", name="")
  @core.layout_meta_data_service_register_category(other)

  let provider = new_algorithm_content_provider()
  debug_inspect(provider.get_elements().length(), content="2")
  debug_inspect(
    provider.has_children(CoreUiLayoutCategoryMeta(category)),
    content="true",
  )
  debug_inspect(
    provider.get_parent(CoreUiLayoutAlgorithmMeta(algorithm_data)) is Some(_),
    content="true",
  )

  provider.update_filter(Some("lay"))
  debug_inspect(
    provider.apply_filter(CoreUiLayoutCategoryMeta(category)),
    content="true",
  )
  debug_inspect(
    match provider.get_best_filter_match() {
      Some(data) => core_ui_layout_meta_data_get_id(data)
      None => ""
    },
    content=(
      #|"org.eclipse.elk.category.layered"
    ),
  )

  let selected_count : Ref[Int] = Ref(0)
  let dialog = new_algorithm_selection_dialog(algorithm_data.get_id())
  dialog.add_algorithm_selection_listener(
    new_core_ui_algorithm_selection_listener(_ => {
      selected_count.val = selected_count.val + 1
    }),
  )
  dialog.configure_shell()
  dialog.create_dialog_area()
  debug_inspect(
    dialog.get_shell_text(),
    content=(
      #|"Select Layout Algorithm or Type"
    ),
  )
  debug_inspect(
    dialog.get_selected_hint(),
    content=(
      #|"org.eclipse.elk.layered"
    ),
  )
  debug_inspect(dialog.is_ok_enabled(), content="true")
  debug_inspect(
    match dialog.get_image() {
      Some(image) => image.to_string()
      None => ""
    },
    content=(
      #|"bundle.layered:scaled:preview/layered.png"
    ),
  )

  dialog.update_filter_text("family")
  debug_inspect(
    dialog.get_selected_hint(),
    content=(
      #|"org.eclipse.elk.category.layered"
    ),
  )
  debug_inspect(dialog.is_ok_enabled(), content="false")
  debug_inspect(selected_count.val >= 2, content="true")
  debug_inspect(dialog.close(), content="true")
}

///|
test "LayoutOptionLabelProvider and handler use expected UI semantics" {
  ignore(core_ui_test_reset_environment())
  let (_category, algorithm_data) = core_ui_test_register_algorithm_and_category()

  let algorithm_option = @core.new_layout_option_data(
    @core.algorithm.get_id(),
    name="Algorithm",
    option_type=StringType,
  )
  let algorithm_provider = new_layout_option_label_provider(algorithm_option)
  debug_inspect(
    algorithm_provider.get_text(CoreUiStringValue(algorithm_data.get_id())),
    content=(
      #|"Layered (ELK)"
    ),
  )

  let bool_option = @core.new_layout_option_data(
    "opt.bool",
    option_type=BoolType,
    choices=["false", "true"],
  )
  let bool_provider = new_layout_option_label_provider(bool_option)
  debug_inspect(
    match bool_provider.get_image(CoreUiIntValue(0)) {
      Some(descriptor) => descriptor.path
      None => ""
    },
    content=(
      #|"icons/obj16/prop_false.gif"
    ),
  )

  let enum_like = @core.new_layout_option_data(
    "opt.enum",
    option_type=StringType,
    choices=["A", "B"],
  )
  let enum_provider = new_layout_option_label_provider(enum_like)
  debug_inspect(
    enum_provider.get_text(CoreUiIntValue(1)),
    content=(
      #|"B"
    ),
  )

  let pref_store = elk_ui_plugin_get_instance().get_preference_store()
  pref_store.set_default_boolean(core_ui_pref_animation, true)
  pref_store.set_default_boolean(core_ui_pref_zoom, false)
  pref_store.set_default_boolean(core_ui_pref_progress, true)

  let captured : Ref[String] = Ref("")
  let handler = new_layout_handler(invoke_layout_fn=invocation => {
    let editor = match invocation.editor {
      Some(value) => "Some(\{value})"
      None => "None"
    }
    let diagram_part = match invocation.diagram_part {
      Some(value) => "Some(\{value})"
      None => "None"
    }
    captured.val = "\{editor}|\{diagram_part}|\{invocation.animation}|\{invocation.progress_dialog}|\{invocation.zoom_to_fit}"
  })
  let event_params : Map[String, String] = {}
  event_params[core_ui_param_layout_scope] = core_ui_val_selection
  handler.execute(
    new_core_ui_execution_event(
      parameters=event_params,
      selection=CoreUiLayoutSelectionSingle(99),
      active_editor=Some(7),
    ),
  )
  debug_inspect(
    captured.val,
    content=(
      #|"Some(7)|Some(99)|true|true|false"
    ),
  )
}

///|
test "Preference initializer and page synchronize stores and refresh view" {
  ignore(core_ui_test_reset_environment())
  core_ui_preference_initializer_initialize_default_preferences()

  let pref_store = elk_ui_plugin_get_instance().get_preference_store()
  debug_inspect(
    pref_store.get_default_boolean(core_ui_pref_animation),
    content="true",
  )
  debug_inspect(
    pref_store.get_default_boolean(core_ui_pref_zoom),
    content="false",
  )
  debug_inspect(
    @service.elk_service_plugin_get_instance().get_default_boolean_preference(
      @service.diagram_layout_engine_pref_debug_store,
    ),
    content="false",
  )

  let view = layout_view_part_open()
  let page = new_layout_preference_page()
  page.init()
  page.create_contents()
  debug_inspect(
    page.get_values(),
    content="(true, false, false, false, false, false)",
  )

  page.set_animation(false)
  page.set_zoom(true)
  page.set_progress(true)
  page.set_exec_time(true)
  page.set_enable_logging(true)
  page.set_store_logs(true)
  debug_inspect(page.perform_ok(), content="true")
  debug_inspect(pref_store.get_boolean(core_ui_pref_zoom), content="true")
  debug_inspect(
    @service.elk_service_plugin_get_instance().get_boolean_preference(
      @service.diagram_layout_engine_pref_debug_exec_time, false,
    ),
    content="true",
  )
  debug_inspect(view.get_refresh_count(), content="1")

  page.perform_defaults()
  debug_inspect(
    page.get_values(),
    content="(true, false, false, false, false, false)",
  )

  core_ui_layout_preference_page_set_debug_folder_for_test("/tmp/elk-debug")
  core_ui_layout_preference_page_mark_path_exists_for_test(
    "/tmp/elk-debug", true,
  )
  page.open_log_folder()
  debug_inspect(
    core_ui_layout_preference_page_get_launched_paths_for_test(),
    content="[\"/tmp/elk-debug\"]",
  )
}

///|
test "ElkUiUtil and property source stack perform translations and validation" {
  ignore(core_ui_test_reset_environment())
  let (_category, algorithm_data) = core_ui_test_register_algorithm_and_category()

  let flag_option = @core.new_layout_option_data(
    "opt.flag",
    name="Flag",
    option_type=BoolType,
    targets=[@core.NodesTarget],
  )
  let threshold_option = @core.new_layout_option_data(
    "opt.threshold",
    name="Threshold",
    description="Threshold. Long description.",
    option_type=DoubleType,
    lower_bound=Some(1.0),
    targets=[@core.ParentsTarget],
  )
  threshold_option.add_dependency("opt.flag", expected_value=Some("true"))
  let mode_option = @core.new_layout_option_data(
    "opt.mode",
    name="Mode",
    option_type=StringType,
    choices=["A", "B"],
    targets=[@core.NodesTarget],
    visibility=AdvancedOption,
  )
  mode_option.mark_advanced_choice("B")
  @core.layout_meta_data_service_register_option(
    @core.new_layout_option_data(
      @core.algorithm.get_id(),
      name="Algorithm",
      option_type=StringType,
      targets=[@core.ParentsTarget],
    ),
  )
  @core.layout_meta_data_service_register_option(flag_option)
  @core.layout_meta_data_service_register_option(threshold_option)
  @core.layout_meta_data_service_register_option(mode_option)
  algorithm_data.add_known_option(@core.algorithm.get_id())
  algorithm_data.add_known_option("opt.flag")
  algorithm_data.add_known_option("opt.threshold")
  algorithm_data.add_known_option("opt.mode")

  debug_inspect(
    core_ui_elk_ui_util_get_option_data(algorithm_data, "Threshold") is Some(_),
    content="true",
  )
  debug_inspect(
    core_ui_elk_ui_util_get_option_data_from_providers(
      [algorithm_data],
      "missing",
    )
    is Some(_),
    content="true",
  )

  let options : Map[String, String] = {}
  options[@core.algorithm.get_id()] = algorithm_data.get_id()
  options["opt.flag"] = "true"
  options["opt.threshold"] = "2.5"
  options["opt.mode"] = "B"
  let config = @service.new_simple_layout_configuration_store(
    options~,
    option_targets=[@core.ParentsTarget, @core.NodesTarget],
    editing_domain=Some(42),
  )
  let manager = @service.new_layout_configuration_manager()
  let source = new_layout_property_source(config, manager)
  source.set_validator(@core.new_layout_option_validator())

  let view = layout_view_part_open()
  let descriptors = source.get_property_descriptors()
  debug_inspect(descriptors.length() >= 3, content="true")
  let mut threshold_descriptor : LayoutPropertyDescriptor? = None
  for descriptor in descriptors {
    if descriptor.get_id() == "opt.threshold" {
      threshold_descriptor = Some(descriptor)
    }
  }
  debug_inspect(threshold_descriptor is Some(_), content="true")
  let descriptor = match threshold_descriptor {
    Some(value) => value
    None => abort("missing descriptor")
  }
  debug_inspect(descriptor.get_category(), content="Some(\"Subgraph Options\")")
  debug_inspect(
    descriptor.get_description(),
    content=(
      #|"Threshold."
    ),
  )
  debug_inspect(descriptor.get_filter_flags(), content="None")
  let editor = match descriptor.create_property_editor() {
    Some(value) => value
    None => abort("missing editor")
  }
  debug_inspect(
    editor.validate(CoreUiStringValue("0.1")),
    content="Some(\"The assigned value 0.1 of the option 'Threshold' is less than the lower bound 1.0.\")",
  )

  debug_inspect(
    match source.get_property_value("opt.flag") {
      CoreUiIntValue(value) => value
      _ => -1
    },
    content="1",
  )
  source.set_property_value("opt.flag", CoreUiIntValue(0))
  debug_inspect(config.get_option_value("opt.flag"), content="Some(\"false\")")
  debug_inspect(view.get_refresh_count(), content="1")
  source.reset_property_value("opt.flag")
  debug_inspect(config.get_option_value("opt.flag"), content="None")
  debug_inspect(
    core_ui_elk_ui_util_model_change_labels_for_domain(42),
    content="[\"Set Layout Option\", \"!elk.ui.12!\"]",
  )
  debug_inspect(
    core_ui_layout_property_source_get_layout_hint("Layered (ELK)"),
    content="Some(\"org.eclipse.elk.layered\")",
  )

  let provider = new_layout_property_source_provider(
    configuration_store_provider=Some(
      @service.new_layout_configuration_store_provider((_wb, _obj) => {
        Some(config)
      }),
    ),
    config_manager=manager,
  )
  provider.set_workbench_part(Some(5))
  debug_inspect(
    provider.get_property_source(Some(99)) is Some(_),
    content="true",
  )
  debug_inspect(provider.get_configuration_stores().length(), content="1")
}

///|
test "Validating property sheet entry builds overlay image and error description" {
  ignore(core_ui_test_reset_environment())
  let (_category, algorithm_data) = core_ui_test_register_algorithm_and_category()
  let numeric = @core.new_layout_option_data(
    "opt.numeric",
    name="Numeric",
    option_type=DoubleType,
    lower_bound=Some(1.0),
    targets=[@core.NodesTarget],
  )
  @core.layout_meta_data_service_register_option(
    @core.new_layout_option_data(
      @core.algorithm.get_id(),
      name="Algorithm",
      option_type=StringType,
      targets=[@core.ParentsTarget],
    ),
  )
  @core.layout_meta_data_service_register_option(numeric)
  algorithm_data.add_known_option(@core.algorithm.get_id())
  algorithm_data.add_known_option("opt.numeric")

  let numeric_options : Map[String, String] = {}
  numeric_options[@core.algorithm.get_id()] = algorithm_data.get_id()
  numeric_options["opt.numeric"] = "2.0"
  let config = @service.new_simple_layout_configuration_store(
    options=numeric_options,
    option_targets=[@core.NodesTarget],
  )
  let source = new_layout_property_source(
    config,
    @service.new_layout_configuration_manager(),
  )
  source.set_validator(@core.new_layout_option_validator())
  let descriptor = new_layout_property_descriptor(
    source,
    numeric,
    Some([@core.NodesTarget]),
  )

  let entry = new_validating_property_sheet_entry()
  entry.set_source(Some(source))
  entry.set_descriptor(Some(descriptor))
  entry.set_values([CoreUiStringValue("0.5")])
  entry.set_image(Some(elk_ui_plugin_get_image_descriptor("icons/base.png")))
  entry.set_description("base")

  debug_inspect(
    entry.get_description(),
    content=(
      #|"Error: The assigned value 0.5 of the option 'Numeric' is less than the lower bound 1.0."
    ),
  )
  debug_inspect(
    match entry.get_image() {
      Some(image) => image.path.has_prefix("overlay:")
      None => false
    },
    content="true",
  )
}

///|
test "Layout view handler, cell editors, and rendering stack integrate" {
  ignore(core_ui_test_reset_environment())
  let (_category, algorithm_data) = core_ui_test_register_algorithm_and_category()
  @core.layout_meta_data_service_register_option(
    @core.new_layout_option_data(
      @core.algorithm.get_id(),
      name="Algorithm",
      option_type=StringType,
      targets=[@core.ParentsTarget],
    ),
  )

  let handler = new_show_layout_view_handler()
  handler.execute(new_core_ui_show_layout_view_event())
  debug_inspect(layout_view_part_find_view() is Some(_), content="true")
  handler.execute(new_core_ui_show_layout_view_event(can_open=false))
  debug_inspect(
    handler.get_last_error(),
    content="Some(\"Could not open Layout View.\")",
  )

  let view = layout_view_part_open()
  let algorithm_editor = new_algorithm_cell_editor(@core.algorithm.get_id())
  algorithm_editor.set_next_dialog_result_for_test(
    Some(algorithm_data.get_id()),
  )
  algorithm_editor.on_double_click()
  debug_inspect(algorithm_editor.get_counts_for_test(), content="(1, 1)")
  debug_inspect(view.is_focused(), content="true")

  let multiple_editor = new_multiple_options_cell_editor(
    ["A (advanced)", "B"],
    true,
  )
  multiple_editor.set_next_dialog_result_for_test(Some(["A", "B"]))
  multiple_editor.on_double_click()
  debug_inspect(multiple_editor.get_value(), content="[\"A\", \"B\"]")

  let graph = @graph.create_graph()
  @graph.node_set_dimensions(graph, 10.0, 10.0)
  let child = @graph.create_node(Some(graph))
  @graph.node_set_location(child, -5.0, -3.0)
  @graph.node_set_dimensions(child, 4.0, 6.0)
  let edge = @graph.create_edge(Some(graph))
  @graph.edge_add_source(edge, @graph.make_node_shape(child))
  @graph.edge_add_target(edge, @graph.make_node_shape(child))
  let section = @graph.create_edge_section(edge)
  @graph.edge_section_set_start(section, -1.0, 0.0)
  @graph.edge_section_set_end(section, 9.0, 5.0)

  let display = new_core_ui_display()
  let config1 = new_graph_rendering_configurator(display)
  let renderer = new_graph_renderer(config1)
  renderer.calculate_base_offset_from_top_level_graph(graph)
  debug_inspect(
    renderer.get_base_offset().x >= 0.0 && renderer.get_base_offset().y >= 0.0,
    content="true",
  )
  let graphics = new_core_ui_graphics()
  renderer.render(graph, graphics, new_core_ui_paint_rectangle(0, 0, 200, 200))
  debug_inspect(graphics.operations.length() > 0, content="true")
  debug_inspect(
    renderer.make_arrow_for_test(
      @core.new_kvector_xy(0.0, 0.0),
      @core.new_kvector_xy(3.0, 2.0),
    )
    is Some(_),
    content="true",
  )

  let config2 = new_graph_rendering_configurator(display)
  let canvas = new_graph_rendering_canvas_with_configurator(display, config2)
  canvas.setup_mouse_interaction()
  canvas.set_layout_graph(Some(graph))
  canvas.handle_mouse_wheel(3, 10, 10)
  canvas.mouse_down(0, 0)
  canvas.mouse_move(5, 3)
  canvas.mouse_up(5, 3)
  let paint_graphics = new_core_ui_graphics()
  canvas.paint_control(new_core_ui_paint_event(0, 0, 200, 200, paint_graphics))
  debug_inspect(canvas.get_redraw_count() >= 3, content="true")
  debug_inspect(paint_graphics.operations.length() > 0, content="true")

  let config3 = new_graph_rendering_configurator(display)
  let dialog = new_layout_graph_dialog(graph, Some("demo.elkg"), config3)
  dialog.configure_shell()
  debug_inspect(
    dialog.get_shell_text(),
    content=(
      #|"demo.elkg"
    ),
  )
  ignore(dialog.create_contents(display))
  debug_inspect(dialog.get_graph_canvas() is Some(_), content="true")
}
