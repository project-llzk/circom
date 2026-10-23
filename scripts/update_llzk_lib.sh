#!/usr/bin/env bash

# Program: update_llzk_lib.sh
# Description: This script updates llzk-rs in the nix flake lock file,
#   then pins the cargo dependency to the same revision.
#
# Required Programs:
#   - cargo: For updating the rust dependencies
#   - nix: For updating the nix flake
#
# Usage: ./scripts/update_llzk_lib.sh

set -e

nix flake update llzk-rs-pkgs

llzk_rev=$(nix eval --impure --raw --expr '
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    llzkNode = lock.nodes.${lock.root}.inputs.llzk-rs-pkgs;
  in
    lock.nodes.${llzkNode}.locked.rev
')
cargo update -p llzk --precise "$llzk_rev"
