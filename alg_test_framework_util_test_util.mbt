///|
pub struct TestMethodSignature {
  name : String
  is_public : Bool
  return_type : String
  parameter_types : Array[String]
  annotations : Array[String]
}

///|
pub fn new_test_method_signature(
  name : String,
  is_public : Bool,
  return_type : String,
  parameter_types : Array[String],
  annotations? : Array[String] = [],
) -> TestMethodSignature {
  {
    name,
    is_public,
    return_type,
    parameter_types: parameter_types.copy(),
    annotations: annotations.copy(),
  }
}

///|
pub fn test_method_signature_name(signature : TestMethodSignature) -> String {
  signature.name
}

///|
fn array_contains(values : Array[String], value : String) -> Bool {
  for item in values {
    if item == value {
      return true
    }
  }
  false
}

///|
fn join_type_names(type_names : Array[String]) -> String {
  let rendered = @buffer.new()
  rendered.write_string("[")
  let mut first = true
  for type_name in type_names {
    if !first {
      rendered.write_string(", ")
    }
    rendered.write_string(type_name)
    first = false
  }
  rendered.write_string("]")
  rendered.to_string()
}

///|
pub fn test_util_ensure_public(
  signature : TestMethodSignature,
  errors : Array[String],
) -> Bool {
  if signature.is_public {
    true
  } else {
    errors.push("Method \{signature.name} must be public")
    false
  }
}

///|
pub fn test_util_ensure_returns_type(
  signature : TestMethodSignature,
  errors : Array[String],
  expected_type : String,
) -> Bool {
  if signature.return_type == expected_type {
    true
  } else {
    errors.push(
      "Method \{signature.name} must have return type \{expected_type}",
    )
    false
  }
}

///|
pub fn test_util_ensure_parameters(
  signature : TestMethodSignature,
  errors : Array[String],
  expected_types : Array[String],
) -> Bool {
  let actual_types = signature.parameter_types
  if actual_types.length() != expected_types.length() {
    errors.push(
      "Method \{signature.name} must expect parameters of types: \{join_type_names(expected_types)}",
    )
    return false
  }
  for i in 0..<actual_types.length() {
    if actual_types[i] != expected_types[i] {
      errors.push(
        "Method \{signature.name} must expect parameters of types: \{join_type_names(expected_types)}",
      )
      return false
    }
  }
  true
}

///|
pub fn test_util_ensure_not_annotated_with(
  signature : TestMethodSignature,
  errors : Array[String],
  forbidden_annotations : Array[String],
) -> Bool {
  let mut success = true
  for annotation in signature.annotations {
    if array_contains(forbidden_annotations, annotation) {
      errors.push(
        "Method \{signature.name} cannot have annotation \{annotation}",
      )
      success = false
    }
  }
  success
}

///|
pub struct TestClassConstructorSignature {
  is_public : Bool
  parameter_count : Int
}

///|
pub fn new_test_class_constructor_signature(
  is_public : Bool,
  parameter_count : Int,
) -> TestClassConstructorSignature {
  { is_public, parameter_count }
}

///|
pub fn test_util_ensure_single_public_no_parameter_constructor(
  constructors : Array[TestClassConstructorSignature],
  errors : Array[String],
) -> Bool {
  if constructors.length() != 1 {
    errors.push(
      "Test class must have a single public constructor without parameters.",
    )
    return false
  }
  let only = constructors[0]
  if !only.is_public || only.parameter_count != 0 {
    errors.push(
      "Test class must have a single public constructor without parameters.",
    )
    return false
  }
  true
}

///|
pub fn[T] test_util_create_test_class_instance(factory : () -> T) -> T {
  factory()
}
