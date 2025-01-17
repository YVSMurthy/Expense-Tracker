from flask import Flask, request, jsonify # type: ignore for warning
from database import Database
import bcrypt # type: ignore for warning
from datetime import date

app = Flask(__name__)

# hash function
def hashText(password):
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode()


# ----------------------------------------------------------------------------------------------------------------------
# authentication routes ------------------------------------------------------------------------------------------------


@app.route('/auth/login', methods=['POST'])
def login():
    data = request.get_json()

    mobile = data.get('mobile')
    password = data.get('password')

    db = Database()
    response = db.getUserByMobile(mobile, password)
    db.close()
    
    if (response['status'] == 200):
        return jsonify({'message': 'ok', 'user_id': response['user_id'], 'name': response['name']}), 200
    elif (response['status'] == 401):
        return jsonify({'title': 'Unauthorized access', 'message': 'Please verify your credentials and try again'}), 401
    else:
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500

@app.route('/auth/register', methods=['POST'])
def register():
    data = request.get_json()

    name = data.get('name')
    mobile = data.get('mobile')
    password = data.get('password')
    age = int(data.get('age'))
    gender = data.get('gender')

    hashedPassword = hashText(password)

    db = Database()
    response = db.createUserRecord(name, mobile, hashedPassword, age, gender)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok', 'user_id': response['user_id']}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500


# ----------------------------------------------------------------------------------------------------------------------
# update routes --------------------------------------------------------------------------------------------------------


@app.route('/update/getBudget', methods=['POST'])
def getBudget():
    data = request.get_json()

    userId = data.get('user_id')

    db = Database()
    response = db.getBudget(userId)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok', 'monthly_budget': response['monthly_budget']}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500
    
@app.route('/update/getCategories', methods=['POST'])
def getCategories():
    data = request.get_json()

    userId = data.get('user_id')

    db = Database()
    response = db.getCategories(userId)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok', 'categories': response['categories']}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500

@app.route('/update/addCategory', methods=['POST'])
def addCategory():
    data = request.get_json()

    userId = data.get('user_id')
    catName = data.get('cat_name')
    amountAllotted = data.get('allotted_budget')
    monthlyBudget = data.get('monthly_budget')

    db = Database()
    response = db.addCategory(userId, catName, amountAllotted, monthlyBudget)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok'}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500

@app.route('/update/deleteCategory', methods=['POST'])
def deleteCategory():
    data = request.get_json()

    userId = data.get('user_id')
    catName = data.get('cat_name')
    monthlyBudget = data.get('monthly_budget')

    db = Database()
    response = db.deleteCategory(userId, catName, monthlyBudget)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok'}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500

@app.route('/update/updateProfile', methods=['POST'])
def updateProfile():
    data = request.get_json()

    userId = data.get('user_id')
    updates = data.get('updates')
    passwordUpdated = data.get('passwordUpdated')

    if (passwordUpdated == 1):
        hashedPassword = hashText(updates['values'][-1])
        updates['values'][-1] = hashedPassword

    db = Database()
    response = db.updateUserProfile(userId, updates)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok'}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500

@app.route('/update/updateGoals', methods=['POST'])
def updateGoals():
    data = request.get_json()

    userId = data.get('user_id')
    updatedBudgtes = data.get('updated_budget')
    updatedCategories = data.get('updated_categories')
    monthlyBudget = data.get('monthly_budget')

    db = Database()
    response = db.updateCategories(userId, updatedBudgtes, updatedCategories, monthlyBudget)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok'}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500
    

# ----------------------------------------------------------------------------------------------------------------------
# transaction routes ---------------------------------------------------------------------------------------------------


@app.route('/transaction/add', methods=['POST'])
def addTransaction():
    data = request.get_json()

    userId = data.get('user_id')
    title = data.get('title')
    transDesc = data.get('trans_desc')
    transType = data.get('type')
    transDate = data.get('trans_date')
    amount = data.get('amount')
    friendName = data.get('friend')
    split = data.get('split')

    db = Database()
    response = db.addTransaction(userId, title, transDesc, transType, transDate, amount, friendName, split)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok'}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500
    
@app.route('/transaction/updateDue', methods=['POST'])
def updateDue():
    data = request.get_json()

    userId = data.get('user_id')
    transDate = data.get('trans_date')
    amount = data.get('amount')
    friendName = data.get('friend')

    db = Database()
    response = db.updateDue(userId, transDate, amount, friendName)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok'}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500

@app.route('/transactions/getTransactions', methods=['POST'])
def getTransactions():
    data = request.get_json()

    userId = data.get('user_id')
    monthsBack = data.get('months_back', 0)

    db = Database()
    response = db.getTransactions(userId, monthsBack)
    db.close()

    if (response['status'] == 200):
        transactions = {}

        for transaction in response['transactions']:
            month = transaction[3].strftime("%B, %Y")

            if month in transactions:
                transactions[month]['transactions'].append(transaction)
                if (transaction[2] != 'paid' and transaction[2] != "inc"):
                    transactions[month]['total'] -= transaction[4]
                else:
                    transactions[month]['total'] += transaction[4]
            else:
                if (transaction[2] != 'paid' and transaction[2] != "inc"):
                    total = -transaction[4]
                else:
                    total = transaction[4]
                transactions[month] = {'total': total, 'transactions': [transaction]}

        return jsonify({'message': 'ok', 'transactions': transactions}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500
    
@app.route('/transactions/getTransactionDetails', methods=['POST'])
def getTransactionDetails():
    data = request.get_json()

    transId = data.get('trans_id')

    db = Database()
    response = db.getTransactionDetails(transId)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok', 'transaction_details': response['transaction_details']}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': 'Internal Server Error', 'message': 'Please try again.'}), 500
    
@app.route('/transactions/getDues', methods=['POST'])
def getDues():
    data = request.get_json()

    userId = data.get('user_id')

    db = Database()
    response = db.getDues(userId)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok', 'dues': response['dues']}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500

@app.route('/transactions/getDueDetails', methods=['POST'])
def getDueDetails():
    data = request.get_json()

    userId = data.get('user_id')
    friendName = data.get('name')

    db = Database()
    response = db.getDueDetails(userId, friendName)
    db.close()

    if (response['status'] == 200):
        return jsonify({'message': 'ok', 'due_details': response['due_details']}), 200
    elif (response['status'] == 500):
        print(response['error'])
        return jsonify({'title': "Internal server error", 'message': 'Please try again.'}), 500
    


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3001, debug=False)