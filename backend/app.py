from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def health_check():
    return jsonify({"status": "OK", "message": "Backend service is running"})

@app.route('/api/test')
def test_endpoint():
    return jsonify({"data": "This is test data from backend"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)