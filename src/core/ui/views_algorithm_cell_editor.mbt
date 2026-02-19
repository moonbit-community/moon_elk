///|
pub(all) struct AlgorithmCellEditor {
  label_provider : LayoutOptionLabelProvider
  mut value : String
  mut apply_count : Int
  mut cancel_count : Int
  mut next_dialog_result : String?
}

///|
pub fn new_algorithm_cell_editor(
  layout_option_id : String,
) -> AlgorithmCellEditor {
  let algorithm_option = match
    @core.layout_meta_data_service_get_option_data_opt(layout_option_id) {
    Some(option_data) => option_data
    None =>
      @core.new_layout_option_data(
        layout_option_id,
        name="Algorithm",
        option_type=@core.StringType,
      )
  }
  {
    label_provider: new_layout_option_label_provider(algorithm_option),
    value: "",
    apply_count: 0,
    cancel_count: 0,
    next_dialog_result: None,
  }
}

///|
pub fn AlgorithmCellEditor::set_value(
  self : AlgorithmCellEditor,
  value : String,
) -> Unit {
  self.value = value
}

///|
pub fn AlgorithmCellEditor::get_value(self : AlgorithmCellEditor) -> String {
  self.value
}

///|
pub fn AlgorithmCellEditor::set_next_dialog_result_for_test(
  self : AlgorithmCellEditor,
  value : String?,
) -> Unit {
  self.next_dialog_result = value
}

///|
fn algorithm_cell_editor_fire_cancel(editor : AlgorithmCellEditor) -> Unit {
  editor.cancel_count = editor.cancel_count + 1
}

///|
pub fn AlgorithmCellEditor::fire_apply_editor_value(
  self : AlgorithmCellEditor,
) -> Unit {
  self.apply_count = self.apply_count + 1
  algorithm_cell_editor_fire_cancel(self)
}

///|
pub fn AlgorithmCellEditor::update_contents(
  self : AlgorithmCellEditor,
) -> String {
  if self.value.is_empty() {
    ""
  } else {
    self.label_provider.get_text(CoreUiStringValue(self.value))
  }
}

///|
pub fn AlgorithmCellEditor::open_dialog_box(
  self : AlgorithmCellEditor,
) -> String? {
  self.next_dialog_result
}

///|
pub fn AlgorithmCellEditor::on_double_click(self : AlgorithmCellEditor) -> Unit {
  match self.open_dialog_box() {
    Some(new_value) => {
      self.value = new_value
      self.fire_apply_editor_value()
    }
    None => ()
  }
  match layout_view_part_find_view() {
    Some(layout_view) => layout_view.set_focus()
    None => ()
  }
}

///|
pub fn AlgorithmCellEditor::get_counts_for_test(
  self : AlgorithmCellEditor,
) -> (Int, Int) {
  (self.apply_count, self.cancel_count)
}
