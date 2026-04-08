///|
pub suberror NodeReferenceMatcherException {
  NodeReferenceMatcherException(String)
} derive(Debug, ToJson)

///|
fn[T] node_reference_matcher_raise(
  message : String,
) -> T raise NodeReferenceMatcherException {
  raise NodeReferenceMatcherException(message)
}

///|
fn node_reference_matcher_exception_message(
  err : NodeReferenceMatcherException,
) -> String {
  match err {
    NodeReferenceMatcherException(message) => message
  }
}

///|
fn[C, T] node_reference_matcher_comment_text_provider_or_raise(
  matcher : NodeReferenceMatcher[C, T],
) -> ((C) -> String) raise NodeReferenceMatcherException {
  match matcher.comment_text_provider {
    Some(provider) => provider
    None => node_reference_matcher_raise("A comment text function is required.")
  }
}

///|
fn[C, T] node_reference_matcher_target_name_provider_or_raise(
  matcher : NodeReferenceMatcher[C, T],
) -> ((T) -> String) raise NodeReferenceMatcherException {
  match matcher.target_name_provider {
    Some(provider) => provider
    None => node_reference_matcher_raise("A node name function is required.")
  }
}

///|
fn[C, T] node_reference_matcher_bounds_provider_or_raise(
  matcher : NodeReferenceMatcher[C, T],
) -> IBoundsProvider[C, T] raise NodeReferenceMatcherException {
  match matcher.bounds_provider {
    Some(provider) => provider
    None =>
      node_reference_matcher_raise(
        "A bounds provider must be installed if a maximum attachment distance is set.",
      )
  }
}

///|
fn node_reference_matcher_is_word_char(ch : Char) -> Bool {
  ch.is_ascii_alphabetic() || ch.is_ascii_digit() || ch == '_'
}

///|
fn node_reference_matcher_is_word_boundary(
  chars : Array[Char],
  index : Int,
) -> Bool {
  if index <= 0 || index >= chars.length() {
    true
  } else {
    let previous_is_word = node_reference_matcher_is_word_char(chars[index - 1])
    let current_is_word = node_reference_matcher_is_word_char(chars[index])
    previous_is_word != current_is_word
  }
}

///|
fn node_reference_matcher_segment_matches(
  comment_chars : Array[Char],
  start : Int,
  segment : Array[Char],
  case_sensitive : Bool,
) -> Bool {
  if start + segment.length() > comment_chars.length() {
    return false
  }

  for i = 0; i < segment.length(); i = i + 1 {
    let comment_char = comment_chars[start + i]
    let segment_char = segment[i]

    if case_sensitive {
      if comment_char != segment_char {
        return false
      }
    } else if comment_char.to_ascii_lowercase() !=
      segment_char.to_ascii_lowercase() {
      return false
    }
  }

  true
}

///|
fn node_reference_matcher_strict_match(
  comment_text : String,
  target_name : String,
) -> Bool {
  let comment_chars = comment_text.to_array()
  let target_chars = target_name.to_array()

  if target_chars.is_empty() || target_chars.length() > comment_chars.length() {
    return false
  }

  for start = 0
      start + target_chars.length() <= comment_chars.length()
      start = start + 1 {
    if !node_reference_matcher_is_word_boundary(comment_chars, start) {
      continue
    }

    if !node_reference_matcher_segment_matches(
        comment_chars, start, target_chars, true,
      ) {
      continue
    }

    if node_reference_matcher_is_word_boundary(
        comment_chars,
        start + target_chars.length(),
      ) {
      return true
    }
  }

  false
}

///|
fn node_reference_matcher_fuzzy_segments(
  target_name : String,
) -> Array[Array[Char]] {
  let trimmed_target_name = target_name.trim().to_string()
  let trimmed_chars = trimmed_target_name.to_array()
  let segments = []
  let mut current_segment = []

  for i = 0; i < trimmed_chars.length(); i = i + 1 {
    let current_char = trimmed_chars[i]

    if current_char.is_ascii_uppercase() {
      if i > 0 && trimmed_chars[i - 1].is_ascii_lowercase() {
        segments.push(current_segment)
        current_segment = []
      }
      current_segment.push(current_char)
    } else if current_char.is_whitespace() {
      if i > 0 && !trimmed_chars[i - 1].is_whitespace() {
        segments.push(current_segment)
        current_segment = []
      }
    } else {
      current_segment.push(current_char)
    }
  }

  segments.push(current_segment)
  segments
}

