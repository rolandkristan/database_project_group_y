--Generiere die Standardabweichung per Aktien ID
Select s."Stock_ID", stddev(s."Close_Price")
From "project_db"."Stock_Prices_Tbl" AS s
Group By s."Stock_ID";

--Join mit dem Namen des Unternehmens - erstelle als temporäre Tabelle
Create TEMP TABLE tempr_risk AS
Select c."Company_Name", s."Stock_ID", Round(stddev(s."Close_Price")::numeric, 2) AS "Volatility/Risk"
From "project_db"."Stock_Prices_Tbl" AS s
Left Join "project_db"."Company_Tbl" AS c ON s."Stock_ID" = c."Company_ID"
Group By c."Company_Name", s."Stock_ID";

--Look up temporary table (maybe useful for visualization)
Select *
From "tempr_risk"

--Früheste verfügbarer Preis per Aktie
Select c."Company_Name", MIN(s."Date")
From "project_db"."Stock_Prices_Tbl" AS s
Inner Join "project_db"."Company_Tbl" AS c ON s."Stock_ID" = c."Company_ID"
Group By c."Company_Name";

--Differenz & Rendite per Aktie der letzten 5 Jahre
Select a."Stock_ID", Round("Close_Price_Begin"::numeric, 2) AS "Close Price Begin", Round("Close_Price_End"::numeric, 2) AS "Close Price End", Round(("Close_Price_End" - "Close_Price_Begin")::numeric, 2) AS "Difference", Round((("Close_Price_End" - "Close_Price_Begin") / "Close_Price_Begin"*100)::numeric, 2) AS "Rate of Return in %"
From (Select s."Stock_ID", s."Close_Price" AS "Close_Price_Begin"
		From "project_db"."Stock_Prices_Tbl" AS s
		Where s."Date" = '2019-01-04 00:00:00') a
INNER JOIN (Select s."Stock_ID", s."Close_Price" AS "Close_Price_End"
		From "project_db"."Stock_Prices_Tbl" AS s
		Where s."Date" = '2024-12-30 00:00:00') b ON a."Stock_ID" = b."Stock_ID";

--Vertretene Industrien im Index
Select Distinct i."Industry"
From "project_db"."Industry_Tbl" AS i;

--Ausgangstabelle für Visualisierungen (Rendite per Aktie mit Infos zum Land und der jeweiligen Industrie)
Select c."Company_Name", geo."Country_Name", i."Industry" , rendite.*
From (
	Select a."Stock_ID", Round("Close_Price_Begin"::numeric, 2) AS "Close Price Begin", Round("Close_Price_End"::numeric, 2) AS "Close Price End", Round(("Close_Price_End" - "Close_Price_Begin")::numeric, 2) AS "Difference", Round((("Close_Price_End" - "Close_Price_Begin") / "Close_Price_Begin"*100)::numeric, 2) AS "Rate of Return in %"
	From (Select s."Stock_ID", s."Close_Price" AS "Close_Price_Begin"
			From "project_db"."Stock_Prices_Tbl" AS s
			Where s."Date" = '2019-01-04 00:00:00') a
	INNER JOIN (Select s."Stock_ID", s."Close_Price" AS "Close_Price_End"
			From "project_db"."Stock_Prices_Tbl" AS s
			Where s."Date" = '2024-12-30 00:00:00') b ON a."Stock_ID" = b."Stock_ID"
) rendite
Left Join "project_db"."Company_Tbl" AS c ON rendite."Stock_ID" = c."Company_ID"
Left Join "project_db"."Country_Tbl" AS geo ON c."Country_Headquarter" = geo."Country_ID"
Left Join "project_db"."Industry_Tbl" AS i ON c."Activity_ID" = i."Activity_ID";




