--SELECT * 
--FROM FactInternetSales
SELECT CustomerKey, OrderQuantity, UnitPrice, TotalProductCost, SalesAmount, TaxAmt
FROM FactInternetSales
WHERE TaxAmt > 280
ORDER BY CustomerKey;
