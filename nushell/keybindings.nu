def for_modes [modes: list<string>, r: record] {
  $modes | each { |mode| $r | upsert mode $mode }
}

let keybindings = [
      (for_modes [vi_insert vi_normal] {
        name: broot
        modifier: control
        keycode: char_g
        event: {
          send: executehostcommand,
          cmd: "br"
        }
      })
] | flatten
