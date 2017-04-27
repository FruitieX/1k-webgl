const { resolve } = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
module.exports = {
  entry: './src/index.js',
  output: {
    path: resolve(__dirname, './dist'),
  },
  module: {
    rules: [
      { test: /\.glsl$/, use: [{ loader: 'webpack-glsl-loader' }] },
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './index.html'
    })
  ]
};
