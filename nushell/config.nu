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
