import { createHash } from 'crypto';
import axios from 'axios';
const queueBaseUrl = `http://${process.env.QUEUE_PUBLIC_IP}:3000`;

const delay = ms => new Promise(resolve => setTimeout(resolve, ms))

async function get() {
    try {
        const result = await axios.post(`${queueBaseUrl}/poll?name=input`);
        return result.data;
    } catch (ex) {
        return null;
    }
}

async function post(data) {
    await axios.post(`${queueBaseUrl}/push?name=output`, data);
}

function hash(data, iterations) {
    const hash = createHash('sha512')
    data = Buffer.from(data.data);
    for (let i = 0; i < iterations; i++) {
        data = hash.copy().update(data).digest();
    }
    return data;
}

console.log(`Starting, queue URL: ${queueBaseUrl}`);

while (true) {
    const job = await get();
    if (!job) {
        console.log("no job found")
        await delay(1000);
        continue;
    };
    console.log(`processing job [${job.id}]`);
    const result = hash(job.data, job.iterations);
    await post({ id: job.id, data: result });
}