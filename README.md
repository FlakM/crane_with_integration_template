# About this project


Project tries to build nix contained build with integration tests.

- uses [crane](https://github.com/ipetkov/crane) 
- systemd unit to run the service
- integration tests inspired by this [tutorial](https://www.haskellforall.com/2020/11/how-to-use-nixos-for-lightweight.html)




## Running instructions


```bash
# run all checks:
nix flake check

# run integration tests:
nix build .\#checks.x86_64-linux.itg

# generate doc
nix build .\#checks.x86_64-linux.test_nix-doc
```