///|
fn node_reference_matcher_fuzzy_match(
  comment_text : String,
  target_name : String,
) -> Bool {
  let comment_chars = comment_text.to_array()
  let target_segments = node_reference_matcher_fuzzy_segments(target_name)

  for start = 0; start <= comment_chars.length(); start = start + 1 {
    if !node_reference_matcher_is_word_boundary(comment_chars, start) {
      continue
    }

    let mut position = start
    let mut all_segments_match = true

    for i = 0; i < target_segments.length(); i = i + 1 {
      let segment = target_segments[i]

      if !node_reference_matcher_segment_matches(
          comment_chars, position, segment, false,
        ) {
        all_segments_match = false
        break
      }

      position += segment.length()

      if i + 1 < target_segments.length() {
        while position < comment_chars.length() &&
              comment_chars[position].is_whitespace() {
          position += 1
        }
      }
    }

    if all_segments_match &&
      node_reference_matcher_is_word_boundary(comment_chars, position) {
      return true
    }
  }

  false
}

///|
pub(all) struct NodeReferenceMatcher[C, T] {
  mut comment_text_provider : ((C) -> String)?
  mut target_name_provider : ((T) -> String)?
  mut bounds_provider : IBoundsProvider[C, T]?
  mut max_distance : Double
  mut fuzzy : Bool
  mut found_attachments : Array[(C, T)]
}

///|
pub fn[C, T] new_node_reference_matcher() -> NodeReferenceMatcher[C, T] {
  {
    comment_text_provider: None,
    target_name_provider: None,
    bounds_provider: None,
    max_distance: -1.0,
    fuzzy: false,
    found_attachments: [],
  }
}

///|
pub fn[C, T] NodeReferenceMatcher::with_comment_text_provider(
  self : NodeReferenceMatcher[C, T],
  provider : (C) -> String,
) -> NodeReferenceMatcher[C, T] {
  self.comment_text_provider = Some(provider)
  self
}

///|
pub fn[C, T] NodeReferenceMatcher::with_target_name_provider(
  self : NodeReferenceMatcher[C, T],
  provider : (T) -> String,
) -> NodeReferenceMatcher[C, T] {
  self.target_name_provider = Some(provider)
  self
}

///|
pub fn[C, T] NodeReferenceMatcher::with_fuzzy_matching(
  self : NodeReferenceMatcher[C, T],
) -> NodeReferenceMatcher[C, T] {
  self.fuzzy = true
  self
}

///|
pub fn[C, T] NodeReferenceMatcher::with_maximum_attachment_distance(
  self : NodeReferenceMatcher[C, T],
  distance : Double,
) -> NodeReferenceMatcher[C, T] {
  self.max_distance = distance
  self
}

///|
pub fn[C, T] NodeReferenceMatcher::with_bounds_provider(
  self : NodeReferenceMatcher[C, T],
  provider : IBoundsProvider[C, T],
) -> NodeReferenceMatcher[C, T] {
  self.bounds_provider = Some(provider)
  self
}

///|
pub fn[C, T] NodeReferenceMatcher::check_configuration(
  self : NodeReferenceMatcher[C, T],
) -> Unit raise NodeReferenceMatcherException {
  ignore(node_reference_matcher_comment_text_provider_or_raise(self))
  ignore(node_reference_matcher_target_name_provider_or_raise(self))
  if self.max_distance >= 0.0 {
    ignore(node_reference_matcher_bounds_provider_or_raise(self))
  }
}

///|
fn[C, T] node_reference_matcher_preprocess_impl(
  matcher : NodeReferenceMatcher[C, T],
  data_provider : IDataProvider[C, T],
  include_hierarchy : Bool,
) -> Unit raise NodeReferenceMatcherException {
  matcher.check_configuration()

  let comment_text_provider = node_reference_matcher_comment_text_provider_or_raise(
    matcher,
  )
  let target_name_provider = node_reference_matcher_target_name_provider_or_raise(
    matcher,
  )

  let comment_texts = []
  for comment in data_provider.provide_comments() {
    let comment_text = comment_text_provider(comment)
    if !comment_text.is_empty() {
      comment_texts.push((comment, comment_text))
    }
  }

  let target_names = []
  for target in data_provider.provide_targets() {
    let target_name = target_name_provider(target)
    if !target_name.is_empty() {
      target_names.push((target, target_name))
    }
  }

  matcher.go_find_matches(comment_texts, target_names)

  if include_hierarchy {
    for sub_provider in data_provider.provide_sub_hierarchies() {
      node_reference_matcher_preprocess_impl(matcher, sub_provider, true)
    }
  }
}

