
module.exports = class Queue {
    #queueMaps = {
        "input": [],
        "output": []
    };

    push(name, data) {
        this.#queueMaps[name].push(data);
    }

    poll(name) {
        return this.#queueMaps[name].pop();
    }

}
