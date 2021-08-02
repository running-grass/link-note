'use strict';

const debug = require('debug')
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const FileManagerWebpackPlugin = require('filemanager-webpack-plugin')
const HardSourceWebpackPlugin = require('hard-source-webpack-plugin')
const dotenv = require('dotenv')
const dotenvExpand = require('dotenv-expand')

function loadEnv(mode) {
  const logger = debug('vue:env')
  const basePath = path.resolve('./', `.env${mode ? `.${mode}` : ``}`)
  const localPath = `${basePath}.local`

  const load = path => {
    try {
      const env = dotenv.config({ path, debug: process.env.DEBUG })
      dotenvExpand(env)
      logger(path, env)
    } catch (err) {
      // only ignore error if file is not found
      if (err.toString().indexOf('ENOENT') < 0) {
        error(err)
      }
    }
  }

  load(localPath);
  load(basePath);
}
// load mode .env
if (process.env.mode) {
    loadEnv(process.env.mode)
}
// load base .env
loadEnv()

const isDebug = process.env.mode === 'development';

const plugins =
  isDebug ? [
    function () {
      this.plugin('done', function (stats) {
        process.stderr.write(stats.toString('errors-only'));
      });
    },
  ] : [
      new FileManagerWebpackPlugin({
        events: {
          onEnd: {
            delete: [
              './release', // 删除之前已经存在的压缩包
            ],
            archive: [
              { source: './dist', destination: './release/web.zip' },
            ]
          }
        }
      }),
    ]
  ;

module.exports = {
  devtool: isDebug ? 'eval-source-map' : 'none',

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
              watch: isDebug,
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
    modules: ['node_modules'],
    extensions: ['.purs', '.js']
  },

  plugins: [
    new HardSourceWebpackPlugin(),
    new webpack.LoaderOptionsPlugin({
      debug: isDebug
    }),
    new HtmlWebpackPlugin({
      title: 'ais',
      template: 'public/index.html',
      inject: false  // See stackoverflow.com/a/38292765/3067181
    }),
  ].concat(plugins)
};
