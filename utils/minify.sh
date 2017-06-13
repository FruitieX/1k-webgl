#!/bin/bash

# install dependencies:
#
# npm install -g mishoo/UglifyJS2\#harmony
# npm install -g glslmin
# npm install -g regpack

rm -rf dist

mkdir -p dist/temp
cp mintemplate.html dist/temp/temp1.html
cd dist

# js src
#uglifyjs ../src/song.js ../src/player.js ../src/index.js | node ../utils/findandreplace.js --template temp/temp1.html --find '{{javascript}}' > temp/temp2.html
# crunch with regpack
echo "uglifying..."
#../node_modules/.bin/uglifyjs -V
#../node_modules/.bin/uglifyjs ../src/index.js \
  #-m \
    #toplevel,eval \
  #-c \
    #toplevel,unsafe,unsafe_comps,unsafe_math,unsafe_proto,unused,dead_code,drop_console \
#> temp/temp1.js

../node_modules/.bin/uglifyjs -V
../node_modules/.bin/uglifyjs ../src/index.js \
  -m \
    toplevel,eval \
> temp/temp1.js

#cp ../src/index.js temp/temp1.js

# vertex shader
echo "minifying vertex shader..."
glslmin ../src/vertex.glsl | node ../utils/findandreplace.js --template temp/temp1.js --find 'require("./vertex.glsl")' --surround '`' > temp/temp2.js

# fragment shader
echo "minifying fragment shader..."
glslmin -m ../src/fragment.glsl | node ../utils/findandreplace.js --template temp/temp2.js --find 'require("./fragment.glsl")' --surround '`' > temp/temp3.js

echo "running regpack..."
node ../node_modules/.bin/regpack temp/temp3.js \
  --useES6 \
  --hashWebGLContext \
  --hashAudioContext \
  --reassignVars \
  --varsNotReassigned false \
  --crushTiebreakerFactor 1 \
  --crushGainFactor 1 \
  --crushLengthFactor 2 \
  --crushCopiesFactor 0 | node ../utils/findandreplace.js --template temp/temp1.html --find '{{javascript}}' > temp/temp.html

cp temp/temp.html index.html

echo "wrote index.html ($(cat index.html | wc -c)b , $(($(cat index.html | wc -c)-1024))b over budget)"
