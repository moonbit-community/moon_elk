///|
pub struct ExecutionInfoModel {
  executions : Array[ExecutionInfo]
  listeners : Array[IExecutionInfoModelListener]
}

///|
pub fn new_execution_info_model() -> ExecutionInfoModel {
  { executions: [], listeners: [] }
}

///|
fn execution_info_model_notify_listeners(model : ExecutionInfoModel) -> Unit {
  for listener in model.listeners {
    listener.execution_info_changed()
  }
}

///|
pub fn ExecutionInfoModel::get_execution_infos(
  self : ExecutionInfoModel,
) -> Array[ExecutionInfo] {
  self.executions.copy()
}

///|
pub fn ExecutionInfoModel::add_execution(
  self : ExecutionInfoModel,
  info : ExecutionInfo,
) -> Unit {
  self.executions.push(info)
  execution_info_model_notify_listeners(self)
}

///|
pub fn ExecutionInfoModel::replace_execution(
  self : ExecutionInfoModel,
  old_info : ExecutionInfo,
  new_info : ExecutionInfo,
) -> Unit {
  for i = 0; i < self.executions.length(); i = i + 1 {
    if self.executions[i] == old_info {
      self.executions[i] = new_info
      execution_info_model_notify_listeners(self)
      return
    }
  }
}

///|
pub fn ExecutionInfoModel::remove_execution_infos(
  self : ExecutionInfoModel,
  infos : Array[ExecutionInfo],
) -> Unit {
  for info in infos {
    match execution_info_get_parent(info) {
      Some(parent) => execution_info_remove_child(parent, info)
      None => {
        let kept : Array[ExecutionInfo] = []
        for entry in self.executions {
          if entry != info {
            kept.push(entry)
          }
        }
        self.executions.clear()
        for entry in kept {
          self.executions.push(entry)
        }
      }
    }
  }
  execution_info_model_notify_listeners(self)
}

///|
pub fn ExecutionInfoModel::remove_all_execution_infos(
  self : ExecutionInfoModel,
) -> Unit {
  self.executions.clear()
  execution_info_model_notify_listeners(self)
}

///|
pub fn ExecutionInfoModel::add_execution_info_model_listener(
  self : ExecutionInfoModel,
  listener : IExecutionInfoModelListener,
) -> Unit {
  for current in self.listeners {
    if current.get_id() == listener.get_id() {
      return
    }
  }
  self.listeners.push(listener)
}

///|
pub fn ExecutionInfoModel::remove_execution_info_model_listener(
  self : ExecutionInfoModel,
  listener : IExecutionInfoModelListener,
) -> Unit {
  let kept : Array[IExecutionInfoModelListener] = []
  for current in self.listeners {
    if current.get_id() != listener.get_id() {
      kept.push(current)
    }
  }
  self.listeners.clear()
  for current in kept {
    self.listeners.push(current)
  }
}
