# Error Handling
## How would we handle failure modes if this was a real world project:
### Queue machine is not available
Setting up new queue server, alerting the monitoring system, and starting new endpoints and processing units to work with the new queue server.
### Endpoint is down
Restarting endpoints again.
### Processing units is down
Restarting processing units
### Queue load is too high
adding more processing units