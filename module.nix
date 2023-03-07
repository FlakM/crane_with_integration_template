self:
{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.services.test_nix;
  test_nix = self.outputs.packages.x86_64-linux.default;
in {
  options.services.test_nix = {
    enable = mkEnableOption "test_nix";

    environment = mkOption {
      type = types.str;
      default = "prod";
      description = "Environment name passed to ecs logging format";
    };

    rustLog = mkOption {
      type = types.str;
      default = "info";
      description = "Environment name passed to logging level";
    };
  };

  config = mkIf cfg.enable {
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
        Environment = "ENV=${cfg.environment} RUST_LOG=${cfg.rustLog}";
      };
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    systemd.sockets.test_nix = {
      listenStreams = [ "8080" ];
      wantedBy = [ "sockets.target" ];
      enable = true;
    };

  };
}
