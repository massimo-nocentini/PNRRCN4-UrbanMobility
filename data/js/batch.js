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

let s1 = await parse_csv('single-by-epsilon-50-0.1.csv');

for (let i = 0; i < s1.length; i++) {

    let s1_each = s1[i];

    let out = `${s1_each[0]} & ${s1_each[6]} & ${s1_each[7]} & ${s1_each[8]} & ${s1_each[9]} & ${s1_each[10]} & ${s1_each[11]} & ${s1_each[12]} & ${s1_each[13]} & ${s1_each[14]} & ${s1_each[15]} & ${s1_each[16]}  & ${s1_each[17]}  & ${s1_each[18]} \\\\`;

    console.log(out);

}

// console.log(JSON.stringify(s1));

