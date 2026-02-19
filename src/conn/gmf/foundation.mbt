///|
pub(all) enum GmfFigureKind {
  Generic
  WrappingLabel
  Label
  ResizableCompartmentFigure
  BorderedNodeFigure
  BorderItemContainer
  ConnectionFigure
} derive(Eq, Show)

///|
pub(all) enum GmfEditPartKind {
  GenericEditPart
  RootEditPart
  DiagramRootEditPart
  DiagramEditPart
  ShapeNodeEditPart
  AbstractBorderItemEditPart
  AbstractImageEditPart
  CompartmentEditPart
  ResizableCompartmentEditPart
  ConnectionEditPart
  LabelEditPart
  NoteEditPart
} derive(Eq, Show)

///|
pub(all) enum GmfOperation {
  LayoutNodeOperation
  CreateEditPoliciesOperation
  Other(String)
} derive(Eq, Show)

///|
pub struct GmfPoint {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub struct GmfDimension {
  width : Int
  height : Int
} derive(Eq, Show)

///|
pub struct GmfInsets {
  top : Int
  right : Int
  bottom : Int
  left : Int
} derive(Eq, Show)

///|
pub struct GmfRectangle {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Eq, Show)

///|
pub struct GmfPointList {
  points : Array[GmfPoint]
} derive(Show)

///|
pub fn new_gmf_point(x : Int, y : Int) -> GmfPoint {
  { x, y }
}

///|
pub fn new_gmf_dimension(width : Int, height : Int) -> GmfDimension {
  { width, height }
}

///|
pub fn new_gmf_insets(
  top? : Int = 0,
  right? : Int = 0,
  bottom? : Int = 0,
  left? : Int = 0,
) -> GmfInsets {
  { top, right, bottom, left }
}

///|
pub fn new_gmf_rectangle(
  x? : Int = 0,
  y? : Int = 0,
  width? : Int = 0,
  height? : Int = 0,
) -> GmfRectangle {
  { x, y, width, height }
}

///|
pub fn new_gmf_point_list(points? : Array[GmfPoint] = []) -> GmfPointList {
  { points, }
}

///|
pub fn GmfPointList::size(self : GmfPointList) -> Int {
  self.points.length()
}

///|
pub fn GmfPointList::add_point(self : GmfPointList, point : GmfPoint) -> Unit {
  self.points.push(point)
}

///|
pub fn GmfPointList::get_point(self : GmfPointList, index : Int) -> GmfPoint {
  self.points[index]
}

///|
pub fn GmfPointList::get_first_point(self : GmfPointList) -> GmfPoint {
  self.points[0]
}

///|
pub fn GmfPointList::get_last_point(self : GmfPointList) -> GmfPoint {
  self.points[self.points.length() - 1]
}

///|
pub fn GmfPointList::remove_point(self : GmfPointList, index : Int) -> Unit {
  ignore(self.points.remove(index))
}

///|
pub fn GmfPointList::reverse(self : GmfPointList) -> Unit {
  let mut left = 0
  let mut right = self.points.length() - 1
  while left < right {
    let tmp = self.points[left]
    self.points[left] = self.points[right]
    self.points[right] = tmp
    left = left + 1
    right = right - 1
  }
}

///|
pub fn GmfPointList::copy(self : GmfPointList) -> GmfPointList {
  let copied : Array[GmfPoint] = []
  for point in self.points {
    copied.push({ x: point.x, y: point.y })
  }
  { points: copied }
}

///|
pub type GmfFigure = Int

///|
pub type GmfView = Int

///|
pub type GmfEditPart = Int

///|
pub type GmfElkGraphElement = Int

///|
priv struct GmfFigureData {
  kind : GmfFigureKind
  mut parent : GmfFigure?
  children : Array[GmfFigure]
  mut visible : Bool
  mut bounds : GmfRectangle
  mut insets : GmfInsets
  mut is_coordinate_system : Bool
  mut expanded : Bool
  mut text : String
  mut icon_width : Int
  mut icon_height : Int
  mut icon_text_gap : Int
  mut minimum_size : GmfDimension
  mut preferred_size : GmfDimension
  mut font_name : String?
  mut font_size : Int
  mut font_disposed : Bool
  mut border_item_container : GmfFigure?
  mut points : GmfPointList
}

///|
priv struct GmfViewData {
  mut location_x : Int
  mut location_y : Int
  mut width : Int
  mut height : Int
  styles : Map[String, String]
  mut bendpoints : GmfPointList
  mut source_terminal : String?
  mut target_terminal : String?
  mut routing_manual : Bool
  mut smoothness_none : Bool
  name : String
}

///|
priv struct GmfEditPartData {
  kind : GmfEditPartKind
  mut parent : GmfEditPart?
  children : Array[GmfEditPart]
  figure : GmfFigure
  mut notation_node : String
  mut notation_view : GmfView?
  mut top_graphic_edit_part : GmfEditPart?
  mut source : GmfEditPart?
  mut target : GmfEditPart?
  target_connections : Array[GmfEditPart]
  installed_policies : Map[String, String]
  mut key_point : Int
}

///|
let gmf_figure_store_ref : Ref[Array[GmfFigureData]] = Ref::new([])

///|
let gmf_view_store_ref : Ref[Array[GmfViewData]] = Ref::new([])

///|
let gmf_edit_part_store_ref : Ref[Array[GmfEditPartData]] = Ref::new([])

///|
pub struct GmfLayoutElementShape {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Show)

///|
pub struct GmfLayoutElementEdge {
  bends : GmfPointList
  source_terminal : String?
  target_terminal : String?
  junction_points : String?
} derive(Show)

///|
let gmf_layout_element_shape_store_ref : Ref[Map[Int, GmfLayoutElementShape]] = Ref::new({},
)

///|
let gmf_layout_element_edge_store_ref : Ref[Map[Int, GmfLayoutElementEdge]] = Ref::new({},
)

///|
pub struct GmfCommandStack {
  executed_labels : Array[String]
}

///|
pub fn new_gmf_command_stack() -> GmfCommandStack {
  { executed_labels: [] }
}

///|
pub fn GmfCommandStack::execute(
  self : GmfCommandStack,
  command : GmfLayoutCommand,
) -> Unit {
  command.execute()
  self.executed_labels.push(command.get_label())
}

///|
pub fn GmfCommandStack::execution_count(self : GmfCommandStack) -> Int {
  self.executed_labels.length()
}

///|
pub fn GmfCommandStack::last_executed_label(self : GmfCommandStack) -> String? {
  if self.executed_labels.is_empty() {
    None
  } else {
    Some(self.executed_labels[self.executed_labels.length() - 1])
  }
}

///|
pub fn reset_conn_gmf_foundation_for_test() -> Unit {
  gmf_figure_store_ref.val = []
  gmf_view_store_ref.val = []
  gmf_edit_part_store_ref.val = []
  gmf_layout_element_shape_store_ref.val.clear()
  gmf_layout_element_edge_store_ref.val.clear()
  gmf_preference_store_ref.val.clear()
  gmf_last_layout_invocation_ref.val = None
}

///|
fn gmf_checked_figure(figure : GmfFigure) -> Unit {
  if figure < 0 || figure >= gmf_figure_store_ref.val.length() {
    abort("invalid gmf figure")
  }
}

///|
fn gmf_checked_view(view : GmfView) -> Unit {
  if view < 0 || view >= gmf_view_store_ref.val.length() {
    abort("invalid gmf view")
  }
}

///|
fn gmf_checked_edit_part(edit_part : GmfEditPart) -> Unit {
  if edit_part < 0 || edit_part >= gmf_edit_part_store_ref.val.length() {
    abort("invalid gmf edit part")
  }
}

///|
pub fn new_gmf_figure(
  kind? : GmfFigureKind = Generic,
  bounds? : GmfRectangle = new_gmf_rectangle(),
) -> GmfFigure {
  let figure_id = gmf_figure_store_ref.val.length()
  gmf_figure_store_ref.val.push({
    kind,
    parent: None,
    children: [],
    visible: true,
    bounds,
    insets: new_gmf_insets(),
    is_coordinate_system: false,
    expanded: true,
    text: "",
    icon_width: 0,
    icon_height: 0,
    icon_text_gap: 0,
    minimum_size: new_gmf_dimension(0, 0),
    preferred_size: new_gmf_dimension(bounds.width, bounds.height),
    font_name: None,
    font_size: 0,
    font_disposed: false,
    border_item_container: None,
    points: new_gmf_point_list(),
  })
  figure_id
}

///|
pub fn gmf_figure_kind(figure : GmfFigure) -> GmfFigureKind {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].kind
}

