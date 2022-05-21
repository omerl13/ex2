const express = require('express')
const app = express()
const port = 3000
const bodyParser = require('body-parser');
const uuid = require('uuid');
const axios = require('axios');
const queueBaseUrl = `http://${process.env.QUEUE_PUBLIC_IP}:3000`;

app.use(bodyParser.raw({ type: '*/*', limit: '1MB' }));

/**
 * PUT /enqueue?iterations=num– with the body containing the actual data.
    The response for this endpoint would be the id of the submitted work (to be used later)
 */
app.put('/enqueue', async (req, res) => {
    const { iterations } = req.query;
    const jobId = uuid.v4();
    try {
        await axios.post(`${queueBaseUrl}/push?name=input`, { data: req.body, iterations: parseInt(iterations), id: jobId });
    } catch (ex) {
        console.error(`[${ex.code}] ${ex.message}`);
        res.sendStatus(500);
        return;
    }
    res.json({ id: jobId });
})

/**
 * POST /pullCompleted?top=num – return the latest completed work items (the final value for the work and the work id)
 */
app.post('/pullCompleted', async (req, res) => {
    const { top } = req.query;
    const results = [];
    try {
        for (let i = 0; i < top; i++) {
            const result = await axios.post(`${queueBaseUrl}/poll?name=output`);
            results.push(result.data);
        }
    } catch (ex) {
        if (ex.code === 'ERR_BAD_REQUEST') {
            console.log("not enough jobs in the queue");
        } else {
            console.log(ex.code);
        }
    }
    res.json(results);
})

app.listen(port, () => {
    console.log(`Listening on port ${port}`)
    console.log(`Queue URL: ${queueBaseUrl}`)
})