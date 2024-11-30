
import os
import json
import re
import urllib
from pymongo import MongoClient
from bson.objectid import ObjectId
from bson import json_util
from aws_lambda_powertools.event_handler import APIGatewayRestResolver

app = APIGatewayRestResolver()

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
        query = check_url(event)
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

def check_url(event):

    pathes = event["path"].split("/")
    query = {}
    where = {}

    print(pathes)
    exit(0)
    if "queryStringParameters" in event:
        query["mode"] = "index"
        if "category" in event["queryStringParameters"]:
            # category
            query["pipeline"] = make_pipeline("categories", "category", event["queryStringParameters"]["category"])
        elif "tag" in event["queryStringParameters"]:
            # tag
            query["pipeline"] = make_pipeline("tags", "post_tag", event["queryStringParameters"]["tag"])
        elif "year" in event["queryStringParameters"] and "month" in event["queryStringParameters"]:
            # 日付
            where["post_date"] = {
                "$regex": f'{event["queryStringParameters"]["year"]}-{event["queryStringParameters"]["month"]}.*' ,
                "$options": "s"
            }
        elif "search_word" in event["queryStringParameters"]:
            # 詳細
            # 実装
            print("実装予定")
    else:
        #topページはここ
        query["mode"] = "index"

    current_page = check_pager(event)
    query["where"] = where
    query["current_page"] = current_page
    print(query)
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

def check_pager(event):
    current_page = 1
    if "queryStringParameters" in event:
        if "page_no" in event["queryStringParameters"]:
            current_page = int(event["queryStringParameters"]["page_no"])
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
        offset = (int(query["current_page"]) - 1) * per_one_page
        if "pipeline" in query:
            blogs = list(collection.aggregate(query["pipeline"]))
        else:
            blogs = list(collection.find(query["where"]).sort("post_date", -1).skip(offset).limit(per_one_page))
        if len(blogs) > 0:
            res = make_response(blogs, query)
            return respond(200, res)
        else:
            return respond(404, {"error": "not found"})
    except Exception as e:
        return respond(500, {"error": str(e)})

def make_response(items, query):
    total_items_count = collection.count_documents(query["where"])
    total_pages = (total_items_count + per_one_page - 1) // per_one_page  # 総ページ数を計算
    # ページに応じた開始・終了インデックスを計算
    start_index = (int(query["current_page"]) - 1) * per_one_page
    
    # 指定範囲のデータを取得
    return {
        "items": items,
        "total_items_count": total_items_count,
        "total_pages": total_pages,
        "current_page": query["current_page"],
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
