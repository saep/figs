# My own color scheme created over a decade ago
{
  color = rec {
    # grouped names for hex colors (inspired by alacritty)
    normal = {
      black = "#1E1E1E";
      white = "#AEAFAD";
      red = "#D16969";
      green = "#579C4C";
      yellow = "#D7BA7D";
      blue = "#124F7B";
      magenta = "#C586C0";
      cyan = "#207FA1";
    };
    bright = {
      black = "#252526";
      white = "#D4D4CF";
      red = "#DB8E73";
      green = "#B5CEA8";
      yellow = "#D9DAA2";
      blue = "#339CDB";
      magenta = "#68217A";
      cyan = "#85DDFF";
    };

    # other color names
    grey = "#777778";
    orange = bright.red;

    background = normal.black;
    foreground = bright.white;

    selectionBackground = bright.blue;
    selectionForeground = bright.red;

    # 16 terminal colors
    #black
    color0 = normal.black;
    color8 = bright.black;
    #red
    color1 = normal.red;
    color9 = bright.red;
    #green
    color2 = normal.green;
    color10 = bright.green;
    #yellow
    color3 = normal.yellow;
    color11 = bright.yellow;
    #blue
    color4 = normal.blue;
    color12 = bright.blue;
    #magenta
    color5 = normal.magenta;
    color13 = bright.magenta;
    #cyan
    color6 = normal.cyan;
    color14 = bright.cyan;
    #white
    color7 = normal.white;
    color15 = bright.white;
  };
}
