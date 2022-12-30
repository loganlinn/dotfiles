{ ... }:

{
  services.yabai = {
    enable = false;
    enableScriptingAddition = false;
    config = {
      debug_output = "on";
      focus_follows_mouse = "autoraise";
      mouse_follows_focus = "off";

      top_padding    = 10;
      bottom_padding = 10;
      left_padding   = 10;
      right_padding  = 10;
      window_gap     = 10;
      window_placement    = "second_child";
      window_opacity      = "off";

      mouse_modifier = "ctrl";
      mouse_action1 = "move";
      mouse_action2 = "resize";
    };
    # extraConfig = "";
  };
}
