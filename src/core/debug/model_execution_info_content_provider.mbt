///|
fn execution_info_content_provider_all_pass(_info : ExecutionInfo) -> Bool {
  true
}

///|
pub(all) struct ExecutionInfoContentProvider {
  mut filter_fn : (ExecutionInfo) -> Bool
  mut filter_is_default : Bool
}

///|
pub fn new_execution_info_content_provider() -> ExecutionInfoContentProvider {
  {
    filter_fn: execution_info_content_provider_all_pass,
    filter_is_default: true,
  }
}

///|
pub fn ExecutionInfoContentProvider::is_filtering(
  self : ExecutionInfoContentProvider,
) -> Bool {
  self.filter_is_default
}

///|
pub fn ExecutionInfoContentProvider::set_filter(
  self : ExecutionInfoContentProvider,
  filter : ((ExecutionInfo) -> Bool)?,
) -> Unit {
  match filter {
    Some(filter_fn) => {
      self.filter_fn = filter_fn
      self.filter_is_default = false
    }
    None => {
      self.filter_fn = execution_info_content_provider_all_pass
      self.filter_is_default = true
    }
  }
}

///|
pub fn ExecutionInfoContentProvider::get_elements(
  self : ExecutionInfoContentProvider,
  input : Array[ExecutionInfo]?,
) -> Array[ExecutionInfo] {
  match input {
    Some(entries) => {
      let filtered : Array[ExecutionInfo] = []
      for entry in entries {
        if (self.filter_fn)(entry) {
          filtered.push(entry)
        }
      }
      filtered
    }
    None => []
  }
}

///|
pub fn ExecutionInfoContentProvider::get_children(
  self : ExecutionInfoContentProvider,
  parent : ExecutionInfo?,
) -> Array[ExecutionInfo] {
  match parent {
    Some(info) => {
      let filtered : Array[ExecutionInfo] = []
      for child in execution_info_get_children(info) {
        if (self.filter_fn)(child) {
          filtered.push(child)
        }
      }
      filtered
    }
    None => []
  }
}

///|
pub fn ExecutionInfoContentProvider::get_parent(
  _self : ExecutionInfoContentProvider,
  element : ExecutionInfo?,
) -> ExecutionInfo? {
  match element {
    Some(info) => execution_info_get_parent(info)
    None => None
  }
}

///|
pub fn ExecutionInfoContentProvider::has_children(
  self : ExecutionInfoContentProvider,
  element : ExecutionInfo?,
) -> Bool {
  match element {
    Some(info) => {
      for child in execution_info_get_children(info) {
        if (self.filter_fn)(child) {
          return true
        }
      }
      false
    }
    None => false
  }
}
