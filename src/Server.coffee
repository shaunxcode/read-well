express = require "express"
fs = require "fs"
app = express()
server = app.listen 8888

app.configure ->
	app.use express.bodyParser()
	app.use express.static "./public"
	app.get "/*", (req, res) -> res.sendfile "./public/index.html"
