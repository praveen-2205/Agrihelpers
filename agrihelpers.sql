CREATE DATABASE agrihelpers;
USE agrihelpers;
CREATE TABLE Customers(
    Cust_ID INT PRIMARY KEY AUTO_INCREMENT,        -- Unique identifier for each customer
    Cust_Name VARCHAR(100) NOT NULL,               -- Name of the customer
    Phone_No VARCHAR(15) NOT NULL,                 -- Phone number of the customer
    Email VARCHAR(100)                             -- Email of the customer
);
CREATE TABLE Soil (
    Soil_ID INT PRIMARY KEY,                       -- Unique identifier for each soil type
    Soil_Name VARCHAR(100) NOT NULL,               -- Name of the soil type
    Resource VARCHAR(100) NOT NULL,                -- Fertilizer suitable for the soil
    Unit_Resource_Cost DECIMAL(7,2) NOT NULL,    -- Cost per unit of the resource
    Irrigation VARCHAR(100) NOT NULL,              -- Type of irrigation needed
    Irrigation_Cost DECIMAL(8, 2) NOT NULL        -- Cost of irrigation setup
);
CREATE TABLE Crops (
    Crop_ID INT PRIMARY KEY,                       -- Unique identifier for each crop
    Crop_Name VARCHAR(100) NOT NULL,               -- Name of the crop
    Cost_of_Implementation DECIMAL(10, 2) NOT NULL,-- Total cost of implementation (Seed money)
    Min_Temperature DECIMAL(5, 2) NOT NULL,        -- Minimum temperature for growth
    Max_Temperature DECIMAL(5, 2) NOT NULL,        -- Maximum temperature for growth
    Min_Rain DECIMAL(5, 2) NOT NULL,               -- Minimum rainfall required
    Max_Rain DECIMAL(5, 2) NOT NULL,               -- Maximum rainfall required
    Rate_per_kg DECIMAL(10, 2) NOT NULL,           -- Rate per kg of the crop
    Qty_per_acre DECIMAL(10, 2) NOT NULL          -- Quantity of crop produced per acre
);
CREATE TABLE Crop_Soil (
    Crop_ID INT NOT NULL,                          -- References Crops table
    Soil_ID INT NOT NULL,                          -- References Soil table
    FOREIGN KEY (Crop_ID) REFERENCES Crops(Crop_ID),
    FOREIGN KEY (Soil_ID) REFERENCES Soil(Soil_ID),
    PRIMARY KEY (Crop_ID, Soil_ID)                 -- Composite primary key
);


CREATE TABLE Sites (
    Area VARCHAR(100),                     -- Area of the land
    Pincode VARCHAR(10),                   -- Pincode of the location
    Land_size DECIMAL(10, 2),              -- Size of the land in acres
    Soil_ID INT,                           -- Foreign key reference to the Soil table
    Temperature DECIMAL(5, 2),             -- Temperature at the site
    Rainfall DECIMAL(5, 2),                -- Rainfall at the site
    CustomerID INT,                        -- Foreign key reference to the Customers table
    CropID INT,                            -- Foreign key reference to the Crops table
    FOREIGN KEY (CustomerID) REFERENCES Customers(Cust_ID),
    FOREIGN KEY (CropID) REFERENCES Crops(Crop_ID),
    FOREIGN KEY (Soil_ID) REFERENCES Soil(Soil_ID)    -- Changed to INT to reference Soil_ID in Soil table
);

CREATE TABLE Managers (
    Manager_ID INT PRIMARY KEY,
    Manager_Name VARCHAR(100) NOT NULL,
    Phone_No VARCHAR(15),
    Email_ID VARCHAR(100),
    M_availability BOOLEAN NOT NULL DEFAULT TRUE,
    CustomerID int,
    foreign key(CustomerID) references sites(CustomerID)
);

CREATE TABLE Farmers (
    Farmer_ID INT PRIMARY KEY,
    Farmer_Name VARCHAR(100) NOT NULL,
    Phone_No VARCHAR(15) NOT NULL,
    Specialization INT NOT NULL,
    No_of_Working_Days INT NOT NULL,
    F_availability BOOLEAN NOT NULL DEFAULT TRUE,
    Salary_Per_Day DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Specialization) REFERENCES Crops(Crop_ID),
    CustomerID int,
    foreign key(CustomerID) references sites(CustomerID)
);