///|
pub fn gmf_figure_set_parent(figure : GmfFigure, parent : GmfFigure?) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].parent = parent
  match parent {
    Some(parent_figure) => {
      gmf_checked_figure(parent_figure)
      gmf_figure_store_ref.val[parent_figure].children.push(figure)
    }
    None => ()
  }
}

///|
pub fn gmf_figure_parent(figure : GmfFigure) -> GmfFigure? {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].parent
}

///|
pub fn gmf_figure_children(figure : GmfFigure) -> Array[GmfFigure] {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].children
}

///|
pub fn gmf_figure_set_visible(figure : GmfFigure, visible : Bool) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].visible = visible
}

///|
pub fn gmf_figure_is_visible(figure : GmfFigure) -> Bool {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].visible
}

///|
pub fn gmf_figure_set_bounds(figure : GmfFigure, bounds : GmfRectangle) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].bounds = bounds
}

///|
pub fn gmf_figure_bounds(figure : GmfFigure) -> GmfRectangle {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].bounds
}

///|
pub fn gmf_figure_absolute_bounds(figure : GmfFigure) -> GmfRectangle {
  gmf_checked_figure(figure)
  let figure_data = gmf_figure_store_ref.val[figure]
  let mut abs_x = figure_data.bounds.x
  let mut abs_y = figure_data.bounds.y
  let mut current = figure_data.parent
  while current is Some(_) {
    match current {
      Some(parent_figure) => {
        let parent_data = gmf_figure_store_ref.val[parent_figure]
        abs_x = abs_x + parent_data.bounds.x
        abs_y = abs_y + parent_data.bounds.y
        current = parent_data.parent
      }
      None => ()
    }
  }
  {
    x: abs_x,
    y: abs_y,
    width: figure_data.bounds.width,
    height: figure_data.bounds.height,
  }
}

