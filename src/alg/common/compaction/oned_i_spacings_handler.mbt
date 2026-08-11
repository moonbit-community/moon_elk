///|
pub struct ISpacingsHandler {
  get_horizontal_spacing : ((CNode, CNode) -> Double raise)?
  get_vertical_spacing : ((CNode, CNode) -> Double raise)?
  pure_horizontal_spacing : ((CNode, CNode) -> Double)?
  pure_vertical_spacing : ((CNode, CNode) -> Double)?
}

///|
pub fn default_spacing_handler() -> ISpacingsHandler {
  {
    get_horizontal_spacing: None,
    get_vertical_spacing: None,
    pure_horizontal_spacing: Some((_, _) => 0.0),
    pure_vertical_spacing: Some((_, _) => 0.0),
  }
}

///|
pub fn new_spacings_handler(
  get_horizontal_spacing : (CNode, CNode) -> Double raise,
  get_vertical_spacing : (CNode, CNode) -> Double raise,
) -> ISpacingsHandler {
  {
    get_horizontal_spacing: Some(get_horizontal_spacing),
    get_vertical_spacing: Some(get_vertical_spacing),
    pure_horizontal_spacing: None,
    pure_vertical_spacing: None,
  }
}

///|
pub fn ISpacingsHandler::horizontal_spacing(
  self : ISpacingsHandler,
  first : CNode,
  second : CNode,
) -> Double raise {
  match self.get_horizontal_spacing {
    Some(spacing) => spacing(first, second)
    None => self.pure_horizontal_spacing.unwrap()(first, second)
  }
}

///|
pub fn ISpacingsHandler::vertical_spacing(
  self : ISpacingsHandler,
  first : CNode,
  second : CNode,
) -> Double raise {
  match self.get_vertical_spacing {
    Some(spacing) => spacing(first, second)
    None => self.pure_vertical_spacing.unwrap()(first, second)
  }
}
