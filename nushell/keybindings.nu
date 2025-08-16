let keybindings = [
      {
        name: "cut to end"
        modifier: control
        keycode: char_k
        mode: [emacs, vi_insert]
        event: {
          edit: CutToEnd
        }
      }
      {
        name: fuzzy_history
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
            send: ExecuteHostCommand
            cmd: "do {
              commandline edit --replace (
                history
                | get command
                | reverse
                | uniq
                | str join (char -i 0)
                | fzf --scheme=history 
                    --read0
                    --layout=reverse
                    --height=40%
                    --bind 'ctrl-/:change-preview-window(right,70%|right)'
                    -q (commandline)
                | decode utf-8
                | str trim
              )
            }"
          }
        ]
      }
      {
        name: fuzzy_directory
        modifier: alt
        keycode: char_c
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
            send: ExecuteHostCommand
            cmd: "
              let fzf_alt_c_command = \$\"($env.FZF_ALT_C_COMMAND) | fzf ($env.FZF_ALT_C_OPTS)\";
              let result = nu -c $fzf_alt_c_command;
              cd $result;
            "
          }
        ]
      }
      {
        name: fuzzy_file
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: [
          {
            send: ExecuteHostCommand
            cmd: "
              let fzf_ctrl_t_command = \$\"($env.FZF_CTRL_T_COMMAND) | fzf ($env.FZF_CTRL_T_OPTS)\";
              let result = nu -c $fzf_ctrl_t_command;
              commandline edit --insert $result
            "
          }
        ]
      }
] 
