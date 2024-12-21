from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
import mysql.connector
import requests
from config.db_config import get_db_connection
app = Flask(__name__)
app.secret_key = 'your_secret_key'

import requests
import mysql.connector

API_KEY_RAINFALL = "26886b39948a4e3688c125332242810"
API_KEY_GEOCODE = "f61b9e462006499080491728252ab16f"

def get_db_connection():
    conn = mysql.connector.connect(
        host='localhost',
        user='root',
        password='officialmysqlaccount',
        database='agrihelpers'
    )
    return conn

def get_lat_lon(pincode):
    url = f"https://api.opencagedata.com/geocode/v1/json?q={pincode}&key={API_KEY_GEOCODE}"
    result = requests.get(url)
    result_data = result.json()
    
    if 'results' in result_data and len(result_data['results']) > 0:
        geometry = result_data['results'][0]['geometry']
        return geometry['lat'], geometry['lng']
    else:
        print(f"Error: Unable to fetch latitude and longitude for pincode {pincode}.")
        return None, None

def get_weather_data(pincode, start_date="2024-08-01", end_date="2024-10-01"):
    latitude, longitude = get_lat_lon(pincode)

    if latitude and longitude:
        url = f"http://api.worldweatheronline.com/premium/v1/past-weather.ashx?key={API_KEY_RAINFALL}&q={latitude},{longitude}&format=json&date={start_date}&enddate={end_date}&tp=24"
        
        response = requests.get(url)
        weather_data = response.json()
        
        if response.status_code != 200 or 'data' not in weather_data:
            print("Error: Unable to retrieve weather data.")
            return None, None

        temp = None
        if 'weather' in weather_data['data']:
            max_temps = [int(day.get('maxtempC', 0)) for day in weather_data['data']['weather'] if 'maxtempC' in day]
            temp = sum(max_temps) / len(max_temps) if max_temps else None

        total_rainfall = 0
        num_days = 0
        for day in weather_data['data']['weather']:
            if 'hourly' in day:
                daily_rainfall = sum(float(hourly.get('precipMM', 0)) for hourly in day['hourly'])
                total_rainfall += daily_rainfall
                num_days += 1

        num_months = 2
        average_rainfall = (total_rainfall / num_months) if num_days > 0 else None

        return temp, average_rainfall
    else:
        return None, None

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        phone = request.form['phone']

        db = get_db_connection()
        cursor = db.cursor()

        cursor.execute("""
            INSERT INTO Customers (Cust_Name, Phone_No, Email)
            VALUES (%s, %s, %s)
        """, (name, phone, email))

        db.commit()
        customer_id = cursor.lastrowid
        db.close()

        return render_template('registration_success.html', customer_id=customer_id)

    return render_template('registration.html')


@app.route('/customer_login')
def customer_login():
    return render_template('customer_login.html')

@app.route('/customer_login', methods=['GET', 'POST'])
def customer_login_route():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        phone = request.form['phone']

        db = get_db_connection()
        cursor = db.cursor()
        cursor.execute("SELECT CropID FROM sites WHERE CustomerID = %s ", (customer_id,))
        result = cursor.fetchone();
        if result:
            CropID = result[0]
            cursor.close()
            db.close()
            return redirect(url_for('retrieve', customer_id=customer_id , crop_id=CropID) )
            
            
        else:
            db = get_db_connection()
            cursor = db.cursor()
            cursor.execute("SELECT * FROM Customers WHERE Cust_ID = %s AND Phone_No = %s", (customer_id, phone))
            customer = cursor.fetchone()
            db.close()

            if customer:
                return redirect(f'/address_input/{customer_id}')
            else:
                return render_template('customer_login.html', error="Invalid Customer ID or Phone Number.")

    return render_template('customer_login.html')

@app.route('/address_input/<int:customer_id>', methods=['GET'])
def address_input(customer_id):
    db = get_db_connection()
    cursor = db.cursor()
    cursor.execute("SELECT Soil_ID, Soil_Name FROM Soil")
    soils = cursor.fetchall()
    db.close()
    return render_template('address_input.html', soils=soils, customer_id=customer_id)

