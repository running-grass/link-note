import { useState } from "react";
import { Route, Routes } from "react-router-dom";

import { Topiclist } from './pages/topiclist/Topiclist.page';
import { TopicDetailPage } from './pages/topic/TopicDetail.page';
import { Spin } from "antd";
import { RegisterPage } from "./pages/register/Register.page";
import { LoginPage } from "./pages/login/Login.page";
import { useEffectOnce } from "react-use";
import { GlobalStore } from "./mobx/Global.store";
import { observer } from "mobx-react";
import { GlobalStoreContext } from "./context/globalStore.context";
import { LoginedLayout } from "./component/LoginedLayout";
import { TopicLayout } from "./component/TopicLayout";

import "./App.css";

export const App = observer(() => {
  const [global, setGlobal] = useState<GlobalStore | null>(null)

  useEffectOnce(() => {
    GlobalStore.of().then(gs => {
      setGlobal(gs)
    })
  })

  if (!global) {
    return <Spin />;
  }

  return (
    <div id="App">
      <GlobalStoreContext.Provider value={global}>
        <Routes>
          <Route path="register" element={<RegisterPage />} />
          <Route path="login" element={<LoginPage />} />

          <Route path="/" element={<LoginedLayout />}>
            <Route path="topic" element={<TopicLayout />} >
              <Route index element={<Topiclist />} />
              <Route path=":title" element={<TopicDetailPage />} />
            </Route>
          </Route>
        </Routes>
      </GlobalStoreContext.Provider>
    </div>
  );
})
