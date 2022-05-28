import { Spin } from "antd";
import { useEffect, useState } from "react";
import { Outlet, useNavigate } from "react-router-dom";
import { useEffectOnce, useLocalStorage } from "react-use";


import { LSK_JWT_TOKEN } from "../cons";
import { GlobalStoreContext } from "../context/globalStore.context";
import { GlobalStore } from "../mobx/Global.store";
import { Aside } from "./Aside";
import { Nav } from "./Nav";

export const LoginedLayout = () => {
  const [accessToken] = useLocalStorage(LSK_JWT_TOKEN);
  const navigator = useNavigate();

  useEffect(() => {
    if (!accessToken) {
      navigator("/login")
    }
  }, [accessToken, navigator])


  const [global, setGlobal] = useState<GlobalStore | null>(null)

  useEffectOnce(() => {
    GlobalStore.of().then(gs => {
      setGlobal(gs)
    })
  })

  if (!global || !accessToken) {
    return <Spin />;
  }


  return (
    <GlobalStoreContext.Provider value={global}>
      <section className="flex flex-row flex-1 bg-pink-50">
        <Aside />
        <section className="flex flex-col flex-1">
          <Nav />
          <main className="flex-1 mt-4 flex flex-col">
            <Outlet />
          </main>
        </section>
      </section>
    </GlobalStoreContext.Provider>
  );
}
