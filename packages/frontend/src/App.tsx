import React, { useEffect, useState } from 'react';
import './App.css';
import { useFindTopicsQuery, useCreateTopicMutation, useFindTopicsLazyQuery } from './generated/graphql';

import { List,Input } from 'antd'

function App() {
  // const { data, error, loading } = useFindTopicQuery();
  const [findTopics, { data }] = useFindTopicsLazyQuery({
    pollInterval: 500,
  });
  const [createTopicMutation] = useCreateTopicMutation();

  // const [version, setVersion] = useState(0);

  const createTopic = async (ev: React.FormEvent<HTMLInputElement>) => {
    const target = ev.target as HTMLInputElement;
    
    await createTopicMutation({ variables: { title: target.value}});
    // console.log(a)
    await findTopics(); 
    // setVersion(version + 1);
  }

  useEffect(() => {
    findTopics();  
  },[])
  
  return (
    <div className="App">
      <Input placeholder="创建新主题" onPressEnter={createTopic}/>
      <List
        bordered
        dataSource={data?.topics ?? []}
        renderItem={item => (<List.Item>{item?.title}</List.Item>)}
      />
    </div>
  );
}

export default App;
