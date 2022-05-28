import { Route, Routes } from "react-router-dom";

import { Topiclist } from './pages/topiclist/Topiclist.page';
import { TopicDetailPage } from './pages/topic/TopicDetail.page';
import { RegisterPage } from "./pages/register/Register.page";
import { LoginPage } from "./pages/login/Login.page";
import { LoginedLayout } from "./component/LoginedLayout";
import { TopicLayout } from "./component/TopicLayout";

import "./App.css";

export const App = () => {
  return (
    <div id="App">
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
    </div>
  );
}