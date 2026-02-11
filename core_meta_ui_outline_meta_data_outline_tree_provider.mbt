///|
pub struct CoreMetaOutlineNode {
  kind : String
  label : String
  children : Array[CoreMetaOutlineNode]
}

///|
pub fn new_core_meta_outline_node(
  kind : String,
  label : String,
  children? : Array[CoreMetaOutlineNode] = [],
) -> CoreMetaOutlineNode {
  { kind, label, children }
}

///|
fn core_meta_outline_label_or_empty(value : String?) -> String {
  match value {
    Some(text) => text
    None => ""
  }
}

///|
fn core_meta_outline_group_or_option_node(
  value : CoreMetaMdGroupOrOption,
) -> CoreMetaOutlineNode {
  match value {
    CoreMetaMdGroupOrOptionGroup(group) => {
      let children : Array[CoreMetaOutlineNode] = []
      for child in group.get_children() {
        children.push(core_meta_outline_group_or_option_node(child))
      }
      new_core_meta_outline_node(
        "group",
        core_meta_outline_label_or_empty(group.get_name()),
        children~,
      )
    }
    CoreMetaMdGroupOrOptionOption(option) =>
      new_core_meta_outline_node(
        "option",
        core_meta_outline_label_or_empty(option.get_name()),
      )
  }
}

///|
fn core_meta_outline_bundle_member_node(
  value : CoreMetaMdBundleMember,
) -> CoreMetaOutlineNode? {
  match value {
    CoreMetaMdBundleMemberCategory(category) =>
      Some(
        new_core_meta_outline_node(
          "category",
          core_meta_outline_label_or_empty(category.get_name()),
        ),
      )
    CoreMetaMdBundleMemberAlgorithm(algorithm) =>
      Some(
        new_core_meta_outline_node(
          "algorithm",
          core_meta_outline_label_or_empty(algorithm.get_name()),
        ),
      )
    CoreMetaMdBundleMemberGroupOrOption(group_or_option) =>
      Some(core_meta_outline_group_or_option_node(group_or_option))
  }
}

///|
pub struct MetaDataOutlineTreeProvider {
  unit : Unit
}

///|
pub fn new_meta_data_outline_tree_provider() -> MetaDataOutlineTreeProvider {
  { unit: () }
}

///|
pub fn MetaDataOutlineTreeProvider::create_outline(
  self : MetaDataOutlineTreeProvider,
  model : CoreMetaMdModel,
) -> CoreMetaOutlineNode {
  ignore(self)
  let root = new_core_meta_outline_node("document", "root")
  match model.get_bundle() {
    Some(bundle) => {
      let bundle_node = new_core_meta_outline_node("bundle", "bundle")
      for member in bundle.get_members() {
        match core_meta_outline_bundle_member_node(member) {
          Some(child) => bundle_node.children.push(child)
          None => ()
        }
      }
      root.children.push(bundle_node)
    }
    None => ()
  }
  root
}

///|
pub fn MetaDataOutlineTreeProvider::is_leaf_category(
  self : MetaDataOutlineTreeProvider,
  _category : CoreMetaMdCategory,
) -> Bool {
  ignore(self)
  true
}

///|
pub fn MetaDataOutlineTreeProvider::is_leaf_algorithm(
  self : MetaDataOutlineTreeProvider,
  _algorithm : CoreMetaMdAlgorithm,
) -> Bool {
  ignore(self)
  true
}

///|
pub fn MetaDataOutlineTreeProvider::is_leaf_option(
  self : MetaDataOutlineTreeProvider,
  _option : CoreMetaMdOption,
) -> Bool {
  ignore(self)
  true
}
