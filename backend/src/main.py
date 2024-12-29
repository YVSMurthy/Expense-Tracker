from flask import Flask, request, jsonify
from database import Database
import bcrypt

app = Flask(__name__)

# hash function
def hashPassword(password):
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode()

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    mobile = data.get('mobile')
    password = data.get('password')
    print("Mobile No. : ", mobile)
    print("Password : ", password)

    db = Database()

    # based on the credentials, find the user and get the user data from there
    data = db.getUserByMobile(mobile, password)

    db.close()
    
    if (data['status'] == 200):
        return jsonify({'message': 'ok', 'name': data['name']}), 200
    elif (data['status'] == 401):
        return jsonify({'message': 'Unauthorized access'}), 401
    else:
        print(data['message'])
        return jsonify({'message': "Internal server error"}), 500

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()

    name = data.get('name')
    mobile = data.get('mobile')
    password = data.get('password')
    age = int(data.get('age'))
    gender = data.get('gender')

    hashedPassword = hashPassword(password)

    db = Database()

    data = db.createUserRecord(name, mobile, hashedPassword, age, gender)

    if (data['status'] == 200):
        return jsonify({'message': 'ok'}), 200
    elif (data['status'] == 500):
        return jsonify({'message': 'Internal Server Error'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3001, debug=False)