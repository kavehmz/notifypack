# notifypack

This is a simple mojo app that used Websocket to notify connected clients if there was a change in the list of installed packages in the system.

It is a vagrant based setup.

## Install

You need to install vagrant.
You need to clone the repository.

Then:

```bash
$ vagrant up
$ vagrant ssh
```

Inside vagrant you need to:

```bash
$ cd notifypack
$ ./run.sh
```

If port-forwarding works in your setup (check vagrant issues) now you can open Chrome browser. Open console and do:

```javascript
var ws = new WebSocket('ws://localhost:8080/');
var result;
ws.onmessage = function (msg) {
   result = JSON.parse(msg.data);
   console.log(result);
};
```

Every 5 second there will be a message about the changes to the system.

Message will be send to ALL CONNECTED CLIENTS.
