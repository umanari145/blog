import { Footer } from "../layout/Footer";
import { Header } from "../layout/Header";
import { Sidebar } from "../layout/Sidebar";
import '../Detail.css'
import axios from 'axios'
import { useEffect, useState } from "react";
import { useParams } from 'react-router-dom'
import { Post } from "../class/Post";
import moment from "moment";

export const Detail = () => {
  const {post_key} = useParams();
  const [post, setPost] = useState<Post>();

  useEffect(() => {
    getPost(post_key);
  }, [post_key]);

  const getPost = async(post_key?:string) => {
    try {
      const {data, status} = await axios.get(`${process.env.REACT_APP_API_ENDPOINT}/api/blogs/${post_key}`)
      if (status === 200) {
        let res_item = JSON.parse(data.body)
        res_item.date = new Date(res_item.post_date)
        console.log(res_item)
        setPost(res_item)
      }
    } catch (error) {
      console.error('Error fetching data: ', error);
    }
  }

  return (
    <>
      <Header></Header>
      <div className="container">
        <article className="post-detail">
          <h1 className="post-title">{post?.title}</h1>
          <p className="post-date">{moment(post?.post_date).format('YYYY年MM月DD日')}</p>
          <div className="post-content" dangerouslySetInnerHTML={{ __html: post?.contents}}></div>
        </article>
        <Sidebar></Sidebar>
      </div>
      <Footer></Footer>
    </>
  );
};
