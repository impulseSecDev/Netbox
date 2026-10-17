# ============================================================
# Homepage Docker Container for NixOS
# ============================================================

{ config, lib, pkgs, ... }:

{
  sops.secrets = {
    "homepage_auth_secret" = {};
  };

  sops.templates."homepage.env" = {
    content = ''
      HOMEPAGE_AUTH_SECRET=${config.sops.placeholder.homepage_auth_secret};
    '';
    path = "/run/secrets/wazuh-agent.env";
    mode = "0444";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/homepage 0750 homepage homepage -"
  ];

  # OCI Container Definition
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      homepage = {
        image = "ghcr.io/gethomepage/homepage:latest";
        volumes = [
          "/var/lib/homepage/:app/config"
        ];
        ports = "3000:3000";
        environment = [
          HOMEPAGE_ALLOWED_HOSTS: gethomepage.dev,home.mesh.loranjennings.com;
          PUID: $PUID;
          PGID: $PGID;
          HOMEPAGE_AUTH_ENABLED=true;
          HOMEPAGE_EXTERNAL_URL="https://home.mesh.loranjennings.com";
        ];
        environmentFiles = [ config.sops.templates."homepage.env".path ];
      };
    };
  };
}
