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
] 