INSERT INTO Soil (Soil_ID, Soil_Name, Resource, Unit_Resource_Cost, Irrigation, Irrigation_Cost)
VALUES 
(900, 'Clay', 'NPK Fertilizer', 1500.00, 'Drip Irrigation', 10000.00),
(901, 'Clay Loams', 'Compost', 1200.00, 'Drip Irrigation', 9500.00),
(902, 'Deep Alluvial Soil', 'Urea', 1400.00, 'Surface Irrigation', 8000.00),
(903, 'Clayey Black', 'Potash', 1600.00, 'Surface Irrigation', 8500.00),
(904, 'Black', 'NPK Fertilizer', 1550.00, 'Drip Irrigation', 10000.00),
(905, 'Laterite', 'Gypsum', 1100.00, 'Surface Irrigation', 9000.00),
(906, 'Sandy', 'Compost', 1300.00, 'Drip Irrigation', 9500.00),
(907, 'Red Loam', 'Urea', 1400.00, 'Surface Irrigation', 8000.00),
(908, 'Red Laterite', 'Potash', 1500.00, 'Drip Irrigation', 10000.00),
(909, 'Sandy Loam without a hard pan', 'NPK Fertilizer', 1650.00, 'Surface Irrigation', 8500.00),
(910, 'Red Sandy Loam', 'Compost', 1200.00, 'Drip Irrigation', 9000.00),
(911, 'Sandy Loam', 'Gypsum', 1100.00, 'Surface Irrigation', 9500.00);
INSERT INTO Crops (Crop_ID, Crop_Name, Cost_of_Implementation, Min_Temperature, Max_Temperature, Min_Rain, Max_Rain, Rate_per_kg, Qty_per_acre)
VALUES
(600, 'Rice', 6050.00, 25, 35, 175, 300, 80.00, 3000.00),
(601, 'Cotton', 3725.00, 21, 30, 50, 100, 70.00, 1200.00),
(602, 'Maize', 8750.00, 20, 30, 50, 100, 25.00, 500.00),
(603, 'Cashew', 2007.50, 24, 28, 60, 450, 710.00, 550.00),
(604, 'Ladyfinger', 4700.00, 20, 35, 50, 150, 34.00, 4405.00);
INSERT INTO Crop_Soil (Crop_ID, Soil_ID) 
VALUES 
(600, 900),
(600, 901),
(600, 902),
(601, 904),
(601, 905),
(601, 906),
(602, 902),
(602, 907),
(602, 908),
(603, 909),
(603, 910),
(603, 911),
(604, 901),
(604, 906),
(604, 911);
INSERT INTO Managers(Manager_ID, Manager_Name, Phone_No, Email_ID) VALUES 
(300, 'Aarav Sharma', '9876543210', 'aarav.sharma@gmail.com'),
(301, 'Vivaan Gupta', '8765432109', 'vivaan.gupta@gmail.com'),
(302, 'Aditya Verma', '7654321098', 'aditya.verma@gmail.com'),
(303, 'Vihaan Reddy', '6543210987', 'vihaan.reddy@gmail.com'),
(304, 'Arjun Patel', '5432109876', 'arjun.patel@gmail.com'),
(305, 'Sai Kapoor', '4321098765', 'sai.kapoor@gmail.com'),
(306, 'Krishna Rao', '3210987654', 'krishna.rao@gmail.com'),
(307, 'Nitya Singh', '2109876543', 'nitya.singh@gmail.com'),
(308, 'Ishaan Mehta', '1098765432', 'ishaan.mehta@gmail.com'),
(309, 'Reyansh Joshi', '1987654321', 'reyansh.joshi@gmail.com'),
(310, 'Meera Desai', '9876543212', 'meera.desai@gmail.com'),
(311, 'Aanya Bhatia', '8765432101', 'aanya.bhatia@gmail.com'),
(312, 'Rohan Nair', '7654321090', 'rohan.nair@gmail.com'),
(313, 'Pooja Agarwal', '6543210989', 'pooja.agarwal@gmail.com'),
(314, 'Siddharth Sethi', '5432109878', 'siddharth.sethi@gmail.com'),
(315, 'Tanvi Shah', '4321098767', 'tanvi.shah@gmail.com'),
(316, 'Karan Choudhury', '3210987656', 'karan.choudhury@gmail.com'),
(317, 'Simran Kaur', '2109876545', 'simran.kaur@gmail.com'),
(318, 'Devansh Tiwari', '1098765431', 'devansh.tiwari@gmail.com'),
(319, 'Nishant Roy', '1987654320', 'nishant.roy@gmail.com'),
(320, 'Aditi Malik', '9876543213', 'aditi.malik@gmail.com'),
(321, 'Tarun Yadav', '8765432102', 'tarun.yadav@gmail.com'),
(322, 'Kavya Iyer', '7654321091', 'kavya.iyer@gmail.com'),
(323, 'Riya Rani', '6543210980', 'riya.rani@gmail.com'),
(324, 'Ananya Kumar', '5432109877', 'ananya.kumar@gmail.com');
INSERT INTO Farmers (Farmer_ID, Farmer_Name, Phone_No, Specialization, No_of_Working_Days, Salary_Per_Day) VALUES 
(100, 'Suresh Kumar', '9876543214', 600, 30, 300.00),
(101, 'Rajesh Singh', '8765432145', 601, 28, 350.00),
(102, 'Vinod Sharma', '7654321456', 602, 25, 400.00),
(103, 'Deepak Verma', '6543214567', 603, 30, 250.00),
(104, 'Ravi Reddy', '5432145678', 604, 26, 450.00),
(105, 'Ajay Yadav', '4321456789', 600, 27, 300.00),
(106, 'Manoj Patel', '3214567890', 601, 29, 350.00),
(107, 'Kumar Iyer', '2105678901', 602, 30, 400.00),
(108, 'Rahul Bhatia', '1096789012', 603, 25, 250.00),
(109, 'Prakash Joshi', '1987890123', 604, 28, 450.00),
(110, 'Nitin Gupta', '9878901234', 600, 30, 300.00),
(111, 'Pawan Sharma', '8769012345', 601, 27, 350.00),
(112, 'Suraj Kumar', '7650123456', 602, 26, 400.00),
(113, 'Arvind Sethi', '6541234567', 603, 30, 250.00),
(114, 'Sunil Nair', '5432345678', 604, 28, 450.00),
(115, 'Ramesh Singh', '4323456789', 600, 29, 300.00),
(116, 'Anil Agarwal', '3214567890', 601, 30, 350.00),
(117, 'Mukesh Verma', '2105678901', 602, 25, 400.00),
(118, 'Ashok Kumar', '1096789012', 603, 28, 250.00),
(119, 'Gaurav Mehta', '1987890123', 604, 27, 450.00),
(120, 'Shivendra Yadav', '9878901234', 600, 30, 300.00),
(121, 'Praveen Singh', '8769012345', 601, 28, 350.00),
(122, 'Vijay Choudhury', '7650123456', 602, 29, 400.00),
(123, 'Amit Kapoor', '6541234567', 603, 26, 250.00),
(124, 'Himanshu Jain', '5432345678', 604, 30, 450.00),
(125, 'Kiran Rani', '4323456789', 600, 28, 300.00),
(126, 'Deepa Patel', '3214567890', 601, 30, 350.00),
(127, 'Sheetal Sharma', '2105678901', 602, 27, 400.00),
(128, 'Rajendra Rao', '1096789012', 603, 25, 250.00),
(129, 'Gita Mehta', '1987890123', 604, 30, 450.00),
(130, 'Rohit Yadav', '9878901234', 600, 30, 300.00),
(131, 'Rekha Singh', '8769012345', 601, 29, 350.00),
(132, 'Neha Verma', '7650123456', 602, 28, 400.00),
(133, 'Tushar Kumar', '6541234567', 603, 27, 250.00),
(134, 'Sanjay Agarwal', '5432345678', 604, 30, 450.00),
(135, 'Vikas Nair', '4323456789', 600, 28, 300.00),
(136, 'Nisha Gupta', '3214567890', 601, 30, 350.00),
(137, 'Kavita Singh', '2105678901', 602, 29, 400.00),
(138, 'Manisha Verma', '1096789012', 603, 26, 250.00),
(139, 'Kajal Rani', '1987890123', 604, 30, 450.00),
(140, 'Parveen Yadav', '9878901234', 600, 30, 300.00),
(141, 'Meenal Shah', '8769012345', 601, 28, 350.00),
(142, 'Rajiv Rao', '7650123456', 602, 30, 400.00),
(143, 'Kunal Joshi', '6541234567', 603, 25, 250.00),
(144, 'Anita Malik', '5432345678', 604, 28, 450.00),
(145, 'Vijay Raj', '4323456789', 600, 30, 300.00),
(146, 'Sarita Bhatia', '3214567890', 601, 30, 350.00),
(147, 'Vinita Sethi', '2105678901', 602, 25, 400.00),
(148, 'Neelam Agarwal', '1096789012', 603, 28, 250.00),
(149, 'Ishita Kumar', '1987890123', 604, 27, 450.00),
(150, 'Umesh Rani', '9878901234', 600, 30, 300.00),
(151, 'Pankaj Choudhury', '8769012345', 601, 28, 350.00),
(152, 'Jayesh Nair', '7650123456', 602, 30, 400.00),
(153, 'Anjali Kapoor', '6541234567', 603, 25, 250.00),
(154, 'Kajal Yadav', '5432345678', 604, 30, 450.00),
(155, 'Mohan Singh', '4323456789', 600, 29, 300.00),
(156, 'Divya Verma', '3214567890', 601, 30, 350.00),
(157, 'Ajit Kumar', '2105678901', 602, 26, 400.00),
(158, 'Neeraj Joshi', '1096789012', 603, 30, 250.00),
(159, 'Siddhi Rani', '1987890123', 604, 28, 450.00),
(160, 'Alok Mehta', '9878901234', 600, 30, 300.00),
(161, 'Gaurav Singh', '8769012345', 601, 27, 350.00),
(162, 'Pradeep Reddy', '7650123456', 602, 30, 400.00),
(163, 'Vinay Patel', '6541234567', 603, 30, 250.00),
(164, 'Suman Agarwal', '5432345678', 604, 29, 450.00),
(165, 'Varun Mishra', '9876543215', 600, 30, 320.00),
(166, 'Aman Chauhan', '8765432156', 601, 28, 360.00),
(167, 'Preeti Shukla', '7654321567', 602, 27, 410.00),
(168, 'Arun Bhatt', '6543215678', 603, 25, 260.00),
(169, 'Nidhi Srivastava', '5432156789', 604, 29, 460.00),
(170, 'Sonal Saxena', '4321567890', 600, 28, 320.00),
(171, 'Vikrant Deshmukh', '3215678901', 601, 30, 370.00),
(172, 'Ritika Das', '2106789012', 602, 26, 420.00),
(173, 'Abhay Raj', '1097890123', 603, 27, 270.00),
(174, 'Meghna Pandey', '1988901234', 604, 30, 470.00),
(175, 'Sneha Kulkarni', '9876543220', 600, 28, 320.00),
(176, 'Ankita Sinha', '8765432201', 601, 29, 360.00),
(177, 'Rohit Choudhury', '7654322212', 602, 30, 410.00),
(178, 'Abhinav Tripathi', '6543212233', 603, 26, 270.00),
(179, 'Shruti Gupta', '5432152234', 604, 27, 460.00),
(180, 'Sagar Reddy', '4321562235', 600, 30, 320.00),
(181, 'Vishal Jain', '3215672236', 601, 28, 370.00),
(182, 'Shalini Sinha', '2106782237', 602, 25, 420.00),
(183, 'Ajay Bhatt', '1097892238', 603, 30, 270.00),
(184, 'Madhuri Yadav', '1988902239', 604, 26, 470.00),
(185, 'Sandeep Kumar', '9877651230', 600, 30, 320.00),
(186, 'Aishwarya Rao', '8765432100', 601, 29, 360.00),
(187, 'Niraj Mehta', '7654321560', 602, 28, 410.00),
(188, 'Ravi Chaudhary', '6543211234', 603, 30, 270.00),
(189, 'Pallavi Shah', '5432100987', 604, 27, 460.00),
(190, 'Vikram Shetty', '4321098765', 600, 30, 320.00),
(191, 'Anuradha Yadav', '3210987654', 601, 28, 370.00),
(192, 'Tanuja Singh', '2109876543', 602, 25, 420.00),
(193, 'Rahul Pandey', '1098765432', 603, 30, 270.00),
(194, 'Sakshi Verma', '1987654321', 604, 26, 470.00),
(195, 'Naveen Gupta', '9876541230', 600, 30, 320.00),
(196, 'Geeta Malhotra', '8765432109', 601, 29, 360.00),
(197, 'Arjun Kapoor', '7654321987', 602, 28, 410.00),
(198, 'Vineet Patel', '6543212098', 603, 26, 270.00),
(199, 'Kavya Joshi', '5432198760', 604, 30, 460.00),
(200, 'Manish Sethi', '4321987650', 600, 29, 320.00),
(201, 'Chirag Sharma', '3219876540', 601, 28, 370.00),
(202, 'Varsha Aggarwal', '2108765431', 602, 25, 420.00),
(203, 'Sahil Mehra', '1097654321', 603, 30, 270.00),
(204, 'Monika Nair', '1986543210', 604, 26, 470.00),
(205, 'Rohit Khanna', '9875432100', 600, 30, 320.00),
(206, 'Anjali Singh', '8764321098', 601, 29, 360.00),
(207, 'Amit Verma', '7653210987', 602, 30, 410.00),
(208, 'Saniya Malik', '6542109876', 603, 28, 270.00),
(209, 'Rina Shah', '5432109876', 604, 27, 460.00),
(210, 'Siddharth Yadav', '4321098765', 600, 30, 320.00),
(211, 'Priya Iyer', '3210987654', 601, 29, 370.00),
(212, 'Niharika Rao', '2109876543', 602, 25, 420.00),
(213, 'Abhay Verma', '1098765432', 603, 30, 270.00),
(214, 'Sneha Singh', '1987654321', 604, 26, 470.00),
(215, 'Suman Sharma', '9876542109', 600, 30, 320.00),
(216, 'Aarti Mehta', '8765432109', 601, 29, 360.00),
(217, 'Rakesh Kumar', '7654321987', 602, 30, 410.00),
(218, 'Tanvi Gupta', '6543212098', 603, 28, 270.00),
(219, 'Akash Nair', '5432198760', 604, 30, 460.00),
(220, 'Vineeta Rao', '4321987650', 600, 29, 320.00),
(221, 'Raghu Sethi', '3219876540', 601, 28, 370.00),
(222, 'Sonal Gupta', '2108765431', 602, 25, 420.00),
(223, 'Devendra Yadav', '1097654321', 603, 30, 270.00),
(224, 'Parul Joshi', '1986543210', 604, 26, 470.00),
(225, 'Gopal Singh', '9875432100', 600, 30, 320.00),
(226, 'Anita Nair', '8764321098', 601, 29, 360.00),
(227, 'Harsh Kapoor', '7653210987', 602, 30, 410.00),
(228, 'Swati Jain', '6542109876', 603, 28, 270.00),
(229, 'Varun Desai', '5432109876', 604, 27, 460.00),
(230, 'Akshay Patel', '4321098765', 600, 30, 320.00),
(231, 'Meera Gupta', '3210987654', 601, 29, 370.00),
(232, 'Manoj Sharma', '2109876543', 602, 25, 420.00),
(233, 'Simran Kaur', '1098765432', 603, 30, 270.00),
(234, 'Isha Verma', '1987654321', 604, 26, 470.00),
(235, 'Dev Mishra', '9876542109', 600, 30, 320.00),
(236, 'Pratiksha Iyer', '8765432109', 601, 29, 360.00),
(237, 'Ashwin Desai', '7654321987', 602, 30, 410.00),
(238, 'Nidhi Kapoor', '6543212098', 603, 28, 270.00),
(239, 'Anusha Singh', '5432198760', 604, 27, 460.00),
(240, 'Nirav Mehta', '4321987650', 600, 29, 320.00),
(241, 'Pooja Reddy', '3219876540', 601, 28, 370.00),
(242, 'Gagan Sethi', '2108765431', 602, 25, 420.00),
(243, 'Vishnu Patel', '1097654321', 603, 30, 270.00),
(244, 'Amita Rao', '1986543210', 604, 26, 470.00),
(245, 'Karan Kumar', '9875432100', 600, 30, 320.00),
(246, 'Shubham Yadav', '8764321098', 601, 29, 360.00),
(247, 'Preeti Shah', '7653210987', 602, 30, 410.00),
(248, 'Aakash Nair', '6542109876', 603, 28, 270.00),
(249, 'Jaya Choudhury', '5432109876', 604, 27, 460.00);