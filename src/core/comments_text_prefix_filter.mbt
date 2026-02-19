///|
fn[C, T] text_prefix_filter_comment_text_provider_or_abort(
  filter : TextPrefixFilter[C, T],
) -> (C) -> String {
  match filter.comment_text_provider {
    Some(provider) => provider
    None => abort("A comment text provider is required.")
  }
}

///|
pub(all) struct TextPrefixFilter[C, T] {
  mut comment_text_provider : ((C) -> String)?
  prefixes : Array[String]
  mut reject_comment_on_prefix_match : Bool
  mut case_sensitive : Bool
}

///|
pub fn[C, T] new_text_prefix_filter() -> TextPrefixFilter[C, T] {
  {
    comment_text_provider: None,
    prefixes: [],
    reject_comment_on_prefix_match: true,
    case_sensitive: false,
  }
}

///|
pub fn[C, T] TextPrefixFilter::with_comment_text_provider(
  self : TextPrefixFilter[C, T],
  provider : (C) -> String,
) -> TextPrefixFilter[C, T] {
  self.comment_text_provider = Some(provider)
  self
}

///|
pub fn[C, T] TextPrefixFilter::with_prefix_match_required_for_eligibility(
  self : TextPrefixFilter[C, T],
) -> TextPrefixFilter[C, T] {
  self.reject_comment_on_prefix_match = false
  self
}

///|
pub fn[C, T] TextPrefixFilter::with_case_sensitive_matching(
  self : TextPrefixFilter[C, T],
) -> TextPrefixFilter[C, T] {
  self.case_sensitive = true
  self
}

///|
pub fn[C, T] TextPrefixFilter::add_prefix(
  self : TextPrefixFilter[C, T],
  prefix : String,
) -> TextPrefixFilter[C, T] {
  if prefix.is_empty() {
    abort("Prefix cannot be empty. Wouldn't make sense.")
  }

  self.prefixes.push(prefix)
  self
}

///|
pub fn[C, T] TextPrefixFilter::check_configuration(
  self : TextPrefixFilter[C, T],
) -> Unit {
  ignore(text_prefix_filter_comment_text_provider_or_abort(self))
  if self.prefixes.is_empty() {
    abort("At least one prefix is required.")
  }
}

///|
pub fn[C, T] TextPrefixFilter::preprocess(
  self : TextPrefixFilter[C, T],
  _data_provider : IDataProvider[C, T],
  _include_hierarchy : Bool,
) -> Unit {
  self.check_configuration()
}

///|
pub fn[C, T] TextPrefixFilter::eligible_for_attachment(
  self : TextPrefixFilter[C, T],
  comment : C,
) -> Bool {
  let comment_text_provider = text_prefix_filter_comment_text_provider_or_abort(
    self,
  )
  let comment_text = comment_text_provider(comment)

  if !comment_text.is_empty() {
    for prefix in self.prefixes {
      if comment_text.length() >= prefix.length() {
        let starts_with_prefix = if self.case_sensitive {
          comment_text.has_prefix(prefix)
        } else {
          comment_text.to_lower().has_prefix(prefix.to_lower())
        }
        if starts_with_prefix {
          return !self.reject_comment_on_prefix_match
        }
      }
    }
  }

  self.reject_comment_on_prefix_match
}

///|
pub fn[C, T] TextPrefixFilter::as_filter(
  self : TextPrefixFilter[C, T],
) -> IFilter[C, T] {
  new_filter(
    comment => self.eligible_for_attachment(comment),
    (data_provider, include_hierarchy) => {
      self.preprocess(data_provider, include_hierarchy)
    },
    () => (),
  )
}
