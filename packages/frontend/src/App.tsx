import React from "react";
import "./App.css";
import { Route, Routes } from "react-router-dom";

import Topiclist from './pages/topiclist/Topiclist';
import TopicDetail from './pages/topic/TopicDetail';

export default function App() {
  return (
    <div className="App">
      {/* <h1>Welcome to Link Note!</h1> */}
      <Routes>
        <Route path="/" element={<Topiclist />} />
        <Route path="topic/:title" element={<TopicDetail />} />
      </Routes>
    </div>
  );
}
