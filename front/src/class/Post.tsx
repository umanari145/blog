export type Post = {
  _id: string;
  title: string;
  contents: string;
  post_no:string;
  categories: string[];
  tags: string[];
  post_date: Date;
};
