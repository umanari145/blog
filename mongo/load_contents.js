import { promises as fs } from "fs";
import * as yaml from "js-yaml";
import { MongoClient } from "mongodb";
import { readdir } from 'fs/promises';
import { join, basename, dirname } from 'path';

// MongoDB の接続文字列とデータベース名を定数として定義
const MONGO_URI = "mongodb://blog_user:blog_pass@mongo:27017";
const DATABASE_NAME = "blog";
const rootDirectory = './output/';  // 適切にパスを設定してください
// テスト
//const rootDirectory = './output_test/';  // 適切にパスを設定してください

class LoadPosts {

    paths;

    constructor() {
        this.paths = [];
    }

    loadContents = async(rootDirectory) => {
        await this.findLatestIndexMd(rootDirectory);
        let jsons = [];
        for (let i = 0; i < this.paths.length; i++) {
            const path = this.paths[i];
            const json = await this.convertMarkDownToJson(path);
            jsons.push(json);
            if (jsons.length === 100) {
                this.loadData(jsons);
                jsons = [];
            }
        }
        this.loadData(jsons);
    }

    convertMarkDownToJson = async(filePath) => {
        const fileContents = await fs.readFile(filePath, "utf8");
        const sections = fileContents.split("---").map(section => section.trim());
        const metadata= yaml.load(sections[1]);
        const bodySection = sections[2] || "";
        metadata["body"] = bodySection;
        return metadata;
    }

    async loadData(jsons) {
        const client = new MongoClient(MONGO_URI);
        try {
            await client.connect();
            const db = client.db(DATABASE_NAME);
            await db.collection("posts").insertMany(jsons);
        } catch (err) {
            console.error("エラーが発生しました:", err);
        } finally {
            await client.close();
        }
    }


    async searchDir(currentDir, callback) {
        const entries = await readdir(currentDir, { withFileTypes: true });
        for (const entry of entries) {
            const fullPath = join(currentDir, entry.name);
            if (entry.isDirectory()) {
                await this.searchDir(fullPath, callback);
            } else {
                if (fullPath.indexOf('md') > -1) {
                    this.paths.push(fullPath);
                    await callback(entry, fullPath);
                }
            }
        }
    }

    async  findLatestIndexMd(dir) {
        let latestPath = null;
        const updateLatestFile = async (entry, fullPath) => {
            if (entry.isFile() && entry.name === 'index.md') {
                const dirName = basename(dirname(fullPath));
                latestPath = fullPath;
            }
        };

        await this.searchDir(dir, updateLatestFile);
    }

}

const loadPosts = new LoadPosts();
loadPosts.loadContents(rootDirectory);
