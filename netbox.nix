{ config, lib, pkgs, ... }: {

  sops.secrets = {
    "netbox_secret_key" = {
      owner = "netbox";
      group = "netbox";
      mode = "0400";
    };
    "netbox-api-pepper" = {};
  };

  sops.templates."netbox-api-pepper" = {
    content = config.sops.placeholder."netbox-api-pepper";
    owner = "netbox";
    group = "netbox";
    mode = "0400";
  };

  services.netbox = {
    enable = true;
    secretKeyFile = config.sops.secrets."netbox_secret_key".path;
    apiTokenPeppersFile = config.sops.templates."netbox-api-pepper".path;
    listenAddress = "127.0.0.1";
    port = 8001;
    settings = {
      ALLOWED_HOSTS = [ "netbox.mesh.loranjennings.com" "127.0.0.1" "localhost" ];
      CSRF_TRUSTED_ORIGINS = [ "https://netbox.mesh.loranjennings.com" ];
    };
  };

  # 502 fix. longer worker timeout, fewer workers for Pi
  systemd.services.netbox.environment.GUNICORN_CMD_ARGS = "--timeout 300 --workers 2";
  systemd.services.netbox.serviceConfig.TimeoutStartSec = lib.mkForce "30min";
}
