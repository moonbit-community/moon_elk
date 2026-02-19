///|
pub enum CoreMetaMdGroupOrOption {
  CoreMetaMdGroupOrOptionGroup(CoreMetaMdGroup)
  CoreMetaMdGroupOrOptionOption(CoreMetaMdOption)
}

///|
pub fn core_meta_md_group_or_option_group(
  group : CoreMetaMdGroup,
) -> CoreMetaMdGroupOrOption {
  CoreMetaMdGroupOrOptionGroup(group)
}

///|
pub fn core_meta_md_group_or_option_option(
  option : CoreMetaMdOption,
) -> CoreMetaMdGroupOrOption {
  CoreMetaMdGroupOrOptionOption(option)
}

///|
pub fn core_meta_md_group_or_option_tag(
  value : CoreMetaMdGroupOrOption,
) -> String {
  match value {
    CoreMetaMdGroupOrOptionGroup(_) => "group"
    CoreMetaMdGroupOrOptionOption(_) => "option"
  }
}

///|
pub fn core_meta_md_group_or_option_as_group(
  value : CoreMetaMdGroupOrOption,
) -> CoreMetaMdGroup? {
  match value {
    CoreMetaMdGroupOrOptionGroup(group) => Some(group)
    CoreMetaMdGroupOrOptionOption(_) => None
  }
}

///|
pub fn core_meta_md_group_or_option_as_option(
  value : CoreMetaMdGroupOrOption,
) -> CoreMetaMdOption? {
  match value {
    CoreMetaMdGroupOrOptionGroup(_) => None
    CoreMetaMdGroupOrOptionOption(option) => Some(option)
  }
}
