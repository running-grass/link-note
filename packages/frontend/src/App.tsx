import React, { useEffect, useState } from "react";
import "./App.css";
import {
  useFindTopicsQuery,
  useCreateTopicMutation,
  useFindTopicsLazyQuery,
} from "./generated/graphql";

import { List, Input, AutoComplete } from "antd";

const Option = AutoComplete.Option;
function App() {
  const { data, refetch } = useFindTopicsQuery();
  const [createTopicMutation] = useCreateTopicMutation();

  const [_, { data: optionData, loading: searchLoading, refetch: searchTopics }] =
    useFindTopicsLazyQuery();

  const [prevKeyword, setKeyword] = useState<string>("");

  const onSearch = (keyword: string) => {
    setKeyword(keyword);
    searchTopics({
       search: keyword ,
    });
  };

  const onSelect = async (value:any, obj: { key: string, value: string}) => {
    if (obj.key === 'new') {
      // 创建新主题
      await createTopicMutation({ variables: { title: obj.value} });
      await refetch();
    } else {
      console.log(value);
    }
  };

  const hasEq = optionData?.topics.some((it) => it.title === prevKeyword);
  return (
    <div className="App">
      <AutoComplete
        placeholder="搜索或创建新主题"
        style={{ width: "100%" }}
        onSelect={onSelect}
        onSearch={onSearch}
        onDropdownVisibleChange={open => open ? onSearch(prevKeyword): null}
      >
        {hasEq ? (
          <Option key={"kw" + prevKeyword} value={prevKeyword}>
            {prevKeyword}
          </Option>
        ) : prevKeyword ? (
          <Option key="new" value={prevKeyword}>
            【创建】{prevKeyword}
          </Option>
        ) : // <div>{prevKeyword} 创建一个？</div>
        null}
        {optionData?.topics
          ?.filter((item) => item.title !== prevKeyword)
          .map((item) => (
            <Option key={item?.id} value={item?.title}>
              {item?.title}
            </Option>
          ))}
      </AutoComplete>
      <br />
      <br />
      <List
        bordered
        dataSource={data?.topics ?? []}
        renderItem={(item) => <List.Item>{item?.title}</List.Item>}
      />
    </div>
  );
}

export default App;
