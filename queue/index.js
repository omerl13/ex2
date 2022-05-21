const express = require('express')
const Queue = require('./queue')
const app = express()
const bodyParser = require('body-parser');
const port = 3001

app.use(bodyParser.json({ limit: '1MB' }))

const queue = new Queue();

app.post('/push', (req, res) => {
    const { name } = req.query;
    queue.push(name, req.body);
    res.sendStatus(200);
})

app.post('/poll', (req, res) => {
    const { name } = req.query;
    const data = queue.poll(name);
    if (!data) {
        res.sendStatus(404);
    } else {
        res.json(data);
    }
})

app.listen(port, () => {
    console.log(`Listening on port ${port}`)
})
