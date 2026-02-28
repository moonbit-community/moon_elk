///|
pub(all) enum CoreMetaMdBundleMember {
  CoreMetaMdBundleMemberGroupOrOption(CoreMetaMdGroupOrOption)
  CoreMetaMdBundleMemberAlgorithm(CoreMetaMdAlgorithm)
  CoreMetaMdBundleMemberCategory(CoreMetaMdCategory)
}

///|
pub fn core_meta_md_bundle_member_group_or_option(
  value : CoreMetaMdGroupOrOption,
) -> CoreMetaMdBundleMember {
  CoreMetaMdBundleMemberGroupOrOption(value)
}

///|
pub fn core_meta_md_bundle_member_algorithm(
  value : CoreMetaMdAlgorithm,
) -> CoreMetaMdBundleMember {
  CoreMetaMdBundleMemberAlgorithm(value)
}

///|
pub fn core_meta_md_bundle_member_category(
  value : CoreMetaMdCategory,
) -> CoreMetaMdBundleMember {
  CoreMetaMdBundleMemberCategory(value)
}

///|
pub fn core_meta_md_bundle_member_tag(value : CoreMetaMdBundleMember) -> String {
  match value {
    CoreMetaMdBundleMemberGroupOrOption(_) => "group_or_option"
    CoreMetaMdBundleMemberAlgorithm(_) => "algorithm"
    CoreMetaMdBundleMemberCategory(_) => "category"
  }
}

///|
pub fn core_meta_md_bundle_member_name(
  value : CoreMetaMdBundleMember,
) -> String? {
  match value {
    CoreMetaMdBundleMemberGroupOrOption(group_or_option) =>
      match group_or_option {
        CoreMetaMdGroupOrOptionGroup(group) => group.get_name()
        CoreMetaMdGroupOrOptionOption(option) => option.get_name()
      }
    CoreMetaMdBundleMemberAlgorithm(algorithm) => algorithm.get_name()
    CoreMetaMdBundleMemberCategory(category) => category.get_name()
  }
}

///|
pub fn core_meta_md_bundle_member_as_group_or_option(
  value : CoreMetaMdBundleMember,
) -> CoreMetaMdGroupOrOption? {
  match value {
    CoreMetaMdBundleMemberGroupOrOption(group_or_option) =>
      Some(group_or_option)
    _ => None
  }
}

///|
pub fn core_meta_md_bundle_member_as_algorithm(
  value : CoreMetaMdBundleMember,
) -> CoreMetaMdAlgorithm? {
  match value {
    CoreMetaMdBundleMemberAlgorithm(algorithm) => Some(algorithm)
    _ => None
  }
}

///|
pub fn core_meta_md_bundle_member_as_category(
  value : CoreMetaMdBundleMember,
) -> CoreMetaMdCategory? {
  match value {
    CoreMetaMdBundleMemberCategory(category) => Some(category)
    _ => None
  }
}
