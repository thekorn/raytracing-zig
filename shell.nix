let
  unstable = import (fetchTarball "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz") {};
in
  unstable.mkShell {
    buildInputs = [
      # zig is broken in nix, also 0.13.0 is not available in nixpkgs yet
      #unstable.zig
      #unstable.zls
      unstable.hyperfine
    ];
  }
