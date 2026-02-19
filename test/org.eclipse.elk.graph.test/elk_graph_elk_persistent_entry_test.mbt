///|
test "elk persistent entry key and value accessors" {
  let entry = new_elk_persistent_entry()
  inspect(entry.get_key(), content="")
  inspect(entry.get_value() is None, content="true")

  entry.set_key("sample-key")
  entry.set_value(Some("sample-value"))
  inspect(entry.get_key(), content="sample-key")
  inspect(entry.get_value() == Some("sample-value"), content="true")

  entry.set_value(None)
  inspect(entry.get_value() is None, content="true")
}