@app.route('/save_site_info', methods=['POST'])
def save_site_info():
    area = request.form['area']
    pincode = request.form['pincode']
    land_size = request.form['land_size']
    soil_id = request.form['soil_id']
    customer_id = request.form['customer_id']

    temperature, avg_rainfall = get_weather_data(pincode)

    db = get_db_connection()
    cursor = db.cursor()
    cursor.execute("""
        INSERT INTO Sites (Area, Pincode, Land_size, Soil_ID, Temperature, Rainfall, CustomerID)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (area, pincode, land_size, soil_id, temperature, avg_rainfall, customer_id))
    db.commit()
    db.close()

    return redirect(url_for('suitable_crops',customer_id=customer_id))




@app.route('/suitable_crops', methods=['GET'])
def suitable_crops():
    customer_id = request.args.get('customer_id')

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT Soil_ID, Temperature, Rainfall 
        FROM Sites 
        WHERE CustomerID = %s
    """, (customer_id,))
    
    site_data = cursor.fetchone()

    
    if not site_data:
        return "No site data found for the given customer ID.", 404

    soil_id = site_data['Soil_ID']
    temperature = site_data['Temperature']
    rainfall = site_data['Rainfall']

    cursor.execute("""
        SELECT cs.Crop_ID, c.Crop_Name, c.Min_Temperature, c.Max_Temperature, c.Min_Rain, c.Max_Rain
        FROM Crop_Soil cs
        JOIN Crops c ON cs.Crop_ID = c.Crop_ID
        WHERE cs.Soil_ID = %s
    """, (soil_id,))
    
    available_crops = cursor.fetchall()

    # Step 3: Filter crops based on temperature and rainfall conditions
    suitable_crops = []
    for crop in available_crops:
        if (crop['Min_Temperature'] <= temperature <= crop['Max_Temperature'] and
                crop['Min_Rain'] <= rainfall <= crop['Max_Rain']):
            suitable_crops.append(crop)

    cursor.close()
    db.close()

    if suitable_crops:
        # Step 4: Render the results in the HTML template
        return render_template('crops.html', crops=suitable_crops, customer_id=customer_id)
    else:
        return redirect(url_for('assign',customer_id = customer_id))




# Route to update crop information in the Sites table
@app.route('/update_crop', methods=['POST'])
def update_crop():
    # Get the posted form data
    crop_id = request.form['crop_id']  # The Crop ID entered by the user
    customer_id = request.form['customer_id']  # Customer ID from the form (optional)
    
    # Step 1: Get the site record that needs to be updated
    db = get_db_connection()
    cursor = db.cursor()

    # Update the CropID for the specific customer
    cursor.execute("""
        UPDATE Sites 
        SET CropID = %s 
        WHERE CustomerID = %s
    """, (crop_id, customer_id))
    
    # Commit the changes to the database
    db.commit()

    cursor.close()
    db.close()

    return jsonify(success=True)  # Redirect back to suitable crops

# Manager login page route
@app.route('/employee_login', methods=['GET', 'POST'])
def employee_login():
    if request.method == 'POST':
        manager_id = request.form['manager_id']
        phone_number = request.form['phone_number']  # Password is the phone number

        # Validate the manager credentials
        db = get_db_connection()
        cursor = db.cursor()
        cursor.execute("SELECT * FROM Managers WHERE Manager_ID = %s AND Phone_No = %s", (manager_id, phone_number))
        manager = cursor.fetchone()
        db.close()
        # print(manager[5]);
        if manager:
            if manager[5]:
                # Successful login - you can redirect to a manager-specific page
                return redirect(url_for('manager_homepage',Manager_ID = manager_id))  # Change to the actual page for managers
            else:
                return redirect(url_for('manager_homepage_2'))
            
            
        else:
            # Handle login failure (e.g., show an error message)
            return render_template('employee_login.html', error="Invalid Manager ID or Phone Number.")

    return render_template('employee_login.html')


@app.route('/manager_homepage_2', methods=['GET', 'POST'])
def manager_homepage_2():
    if request.method == 'POST':
        return render_template('index.html')
    return render_template('employee_homepage_2.html')

