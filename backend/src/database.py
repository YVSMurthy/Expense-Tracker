import mysql.connector
import os
from dotenv import load_dotenv
import bcrypt
import uuid

# loading environment variables
load_dotenv()

class Database:
    # initialising
    def __init__(self):
        user = os.getenv('USER')
        password = os.getenv('PASSWORD')

        print("user: ", user)

        self.connection = mysql.connector.connect(
            host="localhost",
            user=user,
            password=password,
            database="expense_tracker"
        )

        self.cursor = self.connection.cursor()
    
    # closing the connection
    def close(self):
        if (self.cursor):
            self.cursor.close()
        if (self.connection):
            self.connection.close()


    # create a new user record
    def createUserRecord(self, name, mobile, password, age, gender):
        try:
            uniqueId = str(uuid.uuid4())

            query = "insert into users values(%s, %s, %s, %s, %s, %s)"
            self.cursor.execute(query, (uniqueId, name, mobile, password, age, gender))
            self.connection.commit()

            return {'status': 200}
        except:
            return {'status': 500}



    # getting users for login
    def getUserByMobile(self, mobile, password):
        try:
            query = "select name, password from users where mobile = %s"
            self.cursor.execute(query, (mobile,))

            user = self.cursor.fetchone()

            if (user):
                storedPassword = user[1]

                if (bcrypt.checkpw(password.encode('utf-8'), storedPassword.encode('utf-8'))):
                    return {'status': 200, 'name': user[0]}
            else:
                return {'status': 401}
        except Exception as e:
            return {'status': 500, 'message': e}
