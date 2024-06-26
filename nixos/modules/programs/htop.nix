{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.htop;

  fmt = value:
    if isList value then concatStringsSep " " (map fmt value) else
    if isString value then value else
    if isBool value then if value then "1" else "0" else
    if isInt value then toString value else
    throw "Unrecognized type ${typeOf value} in htop settings";

in

{

  options.programs.htop = {
    package = mkPackageOption pkgs "htop" { };

    enable = mkEnableOption "htop process monitor";

    settings = mkOption {
      type = with types; attrsOf (oneOf [ str int bool (listOf (oneOf [ str int bool ])) ]);
      default = {};
      example = {
        hide_kernel_threads = true;
        hide_userland_threads = true;
      };
      description = ''
        Extra global default configuration for htop
        which is read on first startup only.
        Htop subsequently uses ~/.config/htop/htoprc
        as configuration source.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    environment.etc."htoprc".text = ''
      # Global htop configuration
      # To change set: programs.htop.settings.KEY = VALUE;
    '' + concatStringsSep "\n" (mapAttrsToList (key: value: "${key}=${fmt value}") cfg.settings);
  };

}
