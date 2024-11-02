# blog


## ディレクトリ構成
- app・・API部分(lambda)
- docker・・Dockerファイル
- front・・フロントエンド(react)
- infra・・インフラ(terraform)
- mongo・・mongo


### mongoのdbのセットアップ

- init/createDB.js データベースやユーザー作成
- output ブログデータ
- output_test ブログテストデータ
- load_contents.js データ読み込み
- delete_contents.js データ全削除

```
docker exec -it blog_node sh

cd /app/mongo
# テーブル定義
node init/createDB.js 

#メッセージ
Connected to MongoDB
User 'blog_user' created for database 'blog'
Collection 'posts' created in database 'blog'
Connection to MongoDB closed

# データ読み込み
node load_contents.js

# データ全削除
node delete_contents.js

```

### app(lambda)

https://www.distant-view.co.jp/column/6484/<br>
https://qiita.com/eiji-noguchi/items/e226ed7b8da2cd85a06a


ローカルデバッグ
```
cd /root
# -t timeout・・秒数　-e 環境変数
python-lambda-local -f handler lambda_function.py event/(イベントファイル名).json -e env.json -t 10
```