@app.route('/manager_homepage', methods=['GET', 'POST'])
def manager_homepage():
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    if request.method == 'POST':
        farmer_id = request.form.get('farmer_id')
        manager_id = request.form.get('manager_id')
        customer_id = request.form.get('customer_id')
        if customer_id:
            cursor.execute("UPDATE farmers SET F_availability = 0, CustomerID = %s WHERE Farmer_ID = %s", (customer_id, farmer_id))
            db.commit()
        
            cursor.close()
            db.close()
            return redirect(url_for('manager_homepage', Manager_ID=manager_id))  # Redirect to avoid form resubmission
        else:
            cursor.execute("UPDATE farmers SET F_availability = 1 , CustomerID = NULL WHERE Farmer_ID = %s",(farmer_id,))
            db.commit()

            cursor.close()
            return redirect(url_for('manager_homepage', Manager_ID=manager_id)) 
        
        

    elif request.method == 'GET' and request.method!='POST':
        manager_id =request.args.get('Manager_ID')
        # manager_id = int(manager_id)

        cursor.execute("SELECT CustomerID FROM managers WHERE Manager_ID = %s" , (manager_id,))
        manager = cursor.fetchone()
        customer_id = manager['CustomerID']

        cursor.execute("SELECT * FROM customers WHERE Cust_ID  = %s",(customer_id,))
        customer = cursor.fetchone()
        customer_name = customer['Cust_Name']
        customer_number = customer['Phone_No']

        cursor.execute("SELECT Area,Land_size,CropID FROM sites WHERE CustomerID  = %s",(customer_id,))
        info = cursor.fetchone()
        customer_area = info['Area']
        customer_land_size = info['Land_size']
        customer_crop_id = info['CropID']

        cursor.execute("SELECT Crop_Name FROM crops WHERE Crop_ID  = %s",(customer_crop_id,))
        crop_info = cursor.fetchone()
        customer_crop = crop_info['Crop_Name']

        customer_data = {
                'id':customer_id,
                'name': customer_name,
                'crop':customer_crop,
                'area': customer_area,
                'land_size': customer_land_size,
                'number': customer_number,
                'manager_id':manager_id
            }
        
        cursor.execute("SELECT Farmer_ID,Farmer_Name,Phone_No FROM farmers WHERE Specialization = %s AND F_availability = 1",(customer_crop_id,))
        farmer_info = cursor.fetchall();
        available_farmers=[]
        for farmer in farmer_info:
            available_farmers.append(farmer)

        
        cursor.execute("SELECT Farmer_ID,Farmer_Name,Phone_No FROM farmers WHERE Specialization = %s AND CustomerID = %s",(customer_crop_id,customer_id))
        farmer_info = cursor.fetchall();
        allocated_farmers=[]
        for farmer in farmer_info:
            allocated_farmers.append(farmer)

        cursor.close()
        db.close()
    return render_template('employee_homepage.html',customer = customer_data,available_farmers=available_farmers, allocated_farmers = allocated_farmers )




