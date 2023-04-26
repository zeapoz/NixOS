{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.modules.desktop.eww;
in
{
  options.modules.desktop.eww.enable = mkEnableOption "eww";

  config = mkIf cfg.enable {
    hm = {
      packages = with pkgs; [ eww-wayland ];

      configFile = {
        "eww/scripts".source = ../../config/eww/scripts;

        "eww/eww.yuck".text = ''
          (defpoll time :interval "1s" `date +'{"date": "%b %d", "hour": "%H", "minute": "%M", "day": "%a"}'`)
          (defwidget clock []
            (box :space-evenly false :class "clock"
              (label :text " ''${time.day} ''${time.date} ''${time.hour}:''${time.minute}")))

          (defwidget cpu []
            (box :class "cpu" :space-evenly false
              (label :text " ''${round(EWW_CPU.avg, 0)}%")))

          (defwidget ram []
            (box :class "ram" :space-evenly false
              (label :text " ''${round(EWW_RAM.used_mem_perc, 0)}%")))

          (defwidget disk []
            (box :class "disk" :space-evenly false
              (label :text " ''${round(EWW_DISK["/"].used_perc, 0)}%")))

          (deflisten workspace "scripts/workspaces")
          (defwidget workspaces []
            (eventbox
              :onscroll "echo {} | sed -e \"s/up/-1/g\" -e \"s/down/+1/g\" | xargs hyprctl dispatch workspace"
              (box
                :class "workspaces"
                :spacing 5
                (for ws in workspace
                  (button
                    :onclick "hyprctl dispatch workspace ''${ws.number}"
                    :class "workspace icon ''${ws.class}"
                    ; :tooltip {ws.tooltip}
                    "")))))

          (deflisten window :initial "::" "scripts/get-window-title")
          (defwidget window_w []
            (box 
              :space-evenly false
              :class "window"
              (label :text "''${window}")))

          (defpoll kernel :interval "24h" "uname -r")
          (defwidget kernel []
            (box :class "kernel" :space-evenly false
              (label :text " ''${kernel}")))

          (deflisten net "scripts/net")
          (defwidget net []
            (button :class "net"
              :onclick "scripts/net toggle &"
              {net.icon}))

          (deflisten volume "scripts/volume")
          (defwidget volume []
            (box
              :class "volume"
              (eventbox
                :onscroll "echo {} | sed -e 's/up/+/g' -e 's/down/-/g' | xargs -I% wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.005%"
                :onclick "pavucontrol &"
                :onrightclick "scripts/volume mute SINK"
                (label
                  :class "vol-icon"
                  :text "''${volume.icon} ''${volume.percent}%"))))

          (deflisten battery "scripts/battery")
          (defwidget battery []
            (box :class "battery ''${battery.class}"
              (label 
                :text "''${battery.percent}% ''${battery.icon}")))

          (deflisten keyboard_lang "scripts/keyboard")
          (defwidget keyboard []
            (box :class "keyboard" :space-evenly false
              (label :text "''${keyboard_lang}")))

          (defwidget power []
            (eventbox :onclick "wlogout -p layer-shell &"
              (box :class "power"
                (label :text ""))))

          (defwidget left []
            (box :space-evenly false
              (clock)
              (kernel)
            ))

          (defwidget left-box []
            (box :space-evenly false
                 :halign "start"
              (left)
              (workspaces)
            ))

          (defwidget center []
            (box :space-evenly false
                 :halign "center"
              (window_w)))

          (defwidget system []
            (box :space-evenly false
              (cpu)
              (ram)
              (disk)
            ))

          (defwidget right []
            (box :class "right"
                 :space-evenly false
              (net)
              (volume)
              (keyboard)
              ${if config.hardware.hasBattery then "(battery)" else ""}
            ))

          (defwidget right-box []
            (box :space-evenly false
                 :halign "end"
              (system)
              (right)
              (power)
            ))

          (defwidget bar-box []
            (centerbox :class "bar"
              (left-box)
              (center)
              (right-box)))

          (defwindow bar
            :monitor 0
            :geometry (geometry 
              :x "0%"
              :width "100%"
              :anchor "top center")
            :stacking "fg"
            :exclusive true
            (bar-box))
          ${if (config.networking.hostName == "helium") then ''

          (defwindow bar2
            :monitor 1
            :geometry (geometry 
              :x "0%"
              :width "100%"
              :anchor "top center")
            :stacking "fg"
            :exclusive true
            (bar-box))
            ''
          else ""}
        '';

        "eww/eww.scss".text = ''
          $fg: #bbc2cf;
          $bg: #282c34;
          $black: #2a2e38;
          $red: #ff6655;
          $green: #99bb66;
          $yellow: #ECBE7B;
          $blue: #51afef;
          $purple: #c678dd;
          $cyan: #46D9FF;
          $white: #DFDFDF;
          $lightBlack: #3f444a;
          $lightRed: #ff6c6b;
          $lightGreen: #98be65;
          $lightYellow: #ECBE7B;
          $lightBlue: #51afef;
          $lightPurple: #c678dd;
          $lightCyan: #46D9FF;
          $gray: #bbc2cf;

          @mixin margin-right {
            margin-right: 20px;
          }

          @mixin margin-left {
            margin-left: 20px;
          }

          @mixin workspace ($color) {
            &.workspace-focused {
              color: $color;
            }

            &.workspace-unfocused {
              color: transparentize($color, 0.5);
            }
          }

          * {
            all: unset;
            font-family: "FiraCode", "Font Awesome 6 Free";
            font-weight: bold;
            font-size: 14px;
            transition: 200ms ease;
          }

          .bar {
            color: $fg;
            background-color: $bg;
            box-shadow: 0 0 2px 1px rgba(0, 0, 0, 0.3);
          }

          .revealer {
            background-color: $bg;
          }

          .clock {
            color: $blue;
            @include margin-left;
          }

          .cpu {
            color: $lightRed;
            @include margin-right;
          }

          .ram {
            color: $green;
            @include margin-right;
          }

          .disk {
            color: $purple;
            @include margin-right;
          }

          workspaces {
            margin-bottom: 12px;
          }

          .workspace {
            color: transparentize($fg, 0.8);
            padding: 4px 8px;
          }

          .monitor-0 {
            @include workspace ($lightRed);
          }
          .monitor-1 {
            @include workspace ($yellow);
          }
          .monitor-2 {
            @include workspace ($blue);
          }
          .monitor-3 {
            @include workspace ($green);
          }

          .kernel {
            color: $purple;
            @include margin-left;
            @include margin-right;
          }

          .net {
            color: $blue;
            margin: 0 20px 4px 0;
          }

          .volume {
            color: $lightRed;
            @include margin-right;
          }

          .keyboard {
            color: $green;
            ${if config.hardware.hasBattery then "@include margin-right;" else ""}
          }

          .battery {
            @include margin-right;
            padding-top: 4px;
          }

          .battery-low {
            color: $yellow;
          }

          .battery-critical {
            color: $lightRed;
          }

          .power {
            color: $purple;
            @include margin-right;
          }
        '';
      };
    };
  };
}
