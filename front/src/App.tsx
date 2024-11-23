import { Routes, Route, BrowserRouter } from 'react-router-dom';
import './App.css';
import { Detail } from './pages/Detail';
import { Top } from './pages/Top';

function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path="/" Component={Top} />
          <Route path="/detail" Component={Detail} />
        </Routes>
      </BrowserRouter>            
    </div>
  );
}

export default App;
