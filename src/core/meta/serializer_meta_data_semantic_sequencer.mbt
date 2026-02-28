///|
pub(all) struct MetaDataSemanticSequencer {
  grammar_access : MetaDataGrammarAccess
}

///|
pub fn new_meta_data_semantic_sequencer(
  grammar_access? : MetaDataGrammarAccess = new_meta_data_grammar_access(),
) -> MetaDataSemanticSequencer {
  { grammar_access, }
}

///|
pub fn MetaDataSemanticSequencer::get_grammar_access(
  self : MetaDataSemanticSequencer,
) -> MetaDataGrammarAccess {
  self.grammar_access
}

///|
pub fn[T] MetaDataSemanticSequencer::sequence(
  self : MetaDataSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  ignore(self)
  semantic_object
}

///|
pub fn[T] MetaDataSemanticSequencer::sequence_md_model(
  self : MetaDataSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] MetaDataSemanticSequencer::sequence_md_bundle(
  self : MetaDataSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] MetaDataSemanticSequencer::sequence_md_option(
  self : MetaDataSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] MetaDataSemanticSequencer::sequence_md_algorithm(
  self : MetaDataSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] MetaDataSemanticSequencer::sequence_md_category(
  self : MetaDataSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] MetaDataSemanticSequencer::sequence_md_option_dependency(
  self : MetaDataSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] MetaDataSemanticSequencer::sequence_md_option_support(
  self : MetaDataSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}
