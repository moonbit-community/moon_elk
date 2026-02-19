///|
pub(all) struct MultipleOptionsCellEditor {
  items : Array[String]
  decorated_item_values : Bool
  mut value : Array[String]
  mut next_dialog_result : Array[String]?
  mut apply_count : Int
  mut cancel_count : Int
}

///|
pub fn new_multiple_options_cell_editor(
  items : Array[String],
  enumeration_set : Bool,
) -> MultipleOptionsCellEditor {
  {
    items,
    decorated_item_values: enumeration_set,
    value: [],
    next_dialog_result: None,
    apply_count: 0,
    cancel_count: 0,
  }
}

///|
pub fn MultipleOptionsCellEditor::set_value(
  self : MultipleOptionsCellEditor,
  value : Array[String],
) -> Unit {
  self.value = value
}

///|
pub fn MultipleOptionsCellEditor::get_value(
  self : MultipleOptionsCellEditor,
) -> Array[String] {
  self.value
}

///|
pub fn MultipleOptionsCellEditor::set_next_dialog_result_for_test(
  self : MultipleOptionsCellEditor,
  value : Array[String]?,
) -> Unit {
  self.next_dialog_result = value
}

///|
fn multiple_options_fire_apply(editor : MultipleOptionsCellEditor) -> Unit {
  editor.apply_count = editor.apply_count + 1
}

///|
fn multiple_options_fire_cancel(editor : MultipleOptionsCellEditor) -> Unit {
  editor.cancel_count = editor.cancel_count + 1
}

///|
fn multiple_options_strip_decorator(
  editor : MultipleOptionsCellEditor,
  text : String,
) -> String {
  if editor.decorated_item_values {
    for part in text.split(" ") {
      let trimmed = part.trim()
      if !trimmed.is_empty() {
        return trimmed.to_string()
      }
    }
    text
  } else {
    text
  }
}

///|
fn multiple_options_match_selection_to_items(
  editor : MultipleOptionsCellEditor,
  selection : Array[String],
) -> Array[String] {
  if editor.decorated_item_values {
    let selected_items : Array[String] = []
    for selected in selection {
      let mut found = ""
      for candidate in editor.items {
        if candidate.has_prefix(selected) {
          found = candidate
          break
        }
      }
      selected_items.push(found)
    }
    selected_items
  } else {
    selection
  }
}

///|
pub fn MultipleOptionsCellEditor::update_contents(
  self : MultipleOptionsCellEditor,
) -> String {
  if self.value.is_empty() {
    ""
  } else {
    self.value.join(", ")
  }
}

///|
pub fn MultipleOptionsCellEditor::open_dialog_box(
  self : MultipleOptionsCellEditor,
) -> Array[String]? {
  let raw_result = match self.next_dialog_result {
    Some(values) => values
    None => return None
  }
  let matched = multiple_options_match_selection_to_items(self, raw_result)
  let string_result : Array[String] = []
  for value in matched {
    string_result.push(multiple_options_strip_decorator(self, value))
  }
  Some(string_result)
}

///|
pub fn MultipleOptionsCellEditor::on_double_click(
  self : MultipleOptionsCellEditor,
) -> Unit {
  match self.open_dialog_box() {
    Some(new_value) => {
      self.value = new_value
      multiple_options_fire_apply(self)
    }
    None => multiple_options_fire_cancel(self)
  }
  match layout_view_part_find_view() {
    Some(layout_view) => layout_view.set_focus()
    None => ()
  }
}

///|
pub fn MultipleOptionsCellEditor::get_counts_for_test(
  self : MultipleOptionsCellEditor,
) -> (Int, Int) {
  (self.apply_count, self.cancel_count)
}
