import pandas as pd
from jinja2 import Environment, FileSystemLoader

# 入力Excelファイルとテンプレート、出力ファイルの設定
excel_file_path = "api_paths.xlsx"  # Excelファイル名
template_file_path = "template.tf.j2"  # Terraformテンプレートファイル
output_file_path = "apigateway2.tf"  # 出力ファイル名
api_name = "blog_api"
description="skill-up-engineering.comのblog"


# Excelデータを読み込み
df = pd.read_excel(excel_file_path)
# 一瞬で連想配列を作れる
#data_list = df.to_dict(orient='records')

# リソースとメソッドのリスト
resources = []
methods = []
# 親リソースIDをトラッキングする辞書
resource_ids = {"root": "aws_api_gateway_rest_api.example.root_resource_id"}

def make_df_initial(df):
    # pathの分割
    df['pathes'] = df['path'].str.split("/")
    # 最終パスの設定
    df['last_path'] = df['pathes'].apply(lambda x: x[-1] if isinstance(x, list) else None)
    return df

# 親子関係の設定
def find_parent_id(df):
    df['parent_id'] = None
    for i, row in df.iterrows():
        # 現在の行のpathesとlast_pathを取得
        current_pathes = set(row['pathes'])
        last_path = row['last_path']
        # 他の行と比較して親を見つける
        for j, potential_parent in df.iterrows():
            if i != j:  # 自分自身との比較は避ける
                # 親候補のpathesが現在のpathesの部分集合であり、差集合がlast_pathであるか確認
                if current_pathes - set(potential_parent['pathes']) == {last_path}:
                    df.at[i, 'parent_id'] = potential_parent['id']
                    break  # 親が見つかったらループを抜ける
    return df

def make_template_data(df):
    # pathの分割
    df["name"] = df['id'].apply(lambda x: 'api_' + str(x))
    df_with_method = df[df['method'].notna()]
    return df

df = make_df_initial(df)
df = find_parent_id(df)   
df = make_template_data(df)

# nameの作成
df["name"] = df['id'].apply(lambda x: 'api_' + str(x))

# methodのみ
method = df[df['method'].notna()]
method = method.rename(columns={'method': 'http_method', 'id': 'resource_id'})
integrations = method.rename(columns={'name': 'resource_name'})
integrations['method_name'] = integrations.apply(lambda row: "{}_{}".format(row['resource_name'], row['http_method']), axis=1)

# Jinja2テンプレートの読み込み
env = Environment(loader=FileSystemLoader('.'))
template = env.get_template(template_file_path)

# テンプレートにリソースとメソッドのデータを渡してレンダリング
terraform_code = template.render(
    api_name=api_name,
    description=description,
    resources=df.to_dict(orient="records"), 
    methods=method.to_dict(orient="records"),
    integrations=integrations.to_dict(orient="records"),
)

# Terraformファイルに書き出し
with open(output_file_path, "w") as file:
    file.write(terraform_code)

print(f"Terraformファイルが生成されました: {output_file_path}")
