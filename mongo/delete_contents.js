import { promises as fs } from "fs";
import * as yaml from "js-yaml";
import { MongoClient } from "mongodb";
import { readdir } from 'fs/promises';
import { join, basename, dirname } from 'path';

// MongoDB の接続文字列とデータベース名を定数として定義
const MONGO_URI = "mongodb://blog_user:blog_pass@mongo:27017";
const DATABASE_NAME = "blog";

async function deleteDocuments() {

    // MongoDBに接続
    const client = new MongoClient(MONGO_URI);

    try {
        await client.connect();
        console.log("Connected to MongoDB");
    
        // データベースとコレクションの指定
        const database = client.db(DATABASE_NAME);
        const collection = database.collection("posts");
            
        // 一括削除処理
        const result = await collection.deleteMany({});
        console.log(`${result.deletedCount} documents were deleted.`);
    
    } catch (error) {
        console.error("Error during delete operation:", error);
    } finally {
        // MongoDBとの接続を閉じる
        await client.close();
        console.log("Connection to MongoDB closed");
    }
}

deleteDocuments();
