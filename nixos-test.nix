{ 
  system,
  pkgs
, makeTest
, test_nix
}:
let
  a = 1;
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

      imports = [ sharedModule ];
      users.users.test_nix = {
        isSystemUser = true;
        group = "test_nix";
      };

      users.groups.test_nix = {};

      systemd.services.test_nix = {
        serviceConfig = {
          ExecStart = "${test_nix}/bin/test_nix";
          Type = "simple";
          User = "test_nix";
          Group = "test_nix";
          RestartSec = 5;
          Restart = "always";
          Environment = "ENV=DEV RUST_LOG=DEBUG";
        };
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
      };

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
