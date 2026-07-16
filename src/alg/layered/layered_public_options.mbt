///|
/// Keep the algorithm identifier at the established layered package seam.
///
/// Option definitions live in the dedicated options package, while callers
/// that only need to select the algorithm should not depend on that internal
/// organization.
pub let layered_algorithm_id : String = @options.layered_algorithm_id
