{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "clock" "cpu" "memory" "disk" ];
        modules-center = [ "river/tags" ];
        modules-right = [
          "keyboard-state"
          "temperature"
          "custom/kernel"
          "network"
          "pulseaudio"
          "battery"
          "tray"
        ];

        "river/tags" = {
          num-tags = 4;
          tag-labels = [ "" "" "" "" ];
        };
        "cpu" = {
          interval = 10;
          format = " {usage}%";
          tooltip = false;
        };
        "memory" = {
          interval = 10;
          format = " {}%";
        };
        "disk" = {
          interval = 600;
          format = " {percentage_used}%";
          path = "/";
        };
        "clock" = {
          interval = 60;
          format = "{: %a %b %e %H:%M}";
        };
        "keyboard-state" = {
          capslock = true;
          format = "{icon}";
          format-icons = {
            locked = "CAPS";
            unlocked = "";
          };
        };
        "temperature" = {
          interval = 5;
          critical-threshold = 60;
          format = " {temperatureC}°C";
        };
        "custom/kernel" = {
          interval = "once";
          format = " {}";
          exec = "uname -r";
        };
        "network" = {
          format-wifi = " {signalStrength}%";
          format-ethernet = "";
          tooltip-format = "{ifname} via {gwaddr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "";
        };
        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-muted = " {format_source}";
          format-source = "";
          format-source-muted = "";
          format-icons = { "default" = [ "" "" "" ]; };
          scroll-step = 1;
          tooltip-format = "{desc}; {volume}%";
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-click-right = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          on-click-middle = "pavucontrol";
        };
        "tray" = { spacing = 10; };
      };
    };
    style = ''
      @define-color bg #282828;
      @define-color bg1 #3c3836;
      @define-color fg #ebdbb2;
      @define-color red-normal #cc241d;
      @define-color red-accent #fb4934;
      @define-color green-normal #98971a;
      @define-color green-accent #b8bb26;
      @define-color yellow-normal #d79921;
      @define-color yellow-accent #fabd2f;
      @define-color blue-normal #458588;
      @define-color blue-accent #83a598;
      @define-color purple-normal #b16286;
      @define-color purple-accent #d3869b;
      @define-color orange-normal #d65d0e;
      @define-color orange-accent #fe8019;

      * {
        font-family: "FiraCode", "Font Awesome 6 Free";
        font-weight: bold;
        font-size: 14px;
        min-height: 0px;
      }

      window#waybar {
        color: @fg;
        background: rgba(29, 32, 33, 0.9);
      }

      #tags,
      #cpu,
      #memory,
      #disk,
      #clock,
      #keyboard-state label.locked,
      #temperature,
      #custom-kernel,
      #network,
      #pulseaudio,
      #battery,
      #tray {
        padding: 2px 12px;
        margin: 0 4px;
      }

      #tags button {
        color: @fg;
        margin-bottom: 3px;
        padding: 2px 12px;
      }

      #tags button.focused {
        color: @yellow-normal;
      }

      #tags button.active {
        background-color: @bg;
      }

      #tags button.urgent {
        color: @red-normal;
      }

      #cpu {
        color: @red-accent;
      }

      #memory {
        color: @green-accent;
      }

      #disk {
        color: @purple-normal;
      }

      #clock {
        color: @blue-accent;
      }

      #keyboard-state {
        color: @red-accent;
      }

      #temperature {
        color: @yellow-normal;
      }

      #temperature.critical {
        color: @red-normal;
      }

      #custom-kernel {
        color: @purple-normal;
      }

      #network {
        color: @blue-accent;
      }

      #network.ethernet {
        margin-bottom: 3px;
      }

      #pulseaudio {
        color: @fg;
      }

      #battery.warning {
        color: @yellow-normal;
      }

      #battery.critical {
        color: @red-normal;
      }
    '';
  };
}