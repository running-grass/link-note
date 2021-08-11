
const debug = require('debug')
const path = require('path');
const dotenv = require('dotenv');
const dotenvExpand = require('dotenv-expand');

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