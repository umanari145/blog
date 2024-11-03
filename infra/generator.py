import pandas as pd
from jinja2 import Environment, FileSystemLoader

# 入力Excelファイルとテンプレート、出力ファイルの設定
excel_file_path = "api_paths.xlsx"  # Excelファイル名
template_file_path = "resource_template.tf.j2"  # Terraformテンプレートファイル
output_file_path = "apigateway.tf"  # 出力ファイル名

# Excelデータを読み込み
data = pd.read_excel(excel_file_path)

# リソースとメソッドのリスト
resources = []
methods = []

# 親リソースIDをトラッキングする辞書
resource_ids = {"root": "aws_api_gateway_rest_api.example.root_resource_id"}

# 各パスを処理
for _, row in data.iterrows():
    path = row['path'].strip("/")
    method = row['method']
    path_parts = path.split("/")

    parent_id_var = "aws_api_gateway_rest_api.example.root_resource_id"
    full_resource_name = "api"

    # パスごとにリソースを作成
    for part in path_parts:
        resource_name = f"{full_resource_name}_{part.replace('{', '').replace('}', '')}"
        
        if resource_name not in resource_ids:
            resources.append({
                "name": resource_name,
                "parent_id": parent_id_var,
                "path_part": part
            })
            resource_ids[resource_name] = f"aws_api_gateway_resource.{resource_name}.id"

        parent_id_var = resource_ids[resource_name]
        full_resource_name = resource_name

    # メソッドが指定されている場合、そのメソッドを追加
    if pd.notna(method):
        methods.append({
            "resource_name": full_resource_name,
            "http_method": method,
            "resource_id": resource_ids[full_resource_name]
        })

# Jinja2テンプレートの読み込み
env = Environment(loader=FileSystemLoader('.'))
template = env.get_template(template_file_path)

# テンプレートにリソースとメソッドのデータを渡してレンダリング
terraform_code = template.render(resources=resources, methods=methods)

# Terraformファイルに書き出し
with open(output_file_path, "w") as file:
    file.write(terraform_code)

print(f"Terraformファイルが生成されました: {output_file_path}")
