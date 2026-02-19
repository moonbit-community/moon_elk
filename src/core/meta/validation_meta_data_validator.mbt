///|
pub(all) struct CoreMetaValidationIssue {
  message : String
  feature : String
  member_name : String?
}

///|
pub fn new_core_meta_validation_issue(
  message : String,
  feature : String,
  member_name : String?,
) -> CoreMetaValidationIssue {
  { message, feature, member_name }
}

///|
pub(all) struct MetaDataValidator {
  base : AbstractMetaDataValidator
}

///|
pub fn new_meta_data_validator(
  base? : AbstractMetaDataValidator = new_abstract_meta_data_validator(),
) -> MetaDataValidator {
  { base, }
}

///|
pub fn MetaDataValidator::get_epackages(
  self : MetaDataValidator,
) -> Array[String] {
  self.base.get_epackages()
}

///|
fn core_meta_validator_duplicate_id_issue(
  member_name : String?,
) -> CoreMetaValidationIssue {
  let formatted = match member_name {
    Some(name) => name
    None => ""
  }
  new_core_meta_validation_issue(
    "The id '" + formatted + "' is already used.",
    core_meta_md_bundle_member_name_feature,
    member_name,
  )
}

///|
fn core_meta_validator_check_exists_and_remember(
  seen : Map[String, Int],
  name : String,
  issues : Array[CoreMetaValidationIssue],
) -> Unit {
  match seen.get(name) {
    None => seen[name] = 1
    Some(state) =>
      if state == 1 {
        // Keep parity with upstream validator: first duplicate marks both
        // the original and the duplicate entry.
        issues.push(core_meta_validator_duplicate_id_issue(Some(name)))
        issues.push(core_meta_validator_duplicate_id_issue(Some(name)))
        seen[name] = 2
      } else {
        issues.push(core_meta_validator_duplicate_id_issue(Some(name)))
      }
  }
}

///|
fn core_meta_validator_check_duplicate_ids_in_group_or_options(
  members : Array[CoreMetaMdGroupOrOption],
  seen_group_ids : Map[String, Int],
  seen_option_ids : Map[String, Int],
  issues : Array[CoreMetaValidationIssue],
) -> Unit {
  for group_or_option_member in members {
    match group_or_option_member {
      CoreMetaMdGroupOrOptionGroup(group) => {
        match group.get_name() {
          Some(name) =>
            core_meta_validator_check_exists_and_remember(
              seen_group_ids, name, issues,
            )
          None => ()
        }
        core_meta_validator_check_duplicate_ids_in_group_or_options(
          group.get_children(),
          seen_group_ids,
          seen_option_ids,
          issues,
        )
      }
      CoreMetaMdGroupOrOptionOption(option) =>
        match option.get_name() {
          Some(name) =>
            core_meta_validator_check_exists_and_remember(
              seen_option_ids, name, issues,
            )
          None => ()
        }
    }
  }
}

///|
pub fn MetaDataValidator::check_duplicate_member_id(
  self : MetaDataValidator,
  bundle : CoreMetaMdBundle,
) -> Array[CoreMetaValidationIssue] {
  ignore(self)
  let issues : Array[CoreMetaValidationIssue] = []
  let algorithm_ids : Map[String, Int] = {}
  let category_ids : Map[String, Int] = {}
  let option_ids : Map[String, Int] = {}
  let group_ids : Map[String, Int] = {}

  for bundle_member in bundle.get_members() {
    match bundle_member {
      CoreMetaMdBundleMemberAlgorithm(algorithm) =>
        match algorithm.get_name() {
          Some(name) =>
            core_meta_validator_check_exists_and_remember(
              algorithm_ids, name, issues,
            )
          None => ()
        }
      CoreMetaMdBundleMemberCategory(category) =>
        match category.get_name() {
          Some(name) =>
            core_meta_validator_check_exists_and_remember(
              category_ids, name, issues,
            )
          None => ()
        }
      CoreMetaMdBundleMemberGroupOrOption(group_or_option) =>
        core_meta_validator_check_duplicate_ids_in_group_or_options(
          [group_or_option],
          group_ids,
          option_ids,
          issues,
        )
    }
  }

  issues
}
