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

### infra(terraform)

```
#最初だけ
terraform init

# 確認
terraform plan -var-file terraform.tfvars

# 構築
terraform apply -var-file terraform.tfvars

# 削除
terraform destroy -var-file terraform.tfvars
```

### lambda & ecr terraform
 
https://zenn.dev/ikedam/articles/4d0646c8effb1c

https://qiita.com/suzuki-navi/items/47d7093278ee9f4d1147

https://thaim.hatenablog.jp/entry/2021/07/05/081325

https://qiita.com/neruneruo/items/d395fef4929c9486ec0a#ecr

https://qiita.com/hayaosato/items/d6049cf68c84a26845d2

https://qiita.com/wwalpha/items/4a3e4f1f54e896633c01


