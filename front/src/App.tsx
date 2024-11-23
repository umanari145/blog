import React from 'react';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src="./head_capture.jpg" className="App-logo" alt="https://skill-up-engineering.com/" />
      </header>
      <div className="container">
        <section className="posts">
          <article className="post">
            <h2 className="post-title"><a href="#">Reactの基礎を学ぶ</a></h2>
            <p className="post-date">2024年11月23日</p>
            <p className="post-excerpt">Reactの基本的なコンセプトを解説します。初心者にもわかりやすい内容です。</p>
          </article>
          <article className="post">
            <h2 className="post-title"><a href="#">CSS Gridでレイアウトを作る</a></h2>
            <p className="post-date">2024年11月20日</p>
            <p className="post-excerpt">CSS Gridを使って効率的にウェブサイトのレイアウトを構築する方法を紹介します。</p>
          </article>
          <article className="post">
            <h2 className="post-title"><a href="#">Dockerの基本操作</a></h2>
            <p className="post-date">2024年11月18日</p>
            <p className="post-excerpt">Dockerを初めて使う方向けに、基本的な操作を詳しく解説します。</p>
          </article>
        </section>
        <aside className="sidebar">
          <section className="widget">
            <h2 className="widget-title">Category</h2>
            <ul className="widget-list">
              <li><a href="#">JavaScript</a></li>
              <li><a href="#">React</a></li>
              <li><a href="#">CSS</a></li>
              <li><a href="#">Docker</a></li>
              <li><a href="#">AWS</a></li>
            </ul>
          </section>

          <section className="widget">
            <h2 className="widget-title">Archive</h2>
            <ul className="widget-list">
              <li><a href="#">2024年11月</a></li>
              <li><a href="#">2024年10月</a></li>
              <li><a href="#">2024年9月</a></li>
              <li><a href="#">2024年8月</a></li>
            </ul>
          </section>
        </aside>
      </div>
      <footer className="footer">
        <div className="container">
          <p>&copy; 2024 技術ブログ. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}

export default App;
