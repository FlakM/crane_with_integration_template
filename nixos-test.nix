{ 
  system,
  pkgs
, makeTest
, test_nix
, self
}:
let
  test_port = 3000;  

  # NixOS module shared between server and client
  sharedModule = {
    # Since it's common for CI not to have $DISPLAY available, we have to explicitly tell the tests "please don't expect any screen available"
    virtualisation.graphics = false;
  };
in
makeTest {
  name = "integration";
  nodes = {
    server = {
      networking.firewall.allowedTCPPorts = [ test_port ];
      imports = [ sharedModule self.nixosModules.test_nix ];
      services.test_nix.enable = true;
     };
     client = {
       imports = [ sharedModule ];
     };
  };

  testScript = ''
    start_all()
    import json
    import sys

    start_all()

    server.wait_for_open_port(${toString test_port})

    expected = {"hello": "world"}

    actual = json.loads(
        client.succeed(
            "${pkgs.curl}/bin/curl -vv http://server:${toString test_port}"
        )
    )

    if expected != actual:
        sys.exit(1)
  '';
} {
  inherit pkgs;
  inherit (pkgs) system;
}
