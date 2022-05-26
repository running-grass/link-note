import React, { useCallback, useEffect, useState } from "react";
import "./App.css";
import { Link, Outlet, Route, Routes, useNavigate } from "react-router-dom";

import { Topiclist } from './pages/topiclist/Topiclist';
import { TopicDetail } from './pages/topic/TopicDetail';
import { AutoComplete, Divider } from "antd";
import { useCreateTopicMutation, useFindTopicsLazyQuery } from "./generated/graphql";
import { RegisterPage } from "./pages/register/Register.page";
import { LoginPage } from "./pages/login/Login.page";
import { useLocalStorage } from "react-use";
import { LSK_JWT_TOKEN } from "./cons";


const Option = AutoComplete.Option;


function GlobalNav() {
  return <div>我是导航条</div>
}


function LoginLayout() {
  const [accessToken] = useLocalStorage(LSK_JWT_TOKEN);
  const navigator = useNavigate();

  useEffect(() => {
    if (!accessToken) {
      navigator("/login")
    }
  }, [accessToken])

  return (
    <div>
      <GlobalNav />
      <main>
        <Outlet />
      </main>
    </div>
  );
}

function TopicLayout() {

  const [createTopicMutation] = useCreateTopicMutation();

  const [searchTopics, { data }] =
    useFindTopicsLazyQuery();

  // 最后一次search的keyword
  const [prevKeyword, setKeyword] = useState<string>("");

  let navigate = useNavigate();


  const onSearch = (keyword: string) => {
    setKeyword(keyword);
    searchTopics({
      variables: {
        search: keyword,
      }
    });
  };

  const onSelect = async (value: any, obj: { key: string; value: string }) => {

    setKeyword(obj.value);

    if (obj.key === "new") {
      // 创建新主题
      await createTopicMutation({ variables: { title: obj.value } });
    }

    navigate('/topic/' + obj.value);
  };

  const existed = data?.topics.some((it) => it.title === prevKeyword);


  return <div>

    {/* <h1>Welcome to Link Note!</h1> */}

    <AutoComplete
      placeholder="搜索或创建新主题"
      style={{ width: "100%" }}
      onSelect={onSelect}
      onSearch={onSearch}
    // onDropdownVisibleChange={(open) =>
    //   open ? onSearch(prevKeyword) : null
    // }
    >
      {existed ? (
        <Option key={"kw" + prevKeyword} value={prevKeyword}>
          {prevKeyword}
        </Option>
      ) : prevKeyword ? (
        <Option key="new" value={prevKeyword}>
          【创建】{prevKeyword}
        </Option>
      ) : null}

      {data?.topics
        ?.filter((item) => item.title !== prevKeyword)
        .map((item) => (
          <Option key={item?.id} value={item?.title}>
            <Link to={`/topic/${item?.title}`}> {item?.title}</Link>
          </Option>
        ))}
    </AutoComplete>
    <br />
    <br />
    <Outlet />


  </div>
}


export default function App() {
  return (
    <div className="App">
      <Routes>
        <Route path="register" element={<RegisterPage />} />
        <Route path="login" element={<LoginPage />} />

        <Route path="/" element={<LoginLayout />}>
          <Route path="topic" element={<TopicLayout />} >
            <Route index element={<Topiclist />} />
            <Route path=":title" element={<TopicDetail />} />
          </Route>
        </Route>
      </Routes>
    </div>
  );
}
