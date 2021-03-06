from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "<h1>Hello World!</h1>"

@app.route("/hellodevops")
def hellodevops():
    return "<h1>Hello Edinburgh DevOps!</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0')