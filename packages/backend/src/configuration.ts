import { config } from "dotenv"
import { resolve } from "path"

// 这里会处理各种的配置变量
// 包括cross-env的、.env文件的，PATH中的

const nodeEnv = process.env.NODE_ENV;

config( { path: resolve(__dirname, `../.env.${nodeEnv}.local`), override: false})
config( { path: resolve(__dirname, `../.env.${nodeEnv}`), override: false})

config( { path: resolve(__dirname, '../.env.local'), override: false})
config( { path: resolve(__dirname, '../.env'), override: false})

export const configuration = () => (process.env)