///|
pub fn gmf_figure_set_insets(figure : GmfFigure, insets : GmfInsets) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].insets = insets
}

///|
pub fn gmf_figure_insets(figure : GmfFigure) -> GmfInsets {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].insets
}

///|
pub fn gmf_figure_set_coordinate_system(
  figure : GmfFigure,
  is_coordinate_system : Bool,
) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].is_coordinate_system = is_coordinate_system
}

///|
pub fn gmf_figure_is_coordinate_system(figure : GmfFigure) -> Bool {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].is_coordinate_system
}

///|
pub fn gmf_figure_set_expanded(figure : GmfFigure, expanded : Bool) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].expanded = expanded
}

///|
pub fn gmf_figure_is_expanded(figure : GmfFigure) -> Bool {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].expanded
}

///|
pub fn gmf_figure_set_text(figure : GmfFigure, text : String) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].text = text
}

///|
pub fn gmf_figure_text(figure : GmfFigure) -> String {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].text
}

///|
pub fn gmf_figure_set_icon(
  figure : GmfFigure,
  width : Int,
  height : Int,
  text_gap? : Int = 0,
) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].icon_width = width
  gmf_figure_store_ref.val[figure].icon_height = height
  gmf_figure_store_ref.val[figure].icon_text_gap = text_gap
}

///|
pub fn gmf_figure_icon_width(figure : GmfFigure) -> Int {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].icon_width
}

///|
pub fn gmf_figure_icon_height(figure : GmfFigure) -> Int {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].icon_height
}

///|
pub fn gmf_figure_icon_text_gap(figure : GmfFigure) -> Int {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].icon_text_gap
}

///|
pub fn gmf_figure_set_minimum_size(
  figure : GmfFigure,
  size : GmfDimension,
) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].minimum_size = size
}

///|
pub fn gmf_figure_minimum_size(figure : GmfFigure) -> GmfDimension {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].minimum_size
}

///|
pub fn gmf_figure_set_preferred_size(
  figure : GmfFigure,
  size : GmfDimension,
) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].preferred_size = size
}

///|
pub fn gmf_figure_preferred_size(figure : GmfFigure) -> GmfDimension {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].preferred_size
}

///|
pub fn gmf_figure_set_font(
  figure : GmfFigure,
  font_name : String,
  font_size : Int,
) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].font_name = Some(font_name)
  gmf_figure_store_ref.val[figure].font_size = font_size
  gmf_figure_store_ref.val[figure].font_disposed = false
}

///|
pub fn gmf_figure_font_name(figure : GmfFigure) -> String? {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].font_name
}

