-- Supply Chain Logistics Database Analysis Project

-- 1. Total Orders and Weight by Plant
 SELECT 
    o.Plant_Code,
    COUNT(*) AS Total_Orders,
    SUM(o.Unit_quantity) AS Total_Units,
    SUM(o.Weight) AS Total_Weight
FROM OrderList o
GROUP BY o.Plant_Code
ORDER BY Total_Orders DESC;

-- 2. Orders by Plant and Valid Ports
SELECT 
    o.Plant_Code,
	o.Origin_Port,
    o.Destination_Port,
    pp.[Port] AS Origin_Port,
    COUNT(*) AS Order_Count
FROM OrderList o
LEFT JOIN PlantPorts pp ON o.Plant_Code = pp.Plant_Code 
GROUP BY o.Plant_Code, o.Destination_Port, pp.Port, o.Origin_Port
HAVING pp.Port IS NOT NULL
ORDER BY Order_Count DESC;

-- 3. Top 5 Most Ordered Products by Unit
SELECT TOP 5 Product_ID, Plant_Code, SUM(Unit_Quantity) AS Total_Units
FROM OrderList
GROUP BY Product_ID, Plant_Code
ORDER BY Total_Units DESC;

-- 4. Top 5 Most Ordered Products By Number of Orders Placed
SELECT TOP 5 Product_ID, COUNT(*) AS OrderCount
FROM OrderList
GROUP BY Product_ID
ORDER BY OrderCount DESC;


-- 5. Plants Exceeding Historical Average Order Volume
WITH PlantOrderCounts AS (
    SELECT Plant_Code, COUNT(*) AS Total_Orders
    FROM OrderList
    GROUP BY Plant_Code
),
AvgOrders AS (
    SELECT AVG(CAST(Total_Orders AS FLOAT)) AS Avg_Orders FROM PlantOrderCounts
)
SELECT p.Plant_Code, p.Total_Orders
FROM PlantOrderCounts p
CROSS JOIN AvgOrders a 
WHERE p.Total_Orders > a.Avg_Orders
ORDER BY p.Total_Orders DESC;

-- 6. Top 5 Plants by Total Weight Shipped
WITH PlantWeight AS (
    SELECT 
        Plant_Code,
        ROUND(SUM(Weight), 2) AS Total_Weight,
        COUNT(*) AS Order_Count
    FROM OrderList
    GROUP BY Plant_Code
)
SELECT TOP 5
    pw.Plant_Code,
    pw.Total_Weight,
    pw.Order_Count,
    RANK() OVER (ORDER BY pw.Total_Weight DESC) AS Weight_Rank
FROM PlantWeight pw
ORDER BY Total_Weight DESC;

-- 7. Identify Orders Exceeding Weight Limits
WITH shipping_table AS(
	SELECT o.Order_ID, o.Origin_Port, o.Destination_Port, o.Weight, f.max_wgh_qty,
		   CASE 
			   WHEN o.Weight > f.max_wgh_qty THEN 'EXCEEDED'
			   ELSE 'WITHIN LIMIT'
		   END AS Shipping_Status
	FROM OrderList o
	JOIN FreightRates f ON o.Origin_Port = f.orig_port_cd 
						AND o.Destination_Port = f.dest_port_cd
)
SELECT DISTINCT *
FROM shipping_table
WHERE Shipping_Status = 'EXCEEDED'
ORDER BY [Weight] DESC;

-- 8.  Warehouse Utilisation Analysis
SELECT
  o.Plant_Code,
  CAST(o.Order_Date AS DATE) AS OrderDay,
  SUM(o.Unit_quantity) AS TotalUnits,
  wc.Daily_Capacity,
  CASE 
    WHEN SUM(o.Unit_quantity) > wc.Daily_Capacity THEN 'Over Capacity' 
    ELSE 'Under Capacity' 
  END AS CapacityStatus
FROM OrderList o
JOIN WarehouseCapacity wc
  ON o.Plant_Code = wc.Plant_ID
GROUP BY o.Plant_Code, CAST(o.Order_Date AS DATE), wc.Daily_Capacity;

-- 9.  On-Time Shipping Percentage by Carrier
SELECT Carrier,
	CAST(SUM(CASE WHEN Ship_Late_Day_count = 0 THEN 1 ELSE 0 END) * 100.00
    / COUNT(*) AS DECIMAL (10, 2)) AS OnTimeRate
FROM OrderList
GROUP BY Carrier
ORDER BY OnTimeRate DESC;

-- 10. Logistics Cost
SELECT
    o.Order_ID,
    -- Freight Cost
    CASE 
        WHEN o.Weight < f.minm_wgh_qty THEN f.minimum_cost
        ELSE ROUND(o.Weight * f.rate, 2)
    END AS Freight_Cost,

    -- Warehouse Cost
    ROUND(o.Unit_quantity * wc.Cost_unit, 2) AS Warehouse_Cost,

    -- Summation
    CASE 
        WHEN o.Weight < f.minm_wgh_qty THEN f.minimum_cost
        ELSE ROUND(o.Weight * f.rate, 2)
    END 
    + ROUND((o.Unit_quantity * wc.Cost_unit), 2) AS Total_Logistics_Cost
FROM OrderList AS o
INNER JOIN FreightRates AS f
    ON  o.Carrier = f.Carrier
    AND o.Origin_Port = f.orig_port_cd
    AND o.Destination_Port = f.dest_port_cd
    -- Ensure the weight fits the appropriate band
    AND o.Weight BETWEEN f.minm_wgh_qty AND f.max_wgh_qty
INNER JOIN WarehouseCosts AS wc
    ON O.Plant_Code = wc.WH;



