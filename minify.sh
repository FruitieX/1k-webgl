#!/bin/bash

# install dependencies:
#
# npm install -g mishoo/UglifyJS2\#harmony
# npm install -g glslmin

rm -rf dist

mkdir -p dist/temp
cp mintemplate.html dist/temp/temp1.html
cd dist

# js src
uglifyjs ../src/song.js ../src/player.js ../src/index.js | node ../utils/findandreplace.js --template temp/temp1.html --find '{{javascript}}' > temp/temp2.html

# vertex shader
glslmin ../src/vertex.glsl | node ../utils/findandreplace.js --template temp/temp2.html --find 'require("./vertex.glsl")' --surround '`' > temp/temp3.html
#cat ../src/vertex.glsl | node ../utils/findandreplace.js --template temp/temp2.html --find 'require("./vertex.glsl")' --surround '`' > temp/temp3.html

# fragment shader
glslmin -m ../src/fragment.glsl | node ../utils/findandreplace.js --template temp/temp3.html --find 'require("./fragment.glsl")' --surround '`' > temp/temp4.html
#cat ../src/fragment.glsl | node ../utils/findandreplace.js --template temp/temp3.html --find 'require("./fragment.glsl")' --surround '`' > temp/temp4.html

cp temp/temp4.html index.html

echo "wrote index.html ($(cat index.html | wc -c) bytes)"
