import { customAlphabet } from "nanoid";
import { Guid } from "./type";

export const guidAlphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
export const guidLength = 15

export const guid : () => Guid = customAlphabet(guidAlphabet, guidLength)


