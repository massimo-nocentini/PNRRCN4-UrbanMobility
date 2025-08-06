import fs from "node:fs";
import { parse } from "csv-parse";

const __dirname = new URL("../", import.meta.url).pathname;

let options = {
    delimiter: "&",
    trim: true,
    columns: false,
    cast: true,
    cast_date: true,
};

const parse_csv = async (filename) => {

    const parser = fs.createReadStream(`${__dirname}/transport/${filename}`).pipe(parse(options));

    let data = [];
    for await (const record of parser) {
        data.push(record);
    }

    return data;
};

let s1 = await parse_csv('single-1.csv');

console.log('City,s1_at,s1_at_log,s1_aw,s1_aw_log,s1_eta,s1_eta_log');

function checked_log(value) {
    return Math.log(1 + value);
}

for (let i = 0; i < s1.length; i++) {

    let s1_each = s1[i];

    console.log(`${s1_each[0]},${s1_each[8]},${checked_log(s1_each[8])},${s1_each[13]},${checked_log(s1_each[13])},${s1_each[17]},${checked_log(s1_each[17])}`);

}

// console.log(JSON.stringify(s1));

