import { config } from "dotenv"
import { resolve } from "path"

config( { path: resolve(__dirname, '../.env'), override: true})
config( { path: resolve(__dirname, '../.env.local'), override: true})

export const configuration = () => (process.env)