///|
fn[C, T] comment_attacher_default_explicit_attachment_provider() -> IExplicitAttachmentProvider[
  C,
  T,
] {
  new_explicit_attachment_provider_with_default_lifecycle(_comment => None)
}

///|
pub(all) struct CommentAttacher[C, T] {
  mut include_hierarchy : Bool
  mut explicit_attachments_disable_heuristics : Bool
  mut explicit_attachment_provider : IExplicitAttachmentProvider[C, T]
  mut bounds_provider : IBoundsProvider[C, T]?
  filters : Array[IFilter[C, T]]
  matchers : Array[IMatcher[C, T]]
  mut decider : IDecider[T]
}

///|
pub fn[C, T] new_comment_attacher() -> CommentAttacher[C, T] {
  {
    include_hierarchy: true,
    explicit_attachments_disable_heuristics: true,
    explicit_attachment_provider: comment_attacher_default_explicit_attachment_provider(),
    bounds_provider: None,
    filters: [],
    matchers: [],
    decider: new_aggregated_match_decider().as_decider(),
  }
}

///|
pub fn[C, T] CommentAttacher::limit_to_current_hierarchy_level(
  self : CommentAttacher[C, T],
  limit : Bool,
) -> CommentAttacher[C, T] {
  self.include_hierarchy = !limit
  self
}

///|
pub fn[C, T] CommentAttacher::keep_heuristics_enabled_with_explicit_attachments(
  self : CommentAttacher[C, T],
  keep_enabled : Bool,
) -> CommentAttacher[C, T] {
  self.explicit_attachments_disable_heuristics = !keep_enabled
  self
}

///|
pub fn[C, T] CommentAttacher::with_explicit_attachment_provider(
  self : CommentAttacher[C, T],
  provider : IExplicitAttachmentProvider[C, T]?,
) -> CommentAttacher[C, T] {
  match provider {
    Some(installed_provider) =>
      self.explicit_attachment_provider = installed_provider
    None =>
      self.explicit_attachment_provider = comment_attacher_default_explicit_attachment_provider()
  }
  self
}

///|
pub fn[C, T] CommentAttacher::with_bounds_provider(
  self : CommentAttacher[C, T],
  provider : IBoundsProvider[C, T],
) -> CommentAttacher[C, T] {
  self.bounds_provider = Some(provider)
  self
}

///|
pub fn[C, T] CommentAttacher::add_filter(
  self : CommentAttacher[C, T],
  filter : IFilter[C, T],
) -> CommentAttacher[C, T] {
  self.filters.push(filter)
  self
}

///|
pub fn[C, T] CommentAttacher::add_matcher(
  self : CommentAttacher[C, T],
  matcher : IMatcher[C, T],
) -> CommentAttacher[C, T] {
  self.matchers.push(matcher)
  self
}

///|
pub fn[C, T] CommentAttacher::with_attachment_decider(
  self : CommentAttacher[C, T],
  attachment_decider : IDecider[T],
) -> CommentAttacher[C, T] {
  self.decider = attachment_decider
  self
}

///|
pub fn[C, T] CommentAttacher::attach_comments(
  self : CommentAttacher[C, T],
  data_provider : IDataProvider[C, T],
) -> Unit {
  self.preprocess(data_provider)

  let explicit_attachments = []
  let heuristic_attachments = []
  let processing_queue = [data_provider]
  let mut queue_index = 0

  while queue_index < processing_queue.length() {
    let current_hierarchy = processing_queue[queue_index]
    queue_index += 1

    for comment in current_hierarchy.provide_comments() {
      let explicit_attachment = self.explicit_attachment_provider.find_explicit_attachment(
        comment,
      )
      match explicit_attachment {
        Some(explicit_target) =>
          explicit_attachments.push((comment, explicit_target))
        None =>
          if (
              explicit_attachments.is_empty() ||
              !self.explicit_attachments_disable_heuristics
            ) &&
            self.is_eligible_for_heuristic_attachment(comment) {
            match self.find_match(current_hierarchy, comment) {
              Some(heuristic_target) =>
                heuristic_attachments.push((comment, heuristic_target))
              None => ()
            }
          }
      }
    }

    if self.include_hierarchy {
      for sub_hierarchy in current_hierarchy.provide_sub_hierarchies() {
        processing_queue.push(sub_hierarchy)
      }
    }
  }

  self.cleanup()
  self.edgeify_found_attachments(
    data_provider, explicit_attachments, heuristic_attachments,
  )
}

///|
pub fn[C, T] CommentAttacher::preprocess(
  self : CommentAttacher[C, T],
  data_provider : IDataProvider[C, T],
) -> Unit {
  self.explicit_attachment_provider.preprocess(
    data_provider,
    self.include_hierarchy,
  )

  for filter in self.filters {
    filter.preprocess(data_provider, self.include_hierarchy)
  }

  for matcher in self.matchers {
    matcher.preprocess(data_provider, self.include_hierarchy)
  }

  match self.bounds_provider {
    Some(provider) => provider.preprocess(data_provider, self.include_hierarchy)
    None => ()
  }
}

///|
pub fn[C, T] CommentAttacher::is_eligible_for_heuristic_attachment(
  self : CommentAttacher[C, T],
  comment : C,
) -> Bool {
  for filter in self.filters {
    if !filter.eligible_for_attachment(comment) {
      return false
    }
  }

  true
}

///|
pub fn[C, T] CommentAttacher::find_match(
  self : CommentAttacher[C, T],
  data_provider : IDataProvider[C, T],
  comment : C,
) -> T? {
  if self.matchers.is_empty() {
    return None
  }

  let candidates = data_provider.provide_targets_for(comment)
  if candidates.is_empty() {
    return None
  }

  let results = []
  for candidate in candidates {
    let candidate_results = []
    for matcher in self.matchers {
      candidate_results.push(
        (matcher.matcher_id(), matcher.normalized(comment, candidate)),
      )
    }
    results.push((candidate, candidate_results))
  }

  self.decider.make_attachment_decision(results)
}

///|
pub fn[C, T] CommentAttacher::edgeify_found_attachments(
  self : CommentAttacher[C, T],
  data_provider : IDataProvider[C, T],
  explicit_attachments : Array[(C, T)],
  heuristic_attachments : Array[(C, T)],
) -> Unit {
  ignore(self)

  for explicit_attachment in explicit_attachments {
    let (comment, target) = explicit_attachment
    data_provider.attach(comment, target)
  }

  if explicit_attachments.is_empty() ||
    !self.explicit_attachments_disable_heuristics {
    for heuristic_attachment in heuristic_attachments {
      let (comment, target) = heuristic_attachment
      data_provider.attach(comment, target)
    }
  }
}

///|
pub fn[C, T] CommentAttacher::cleanup(self : CommentAttacher[C, T]) -> Unit {
  self.explicit_attachment_provider.cleanup()

  for filter in self.filters {
    filter.cleanup()
  }

  for matcher in self.matchers {
    matcher.cleanup()
  }

  match self.bounds_provider {
    Some(provider) => provider.cleanup()
    None => ()
  }
}
