import { config } from "dotenv"
import { resolve } from "path"

config( { path: resolve(__dirname, '../.env.local'), override: false})
config( { path: resolve(__dirname, '../.env'), override: false})

console.log(process.env)
export const configuration = () => (process.env)