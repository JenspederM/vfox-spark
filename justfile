TEST_DIR:="~/.version-fox/plugin"

runlib name:
  ./lua ./lib/{{name}}.lua

test:
  rm -rf {{TEST_DIR}}
  mkdir -p {{TEST_DIR}}
  cp -r . {{TEST_DIR}}
