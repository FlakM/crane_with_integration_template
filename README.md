# About this project

Showcase rust build using nix with rich checks and integration tests inside vms.

- uses [crane](https://github.com/ipetkov/crane) 
- systemd unit to run the service
- integration tests inspired by [tutorial](https://www.haskellforall.com/2020/11/how-to-use-nixos-for-lightweight.html)


## Running instructions


```bash
# run all checks:
nix flake check

# run integration tests:
nix build .\#checks.x86_64-linux.itg

# generate doc
nix build .\#checks.x86_64-linux.test_nix-doc
```


### Notes

Thank for the support from amazing [matrix room](https://matrix.to/#/#nixnerds:jupiterbroadcasting.com) <3

