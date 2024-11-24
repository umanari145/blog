export const Sidebar = () => {
  return (
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
  );
};