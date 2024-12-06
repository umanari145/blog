# blog


## ディレクトリ構成
- .github/workflows・・ecrへのプッシュ
- app・・API部分(lambda)
- docker・・Dockerファイル
- front・・フロントエンド(react)
- infra・・インフラ(terraform)
- mongo・・mongo

### GitHubActions

- CI/CDのワークフロー
    1. mainブランチへのマージ
    2. ECRにログイン
    3. ImageのPush
    4. Lambdaの更新
### front

- public・・成果物が展開される
- src・・実際のreactのソースが入っている
    - class・・型
    - layout・・htmlのパーツ
    - pages・・routeから飛んできた時のページ
    - parts・・Paginationなどのhtmlのパーツ
    - App.tsx・・エントリーポイント

プロジェクトスタート
```
docker exec -it blog_node sh
pwd /app
# プロジェクトの作成
npx create-react-app front --template typescript
frontディレクトリ以下にプロジェクト作られる
cd front
npm start ここでホットリロードができる

http://localhost:3000/ でアクセスできる
```

### infra
- api_paths.xlsx・・APIGatewayのパス情報をここから展開
- apigateway.tf・・APIGatewayのtfファイル
- ecr_build.sh・・ECRの構築とイメージのpush。`bash ecr_builds.sh`でECR作成とコンテナイメージのpush
- generator.py・・apigateway.tfを作成するためのツール　コンテナ内で以下コマンドで`cd /app/infra && python generator.py`でtfファイル作成
- lambda.tf・・lambdaのtfファイル
- provider.tf・・providerの設定ファイル
- template.tf.j2・・generatorのtemplate。ここをgeneratorはここを経由してtfファイルを作成する
- terraform.tfstate・・terraformの状態 
- terraform.tfstate.backup・・terraformの状態(backup)
- terraform.tfvars.dummy・・terraformの変数(dummyがない方の拡張子が実際の値)
- variables.tf・・terraform内で使う変数の定義
- aws_configure.txt.default・・awsの設定情報。ecr_build.shで使用(.defautがない方の拡張子が実施の値)

#### 実際の構築コマンド

1. `bash ecr_build`
2. `terraform apply -var-file terraform.tfvars` で構築
3. 構築後は`.github/workflows/deploy.yml`で更新が走る

### mongoのdbのセットアップ

- init/createDB.js データベースやユーザー作成
- output ブログデータ
- output_test ブログテストデータ
- convet_contents.js データ読み込みとmongoへの直投入
- load_contents.js データ読み込み(markdownからの読み込み)
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
### mongodbの実環境

- ドキュメント型のデータベース
- JSONをそのままの形式で保存できる
- RDBに比べて低コスト
- トランザクションがない&複雑なJOINが難しい
- 拡張性が容易でデータ増加に強い

https://www.mongodb.com/ja-jp

MFA搭載(emailにワンタイムトークン)

#### アクセス制限

「Security」→「Network Access」→「IP Access List」でIPアドレス制限をかけられる

### app(lambda)

- サーバーレスのFaaS
- 短時間のバッチやAPIなど

ライブラリ
- pymongo・・mongoDBとpythonを繋ぐライブラリ
- aws_lambda_powertools.event_handler・・routingが便利

https://www.distant-view.co.jp/column/6484/<br>
https://qiita.com/eiji-noguchi/items/e226ed7b8da2cd85a06a


ローカルデバッグ
```
# -f function・・軌道関数
# -e environment・・環境変数
# -t timeout・・秒数　-e 環境変数
python-lambda-local -f handler lambda_function.py event/****.json -e env.json -t 10
```

テスト
```
docker exec -it blog_python_lambda bash
python lambda_function_test.py 
```


### infra(terraform)

- dockerbuild.sh ecrのnull_resourceがあるためpushがされる
- lambda.tf

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


terraform import<br>
すでに既存にリソースがある場合<br>
terraform import (terraforのりソースの種類).(terraformのリソース名) リソースのID、名前などの何らかのユニーク情報
```
terraform import aws_cloudwatch_log_group.log_group :/aws/lambda/blogLambdaFunction:
```
https://zenn.dev/yumainaura/articles/qiita-2023-09-15t13_31_48-09_00

## 環境変数登録(GithubActions)
```
gh auth login
gh secret set AWS_ACCOUNT_ID --body "$AWS_ACCOUNT_ID" --repo umanari145/blog
gh secret set AWS_ACCESS_KEY_ID --body "$AWS_ACCESS_KEY_ID" --repo umanari145/blog
gh secret set AWS_SECRET_ACCESS_KEY --body "$AWS_SECRET_ACCESS_KEY" --repo umanari145/blog
gh secret set AWS_REGION --body "$AWS_REGION" --repo umanari145/blog
```