///|
pub fn gmf_figure_font_size(figure : GmfFigure) -> Int {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].font_size
}

///|
pub fn gmf_figure_set_font_disposed(
  figure : GmfFigure,
  disposed : Bool,
) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].font_disposed = disposed
}

///|
pub fn gmf_figure_font_is_disposed(figure : GmfFigure) -> Bool {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].font_disposed
}

///|
pub fn gmf_figure_set_border_item_container(
  figure : GmfFigure,
  container : GmfFigure?,
) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].border_item_container = container
}

///|
pub fn gmf_figure_border_item_container(figure : GmfFigure) -> GmfFigure? {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].border_item_container
}

///|
pub fn gmf_figure_set_points(figure : GmfFigure, points : GmfPointList) -> Unit {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].points = points
}

///|
pub fn gmf_figure_points(figure : GmfFigure) -> GmfPointList {
  gmf_checked_figure(figure)
  gmf_figure_store_ref.val[figure].points
}

///|
pub fn new_gmf_view(
  name? : String = "",
  location_x? : Int = 0,
  location_y? : Int = 0,
  width? : Int = 0,
  height? : Int = 0,
) -> GmfView {
  let view_id = gmf_view_store_ref.val.length()
  gmf_view_store_ref.val.push({
    location_x,
    location_y,
    width,
    height,
    styles: {},
    bendpoints: new_gmf_point_list(),
    source_terminal: None,
    target_terminal: None,
    routing_manual: false,
    smoothness_none: false,
    name,
  })
  view_id
}

///|
pub fn gmf_view_location_x(view : GmfView) -> Int {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].location_x
}

///|
pub fn gmf_view_location_y(view : GmfView) -> Int {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].location_y
}

///|
pub fn gmf_view_width(view : GmfView) -> Int {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].width
}

///|
pub fn gmf_view_height(view : GmfView) -> Int {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].height
}

///|
pub fn gmf_view_set_location(view : GmfView, x : Int, y : Int) -> Unit {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].location_x = x
  gmf_view_store_ref.val[view].location_y = y
}

///|
pub fn gmf_view_set_size(view : GmfView, width : Int, height : Int) -> Unit {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].width = width
  gmf_view_store_ref.val[view].height = height
}

///|
pub fn gmf_view_set_style(view : GmfView, key : String, value : String) -> Unit {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].styles[key] = value
}

///|
pub fn gmf_view_get_style(view : GmfView, key : String) -> String? {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].styles.get(key)
}

///|
pub fn gmf_view_remove_style(view : GmfView, key : String) -> Unit {
  gmf_checked_view(view)
  ignore(gmf_view_store_ref.val[view].styles.remove(key))
}

///|
pub fn gmf_view_style_entries(view : GmfView) -> Array[(String, String)] {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].styles.to_array()
}

///|
pub fn gmf_view_set_bendpoints(
  view : GmfView,
  bendpoints : GmfPointList,
) -> Unit {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].bendpoints = bendpoints
}

///|
pub fn gmf_view_bendpoints(view : GmfView) -> GmfPointList {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].bendpoints
}

///|
pub fn gmf_view_set_source_terminal(view : GmfView, terminal : String?) -> Unit {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].source_terminal = terminal
}

///|
pub fn gmf_view_source_terminal(view : GmfView) -> String? {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].source_terminal
}

///|
pub fn gmf_view_set_target_terminal(view : GmfView, terminal : String?) -> Unit {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].target_terminal = terminal
}

///|
pub fn gmf_view_target_terminal(view : GmfView) -> String? {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].target_terminal
}

///|
pub fn gmf_view_set_routing_manual(view : GmfView, manual : Bool) -> Unit {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].routing_manual = manual
}

///|
pub fn gmf_view_is_routing_manual(view : GmfView) -> Bool {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].routing_manual
}

///|
pub fn gmf_view_set_smoothness_none(view : GmfView, none : Bool) -> Unit {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].smoothness_none = none
}

///|
pub fn gmf_view_is_smoothness_none(view : GmfView) -> Bool {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].smoothness_none
}

///|
pub fn gmf_view_name(view : GmfView) -> String {
  gmf_checked_view(view)
  gmf_view_store_ref.val[view].name
}

