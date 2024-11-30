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

  const getPosts = async (page_no?:number) => {
    let page_no_query = page_no ? `?page_no=${page_no}` : ""

    try {
       const {data, status} = await axios.get(`${process.env.REACT_APP_API_ENDPOINT}/api/blogs${page_no_query}`)
      if (status === 200) {
		  	let res_items = JSON.parse(data.body)
				// dateの値を変換
				const parseItems = (posts:Post[]):Post[] => {
					return posts.map((post:Post) => {
						const parsedDate = new Date(post.post_date);
						return {
							...post,
              contents: post.contents?.slice(0, 100),
							date: parsedDate,
						};
					});
				};
				setPosts(parseItems(res_items.items));
				// たとえばページ読み込み順の関係からこの部分だたのtotal_page=data.total_pagesだと反映されない
				setTotalPage(parseInt(res_items.total_pages))
				setCurrentPage(parseInt(res_items.current_page))
      }
    } catch (error) {
      console.error('Error fetching data: ', error);
    }
  };

	const handlePageChange = async(page:number) => {
    getPosts(page)
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
						<p className="post-excerpt" dangerouslySetInnerHTML={{ __html: post?.contents}}>
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
