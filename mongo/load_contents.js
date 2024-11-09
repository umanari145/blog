import { promises as fs } from "fs";
import * as yaml from "js-yaml";
//import { MongoClient } from "mongodb";
import { readdir } from 'fs/promises';
import { join, basename, dirname} from 'path';
import path from 'path';
import { fileURLToPath } from 'url';
import { dir } from "console";
import { exit } from "process";

// MongoDB の接続文字列とデータベース名を定数として定義
//const MONGO_URI = "mongodb://blog_user:blog_pass@mongo:27017";
//const DATABASE_NAME = "blog";
//const rootDirectory = './output/';  // 適切にパスを設定してください
// テスト
const rootDirectory = './output/';  // 適切にパスを設定してください
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
class LoadPosts {

    paths;

    constructor() {
        this.paths = [];
    }

    loadContents = async(rootDirectory) => {
        await this.findLatestIndexMd(rootDirectory);
        let items = [];
        for (let i = 0; i < this.paths.length; i++) {
            const path = this.paths[i];
            const item = await this.convertMarkDownToJson(path);
            items.push(item);
            if (items.length === 100) {
                this.loadData(items);
                items = [];
            }
        }
        this.loadData(items);
    }

    convertMarkDownToJson = async(filePath) => {
        const fileContents = await fs.readFile(filePath, "utf8");
        const sections = fileContents.split("---").map(section => section.trim());
        const metadata= yaml.load(sections[1]);
        const bodySection = sections[2] || "";
        metadata["body"] = bodySection;
        return metadata;
    }

    loadData(items) {
        items.forEach((item, index) => {
            const [year, month] = item.date.split('-');
            const dirPath = path.join(__dirname, "blog_json", year, month);
            // ディレクトリが存在しない場合は作成

            //fs.mkdir(dirPath, { recursive: true }, (err) => {
            //    if (err) {
            //        console.error('Error creating directories', err);
            //        return;
            //    }
            //});

            if (dirPath) {
                const filePath = path.join(dirPath, `${item.date}-${index}.json`);
                fs.writeFile(filePath, JSON.stringify(item, null, 2), (err) => {
                    if (err) {
                        console.error('Error writing JSON file', err);
                    } else {
                        console.log(`File successfully written to ${filePath}`);
                    }
                });
            } else {
                console.log(`error dirPath:${dirPath} File: ${item.title}`)
            }
        }) 
    }

    //async loadData(jsons) {
    //    const client = new MongoClient(MONGO_URI);
    //    try {
    //        await client.connect();
    //        const db = client.db(DATABASE_NAME);
    //        await db.collection("posts").insertMany(jsons);
    //    } catch (err) {
    //        console.error("エラーが発生しました:", err);
    //    } finally {
    //        await client.close();
    //    }
    //}


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
