///|
pub type ElkReflectNewInstanceFunction = () -> Json

///|
pub type ElkReflectCloneFunction = (Json) -> Json

///|
let elk_reflect_registry_new : Ref[Map[String, ElkReflectNewInstanceFunction]] = Ref({},
)

///|
let elk_reflect_registry_clone : Ref[Map[String, ElkReflectCloneFunction]] = Ref({},
)

///|
pub fn elk_reflect_register(
  clazz : String,
  new_fun? : ElkReflectNewInstanceFunction? = None,
  clone_fun? : ElkReflectCloneFunction? = None,
) -> Unit {
  match new_fun {
    Some(new_instance) => elk_reflect_registry_new.val[clazz] = new_instance
    None => ()
  }
  match clone_fun {
    Some(clone_value) => elk_reflect_registry_clone.val[clazz] = clone_value
    None => ()
  }
}

///|
pub fn elk_reflect_register_new_instance(
  clazz : String,
  new_fun : ElkReflectNewInstanceFunction,
) -> Unit {
  elk_reflect_register(clazz, new_fun=Some(new_fun))
}

///|
pub fn elk_reflect_register_clone(
  clazz : String,
  clone_fun : ElkReflectCloneFunction,
) -> Unit {
  elk_reflect_register(clazz, clone_fun=Some(clone_fun))
}

///|
pub fn elk_reflect_new_instance(clazz : String) -> Json? {
  match elk_reflect_registry_new.val.get(clazz) {
    Some(new_fun) => Some(new_fun())
    None => None
  }
}

///|
pub fn elk_reflect_clone(clazz : String, clonee : Json) -> Json? {
  match elk_reflect_registry_clone.val.get(clazz) {
    Some(clone_fun) => Some(clone_fun(clonee))
    None => None
  }
}

///|
pub fn elk_reflect_reset_for_test() -> Unit {
  elk_reflect_registry_new.val.clear()
  elk_reflect_registry_clone.val.clear()
}