///|
pub fn[C, T] NodeReferenceMatcher::preprocess(
  self : NodeReferenceMatcher[C, T],
  data_provider : IDataProvider[C, T],
  include_hierarchy : Bool,
) -> Unit {
  try
    node_reference_matcher_preprocess_impl(
      self, data_provider, include_hierarchy,
    )
  catch {
    err =>
      layout_runtime_report_unsupported_configuration(
        node_reference_matcher_exception_message(err),
      )
  } noraise {
    _ => ()
  }
}

///|
fn[C, T] node_reference_matcher_go_find_matches_impl(
  matcher : NodeReferenceMatcher[C, T],
  comment_texts : Array[(C, String)],
  target_names : Array[(T, String)],
) -> Unit raise NodeReferenceMatcherException {
  for comment_text_pair in comment_texts {
    let (comment, comment_text) = comment_text_pair
    let mut found_target : T? = None

    for target_name_pair in target_names {
      let (target, target_name) = target_name_pair
      let matched = if matcher.fuzzy {
        node_reference_matcher_fuzzy_match(comment_text, target_name)
      } else {
        node_reference_matcher_strict_match(comment_text, target_name)
      }

      if matched {
        if found_target is None {
          found_target = Some(target)
        } else {
          found_target = None
          break
        }
      }
    }

    match found_target {
      Some(target) =>
        if matcher.max_distance < 0.0 {
          matcher.found_attachments.push((comment, target))
        } else {
          let bounds_provider = node_reference_matcher_bounds_provider_or_raise(
            matcher,
          )
          let comment_bounds = match
            bounds_provider.bounds_for_comment(comment) {
            Some(bounds) => bounds
            None =>
              node_reference_matcher_raise(
                "Bounds for comment are unavailable.",
              )
          }
          let target_bounds = match bounds_provider.bounds_for_target(target) {
            Some(bounds) => bounds
            None =>
              node_reference_matcher_raise("Bounds for target are unavailable.")
          }

          if distance_matcher_distance(comment_bounds, target_bounds) <=
            matcher.max_distance {
            matcher.found_attachments.push((comment, target))
          }
        }
      None => ()
    }
  }
}

///|
pub fn[C, T] NodeReferenceMatcher::cleanup(
  self : NodeReferenceMatcher[C, T],
) -> Unit {
  self.found_attachments = []
}

///|
pub fn[C : Eq, T : Eq] NodeReferenceMatcher::raw(
  self : NodeReferenceMatcher[C, T],
  comment : C,
  target : T,
) -> Double {
  for attachment in self.found_attachments {
    let (attached_comment, attached_target) = attachment
    if attached_comment == comment && attached_target == target {
      return 1.0
    }
  }

  0.0
}

///|
pub fn[C : Eq, T : Eq] NodeReferenceMatcher::normalized(
  self : NodeReferenceMatcher[C, T],
  comment : C,
  target : T,
) -> Double {
  self.raw(comment, target)
}

///|
pub fn[C, T] NodeReferenceMatcher::go_find_matches(
  self : NodeReferenceMatcher[C, T],
  comment_texts : Array[(C, String)],
  target_names : Array[(T, String)],
) -> Unit {
  try
    node_reference_matcher_go_find_matches_impl(
      self, comment_texts, target_names,
    )
  catch {
    err =>
      layout_runtime_report_unsupported_configuration(
        node_reference_matcher_exception_message(err),
      )
  } noraise {
    _ => ()
  }
}

///|
pub fn[C, T] NodeReferenceMatcher::get_attachments(
  self : NodeReferenceMatcher[C, T],
) -> Array[(C, T)] {
  self.found_attachments
}

///|
pub fn[C : Eq, T : Eq] NodeReferenceMatcher::as_matcher(
  self : NodeReferenceMatcher[C, T],
) -> IMatcher[C, T] {
  new_matcher(
    (comment, target) => self.raw(comment, target),
    (comment, target) => self.normalized(comment, target),
    (data_provider, include_hierarchy) => {
      self.preprocess(data_provider, include_hierarchy)
    },
    () => self.cleanup(),
  )
}
