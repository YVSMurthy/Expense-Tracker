from flask import Flask, request, jsonify
import mysql.connector

app = Flask(__name__)

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    print("Username : ", username)
    print("Password : ", password)
    data = {'status': 200, 'authToken': '1234'}
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3001, debug=False)