
import os
import json
import re
from pymongo import MongoClient
from bson.objectid import ObjectId
from bson import json_util

# DocumentDB クライアントの設定
client = MongoClient(os.getenv('DOC_DB_URI'))
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
    if pathes[1] is not None:
        if pathes[1] == "category":
            # category
            where["categories"] = {
                "$in":[pathes[2]]
            }
            query["mode"] = "index"
        elif pathes[1] == "tag":
            # tag
            where["tags"] = {
                "$in":[pathes[2]]
            } 
            query["mode"] = "index"
        elif re.search(r'\d{4}', pathes[1]) and re.search(r'\d{2}', pathes[2]) and pathes[3] == "":
            # 日付
            where["date"] = {
                "$regex": f'{pathes[1]}-{pathes[2]}.*' ,
                "$options": "s"
            }
            query["mode"] = "index"
        elif re.search(r'\d{4}', pathes[1]) and re.search(r'\d{2}', pathes[2]) and re.search(r'\d{2}', pathes[3]) and pathes[4] != "":
            where["date"] = "{0}-{1}-{2}".format(pathes[1], pathes[2], pathes[3])
            where["title"] = pathes[4]
            query["mode"] = "show"
        else:
            #要改造
            query["mode"] = "index"

    current_page = check_pager(pathes)
    query["where"] = where
    query["current_page"] = current_page
    return query

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
        if collection.count_documents(query["where"]) > 0:
            blogs = collection.find(query["where"]).sort("date", -1)
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
        "headers": {
            "Content-Type": "application/json"
        }
    }
