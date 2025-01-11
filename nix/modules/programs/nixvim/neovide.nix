{
  programs.nixvim = {
    globals = {
      neovide_cursor_trail_size = 0.1;
      neovide_cursor_animation_length = 0.07;
      neovide_position_animation_length = 0.07;
      neovide_input_macos_option_key_is_meta = "only_left";
      neovide_floating_corner_radius = 0.0;

      # # disable animations
      # neovide_position_animation_length = 0;
      # neovide_cursor_animation_length = 0.00;
      # neovide_cursor_trail_size = 0;
      # neovide_cursor_animate_in_insert_mode = false;
      # neovide_cursor_animate_command_line = false;
      # neovide_scroll_animation_far_lines = 0;
      # neovide_scroll_animation_length = 0.00;
    };
  };
}
