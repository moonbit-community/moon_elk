# Layered runtime kernel

This package is the internal strong component of the layered implementation.
It owns the graph model and the processor state whose types are stored directly
on that model.

Keep new code out of this package when it has a one-way dependency on the
kernel. In particular:

- option vocabulary belongs in `../options`;
- graph import, result transfer, and top-level orchestration belong in
  `../pipeline`;
- independently linkable phases and processors belong in their concrete child
  packages and register through `layered_phase_registry.mbt`.

Do not make runtime depend on those upper or concrete packages to save a local
qualification. Such an import would recreate the package cycle that the facade
and pipeline split removed.
