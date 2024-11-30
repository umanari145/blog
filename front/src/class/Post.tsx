export type Post = {
  _id: string;
  title: string;
  // dangerouslySetInnerHTMLでTrustedHTMLに適用するためにanyにしておく
  contents: any;
  post_no:string;
  categories: string[];
  tags: string[];
  post_date: Date;
};
