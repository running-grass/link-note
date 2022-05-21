import { KeyHandler } from "hotkeys-js";
import { MutableRefObject } from "react";
import { Options, useHotkeys } from "react-hotkeys-hook";

export enum KEYMAP {
    NAV_PLANT_UP = "shift+up",
    NAV_PLANT_DOWN = "shift+down",
    NAV_LEFT = "shift+left",
    NAV_RIGHT = "shift+right",
  
    NEW_NEXT = "enter",
    NEW_PREV = "cmd+shift+enter",
  
    MOVE_UP = "cmd+shift+up,cmd+shift+p",
    MOVE_DOWN = "cmd+shift+down,cmd+shift+n",
    MOVE_LEFT = "cmd+shift+left,shift+tab",
    MOVE_RIGHT = "cmd+shift+right,tab",
  
    BACKSPACE = "backspace",
  }
  
  
export  const useMultHotkeys = <T extends Element>(
    listens: { [propName: string]: KeyHandler },
    option?: Options,
    deps?: any[]
  ): MutableRefObject<T | null> => {
    const keyListens: { [propName: string]: KeyHandler } = {};
    Object.entries(listens).forEach(([k, v]) => {
      // 把多对一的键绑定拆开
      k.split(",").forEach((k1) => {
        keyListens[k1] = v;
      });
    });
  
    const almost = Object.keys(keyListens).join(",");
  
    return useHotkeys(
      almost,
      (ke, he) => {
        const handler = keyListens[he.key];
        if (handler) {
          handler(ke, he);
        }
      },
      option,
      deps
    );
  };
  