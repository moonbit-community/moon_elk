///|
pub struct AlgorithmProjectCreationPage {
  plug_in_name : String
  mut algorithm_name : String
}

///|
pub fn new_algorithm_project_creation_page(
  plug_in_name : String,
) -> AlgorithmProjectCreationPage {
  { plug_in_name, algorithm_name: plug_in_name }
}

///|
pub fn AlgorithmProjectCreationPage::set_algorithm_name(
  self : AlgorithmProjectCreationPage,
  algorithm_name : String,
) -> Unit {
  self.algorithm_name = algorithm_name
}

///|
pub fn AlgorithmProjectCreationPage::get_algorithm_name(
  self : AlgorithmProjectCreationPage,
) -> String {
  self.algorithm_name
}

///|
pub fn AlgorithmProjectCreationPage::is_page_complete(
  self : AlgorithmProjectCreationPage,
) -> Bool {
  !self.algorithm_name.is_empty()
}

///|
pub fn AlgorithmProjectCreationPage::get_plug_in_name(
  self : AlgorithmProjectCreationPage,
) -> String {
  self.plug_in_name
}
