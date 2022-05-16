import React, { useState } from "react";

import { List, AutoComplete } from "antd";
import { Link, Route, Routes } from "react-router-dom";

import {
    useFindTopicsQuery,
    useCreateTopicMutation,
    useFindTopicsLazyQuery,
  } from "../../generated/graphql";

  
const Option = AutoComplete.Option;
function Topiclist() {
  const { data, refetch: refetchTopicList } = useFindTopicsQuery();
  const [createTopicMutation] = useCreateTopicMutation();

  const [, { data: optionData, refetch: searchTopics }] =
    useFindTopicsLazyQuery();

  // 最后一次search的keyword
  const [prevKeyword, setKeyword] = useState<string>("");

  const onSearch = (keyword: string) => {
    setKeyword(keyword);
    searchTopics({
      search: keyword,
    });
  };

  const onSelect = async (value: any, obj: { key: string; value: string }) => {
    if (obj.key === "new") {
      // 创建新主题
      await createTopicMutation({ variables: { title: obj.value } });
      // 刷新列表
      await refetchTopicList();
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
        onDropdownVisibleChange={(open) =>
          open ? onSearch(prevKeyword) : null
        }
      >
        {hasEq ? (
          <Option key={"kw" + prevKeyword} value={prevKeyword}>
            {prevKeyword}
          </Option>
        ) : prevKeyword ? (
          <Option key="new" value={prevKeyword}>
            【创建】{prevKeyword}
          </Option>
        ) : null}
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
        renderItem={(item) => <List.Item><Link to={`/topic/${item?.title}`}> {item?.title}</Link></List.Item>}
      />
    </div>
  );
}

export default Topiclist;
