///|
fn cross_min_reverse_ports(
  ports : Array[@runtime.LPort],
) -> Array[@runtime.LPort] {
  let reversed = []
  let mut i = ports.length()
  while i > 0 {
    i = i - 1
    reversed.push(ports[i])
  }
  reversed
}

///|
pub fn in_north_south_east_west_order(
  node : @runtime.LNode,
  side : @core.PortSide,
) -> Array[@runtime.LPort] {
  match side {
    East => node.get_port_side_view(side)
    North => node.get_port_side_view(side)
    South => cross_min_reverse_ports(node.get_port_side_view(side))
    West => cross_min_reverse_ports(node.get_port_side_view(side))
    SideUndefined => []
  }
}
