import { Footer } from "../layout/Footer";
import { Header } from "../layout/Header";
import { Sidebar } from "../layout/Sidebar";
import '../Detail.css'

export const Detail = () => {
  return (
    <>
      <Header></Header>
      <div className="container">
        <article className="post-detail">
          <h1 className="post-title">Reactの基礎を学ぶ</h1>
          <p className="post-date">2024年11月23日</p>
          <div className="post-content">
            <p>
              ReactはFacebookが開発したJavaScriptライブラリで、シングルページアプリケーションの構築に役立ちます。本記事では、Reactの基本概念、コンポーネント、状態管理について解説します。
            </p>
            <h2>Reactの特徴</h2>
            <p>
              Reactはコンポーネントベースのアプローチを採用しており、再利用可能なコードを効率的に作成できます。また、仮想DOMを使用することで、高速なUIレンダリングが可能です。
            </p>
            <h2>コンポーネントの基本</h2>
            <p>
              Reactでは、UIを小さな部品であるコンポーネントに分割して構築します。以下は簡単な例です：
            </p>
            <pre>
              echo hello world
            </pre>
          </div>
        </article>
        <Sidebar></Sidebar>
      </div>
      <Footer></Footer>
    </>
  );
};
