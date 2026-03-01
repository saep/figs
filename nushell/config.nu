source keybindings.nu

$env.config = {
  show_banner: false,
  edit_mode: vi,
  history: {
    file_format: 'sqlite',
    max_size: 1000000,
  },
    keybindings: $keybindings
}

# Add today's date in front of the given file name or return the current date
# as a string when no file name is given.
def today [file_name?: string] {
  let date_str: string = (date now | format date "%Y-%m-%d")
  match $file_name {
    null => $date_str
    _ => { $date_str + "_" + $file_name }
  }
}
