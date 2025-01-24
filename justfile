OPENSSL_DIR:="/opt/homebrew/Cellar/openssl@3/3.3.2"

setup:
    luarocks install luasocket
    luarocks install luasec OPENSSL_DIR={{OPENSSL_DIR}}