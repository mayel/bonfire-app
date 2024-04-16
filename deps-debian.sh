#!/bin/bash

apt-get update -q -y

# deps
apt-get install -q -y --no-install-recommends git tar file gcc sqlite3 npm mailcap ca-certificates libssl-dev tzdata gettext curl rustc cargo wget gnupg sudo unzip

# deps of tools
apt-get install -q -y --no-install-recommends autoconf dpkg-dev gcc g++ make libncurses-dev unixodbc-dev libssl-dev libsctp-dev libodbc1 libssl1.1 libsctp1 

# NOTE: using mise because bullseye elixir version is too old
curl https://mise.run | sh
PATH="~/.local/share/mise/shims:$PATH"
echo 'export PATH="~/.local/share/mise/shims:$PATH"' >> ~/.bash_profile
mise plugin-add erlang 
mise plugin-add elixir 
mise plugin-add just

mise install

# FYI: uses .tool-versions instead of the below
# which erl || (mise install erlang latest && asdf global erlang latest)
# elixir -v || (asdf install elixir latest && asdf global elixir latest) #|| apt-get install -y elixir
# just --version || (asdf install just latest && asdf global just latest) || cargo install just #|| apt-get install -y just 
# npm install --global yarn

