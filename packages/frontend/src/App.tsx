import React from 'react';
import logo from './logo.svg';
import './App.css';
import { useTopicQuery } from './generated/graphql';


function App() {
  const { data, error, loading } = useTopicQuery();

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload. learn react
        </p>
        <ul>
          topic.title = { data?.topic?.title }
        </ul>

        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
