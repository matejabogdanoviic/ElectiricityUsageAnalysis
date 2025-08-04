--Consumption Analysis by City
--Create a query that shows the total electricity consumption per city, sorted in descending order by consumption, along with the average number of occupants per household

SELECT r.City,SUM(cr.KilowattHours) AS TotalElUsageByCity,AVG(r.NumberOfOccupants) AS AvgOccupantsPerFlat
FROM Residences r
LEFT JOIN ConsumptionRecords cr
ON r.ResidenceID=cr.ResidenceID
GROUP BY r.City
ORDER BY TotalElUsageByCity DESC;


--Write a report to show Average Usage of Electricity per KWH for Every WeekDay

SELECT 
    DATENAME(weekday, Date) AS Weekday,
    AVG(KilowattHours) AS AvgKWhPerDay
FROM ConsumptionRecords 
WHERE YEAR(Date) = 2024
GROUP BY DATENAME(weekday, Date), DATEPART(weekday, Date)
ORDER BY DATEPART(weekday,Date);



--Comparing Bills with and without Solar Panels
--Create a query that compares the average electricity bills between households with and without solar panels, including the percentage of savings.
-- created nonclustered Index to improve query performance
CREATE NONCLUSTERED INDEX idx_Residences_SolarPanelsStatus
ON Residences(SolarPanelsStatus);


GO
WITH cte AS (
SELECT 
AVG(CASE WHEN r.SolarPanelsStatus='Yes' THEN TotalCharge ELSE NULL END) AS AvgCostWithSolar,
AVG(CASE WHEN r.SolarPanelsStatus='No' THEN TotalCharge ELSE NULL END) AS AvgCostWithNoSolar
FROM Residences r
LEFT JOIN Bills b
ON r.ResidenceID=b.ResidenceID
)

SELECT AvgCostWithNoSolar,AvgCostWithSolar,ROUND((((AvgCostWithNoSolar-AvgCostWithSolar)/AvgCostWithNoSolar)*100.00),2) AS
PercentageSavedWithSolar
FROM cte;
GO


--Location With Most Daily Usage of Electricity
--Find the top 3 locations in the House of HouseHolder which use the most amount of electricity

GO
WITH cte AS (
SELECT Location,SUM(EstimatedDailyUsage) AS TotalElectricityUsage,
ROW_NUMBER() OVER(ORDER BY SUM(EstimatedDailyUsage) DESC) AS rn
  FROM Appliances
GROUP BY Location
)

SELECT * FROM cte
WHERE rn<=3;

   
  -- Shows total kWh used by each residence during Morning and Night in 2024.
-- Results are sorted by usage (descending) and address.

  SELECT 
    r.ResidenceID,
    r.StreetAddress,
    SUM(c.KilowattHours) AS KWh
FROM Residences r
JOIN ConsumptionRecords c ON r.ResidenceID = c.ResidenceID
WHERE YEAR(c.Date) = 2024 AND (c.PartOfDay='Morning' OR c.PartOfDay='Night')
GROUP BY r.ResidenceID, r.StreetAddress
ORDER BY KWh DESC, r.StreetAddress;



--Write a query to show Top 10 most used Appliances

SELECT TOP 5
    Type,
    COUNT(*) AS ApplianceCount
FROM Appliances
GROUP BY Type
ORDER BY ApplianceCount DESC;



----Create a View that shows all appliances per residence
-- It shows total number of appliances and average daily usage for each residence

GO
CREATE VIEW vw_ApplianceSummaryPerResidence AS
SELECT
    r.ResidenceID,
    r.StreetAddress,
    COUNT(a.ApplianceID) AS TotalAppliances,
    ROUND(AVG(a.EstimatedDailyUsage), 2) AS AvgDailyUsagePerAppliance
FROM Residences r
LEFT JOIN Appliances a 
ON r.ResidenceID = a.ResidenceID
GROUP BY r.ResidenceID, r.StreetAddress;
GO

--SELECT * FROM vw_ApplianceSummaryPerResidence
--ORDER BY TotalAppliances DESC;

CREATE NONCLUSTERED INDEX idx_ConsumptionRecords_Date
ON ConsumptionRecords(Date);

-- Retrieve ResidenceID and KilowattHours for records from the year 2024
-- Results are ordered by 'Date' ascending and then by 'KilowattHours' descending

SELECT 
    ResidenceID,
    Date,
    KilowattHours
FROM ConsumptionRecords
WHERE YEAR(Date) = 2024
ORDER BY Date ASC, KilowattHours DESC;



---- Create a stored procedure that returns the count of active pricing plans and the average rate per kWh 
-- within a specified period of time


GO
CREATE PROCEDURE sp_ActivePricingPlan
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        COUNT(PlanID) AS ActivePlansCount,
        AVG(RatePerKWh) AS AvgKWhRate
    FROM PricingPlans
    WHERE Status = 'Active'
      AND EffectiveFrom <= @EndDate
      AND EffectiveTo >= @StartDate;
END;
GO


-- EXEC sp_ActivePricingPlan @StartDate = '2024-01-01', @EndDate = '2024-06-30';


--Create a stored Procedure to create new Appliance easier
GO
CREATE PROCEDURE sp_AddNewAppliance
    @ResidenceID INT,
    @Type NVARCHAR(50),
    @EstimatedDailyUsage DECIMAL(6,2),
    @Location NVARCHAR(50),
    @PurchaseDate DATE
AS
BEGIN
    INSERT INTO Appliances (ResidenceID, Type, EstimatedDailyUsage, Location, PurchaseDate)
    VALUES (@ResidenceID, @Type, @EstimatedDailyUsage, @Location, @PurchaseDate);
END;
GO

--EXEC sp_AddAppliance 
 --   @ResidenceID = 7, 
 --   @Type = 'Desk Lamp', 
 --   @EstimatedDailyUsage = 0.15, 
 --   @Location = 'Study Room', 
 --   @PurchaseDate = '2023-09-20';
