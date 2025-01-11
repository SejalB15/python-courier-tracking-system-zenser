import mysql.connector
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
from urllib.parse import urlparse
import datetime
import logging

# Set up basic logging
logging.basicConfig(level=logging.DEBUG)

# Function to convert date objects to string
def convert_to_serializable(obj):
    if isinstance(obj, datetime.date):
        return obj.isoformat()  # Converts to 'YYYY-MM-DD' format
    raise TypeError(f"Type {obj.__class__.__name__} not serializable")

# MySQL database connection
def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host="localhost",  # Change to your MySQL host
            user="root",       # Change to your MySQL user
            password="root",       # Add your MySQL password here
            database="courier_track"  # Change to your database name
        )
        return connection
    except mysql.connector.Error as err:
        logging.error(f"Error connecting to database: {err}")
        return None

# BaseHTTPServer handler
class RequestHandler(BaseHTTPRequestHandler):

    def send_json_response(self, status_code, data):
        self.send_response(status_code)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        
        # Convert the data to a JSON serializable format
        try:
            json_data = json.dumps(data, default=convert_to_serializable)
            self.wfile.write(json_data.encode())
        except TypeError as e:
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            error_message = {"message": f"Error serializing data: {str(e)}"}
            self.wfile.write(json.dumps(error_message).encode())

    # GET method to fetch courier details
    def do_GET(self):
        parsed_path = urlparse(self.path)
        path_parts = parsed_path.path.strip('/').split('/')
        
        if path_parts[0] == 'couriers':
            courier_id = path_parts[1] if len(path_parts) > 1 else None
            if courier_id:
                self.get_courier(courier_id)
            else:
                self.get_all_couriers()

        elif path_parts[0] == 'tracking':
            tracking_id = path_parts[1] if len(path_parts) > 1 else None
            if tracking_id:
                self.get_tracking(tracking_id)
            else:
                self.get_all_tracking()

    # POST method to create a new courier
    def do_POST(self):
        parsed_path = urlparse(self.path)
        path_parts = parsed_path.path.strip('/').split('/')

        if path_parts[0] == 'couriers':
            self.create_courier()

        elif path_parts[0] == 'tracking':
            self.create_tracking()

    # PUT method to update existing courier or tracking
    def do_PUT(self):
        parsed_path = urlparse(self.path)
        path_parts = parsed_path.path.strip('/').split('/')

        if path_parts[0] == 'couriers':
            courier_id = path_parts[1] if len(path_parts) > 1 else None
            if courier_id:
                self.update_courier(courier_id)

        elif path_parts[0] == 'tracking':
            tracking_id = path_parts[1] if len(path_parts) > 1 else None
            if tracking_id:
                self.update_tracking(tracking_id)

    # Function to get all couriers
    def get_all_couriers(self):
        connection = get_db_connection()
        if not connection:
            self.send_json_response(500, {"message": "Database connection failed"})
            return
        
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Couriers")
        result = cursor.fetchall()
        cursor.close()
        connection.close()
        self.send_json_response(200, result)

    # Function to get a specific courier by ID
    def get_courier(self, courier_id):
        connection = get_db_connection()
        if not connection:
            self.send_json_response(500, {"message": "Database connection failed"})
            return
        
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Couriers WHERE courier_id = %s", (courier_id,))
        result = cursor.fetchone()
        cursor.close()
        connection.close()
        if result:
            self.send_json_response(200, result)
        else:
            self.send_json_response(404, {"message": "Courier not found"})

    # Function to get all tracking details
    def get_all_tracking(self):
        connection = get_db_connection()
        if not connection:
            self.send_json_response(500, {"message": "Database connection failed"})
            return
        
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Tracking")
        result = cursor.fetchall()
        cursor.close()
        connection.close()
        self.send_json_response(200, result)

    # Function to get specific tracking details by tracking ID
    def get_tracking(self, tracking_id):
        connection = get_db_connection()
        if not connection:
            self.send_json_response(500, {"message": "Database connection failed"})
            return
        
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Tracking WHERE tracking_id = %s", (tracking_id,))
        result = cursor.fetchone()
        cursor.close()
        connection.close()
        if result:
            self.send_json_response(200, result)
        else:
            self.send_json_response(404, {"message": "Tracking not found"})

    # Function to create a new courier (POST)
    def create_courier(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data)
        except json.JSONDecodeError:
            self.send_json_response(400, {"message": "Invalid JSON"})
            return

        # Ensure all required fields are present
        required_fields = ['customer_id', 'origin', 'destination', 'shipment_date', 'delivery_date', 'status']
        for field in required_fields:
            if field not in data:
                self.send_json_response(400, {"message": f"Missing field: {field}"})
                return

        connection = get_db_connection()
        if not connection:
            self.send_json_response(500, {"message": "Database connection failed"})
            return
        
        cursor = connection.cursor()
        cursor.execute(
            "INSERT INTO Couriers (customer_id, origin, destination, shipment_date, delivery_date, status) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (data['customer_id'], data['origin'], data['destination'], data['shipment_date'], 
             data['delivery_date'], data['status'])
        )
        connection.commit()
        cursor.close()
        connection.close()

        self.send_json_response(201, {"message": "Courier created successfully"})

    # Function to create a new tracking record (POST)
    def create_tracking(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data)
        except json.JSONDecodeError:
            self.send_json_response(400, {"message": "Invalid JSON"})
            return

        # Ensure required fields are present
        required_fields = ['courier_id', 'location', 'status_update', 'timestamp']
        for field in required_fields:
            if field not in data:
                self.send_json_response(400, {"message": f"Missing field: {field}"})
                return

        connection = get_db_connection()
        if not connection:
            self.send_json_response(500, {"message": "Database connection failed"})
            return
        
        cursor = connection.cursor()
        cursor.execute(
            "INSERT INTO Tracking (courier_id, location, status_update, timestamp) "
            "VALUES (%s, %s, %s, %s)",
            (data['courier_id'], data['location'], data['status_update'], data['timestamp'])
        )
        connection.commit()
        cursor.close()
        connection.close()

        self.send_json_response(201, {"message": "Tracking record created successfully"})

# Run the server
def run(server_class=HTTPServer, handler_class=RequestHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    logging.info(f"Starting server on port {port}")
    httpd.serve_forever()

if __name__ == '__main__':
    run(port=8080)
