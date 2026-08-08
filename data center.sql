-- PART 1: Database Initialization & Setup

CREATE DATABASE private_smart_clinic_db;
USE private_smart_clinic_db;
-- PART 2: Schema Definition (Tables, Constraints & Data Types)
CREATE TABLE Patient (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    ContactDetails VARCHAR(100) UNIQUE
);
CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    ContactDetails VARCHAR(100)
);
CREATE TABLE Doctor (
    EmployeeID INT PRIMARY KEY,
    Speciality VARCHAR(100) NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE
);
CREATE TABLE Receptionist (
    EmployeeID INT PRIMARY KEY,
    DeskNumber INT NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE
);
CREATE TABLE Medicine (
    MedicineID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Stock INT NOT NULL
);
CREATE TABLE Appointment (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    ApptDate DATETIME NOT NULL,
    Duration INT NOT NULL,
    PatientID INT NOT NULL,
    EmployeeID_Doctor INT NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (EmployeeID_Doctor) REFERENCES Doctor(EmployeeID)
);
CREATE TABLE Treatment (
    TreatmentID INT AUTO_INCREMENT PRIMARY KEY,
    Details VARCHAR(255),
    AppointmentID INT UNIQUE NOT NULL,
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);
CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    PayDate DATETIME NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    AppointmentID INT UNIQUE NOT NULL,
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);
CREATE TABLE Treatment_Medicine (
    TreatmentID INT,
    MedicineID INT,
    Quantity INT NOT NULL,
    PRIMARY KEY (TreatmentID, MedicineID),
    FOREIGN KEY (TreatmentID) REFERENCES Treatment(TreatmentID) ON DELETE CASCADE,
    FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID) ON DELETE CASCADE
);
-- PART 3: Insert Statements
INSERT INTO Patient (Name, ContactDetails) VALUES
('Tariq Al-Ghamdi', '0551234567'),
('Noura Al-Shahrani', '0552345678'),
('Abdullah Al-Dossary', '0553456789'),
('Reem Al-Zahrani', '0554567890'),
('Mohammed Al-Shehri', '0555678901');

INSERT INTO Employee (Name, ContactDetails) VALUES
('Dr. Yousef Al-Mansour', '0507771111'),
('Dr. Mona Al-Ahmadi', '0507772222'),
('Dr. Tariq Al-Khatib', '0507773333'),
('Dr. Huda Al-Najjar', '0507774444'),
('Sami Admin', '0508881111'),
('Lama Front', '0508882222'),
('Yasser Desk', '0508883333');

INSERT INTO Doctor (EmployeeID, Speciality) VALUES
(1, 'Neurology'),
(2, 'Ophthalmology'),
(3, 'ENT'),
(4, 'General Surgery');

INSERT INTO Receptionist (EmployeeID, DeskNumber) VALUES
(5, 101),
(6, 102),
(7, 103);
INSERT INTO Medicine (Name, Stock) VALUES
('Paracetamol', 120),
('Ibuprofen', 45),
('Amoxicillin', 25),
('Cetirizine', 90),
('Omeprazole', 60);

INSERT INTO Appointment (ApptDate, Duration, PatientID, EmployeeID_Doctor) VALUES
('2026-03-10 09:00:00', 30, 1, 1),
('2026-03-11 10:30:00', 45, 2, 2),
('2026-03-12 11:15:00', 15, 3, 3),
('2026-03-13 13:00:00', 60, 4, 4),
('2026-03-14 15:30:00', 30, 5, 1);

INSERT INTO Treatment (Details, AppointmentID) VALUES
('Take 1 pill every 8 hours after meals', 1),
('Apply eye drops 3 times daily', 2),
('Rest for 3 days and drink warm fluids', 3),
('Post-surgery follow up and wound dressing', 4),
('Take medication once before bed', 5);

INSERT INTO Payment (PayDate, Amount, AppointmentID) VALUES
('2026-03-10 09:40:00', 250.00, 1),
('2026-03-11 11:25:00', 400.00, 2),
('2026-03-12 11:40:00', 180.00, 3),
('2026-03-13 14:10:00', 650.00, 4),
('2026-03-14 16:10:00', 250.00, 5);

INSERT INTO Treatment_Medicine (TreatmentID, MedicineID, Quantity) VALUES
(1, 1, 20),
(2, 4, 2),
(3, 3, 1),
(4, 5, 15),
(5, 2, 10);
--  Calculate the average payment amount for each appointment useing (GROUP BY)
SELECT 
    AppointmentID, 
    AVG(Amount) AS AveragePaid
FROM 
    Payment
GROUP BY 
    AppointmentID;
    
-- Join Query
SELECT 
    Patient.Name, 
    Appointment.ApptDate 
FROM 
    Patient
JOIN 
    Appointment ON Patient.PatientID = Appointment.PatientID;
-- Nested Subquery: Retrieve names of medicines prescribed with a quantity greater than 12
SELECT Name 
FROM Medicine 
WHERE MedicineID IN (
    SELECT MedicineID 
    FROM Treatment_Medicine 
    WHERE Quantity > 12
);
-- Update the desk number for the receptionist with EmployeeID = 5
UPDATE Receptionist 
SET DeskNumber = 205 
WHERE EmployeeID = 5;

-- Delete a specific appointment (AppointmentID = 5) from the database
DELETE FROM Payment 
WHERE PaymentID = 5;
-- Create View Display long consultation appointments (duration of 45 minutes or more)
CREATE VIEW LongAppointments AS
SELECT 
    AppointmentID, 
    ApptDate, 
    Duration, 
    PatientID 
FROM 
    Appointment 
WHERE 
    Duration >= 45;
    -- Create Trigger Prevent inserting negative or zero payment amounts
    DELIMITER //
CREATE TRIGGER CheckPositivePayment
BEFORE INSERT ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Payment amount must be greater than zero.';
    END IF;
    
END;
//
DELIMITER ;
