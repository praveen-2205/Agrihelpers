# 🌾 **AgriHelpers - DBMS Project** 🌾

AgriHelpers is a company designed to assist individuals who own unused land but lack agricultural knowledge. The system helps users log in, input land details, and calculates the temperature and rainfall in their area using APIs. Based on this data, the system suggests the most suitable crops from the database. Additionally, it estimates the total costs for seeds, irrigation, and resources, and calculates the profit users can earn after deducting these costs. AgriHelpers charges a 20% fee from the profit as service charges. 💰
---
## 🚀 **Features** 🚀
- **Customer Portal**: Users can log in and enter their land details to receive crop recommendations based on weather conditions. 🌍
- **Crop Database**: Includes detailed crop information:
  - **Crop_ID**: Unique identifier for each crop. 🔢
  - **Crop_Name**: Name of the crop. 🌾
  - **Cost_of_Implementation**: Total cost of implementation (seed money). 💵
  - **Min_Temperature**: Minimum temperature required for crop growth. 🌡️
  - **Max_Temperature**: Maximum temperature allowed for crop growth. 🌞
  - **Min_Rain**: Minimum rainfall required. 🌧️
  - **Max_Rain**: Maximum rainfall allowed. 🌦️
  - **Rate_per_kg**: Rate per kilogram of the crop. 💰
  - **Qty_per_acre**: Quantity of crop produced per acre. 🧑‍🌾
- **Profit Calculation**: Calculates the total costs for seeds, irrigation, and resources, and deducts these from the profit to determine the net earnings. 💹
- **Farmer and Manager Management**:
  - 150 farmers specialized in various crops. 🌱
  - 25 managers to oversee farmer assignments. 🧑‍💼
  - Managers can log in, view farmers under their supervision, assign or remove farmers, and all changes are reflected in the database. 🔄
---
## 🛠️ **Technologies Used** 🛠️

### Database
- MySQL 🗃️

### Programming Languages
- Python 🐍
- HTML 🌐
- CSS 🎨

### Frameworks
- Flask 🚀
- MySQL Connector 🔌
---
## ⚙️ **How It Works** ⚙️
1. Customers log in and input their land details. 👨‍💻
2. The system uses APIs to fetch temperature and rainfall data for the given pincode. 🌦️
3. Based on these values, suitable crops are selected from the database. 🌾
4. The system calculates the costs for resources and provides a profit estimate. 💵
5. Farmers are assigned to customers based on land size, and managers oversee the assignments. 👩‍🌾
6. All data and actions are maintained and updated in the database. 🗃️
---
## 📈 **Project Workflow** 📈
1. User enters land details (pincode, size, etc.). 📍
2. System fetches weather data using APIs. 🌧️
3. Database queries select appropriate crops based on:
   - Temperature range. 🌡️
   - Rainfall range. 🌧️
4. Cost estimation is performed based on:
   - Cost of seeds. 💰
   - Irrigation expenses. 💧
   - Additional resources. 🔧
5. Profit calculation and service charge deduction. 💵
6. Farmer and manager assignments managed through the database. 📊
---
## 🎯 **Conclusion** 🎯
AgriHelpers simplifies the process for landowners with no agricultural expertise, bridging the gap between landowners, farmers, and managers, while ensuring optimal crop recommendations and cost management. 🌱
