import React, { useState } from "react";
import "./App.css";
import { Link, Route, Routes, useNavigate } from "react-router-dom";

import { Topiclist } from './pages/topiclist/Topiclist';
import { TopicDetail } from './pages/topic/TopicDetail';
import { AutoComplete } from "antd";
import { useCreateTopicMutation, useFindTopicsLazyQuery } from "./generated/graphql";


const Option = AutoComplete.Option;


export default function App() {
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

    navigate('/topic/'+obj.value);
  };

  const existed = data?.topics.some((it) => it.title === prevKeyword);
  
  return (
    <div className="App">
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
      
      <Routes>
        <Route path="/" element={<Topiclist />} />
        <Route path="topic/:title" element={<TopicDetail />} />
      </Routes>
    </div>
  );
}
