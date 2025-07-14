OPENSSL_DIR:="/opt/homebrew/Cellar/openssl@3/3.3.2"
PLUGIN_DIR:="~/.version-fox/plugin/spark"

setup:
    luarocks install luasocket
    luarocks install luasec OPENSSL_DIR={{OPENSSL_DIR}}

sync:
    rm -rf {{PLUGIN_DIR}}
    yes | cp -rf . {{PLUGIN_DIR}}