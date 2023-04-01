case "$1" in
  "love")
    pushd tests/love2d > /dev/null 
    ln -s ../../lualoader.lua . > /dev/null
    love .
    rm ./lualoader.lua
    popd
    ;;
esac
