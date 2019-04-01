# Custom Nix expressions

This repo includes Nix expressions for:
FStar development environment, including the Z3 version needed
by Project Everest, and KreMLin.

## Usage

I currently use it as a channel. I now realise that an overlay is
probably more like the Nix way of doing this, but I didn't take the
time yet to change things. Thus, the current known way to make things
work is:

- Clone the repository to somewhere on your local machine;
- Add it as a channel:
```
# nix-channel --add file:///path/to/nix-everest
# nix-channel --update
```
- And add the following to your `configuration.nix`:
```
{ config, pkgs, ... }:

{
  # …

  nixpkgs.config = {
    # …
    packageOverrides = pkgs: {
      nix-everest = import <nix-everest> {};
    };
    # …
  };

  environment.systemPackages = with pkgs; [
    # …
    nix-everest.z3-everest
    nix-everest.fstar-master
    nix-everest.kremlin-master
    nix-everest.ocaml-visitors # TODO this is my own package, this will be available in the next version of NixOS
    # …
  ];

  # …
```
- Activate the new configuration
```
# nixos-rebuild switch
```
- Now, FStar, Z3, and KreMLin will be available under
  `/run/current-system/sw/bin/` as `fstar.exe`, `z3`, and
  `krml`.
- In Emacs or Spacemacs, use it with
```
  (setq-default fstar-executable "/run/current-system/sw/bin/fstar.exe")
  (setq-default fstar-smt-executable "/run/current-system/sw/bin/z3")
```

## Todo

- I did a change in KreMLin's makefile to make it work, create a pull
  request against upstream (branch `blipp_makefile` in my own fork).
- Use overlays.
