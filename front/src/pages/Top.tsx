import { Footer } from "../layout/Footer";
import { Header } from "../layout/Header";
import { Sidebar } from "../layout/Sidebar";

export const Top = () => {
  return (
    <>
      <Header></Header>
      <div className="container">
        <section className="posts">
          <article className="post">
            <h2 className="post-title">
              <a href="#">Reactの基礎を学ぶ</a>
            </h2>
            <p className="post-date">2024年11月23日</p>
            <p className="post-excerpt">
              Reactの基本的なコンセプトを解説します。初心者にもわかりやすい内容です。
            </p>
          </article>
          <article className="post">
            <h2 className="post-title">
              <a href="#">CSS Gridでレイアウトを作る</a>
            </h2>
            <p className="post-date">2024年11月20日</p>
            <p className="post-excerpt">
              CSS
              Gridを使って効率的にウェブサイトのレイアウトを構築する方法を紹介します。
            </p>
          </article>
          <article className="post">
            <h2 className="post-title">
              <a href="#">Dockerの基本操作</a>
            </h2>
            <p className="post-date">2024年11月18日</p>
            <p className="post-excerpt">
              Dockerを初めて使う方向けに、基本的な操作を詳しく解説します。
            </p>
          </article>
        </section>
        <Sidebar></Sidebar>
      </div>
      <Footer></Footer>
    </>
  );
};
