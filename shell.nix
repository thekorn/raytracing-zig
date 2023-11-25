let
  unstable = import (fetchTarball "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz") {};
in
  unstable.mkShell {
    buildInputs = [
      unstable.zig
      unstable.zls
      unstable.hyperfine
    ];
  }
