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

cp ../src/index.js temp/temp1.js

# vertex shader
echo "minifying vertex shader..."
glslmin ../src/vertex.glsl | node ../utils/findandreplace.js --template temp/temp1.js --find 'require("./vertex.glsl")' --surround '"' > temp/temp2.js

# fragment shader
echo "minifying fragment shader..."
glslmin -m ../src/fragment.glsl | node ../utils/findandreplace.js --template temp/temp2.js --find 'require("./fragment.glsl")' --surround '"' > temp/temp3.js

echo "uglifying..."

../node_modules/.bin/uglifyjs -V
../node_modules/.bin/uglifyjs temp/temp3.js \
> temp/temp4.js

echo "find and replace..."
sed \
  -e 's/100/1e2/g' \
  -e 's/10/1e1/g' \
  -e 's/3200/32e2/' \
  -e 's/1800/18e2/' \
  temp/temp4.js > temp/temp5.js

echo "running regpack..."
node ../node_modules/.bin/regpack temp/temp5.js \
  --useES6 \
  --hashWebGLContext \
  --hashAudioContext \
  --reassignVars \
  --varsNotReassigned [] \
  --crushTiebreakerFactor 1 \
  --crushGainFactor 1 \
  --crushLengthFactor 1 \
  --crushCopiesFactor 2 | node ../utils/findandreplace.js --template temp/temp1.html --find '{{javascript}}' > temp/temp.html

cp temp/temp.html index.html

echo "wrote index.html ($(cat index.html | wc -c)b , $(($(cat index.html | wc -c)-1024))b over budget)"
