import { useCallback, useEffect, useState } from "react";
import "./App.css";
import { Link, Outlet, Route, Routes, useNavigate } from "react-router-dom";

import { Topiclist } from './pages/topiclist/Topiclist.page';
import { TopicDetailPage } from './pages/topic/TopicDetail.page';
import { AutoComplete, Menu } from "antd";
import { useCreateTopicMutation, useFindTopicsLazyQuery } from "./generated/graphql";
import { RegisterPage } from "./pages/register/Register.page";
import { LoginPage } from "./pages/login/Login.page";
import { useLocalStorage } from "react-use";
import { LSK_JWT_TOKEN } from "./cons";


const Option = AutoComplete.Option;

function GlobalNav() {
  const navigator = useNavigate();

  const onSelect = useCallback((info: any) => {
    switch (info.key) {
      case 'topic':
        navigator('/topic')
        break
      default:
        navigator('/')
    }
  }, [navigator])


  // >=4.20.0 可用，推荐的写法 ✅
  const items = [
    { label: '主题', key: 'topic' }, // 菜单项务必填写 key
    { label: '文件', key: 'file', disabled: true },
    { label: '图片', key: 'image', disabled: true },
  ];
  return <Menu items={items} mode="horizontal" onSelect={onSelect} theme="light" />;
}


function LoginLayout() {

  const [accessToken] = useLocalStorage(LSK_JWT_TOKEN);
  const navigator = useNavigate();

  useEffect(() => {
    if (!accessToken) {
      navigator("/login")
    }
  }, [accessToken,navigator])
  

  if (!accessToken) return null

  return (
    <section className="flex flex-col flex-1">
      <header>
        <GlobalNav />
      </header>
      <div className="flex-1 mt-4">
        <Outlet />
      </div>
    </section>
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
    <div id="App">
      <Routes>
        <Route path="register" element={<RegisterPage />} />
        <Route path="login" element={<LoginPage />} />

        <Route path="/" element={<LoginLayout />}>
          <Route path="topic" element={<TopicLayout />} >
            <Route index element={<Topiclist />} />
            <Route path=":title" element={<TopicDetailPage />} />
          </Route>
        </Route>
      </Routes>
    </div>
  );
}
