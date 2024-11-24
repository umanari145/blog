
import os
import json
import re
import urllib
from pymongo import MongoClient
from bson.objectid import ObjectId
from bson import json_util

# DocumentDB クライアントの設定
doc_db_user = urllib.parse.quote_plus(os.getenv('DOC_DB_USER'))
doc_db_pass = urllib.parse.quote_plus(os.getenv('DOC_DB_PASS'))
url = 'mongodb+srv://%s:%s@skill-up-engineering.q3kqc.mongodb.net/' % (doc_db_user, doc_db_pass)
client = MongoClient(url)
db = client["blog"] #DB名を設定
collection = db.get_collection("posts")
per_one_page = 10

def handler(event, context):
    method = event['httpMethod']
    if method == 'GET':
        query = check_url(event["path"])
        if  query["mode"] == "show":
            return get_blog(query)
        elif query["mode"] == "index":
            return get_blogs(query)
    #elif method == 'POST':
    #    return create_blog(event)
    #elif method == 'PUT':
    #    return update_blog(blog_id, event)
    #elif method == 'DELETE':
    #    return delete_blog(blog_id)
    else:
        return respond(405, {"error": "Method Not Allowed"})

def check_url(path):

    pathes = path.split("/")
    query = {}
    where = {}
    start_path_index = int(os.getenv('START_PATH_INDEX'))
    if pathes[start_path_index] is not None:
        if pathes[start_path_index] == "category":
            # category
            query["pipeline"] = make_pipeline("categories", "category", pathes[start_path_index+1])
            query["mode"] = "index"
        elif pathes[start_path_index] == "tag":
            # tag
            query["pipeline"] = make_pipeline("tags", "post_tag", pathes[start_path_index+1])
            query["mode"] = "index"
        elif re.search(r'\d{4}', pathes[start_path_index]) and re.search(r'\d{2}', pathes[start_path_index+1]) and pathes[start_path_index+2] == "":
            # 日付
            where["post_date"] = {
                "$regex": f'{pathes[start_path_index]}-{pathes[start_path_index+1]}.*' ,
                "$options": "s"
            }
            query["mode"] = "index"
        elif re.search(r'\d{4}', pathes[start_path_index]) and re.search(r'\d{2}', pathes[start_path_index+1]) and re.search(r'\d{2}', pathes[start_path_index+2]) and pathes[start_path_index+3] != "":
            # 詳細
            where["post_date"] = "{0}-{1}-{2}".format(pathes[start_path_index], pathes[start_path_index+1], pathes[start_path_index+2])
            where["$or"] = [
                { "title": pathes[start_path_index+3]},
                { "post_no": pathes[start_path_index+3]}
            ]
            query["mode"] = "show"
        else:
            #要改造
            query["mode"] = "index"

    current_page = check_pager(pathes)
    query["where"] = where
    print(query)
    query["current_page"] = current_page
    return query

def make_pipeline(taxonomy_type, taxonomy_key, keyword):
    return [
        {
            "$lookup": {
                "from": "labels",
                "localField": taxonomy_type,
                "foreignField": "no",
                "as": "details"
            }
        },
        {
            "$match": {
                "details.name": keyword,
                "details.type": taxonomy_key
            }
        },
        {
            "$sort": {
                "post_date": -1
            }
        }
    ]

def check_pager(pathes):
    current_page = 1
    for i in range(len(pathes)):
        if pathes[i] == "page" and pathes[i+1].isdigit():
            # sqlのoffset
            current_page = pathes[i+1]
            break

    return current_page  


def get_blog(query):
    try:
        blog = collection.find_one(query["where"])
        if blog:
            return respond(200, blog)
        else:
            return respond(404, {"error": "not found"})
    except Exception as e:
        return respond(500, {"error": str(e)})

def get_blogs(query):    
    try:
        if "pipeline" in query:
            blogs = list(collection.aggregate(query["pipeline"]))
        else:
            blogs = list(collection.find(query["where"]).sort("post_date", -1))
        if len(blogs) > 0:
            res = get_contents_inc_page(list(blogs), query["current_page"])
            return respond(200, res)
        else:
            return respond(404, {"error": "not found"})
    except Exception as e:
        return respond(500, {"error": str(e)})        

def get_contents_inc_page(items, current_page):
    total_items_count = len(items)
    total_pages = (total_items_count + per_one_page - 1) // per_one_page  # 総ページ数を計算
    # 指定ページが範囲内にあるかチェック
    if int(current_page) < 1 or int(current_page) > int(total_pages):
        raise Error("不正なページ遷移です。")
    # ページに応じた開始・終了インデックスを計算
    start_index = (int(current_page) - 1) * per_one_page
    end_index = start_index + per_one_page

    # 指定範囲のデータを取得
    return {
        "items": items[start_index:end_index],
        "total_items_count": total_items_count,
        "total_pages": total_pages,
        "current_page": current_page,
        "per_one_page": per_one_page
    }

def create_blog(event):
    try:
        data = json.loads(event['body'])
        result = collection.insert_one(data)
        data['_id'] = str(result.inserted_id)
        return respond(201, {"message": "Blog created", "data": data})
    except Exception as e:
        return respond(500, {"error": str(e)})

def update_blog(blog_id, event):
    try:
        data = json.loads(event['body'])
        result = collection.update_one(
            {"_id": blog_id},
            {"$set": data}
        )
        if result.matched_count == 0:
            return respond(404, {"error": "Blog not found"})
        return respond(200, {"message": "Blog updated"})
    except Exception as e:
        return respond(500, {"error": str(e)})

def delete_blog(blog_id):
    try:
        result = collection.delete_one({"_id": blog_id})
        if result.deleted_count == 0:
            return respond(404, {"error": "Blog not found"})
        return respond(200, {"message": "Blog deleted"})
    except Exception as e:
        return respond(500, {"error": str(e)})

def respond(status_code, body):
    return {
        "statusCode": status_code,
        "body": json.dumps(body, default=json_util.default, ensure_ascii=False),
        'headers': {
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Origin":"*",
            "Access-Control-Allow-Methods":"OPTIONS,POST,GET,PUT,DELETE"
        },
    }
