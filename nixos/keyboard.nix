{ pkgs, ... }:

{
  services.xserver = {
    xkb.layout = "us,ua,ru";
    xkb.options = "grp:alt_shift_toggle";
  };

  environment.systemPackages = with pkgs; [
    klavaro
    gtypist
    via
  ];

  # services.kanata = {
  #   enable = true;
  #   keyboards = {
  #     internalKeyboard = {
  #       extraDefCfg = "process-unmapped-keys yes";
  #        config = ''
  #         (defsrc
  #           caps a s d f j k l ; lctl h
  #         )

  #         (defvar
  #           tap-time 200
  #           hold-time 200
  #         )

  #         (defalias
  #           escsuper (tap-hold $tap-time $hold-time esc lmet)
  #           a-mod (tap-hold $tap-time $hold-time a lctl)
  #           s-mod (tap-hold $tap-time $hold-time s lsft)
  #           d-mod (tap-hold $tap-time $hold-time d lalt)
  #           f-mod (tap-hold $tap-time $hold-time f lmet)
  #           j-mod (tap-hold $tap-time $hold-time j rmet)
  #           k-mod (tap-hold $tap-time $hold-time k ralt)
  #           l-mod (tap-hold $tap-time $hold-time l rsft)
  #           ;-mod (tap-hold $tap-time $hold-time ; rctl)
  #           ctrl-h-backpace (tap-hold $tap-time $hold-time lctl (layer-toggle ctrl-h-layer))
  #         )

  #         (deflayer base
  #           @escsuper @a-mod @s-mod @d-mod @f-mod @j-mod @k-mod @l-mod @;-mod @ctrl-h-backpace h
  #         )
  #         (deflayer ctrl-h-layer
  #          _ _ _ _ _ _ _ _ _ _ bspc
  #         )
  #       '';
  #     };
  #   };
  # };
}
