import mysql.connector # type: ignore for warning
import os
from dotenv import load_dotenv # type: ignore for warning
import bcrypt # type: ignore for warning
import uuid
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta # type: ignore for warning

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
            self.cursor.execute(query, (uniqueId, name.title(), mobile, password, age, gender))
            self.connection.commit()

            return {'status': 200, 'user_id': uniqueId}
        except Exception as e:
            return {'status': 500, 'error': e}



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
        except Exception as e:
            return {'status': 500, 'error': e}
        
    # get the monthly budget of a particular userId
    def getCategories(self, userId):
        try:
            query = "select cat_name, allotted_amount from categories where user_id = %s"
            self.cursor.execute(query, (userId,))

            categories = self.cursor.fetchall()

            return {'status': 200, 'categories': categories}
        except Exception as e:
            return {'status': 500, 'error': e}
        
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
        except Exception as e:
            return {'status': 500, 'error': e}
    
    # adding new category
    def deleteCategory(self, userId, catName, monthlyBudget):
        try:
            # query to update the categories
            query = "delete from categories where user_id = %s and cat_name = %s"
            self.cursor.execute(query, (userId, catName.title()))

            query = "update monthly_budget set budget = %s where user_id = %s"
            self.cursor.execute(query, (monthlyBudget, userId))

            self.connection.commit()

            return {'status': 200}
        except Exception as e:
            return {'status': 500, 'error': e}
    
    # updating the specifics of user profile
    def updateUserProfile(self, userId, updates):
        try:
            query = f"update users set {', '.join(updates['fields'])} where user_id = %s"
            updates['values'].append(userId)
            self.cursor.execute(query, tuple(updates['values']))
            self.connection.commit()

            return {'status': 200}
        except Exception as e:
            return {'status': 500, 'error': e}
    
    # updating the category names and the allotted budget
    def updateCategories(self, userId, updatedBudgets, updatedCategories, monthlyBudget):
        try:
            # query for updating the budget
            if (len(updatedBudgets) != 0):
                for (category, budget) in updatedBudgets.items():
                    query = "update categories set allotted_amount = %s where user_id = %s and cat_name = %s"
                    self.cursor.execute(query, (budget, userId, category.title()))
                
                query = "update monthly_budget set budget = %s where user_id = %s"
                self.cursor.execute(query, (monthlyBudget, userId))
            
            # query for updating categories
            if (len(updatedCategories) != 0):
                for (oldCategory, newCategory) in updatedCategories.items():
                    query = "update categories set cat_name = %s where user_id = %s and cat_name = %s"
                    self.cursor.execute(query, (newCategory.title(), userId, oldCategory.title()))
            
            self.connection.commit()

            return {'status': 200}
                
        except Exception as e:
            return {'status': 500, 'error': e}
        
    # adding transaction
    def addTransaction(self, userId, title, transDesc, transType, transDate, amount, friendName, split):
        try:
            transId = str(uuid.uuid4())
            transTime = datetime.now().time()

            query = "insert into transactions values (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
            self.cursor.execute(query, (transId, userId, title.title(), transDesc, transType, transDate, amount, transTime, split))

            if (split):
                query = "insert into dues values (%s, %s, %s, %s)"
                self.cursor.execute(query, (transId, userId, friendName.title(), amount))
            
            self.connection.commit()

            return {'status': 200}
        except Exception as e:
            return {'status': 500, 'error': e}
    
    # function to get the transactions 
    def getTransactions(self, userId, monthsBack):
        try:
            today = datetime.now()
            year = today.year
            month = today.month
            if (monthsBack >= month):
                month = 12 - (monthsBack - month)
                year = year - 1
            else:
                month = month - monthsBack
            
            initialDate = datetime(year, month, 1).date()

            query = "select trans_id, title, type, trans_date, amount, trans_time from transactions where user_id = %s and trans_date >= %s order by trans_date desc, trans_time desc"
            self.cursor.execute(query, (userId, initialDate))

            transactionsTuple = self.cursor.fetchall()

            transactions = []
            for transaction in transactionsTuple:
                transaction = list(transaction)  # Convert tuple to list
                for index, value in enumerate(transaction):
                    if isinstance(value, timedelta):
                        # Convert timedelta to hours:minutes:seconds format
                        total_seconds = value.total_seconds()
                        hours = int(total_seconds // 3600)
                        minutes = int((total_seconds % 3600) // 60)
                        seconds = int((total_seconds % 3600) % 60)
                        transaction[index] = f"{hours:02}:{minutes:02}:{seconds:02}"
                transactions.append(transaction)

            return {'status': 200, 'transactions': transactions}
        except Exception as e:
            print("\n\n\n\n\n\n\n", e)
            return {'status': 500, 'error': e}
        
    # getting transaction details based on transaction id
    def getTransactionDetails(self, transId):
        try:
            query = "select title, trans_desc, type, trans_date, amount, trans_time, split from transactions where trans_id = %s"
            self.cursor.execute(query, (transId,))

            transactionDetails = list(self.cursor.fetchone())

            if (transactionDetails[6] == 1):
                query = "select name from dues where trans_id = %s"
                self.cursor.execute(query, (transId,))
                name = self.cursor.fetchone()

                transactionDetails.append(name[0])
                
            if isinstance(transactionDetails[5], timedelta):
                # Convert timedelta to hours:minutes:seconds format
                total_seconds = transactionDetails[5].total_seconds()
                hours = int(total_seconds // 3600)
                minutes = int((total_seconds % 3600) // 60)
                seconds = int((total_seconds % 3600) % 60)
                transactionDetails[5] = f"{hours:02}:{minutes:02}:{seconds:02}"

            return {'status': 200, 'transaction_details': transactionDetails}
        except Exception as e:
            print(e)
            return {'status': 500, 'error': e}
    
    # updating the dues
    def updateDue(self, userId, transDate, amount, friendName):
        try:
            query = "select name, sum(amount) from dues where user_id=%s and name=%s group by name"
            self.cursor.execute(query, (userId, friendName.title()))

            due = self.cursor.fetchone()

            transId = str(uuid.uuid4())
            transTime = datetime.now().time()

            query = "insert into transactions values (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
            self.cursor.execute(query, (transId, userId, "Due paid", "Due paid", 'paid', transDate, amount, transTime, 0))

            if (due[1] == amount):
                query = "delete from dues where user_id=%s and name=%s"
                self.cursor.execute(query, (userId, friendName.title()))
            else:
                query = "insert into dues (trans_id, user_id, name, amount) values (%s, %s, %s, %s)"
                self.cursor.execute(query, (transId, userId, friendName.title(), -amount))
            
            self.connection.commit()

            return {'status': 200}
        except Exception as e:
            return {'status': 500, 'error': e}
        
    # getting the list of dues
    def getDues(self, userId):
        try:
            query = "select name, sum(amount) from dues where user_id = %s group by name"
            self.cursor.execute(query, (userId, ))

            dues = self.cursor.fetchall()

            return {'status': 200, 'dues': dues}
        except Exception as e:
            return {'status': 500, 'error': e}
        
    def getDueDetails(self, userId, friendName):
        try:
            query = "select trans_id, title, trans_desc, trans_date, trans_time, amount from transactions where trans_id in (select trans_id from dues where user_id = %s and name = %s) order by trans_date desc, trans_time desc"
            self.cursor.execute(query, (userId, friendName.title()))

            dueDetailsTuple = self.cursor.fetchall()

            dueDetails = []
            for due in dueDetailsTuple:
                due = list(due)  # Convert tuple to list
                for index, value in enumerate(due):
                    if isinstance(value, timedelta):
                        # Convert timedelta to hours:minutes:seconds format
                        total_seconds = value.total_seconds()
                        hours = int(total_seconds // 3600)
                        minutes = int((total_seconds % 3600) // 60)
                        seconds = int((total_seconds % 3600) % 60)
                        due[index] = f"{hours:02}:{minutes:02}:{seconds:02}"
                dueDetails.append(due)

            return {'status': 200, 'due_details': dueDetails}
        except Exception as e:
            return {'status': 500, 'error': e}
        
    # sending the analytics data for dashboard
    def getAnalytics(self, userId):
        try: 
            # finding the monthly expense data
            today = datetime.now()
            initialDate = datetime(today.year, today.month, 1).date()

            query = """
                select 
                    sum(case
                            when type='exp' then amount
                            else 0
                        end) as expenses,
                    sum(case
                            when type='inc' then amount
                            else 0
                        end) as income
                from transactions
                where user_id = %s and trans_date >= %s
            """
            self.cursor.execute(query, (userId, initialDate))

            monthlyExpenseData = self.cursor.fetchone()

            # getting category wise data
            query = """
                select
                    title,
                    sum(amount),
                    coalesce(
                        (select allotted_amount 
                        from categories 
                        where cat_name = title AND user_id = %s), 
                        0
                    ) as allotted_amount
                from transactions
                where user_id = %s and trans_date >= %s and type = 'exp'
                group by title
                order by title
            """
            self.cursor.execute(query, (userId, userId, initialDate))

            categoryWiseData = self.cursor.fetchall()

            return {'status': 200, 'monthly_expense_data': monthlyExpenseData, 'category_wise_data': categoryWiseData}
        except Exception as e:
            print(e)
            return {'status': 500, 'error': e}
