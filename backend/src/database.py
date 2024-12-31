import mysql.connector # type: ignore for warning
import os
from dotenv import load_dotenv # type: ignore for warning
import bcrypt # type: ignore for warning
import uuid

# loading environment variables
load_dotenv()

class Database:
    # initialising
    def __init__(self):
        user = os.getenv('USER')
        password = os.getenv('PASSWORD')

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

            return {'status': 200, 'user_id': uniqueId}
        except:
            return {'status': 500}



    # getting users for login
    def getUserByMobile(self, mobile, password):
        try:
            query = "select user_id, name, password from users where mobile = %s"
            self.cursor.execute(query, (mobile,))

            user = self.cursor.fetchone()

            if (user):
                storedPassword = user[2]

                if (bcrypt.checkpw(password.encode('utf-8'), storedPassword.encode('utf-8'))):
                    return {'status': 200, 'user_id': user[0], 'name': user[1]}
            else:
                return {'status': 401}
        except Exception as e:
            return {'status': 500, 'message': e}
        
    # get the monthly budget of a particular userId
    def getBudget(self, userId):
        try:
            query = "select budget from monthly_budget where user_id = %s"
            self.cursor.execute(query, (userId,))

            budget = self.cursor.fetchone()

            return {'status': 200, 'monthly_budget': budget[0]}
        except:
            return {'status': 500}
        
    # get the monthly budget of a particular userId
    def getCategories(self, userId):
        try:
            query = "select cat_name, allotted_amount from categories where user_id = %s"
            self.cursor.execute(query, (userId,))

            categories = self.cursor.fetchall()

            return {'status': 200, 'categories': categories}
        except:
            return {'status': 500}
        
    # adding new category
    def addCategory(self, userId, catName, allotedAmount, monthlyBudget):
        try:
            # query to update the categories
            query = "insert into categories (user_id, cat_name, allotted_amount) values (%s, %s, %s)"
            self.cursor.execute(query, (userId, catName.title(), allotedAmount))

            query = "update monthly_budget set budget = %s where user_id = %s"
            self.cursor.execute(query, ((monthlyBudget+allotedAmount), userId))

            self.connection.commit()

            return {'status': 200}
        except:
            return {'status': 500}
    
    # adding new category
    def deleteCategory(self, userId, catName, monthlyBudget):
        try:
            # query to update the categories
            query = "delete from categories where user_id = %s and cat_name = %s"
            self.cursor.execute(query, (userId, catName))

            query = "update monthly_budget set budget = %s where user_id = %s"
            self.cursor.execute(query, (monthlyBudget, userId))

            self.connection.commit()

            return {'status': 200}
        except:
            return {'status': 500}
    
    # updating the specifics of user profile
    def updateUserProfile(self, userId, updates):
        try:
            query = f"update users set {', '.join(updates['fields'])} where user_id = %s"
            updates['values'].append(userId)
            self.cursor.execute(query, tuple(updates['values']))
            self.connection.commit()

            return {'status': 200}
        except:
            return {'status': 500}
    
    # updating the category names and the allotted budget
    def updateCategories(self, userId, updatedBudgets, updatedCategories, monthlyBudget):
        try:
            # query for updating the budget
            if (len(updatedBudgets) != 0):
                for (category, budget) in updatedBudgets.items():
                    query = "update categories set allotted_amount = %s where user_id = %s and cat_name = %s"
                    self.cursor.execute(query, (budget, userId, category))
                
                query = "update monthly_budget set budget = %s where user_id = %s"
                self.cursor.execute(query, (monthlyBudget, userId))
            
            # query for updating categories
            if (len(updatedCategories) != 0):
                for (oldCategory, newCategory) in updatedCategories.items():
                    query = "update categories set cat_name = %s where user_id = %s and cat_name = %s"
                    self.cursor.execute(query, (newCategory, userId, oldCategory))
            
            self.connection.commit()

            return {'status': 200}
                
        except:
            return {'status': 500}
