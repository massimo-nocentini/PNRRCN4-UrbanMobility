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

let s1 = await parse_csv('single-by-k-50-1.csv');
let s100 = await parse_csv('single-by-k-50-10.csv');
let s300 = await parse_csv('single-by-k-50-100.csv');
let s500 = await parse_csv('single-by-k-50-500.csv');
let s1k = await parse_csv('single-by-k-50-1000.csv');

console.log('City,s1_at,s1_at_log,s1_aw,s1_aw_log,s1_eta,s1_eta_log,s100_at,s100_at_log,s100_aw,s100_aw_log,s100_eta,s100_eta_log,s300_at,s300_at_log,s300_aw,s300_aw_log,s300_eta,s300_eta_log,s500_at,s500_at_log,s500_aw,s500_aw_log,s500_eta,s500_eta_log,s1k_at,s1k_at_log,s1k_aw,s1k_aw_log,s1k_eta,s1k_eta_log');

function checked_log(value) {
    return Math.log10(1 + value);
}

for (let i = 0; i < s1.length; i++) {

    let s1_each = s1[i];
    let s100_each = s100[i];
    let s300_each = s300[i];
    let s500_each = s500[i];
    let s1k_each = s1k[i];

    let out = `${s1_each[0]},${s1_each[9]},${checked_log(s1_each[9])},${s1_each[14]},${checked_log(s1_each[14])},${s1_each[19]},${checked_log(s1_each[19])}` +
        `,${s100_each[9]},${checked_log(s100_each[9])},${s100_each[14]},${checked_log(s100_each[14])},${s100_each[19]},${checked_log(s100_each[19])}` +
        `,${s300_each[9]},${checked_log(s300_each[9])},${s300_each[14]},${checked_log(s300_each[14])},${s300_each[19]},${checked_log(s300_each[19])}` +
        `,${s500_each[9]},${checked_log(s500_each[9])},${s500_each[14]},${checked_log(s500_each[14])},${s500_each[19]},${checked_log(s500_each[19])}` +
        `,${s1k_each[9]},${checked_log(s1k_each[9])},${s1k_each[14]},${checked_log(s1k_each[14])},${s1k_each[19]},${checked_log(s1k_each[19])}`;

    console.log(out);

}

// console.log(JSON.stringify(s1));

