///|
pub suberror TextPrefixFilterException {
  TextPrefixFilterException(String)
} derive(Show, ToJson)

///|
fn[T] text_prefix_filter_raise(
  message : String,
) -> T raise TextPrefixFilterException {
  raise TextPrefixFilterException(message)
}

///|
fn text_prefix_filter_exception_message(
  err : TextPrefixFilterException,
) -> String {
  match err {
    TextPrefixFilterException(message) => message
  }
}

///|
fn[C, T] text_prefix_filter_comment_text_provider_or_raise(
  filter : TextPrefixFilter[C, T],
) -> ((C) -> String) raise TextPrefixFilterException {
  match filter.comment_text_provider {
    Some(provider) => provider
    None => text_prefix_filter_raise("A comment text provider is required.")
  }
}

///|
pub(all) struct TextPrefixFilter[C, T] {
  mut comment_text_provider : ((C) -> String)?
  prefixes : Array[String]
  mut reject_comment_on_prefix_match : Bool
  mut case_sensitive : Bool
  _phantom : T?
}

///|
pub fn[C, T] new_text_prefix_filter() -> TextPrefixFilter[C, T] {
  {
    comment_text_provider: None,
    prefixes: [],
    reject_comment_on_prefix_match: true,
    case_sensitive: false,
    _phantom: None,
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
) -> TextPrefixFilter[C, T] raise TextPrefixFilterException {
  if prefix.is_empty() {
    text_prefix_filter_raise("Prefix cannot be empty. Wouldn't make sense.")
  }

  self.prefixes.push(prefix)
  self
}

///|
pub fn[C, T] TextPrefixFilter::check_configuration(
  self : TextPrefixFilter[C, T],
) -> Unit raise TextPrefixFilterException {
  ignore(text_prefix_filter_comment_text_provider_or_raise(self))
  if self.prefixes.is_empty() {
    text_prefix_filter_raise("At least one prefix is required.")
  }
}

///|
pub fn[C, T] TextPrefixFilter::preprocess(
  self : TextPrefixFilter[C, T],
  _data_provider : IDataProvider[C, T],
  _include_hierarchy : Bool,
) -> Unit {
  try self.check_configuration() catch {
    err =>
      layout_runtime_report_unsupported_configuration(
        text_prefix_filter_exception_message(err),
      )
  } noraise {
    _ => ()
  }
}

///|
fn[C, T] text_prefix_filter_eligible_for_attachment_impl(
  filter : TextPrefixFilter[C, T],
  comment : C,
) -> Bool raise TextPrefixFilterException {
  let comment_text_provider = text_prefix_filter_comment_text_provider_or_raise(
    filter,
  )
  let comment_text = comment_text_provider(comment)

  if !comment_text.is_empty() {
    for prefix in filter.prefixes {
      if comment_text.length() >= prefix.length() {
        let starts_with_prefix = if filter.case_sensitive {
          comment_text.has_prefix(prefix)
        } else {
          comment_text.to_lower().has_prefix(prefix.to_lower())
        }
        if starts_with_prefix {
          return !filter.reject_comment_on_prefix_match
        }
      }
    }
  }

  filter.reject_comment_on_prefix_match
}

///|
pub fn[C, T] TextPrefixFilter::eligible_for_attachment(
  self : TextPrefixFilter[C, T],
  comment : C,
) -> Bool {
  try text_prefix_filter_eligible_for_attachment_impl(self, comment) catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        text_prefix_filter_exception_message(err),
      )
      self.reject_comment_on_prefix_match
    }
  } noraise {
    eligible => eligible
  }
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
