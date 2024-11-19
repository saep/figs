let keybindings = [
      {
        name: broot
        modifier: control
        keycode: char_g
        mode: [emacs, vi_normal, vi_insert]
        event: {
          send: ExecuteHostCommand
          cmd: "br"
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
              commandline edit --insert (
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
                    # Run without existing commandline query for now to test composability
                    # -q (commandline)
                | decode utf-8
                | str trim
              )
            }"
          }
        ]
      }
] 
