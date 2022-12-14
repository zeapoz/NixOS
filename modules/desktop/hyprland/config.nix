{ config, lib }:
with lib;
let
  cursorCfg = config.home-manager.users.${config.user.name}.home.pointerCursor;
in {
  hyprlandConfig = ''
    monitor=,preferred,auto,1

    # https://wiki.hyprland.org/FAQ/#some-of-my-apps-take-a-really-long-time-to-open
    exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec-once=systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

    # Set mouse cursor.
    exec-once=hyprctl setcursor ${cursorCfg.name} ${
      builtins.toString cursorCfg.size
    }

    input {
      kb_layout=us,se
      ${
        if (config.networking.hostName == "neon") then
          "kb_options=grp:shift_toggle,caps:swapescape"
        else
          "kb_options=grp:shift_toggle"
      }

      repeat_rate=50
      repeat_delay=225

      follow_mouse=1
    }

    general {
      gaps_in=3
      gaps_out=6
      border_size=3

      col.active_border=rgb(bdae93)
      col.inactive_border=rgb(504945)

      layout=dwindle
    }

    decoration {
      rounding=10

      blur=true
      blur_size=3
      blur_new_optimizations=1
    }

    animations {
      enabled=1
      animation=windows,1,2,default
      animation=windows,1,2,default,popin 80%
      animation=border,1,3,default
      animation=fade,1,2,default
      animation=workspaces,1,2,default,fade
    }

    misc {
      disable_hyprland_logo=true
      disable_splash_rendering=true
    }

    binds {
      workspace_back_and_forth=true
    }

    dwindle {
      preserve_split=true
      col.group_border_active=rgb(bdae93)
      col.group_border=rgb(504945)
    }

    master {
      new_is_master=false
    }

    # some nice mouse binds
    bindm=SUPER,mouse:272,movewindow
    bindm=SUPER,mouse:273,resizewindow

    # Useful applications.
    bind=SUPER,RETURN,exec,kitty
    bind=SUPER,D,exec,wofi --show drun -I
    bind=SUPER,X,exec,~/.config/wofi/power-menu.sh
    bind=SUPER,N,exec,${config.modules.editors.mainEditor}
    bind=SUPER,B,exec,librewolf
    bind=SUPER,E,exec,kitty fish -c ranger
    bind=SUPER,S,exec,kitty spt
    bind=SUPER,Y,exec,freetube

    bind=SUPER,W,killactive,
    bind=SUPERSHIFT,E,exit,

    bind=SUPER,F,fullscreen,0
    bind=SUPER,SPACE,togglefloating,

    # Monitors.
    bind=SUPER,COMMA,focusmonitor,l
    bind=SUPER,PERIOD,focusmonitor,r

    bind=ALT,COMMA,movewindow,mon:l
    bind=ALT,PERIOD,movewindow,mon:r

    bind=ALTSHIFT,COMMA,movecurrentworkspacetomonitor,l
    bind=ALTSHIFT,PERIOD,movecurrentworkspacetomonitor,r

    # Layouts.
    bind=SUPER,H,movefocus,l
    bind=SUPER,J,movefocus,d
    bind=SUPER,K,movefocus,u
    bind=SUPER,L,movefocus,r

    bind=ALTSHIFT,H,movewindow,l
    bind=ALTSHIFT,J,movewindow,d
    bind=ALTSHIFT,K,movewindow,u
    bind=ALTSHIFT,L,movewindow,r

    bind=SUPERSHIFT,RETURN,layoutmsg,swapwithmaster
    bind=SUPER,SLASH,togglegroup
    bind=SUPER,SEMICOLON,changegroupactive,b
    bind=SUPER,APOSTROPHE,changegroupactive,f

    # Resize submap.
    bind=SUPER,R,submap,resize
    submap=resize

    binde=,h,resizeactive,-100 0
    binde=,j,resizeactive,0 100
    binde=,k,resizeactive,0 -100
    binde=,l,resizeactive,100 0

    bind=,escape,submap,reset
    bind=,RETURN,submap,reset
    bind=SUPER,R,submap,reset
    submap=reset

    # Workspaces.
    bind=SUPER,u,workspace,1
    bind=SUPER,i,workspace,2
    bind=SUPER,o,workspace,3
    bind=SUPER,p,workspace,4

    bind=ALT,u,movetoworkspace,1
    bind=ALT,i,movetoworkspace,2
    bind=ALT,o,movetoworkspace,3
    bind=ALT,p,movetoworkspace,4

    bind=ALTSHIFT,u,movetoworkspacesilent,1
    bind=ALTSHIFT,i,movetoworkspacesilent,2
    bind=ALTSHIFT,o,movetoworkspacesilent,3
    bind=ALTSHIFT,p,movetoworkspacesilent,4

    bind=SUPER,mouse_down,workspace,e+1
    bind=SUPER,mouse_up,workspace,e-1

    # Volume keys.
    bind=,XF86AudioMute,exec,pactl set-sink-mute @DEFAULT_SINK@ toggle
    bind=,XF86AudioLowerVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ -5%
    bind=,XF86AudioRaiseVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ +5%
    bind=,XF86AudioMicMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle

    # Player controls.
    bind=,XF86AudioPlay,exec,playerctl play-pause
    bind=,XF86AudioStop,exec,playerctl stop
    bind=,XF86AudioNext,exec,playerctl next
    bind=,XF86AudioPrev,exec,playerctl previous

    # Screen backlight.
    bind=,XF86MonBrightnessUp,exec,brightnessctl set 5%+
    bind=,XF86MonBrightnessDown,exec,brightnessctl set 5%-

    # Reload configuration.
    bind=SUPER,C,exec,hyprctl reload

    # Change background.
    bind=SUPERSHIFT,N,exec,killall -q swaybg -9; swaybg -i "$(find ~/Pictures/Wallpapers -type f | shuf -n 1)" -m fill

    # Start some applications in the background.
    exec=~/.config/hypr/autostart.sh
  '';

  autostart = ''
    # Kill applications.
    killall -q .waybar-wrapped -9
    killall -q swaybg -9

    # Start background applications.
    waybar &
    swaybg -i $(find ~/Pictures/Wallpapers -type f | shuf -n 1) -m fill &
  '';
}
