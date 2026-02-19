///|
pub let core_debug_grandom_validation_configuration_md : String = "CONFIGURATION__MD"

///|
pub let core_debug_grandom_validation_configuration_mw : String = "CONFIGURATION__MW"

///|
pub let core_debug_grandom_validation_configuration_pf : String = "CONFIGURATION__PF"

///|
pub struct CoreDebugGRandomValidationError {
  message : String
  feature : String
}

///|
pub fn new_core_debug_grandom_validation_error(
  message : String,
  feature : String,
) -> CoreDebugGRandomValidationError {
  { message, feature }
}

///|

///|
fn core_debug_grandom_form_equals(
  left : CoreDebugGRandomForm,
  right : CoreDebugGRandomForm,
) -> Bool {
  match (left, right) {
    (FormTrees, FormTrees) => true
    (FormCustom, FormCustom) => true
    (FormBipartite, FormBipartite) => true
    (FormBiconnected, FormBiconnected) => true
    (FormTriconnected, FormTriconnected) => true
    (FormAcyclic, FormAcyclic) => true
    _ => false
  }
}

///|
type CoreDebugGRandomValidationPredicate = (CoreDebugGRandomConfiguration) -> Bool

///|
type CoreDebugGRandomValidationRule = (
  CoreDebugGRandomValidationPredicate,
  CoreDebugGRandomValidationError,
)

///|
fn core_debug_grandom_validation_rules() -> Array[
  CoreDebugGRandomValidationRule,
] {
  [
    (
      config => {
        !core_debug_grandom_form_equals(config.form, FormTrees) && config.m_d
      },
      new_core_debug_grandom_validation_error(
        "maxDegree only defined on trees.", core_debug_grandom_validation_configuration_md,
      ),
    ),
    (
      config => {
        !core_debug_grandom_form_equals(config.form, FormTrees) && config.m_w
      },
      new_core_debug_grandom_validation_error(
        "maxWidth only defined on trees.", core_debug_grandom_validation_configuration_mw,
      ),
    ),
    (
      config => {
        !core_debug_grandom_form_equals(config.form, FormBipartite) &&
        config.p_f
      },
      new_core_debug_grandom_validation_error(
        "Partition Fraction only defined on bipartite graphs.", core_debug_grandom_validation_configuration_pf,
      ),
    ),
  ]
}

///|
pub fn core_debug_grandom_options_restrictions(
  config : CoreDebugGRandomConfiguration,
) -> Array[CoreDebugGRandomValidationError] {
  let errors : Array[CoreDebugGRandomValidationError] = []
  for rule in core_debug_grandom_validation_rules() {
    if (rule.0)(config) {
      errors.push(rule.1)
    }
  }
  errors
}
