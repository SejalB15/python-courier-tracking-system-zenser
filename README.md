# Courier Tracking System API Documentation

## Overview
This project is a Courier Tracking System API developed using Python's `http.server` module, designed to interact with a MySQL database for courier management, tracking, and delivery services. The API supports basic CRUD operations and can be tested using tools like Postman.

## Features
- Retrieve, create, and update courier and tracking information.
- MySQL integration for persistent storage.
- RESTful endpoints for seamless interaction.

## Prerequisites
- Python 3.10 or higher
- MySQL server
- Required Python libraries:
  - `mysql-connector-python`
  - `json`

## Setup Instructions
1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. **Install dependencies:**
   ```bash
   pip install mysql-connector-python
   ```

3. **Configure MySQL Database:**
   - Create a MySQL database and import the required tables.
   - Update database credentials in the Python script:
     ```python
     connection = mysql.connector.connect(
         host="<your-host>",
         user="<your-username>",
         password="<your-password>",
         database="<your-database>"
     )
     ```

4. **Run the Server:**
   ```bash
   python courier_tracking_system.py
   ```

## API Endpoints

### Courier Table
- **GET /couriers**: Retrieve all courier records.
- **POST /couriers**: Add a new courier.
  - Request Body:
    ```json
    {
        "customer_id": 1,
        "origin": "NY",
        "destination": "LA",
        "shipment_date": "2025-01-10",
        "delivery_date": null,
        "status": "In Transit"
    }
    ```
- **PUT /couriers/{id}**: Update courier information.
  - Request Body:
    ```json
    {
        "status": "Delivered",
        "delivery_date": "2025-01-11"
    }
    ```

### Tracking Table
- **GET /tracking**: Retrieve all tracking records.
- **POST /tracking**: Add a new tracking record.
  - Request Body:
    ```json
    {
        "courier_id": 1,
        "location": "LA Hub",
        "status_update": "Out for Delivery",
        "timestamp": "2025-01-10"
    }
    ```
- **PUT /tracking/{id}**: Update tracking information.
  - Request Body:
    ```json
    {
        "location": "Delivered",
        "status_update": "Package Delivered",
        "timestamp": "2025-01-11"
    }
    ```

## Testing
1. **Using Postman:**
   - Import the API endpoints and test GET, POST, and PUT requests.
   - Ensure to provide valid JSON bodies for POST and PUT requests.

2. **Using Curl:**
   - Example for POST request:
     ```bash
     curl -X POST http://localhost:8000/couriers -H "Content-Type: application/json" -d '{"customer_id": 1, "origin": "NY", "destination": "LA", "shipment_date": "2025-01-10", "delivery_date": null, "status": "In Transit"}'
     ```

## License
This project is licensed under the MIT License. See `LICENSE` for details.