@app.route('/assign', methods=['POST','GET'])
def assign():


    customer_id = request.form.get('customer_id')
    # print(customer_id)
    # crop_id = request.form.get('crop_id')
    if request.method == 'GET':
        customer_id = request.args.get('customer_id')
        print(customer_id)
    
    
    
    
    db = get_db_connection()
    cursor = db.cursor()
    query="Select land_size from sites where CustomerID=%s"
    cursor.execute(query,(customer_id,))
    result = cursor.fetchone()
    land_size = result[0]
    cursor.execute("select CropID from sites where CustomerID= %s",(customer_id,))
    crop = cursor.fetchone()
    crop_id=crop[0]
    cursor.close()
    db.close()

    num_farmers = 2 * land_size
    
    # Retrieve an available manager and mark them unavailable
    manager = get_available_manager()
    print("manager: ", manager)

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM Managers WHERE CustomerID = %s", (customer_id,))
    res = cursor.fetchone()
    numbers = res[0]

    if numbers < 1:
        if manager:
            manager_id = int(manager['Manager_ID'])
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute("UPDATE managers SET M_availability=0, CustomerID= %s WHERE Manager_ID= %s",(customer_id,manager_id))
            conn.commit()

    cursor.close()
    conn.close()
    # Retrieve and update the required number of available farmers specialized in the selected crop
    farmers = get_crop_specialized_farmers(crop_id, num_farmers)

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM Farmers WHERE CustomerID = %s", (customer_id,))
    res = cursor.fetchone()
    numbers = res[0]
    cursor.close()
    if numbers < num_farmers:
        for farmer in farmers:
            
            cursor = conn.cursor()
            cursor.execute("UPDATE farmers SET F_availability=0, CustomerID= %s WHERE Farmer_ID= %s LIMIT 1",(customer_id,farmer['Farmer_ID']))
            conn.commit()
            cursor.close()
            
    conn.close()


    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            crops.Cost_of_Implementation, 
            crops.Rate_Per_Kg, 
            crops.Qty_Per_Acre, 
            soil.Unit_Resource_Cost, 
            soil.Irrigation_Cost, 
            soil.Resource,
            soil.Irrigation,
            sites.land_size AS acre_size,
            crops.Crop_Name
        FROM crops
        JOIN crop_soil ON crops.Crop_ID = crop_soil.Crop_id
        JOIN soil ON soil.Soil_ID = crop_soil.Soil_ID
        JOIN sites ON sites.CropID = crops.Crop_ID
        WHERE crops.Crop_ID = %s
    """, (crop_id,))

    crop = cursor.fetchone()



    if crop:
        crop_name = crop['Crop_Name']
        cost_of_implementation = crop['Cost_of_Implementation']
        resource_cost = crop['Unit_Resource_Cost']
        irrigation_cost = crop['Irrigation_Cost']
        rate_per_kg = crop['Rate_Per_Kg']
        quantity_per_acre = crop['Qty_Per_Acre']
        acre_size = crop['acre_size']

        additional_cost = 0.2 *float(rate_per_kg * quantity_per_acre * acre_size) 

        total_cost = float(resource_cost + irrigation_cost + cost_of_implementation) + additional_cost
        total_cost = float(resource_cost + irrigation_cost + cost_of_implementation) + additional_cost

        customer_profit = float(rate_per_kg * quantity_per_acre * acre_size) - total_cost

        return render_template('customer_homepage.html', manager=manager, num_farmers=num_farmers,crop = crop, crop_Name=crop_name, total_cost = total_cost, customer_id = customer_id, customer_profit = customer_profit)
    
    


# Function to fetch an available manager
def get_available_manager():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    query = "SELECT * FROM Managers WHERE M_availability = 1 LIMIT 1"
    cursor.execute(query)
    manager = cursor.fetchone()
    cursor.close()
    connection.close()
    return manager


# Function to fetch the required number of farmers with specialization in the selected crop
def get_crop_specialized_farmers(crop_id, num_farmers):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Farmers WHERE F_availability = 1 AND specialization = %s LIMIT %s", (crop_id, int(num_farmers)))
    farmers = cursor.fetchall()
    cursor.close()
    connection.close()
    return farmers


@app.route('/retrieve', )
def retrieve():
    customer_id = request.args.get('customer_id')
    crop_id = request.args.get('crop_id') 

    db = get_db_connection()
    cursor = db.cursor()
    cursor.execute("Select land_size from sites where CustomerID=%s",(customer_id,))
    result=cursor.fetchone()
    land_size = result[0]
    num_farmers= 2 * land_size
    cursor.close()

    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM managers where CustomerID = %s",(customer_id,))
    manager=cursor.fetchone()
    cursor.close()
    db.close()

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            crops.Cost_of_Implementation, 
            crops.Rate_Per_Kg, 
            crops.Qty_Per_Acre, 
            soil.Unit_Resource_Cost, 
            soil.Irrigation_Cost, 
            soil.Resource,
            soil.Irrigation,
            sites.land_size AS acre_size,
            crops.Crop_Name
        FROM crops
        JOIN crop_soil ON crops.Crop_ID = crop_soil.Crop_id
        JOIN soil ON soil.Soil_ID = crop_soil.Soil_ID
        JOIN sites ON sites.CropID = crops.Crop_ID
        WHERE crops.Crop_ID = %s
    """, (crop_id,))

    crop = cursor.fetchone()



    if crop:
        crop_name = crop['Crop_Name']
        cost_of_implementation = crop['Cost_of_Implementation']
        resource_cost = crop['Unit_Resource_Cost']
        irrigation_cost = crop['Irrigation_Cost']
        rate_per_kg = crop['Rate_Per_Kg']
        quantity_per_acre = crop['Qty_Per_Acre']
        acre_size = crop['acre_size']

        additional_cost = 0.2 *float(rate_per_kg * quantity_per_acre * acre_size) 

        total_cost = float(resource_cost + irrigation_cost + cost_of_implementation) + additional_cost
        total_cost = float(resource_cost + irrigation_cost + cost_of_implementation) + additional_cost

        customer_profit = float(rate_per_kg * quantity_per_acre * acre_size) - total_cost

        return render_template('customer_homepage.html', manager=manager, num_farmers=int(num_farmers),crop = crop, crop_Name=crop_name, total_cost = total_cost, customer_id = customer_id, customer_profit = customer_profit)

@app.route('/logout',methods=['POST'])
def logout():
    value = request.form.get('log_value')
    if value == '0':
        return redirect(url_for('customer_login'))
    elif value == '1':
        return render_template('index.html')
    


if __name__ == '__main__':
    app.run(debug=True)