///|
pub fn new_gmf_edit_part(
  kind : GmfEditPartKind,
  figure? : GmfFigure = new_gmf_figure(),
  notation_node? : String = "",
) -> GmfEditPart {
  let edit_part_id = gmf_edit_part_store_ref.val.length()
  gmf_edit_part_store_ref.val.push({
    kind,
    parent: None,
    children: [],
    figure,
    notation_node,
    notation_view: None,
    top_graphic_edit_part: None,
    source: None,
    target: None,
    target_connections: [],
    installed_policies: {},
    key_point: 0,
  })
  edit_part_id
}

///|
pub fn gmf_edit_part_kind(edit_part : GmfEditPart) -> GmfEditPartKind {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].kind
}

///|
pub fn gmf_edit_part_set_parent(
  edit_part : GmfEditPart,
  parent : GmfEditPart?,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].parent = parent
  match parent {
    Some(parent_edit_part) => {
      gmf_checked_edit_part(parent_edit_part)
      gmf_edit_part_store_ref.val[parent_edit_part].children.push(edit_part)
    }
    None => ()
  }
}

///|
pub fn gmf_edit_part_parent(edit_part : GmfEditPart) -> GmfEditPart? {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].parent
}

///|
pub fn gmf_edit_part_children(edit_part : GmfEditPart) -> Array[GmfEditPart] {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].children
}

///|
pub fn gmf_edit_part_figure(edit_part : GmfEditPart) -> GmfFigure {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].figure
}

///|
pub fn gmf_edit_part_set_notation_node(
  edit_part : GmfEditPart,
  notation_node : String,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].notation_node = notation_node
}

///|
pub fn gmf_edit_part_notation_node(edit_part : GmfEditPart) -> String {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].notation_node
}

///|
pub fn gmf_edit_part_set_notation_view(
  edit_part : GmfEditPart,
  view : GmfView?,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].notation_view = view
}

///|
pub fn gmf_edit_part_notation_view(edit_part : GmfEditPart) -> GmfView? {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].notation_view
}

///|
pub fn gmf_edit_part_set_top_graphic_edit_part(
  edit_part : GmfEditPart,
  top_graphic_edit_part : GmfEditPart?,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].top_graphic_edit_part = top_graphic_edit_part
}

///|
pub fn gmf_edit_part_top_graphic_edit_part(
  edit_part : GmfEditPart,
) -> GmfEditPart? {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].top_graphic_edit_part
}

///|
pub fn gmf_edit_part_set_source(
  edit_part : GmfEditPart,
  source : GmfEditPart?,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].source = source
}

///|
pub fn gmf_edit_part_source(edit_part : GmfEditPart) -> GmfEditPart? {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].source
}

///|
pub fn gmf_edit_part_set_target(
  edit_part : GmfEditPart,
  target : GmfEditPart?,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].target = target
}

///|
pub fn gmf_edit_part_target(edit_part : GmfEditPart) -> GmfEditPart? {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].target
}

///|
pub fn gmf_edit_part_add_target_connection(
  edit_part : GmfEditPart,
  connection : GmfEditPart,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].target_connections.push(connection)
}

///|
pub fn gmf_edit_part_target_connections(
  edit_part : GmfEditPart,
) -> Array[GmfEditPart] {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].target_connections
}

///|
pub fn gmf_edit_part_install_edit_policy(
  edit_part : GmfEditPart,
  role : String,
  policy_name : String,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].installed_policies[role] = policy_name
}

///|
pub fn gmf_edit_part_get_installed_edit_policy(
  edit_part : GmfEditPart,
  role : String,
) -> String? {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].installed_policies.get(role)
}

///|
pub fn gmf_edit_part_set_key_point(
  edit_part : GmfEditPart,
  key_point : Int,
) -> Unit {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].key_point = key_point
}

///|
pub fn gmf_edit_part_key_point(edit_part : GmfEditPart) -> Int {
  gmf_checked_edit_part(edit_part)
  gmf_edit_part_store_ref.val[edit_part].key_point
}

///|
pub fn gmf_find_edit_part_by_notation_node(
  parent : GmfEditPart,
  notation_node : String,
) -> GmfEditPart? {
  gmf_checked_edit_part(parent)
  let queue : Array[GmfEditPart] = [parent]
  while !queue.is_empty() {
    let edit_part = queue[0]
    ignore(queue.remove(0))
    if gmf_edit_part_notation_node(edit_part) == notation_node {
      return Some(edit_part)
    }
    for child in gmf_edit_part_children(edit_part) {
      queue.push(child)
    }
  }
  None
}

///|
pub struct GmfLayoutNode {
  node : String
}

