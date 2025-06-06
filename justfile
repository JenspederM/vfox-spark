TEST_DIR:="~/.version-fox/plugin"
OPENSSL_DIR:="/opt/homebrew/Cellar/openssl@3/3.4.0"

install:
  luarocks install http CRYPTO_DIR={{OPENSSL_DIR}} OPENSSL_DIR={{OPENSSL_DIR}}
  luarocks install luasec OPENSSL_DIR={{OPENSSL_DIR}}


runlib name:
  ./lua ./lib/{{name}}.lua

test VERSION="3.5.3":
  rm -rf {{TEST_DIR}}
  mkdir -p {{TEST_DIR}}
  zip -r -q spark.zip .
  mv spark.zip {{TEST_DIR}}
  vfox add --source {{TEST_DIR}}/spark.zip spark
  # vfox search spark
  -vfox install spark@{{VERSION}}
  vfox use spark@{{VERSION}}
