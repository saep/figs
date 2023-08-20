{ config, pkgs, lib, username, stateVersion, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  # Manually add ssh-agent as long as it isn't in the stable home manager branch.
  # Copied from https://github.com/nix-community/home-manager/blob/master/modules/services/ssh-agent.nix
  home.sessionVariablesExtra = ''
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
      export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
    fi
  '';

  systemd.user.services.ssh-agent = {
    Install.WantedBy = [ "default.target" ];

    Unit = {
      Description = "SSH authentication agent";
      Documentation = "man:ssh-agent(1)";
    };

    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
    };
  };
}