///|
pub fn new_gmf_layout_node(node : String) -> GmfLayoutNode {
  { node, }
}

///|
pub fn GmfLayoutNode::get_node(self : GmfLayoutNode) -> String {
  self.node
}

///|
pub struct GmfLayoutHint {
  graphical_edit_part : GmfEditPart?
}

///|
pub fn new_gmf_layout_hint(
  graphical_edit_part? : GmfEditPart? = None,
) -> GmfLayoutHint {
  { graphical_edit_part, }
}

///|
pub fn GmfLayoutHint::get_graphical_edit_part(
  self : GmfLayoutHint,
) -> GmfEditPart? {
  self.graphical_edit_part
}

///|
pub enum GmfDiagramPart {
  NoPart
  Single(GmfEditPart)
  Multiple(Array[GmfEditPart])
} derive(Show)

///|
pub struct GmfLayoutInvocation {
  diagram_part : GmfDiagramPart
  progress_dialog : Bool
  zoom_to_fit : Bool
} derive(Show)

///|
let gmf_last_layout_invocation_ref : Ref[GmfLayoutInvocation?] = Ref::new(None)

///|
pub fn gmf_diagram_layout_engine_invoke_layout(
  diagram_part : GmfDiagramPart,
  progress_dialog : Bool,
  zoom_to_fit : Bool,
) -> Unit {
  gmf_last_layout_invocation_ref.val = Some({
    diagram_part,
    progress_dialog,
    zoom_to_fit,
  })
}

///|
pub fn gmf_last_layout_invocation() -> GmfLayoutInvocation? {
  gmf_last_layout_invocation_ref.val
}

///|
pub fn gmf_last_layout_invocation_zoom_to_fit() -> Bool? {
  match gmf_last_layout_invocation_ref.val {
    Some(invocation) => Some(invocation.zoom_to_fit)
    None => None
  }
}

///|
pub fn gmf_last_layout_invocation_progress_dialog() -> Bool? {
  match gmf_last_layout_invocation_ref.val {
    Some(invocation) => Some(invocation.progress_dialog)
    None => None
  }
}

///|
pub fn gmf_last_layout_invocation_single_part() -> GmfEditPart? {
  match gmf_last_layout_invocation_ref.val {
    Some(invocation) =>
      match invocation.diagram_part {
        Single(edit_part) => Some(edit_part)
        _ => None
      }
    None => None
  }
}

///|
pub fn gmf_last_layout_invocation_multiple_parts() -> Array[GmfEditPart]? {
  match gmf_last_layout_invocation_ref.val {
    Some(invocation) =>
      match invocation.diagram_part {
        Multiple(parts) => Some(parts)
        _ => None
      }
    None => None
  }
}

///|
let gmf_preference_store_ref : Ref[Map[String, Bool]] = Ref::new({})

///|
fn gmf_preference_key(qualifier : String, key : String) -> String {
  qualifier + "#" + key
}

///|
pub fn gmf_set_boolean_preference(
  qualifier : String,
  key : String,
  value : Bool,
) -> Unit {
  gmf_preference_store_ref.val[gmf_preference_key(qualifier, key)] = value
}

///|
pub fn gmf_get_boolean_preference(
  qualifier : String,
  key : String,
  default_value : Bool,
) -> Bool {
  match gmf_preference_store_ref.val.get(gmf_preference_key(qualifier, key)) {
    Some(value) => value
    None => default_value
  }
}

///|
pub fn gmf_set_layout_element_shape(
  element : GmfElkGraphElement,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit {
  gmf_layout_element_shape_store_ref.val[element] = { x, y, width, height }
}

///|
pub fn gmf_get_layout_element_shape(
  element : GmfElkGraphElement,
) -> GmfLayoutElementShape? {
  gmf_layout_element_shape_store_ref.val.get(element)
}

///|
pub fn gmf_set_layout_element_edge(
  element : GmfElkGraphElement,
  bends : GmfPointList,
  source_terminal : String?,
  target_terminal : String?,
  junction_points : String?,
) -> Unit {
  gmf_layout_element_edge_store_ref.val[element] = {
    bends,
    source_terminal,
    target_terminal,
    junction_points,
  }
}

///|
pub fn gmf_get_layout_element_edge(
  element : GmfElkGraphElement,
) -> GmfLayoutElementEdge? {
  gmf_layout_element_edge_store_ref.val.get(element)
}
