///|
/// Keeps trait methods available through dot syntax.
pub extend GmfFigureKind with Eq::{not_equal, equal}

///|
pub extend GmfFigureKind with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfEditPartKind with Eq::{not_equal, equal}

///|
pub extend GmfEditPartKind with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfOperation with Eq::{not_equal, equal}

///|
pub extend GmfOperation with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfPoint with Eq::{not_equal, equal}

///|
pub extend GmfPoint with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfDimension with Eq::{not_equal, equal}

///|
pub extend GmfDimension with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfInsets with Eq::{not_equal, equal}

///|
pub extend GmfInsets with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfRectangle with Eq::{not_equal, equal}

///|
pub extend GmfRectangle with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfPointList with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfLayoutElementShape with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfLayoutElementEdge with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfDiagramPart with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfLayoutInvocation with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfConnectorWorkbenchPart with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GmfConnectorDiagramPart with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfDiagramLayoutConnectorException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend GmfDiagramLayoutConnectorException with ToJson::{to_json}

///|
pub extend GmfLayoutOptionTarget with Eq::{not_equal, equal}

///|
pub extend GmfLayoutOptionTarget with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfLayoutOptionTarget with Show::{to_string, output}

///|
pub extend GmfLayoutSetupObject with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GmfSelectionItem with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LayoutDiagramFileHandlerException with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend LayoutDiagramFileHandlerException with ToJson::{to_json}
