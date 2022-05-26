import React, {  } from "react";

import { List } from "antd";
import { Link } from "react-router-dom";

import {
  useFindTopicsQuery,
} from "../../generated/graphql";

function TopiclistPage() {
  const { data } = useFindTopicsQuery();
  return (
    <div className="App">
     
      <List
        bordered
        dataSource={data?.topics ?? []}
        renderItem={(item) => (
          <List.Item>
            <Link to={`/topic/${item?.title}`}> {item?.title}</Link>
          </List.Item>
        )}
      />
    </div>
  );
}

export { TopiclistPage as Topiclist };
