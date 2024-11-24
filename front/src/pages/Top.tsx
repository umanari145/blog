import { Footer } from "../layout/Footer";
import { Header } from "../layout/Header";
import { Sidebar } from "../layout/Sidebar";
import axios from 'axios'
import { useEffect, useState } from "react";
import { Post } from "../class/Post";
import { Pagination } from "../parts/Pagination";
import moment from "moment";

export const Top = () => {

  const [posts, setPosts] = useState<Post[]>([]);
	const [total_pages, setTotalPage] = useState<number>();
	const [current_page, setCurrentPage] = useState<number>();

  useEffect(() => {
    getPosts();
  }, []);

  const getPosts = async () => {
    try {
       const {data, status} = await axios.get(`${process.env.REACT_APP_API_ENDPOINT}/api/`)
      if (status === 200) {

				// dateの値を変換
				const parseItems = (posts:Post[]):Post[] => {
					return posts.map((post:Post) => {
						const parsedDate = new Date(post.post_date);
						return {
							...post,
							date: parsedDate,
						};
					});
				};

				setPosts(parseItems(data.items));
				// たとえばページ読み込み順の関係からこの部分だたのtotal_page=data.total_pagesだと反映されない
				setTotalPage(data.total_pages)
				setCurrentPage(data.current_page)
      }
    } catch (error) {
      console.error('Error fetching data: ', error);
    }
  };

	const handlePageChange = async(page:number) => {
		console.log("クリック" + page)
  };

  return (
    <>
      <Header></Header>
      <div className="container">
				<section className="posts">
					{posts.map((post:Post) => (
					<article className="post">
						<h2 className="post-title">
							<a href={`${process.env.REACT_APP_DOMAIN}/${moment(post.post_date).format('YYYY/MM/DD')}/${post.post_no}`}>{post.title}</a>
						</h2>
						<p className="post-date">{moment(post.post_date).format('YYYY/MM/DD')}</p>
						<p className="post-excerpt">
							{post.contents?.slice(0,200)}
						</p>
					</article>	 
					))}
					<Pagination
        		totalPages={total_pages!}
        		currentPage={current_page!}
        		onPageChange={handlePageChange}
      		/>
				</section>

        <Sidebar></Sidebar>
      </div>
      <Footer></Footer>
    </>
  );
};
