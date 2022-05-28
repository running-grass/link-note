import { createContext } from "react";
import { GlobalStore } from "../mobx/Global.store";

export const GlobalStoreContext = createContext<GlobalStore | null>(null)
