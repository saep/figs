# saep's configs

## Installation

Configuration files managed with
[home-manager](https://github.com/nix-community/home-manager).

To build the home manager configuration for the user `saep` on the computer
`monoid`:

``` bash
./config build monoid saep
```

The [config.sh](./config.sh) scripts tries to automatically detect the username
and hostname, so no arguments are required for me.

The configuration can be installed by running `result/activate` or by passing
`install` as the first paraemter to [config.sh](./config.sh).
