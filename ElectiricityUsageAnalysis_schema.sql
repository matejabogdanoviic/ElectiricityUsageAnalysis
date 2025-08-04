
CREATE DATABASE ElectiricityUsageAnalysis

USE ElectiricityUsageAnalysis


CREATE TABLE Residences (
    ResidenceID INT PRIMARY KEY,
    StreetAddress NVARCHAR(100),
    City NVARCHAR(50),
    NumberOfOccupants INT,
    SolarPanelsStatus NVARCHAR(10),
    MeterType NVARCHAR(50),
    ContactEmail NVARCHAR(100)
);


CREATE TABLE ConsumptionRecords (
    RecordID INT PRIMARY KEY,
    ResidenceID INT,
    Date DATE,
    KilowattHours DECIMAL(10,2),
    PartOfDay NVARCHAR(20),
    ReadingType NVARCHAR(20),
    FOREIGN KEY (ResidenceID) REFERENCES Residences(ResidenceID)
);


CREATE TABLE PricingPlans (
    PlanID INT PRIMARY KEY,
    PlanName NVARCHAR(50),
    RatePerKWh DECIMAL(10,4),
    EffectiveFrom DATE,
    EffectiveTo DATE,
    PeakHours NVARCHAR(50),
    Status NVARCHAR(10)
);


CREATE TABLE Bills (
    BillID INT PRIMARY KEY,
    ResidenceID INT,
    BillingStart DATE,
    BillingEnd DATE,
    TotalKWh DECIMAL(10,2),
    TotalCharge DECIMAL(12,2),
    PaymentStatus NVARCHAR(20),
    GeneratedDate DATETIME,
    FOREIGN KEY (ResidenceID) REFERENCES Residences(ResidenceID)
);


CREATE TABLE Appliances (
    ApplianceID INT PRIMARY KEY,
    ResidenceID INT,
    Type NVARCHAR(50),
    EstimatedDailyUsage DECIMAL(6,2),
    Location NVARCHAR(50),
    PurchaseDate DATE,
    FOREIGN KEY (ResidenceID) REFERENCES Residences(ResidenceID)
);


