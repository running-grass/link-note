'use strict';

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const FileManagerWebpackPlugin = require('filemanager-webpack-plugin')
const HardSourceWebpackPlugin = require('hard-source-webpack-plugin')


const isWebpackDevServer = process.argv.some(a => path.basename(a) === 'webpack-dev-server');
const isWatch = process.argv.some(a => a === '--watch');

const plugins =
  isWebpackDevServer || !isWatch ? [] : [
    function(){
      this.plugin('done', function(stats){
        process.stderr.write(stats.toString('errors-only'));
      });
    }
  ]
;

module.exports = {
  devtool: 'eval-source-map',

  devServer: {
    // noInfo: true,
    open: true,
    contentBase: path.resolve(__dirname, 'dist'),
    port: 4008,
    stats: 'errors-only'
  },

  entry: './src/index.js',

  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },

  module: {
    rules: [
      {
        test: /\.m?js$/,
        exclude: {
          // and: [/node_modules/],
          or: [/node_modules/],
          not: [/ipfs-http-client/],
        },
        // include: /node_modules\/ipfs-http-client/,
        use: ['cache-loader', 'babel-loader'],

        // use: {
        //   loader: "babel-loader",
        // }
      },
      {
        test: /\.purs$/,
        use: [
          "cache-loader",
          {
            loader: 'purs-loader',
            options: {
              src: [
                'src/**/*.purs'
              ],
              spago: true,
              watch: isWebpackDevServer || isWatch,
              pscIde: true
            }
          }
        ]
      },
      {
        test: /\.(png|jpg|gif)$/i,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 8192,
            },
          },
        ],
      },
    ]
  },

  resolve: {
    modules: [ 'node_modules' ],
    extensions: [ '.purs', '.js']
  },

  plugins: [
    new HardSourceWebpackPlugin(),
    new webpack.LoaderOptionsPlugin({
      debug: true
    }),
    new HtmlWebpackPlugin({
      title: 'ais',
      template: 'public/index.html',
      inject: false  // See stackoverflow.com/a/38292765/3067181
    }),
    new FileManagerWebpackPlugin ({ events: { 
      onEnd: {
         delete: [
              './release', // 删除之前已经存在的压缩包
          ],
         archive: [
              { source: './dist', destination: './release/web.zip'},
          ]
      }
    }}),
  ].concat(plugins)
};
