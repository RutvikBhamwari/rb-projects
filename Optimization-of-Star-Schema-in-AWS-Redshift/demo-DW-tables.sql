/*

============================

DEMO 1 DDL

============================

*/
DROP TABLE IF EXISTS dim_date, dim_product, fact_sales CASCADE;
CREATE TABLE IF NOT EXISTS dim_date
    (
      DateKey INT NULL ,
      AlternateDateKey NVARCHAR(245) NULL sortkey,
      DayOfWeek INT  NULL ,
      DayOfMonth INT  NULL ,
      WeekOfYear INT  NULL ,
      MonthOfYear INT  NULL ,
      Quarter INT  NULL ,
      CONSTRAINT PK_DimDate PRIMARY KEY ( DateKey )
    ) DISTSTYLE ALL;

CREATE TABLE IF NOT EXISTS dim_product
    (
      ProductKey INT NOT NULL sortkey distkey,
      ProductAlternateKey NVARCHAR(25) NULL ,
      ProductSubcategoryKey INT NULL ,
      WeightUnitMeasureCode NCHAR(3) NULL ,
      SizeUnitMeasureCode NCHAR(3) NULL ,
      ProductName NVARCHAR(50) NOT NULL ,
      StandardCost NUMERIC(15, 2) NULL ,
      FinishedGoodsFlag bool NOT NULL ,
      Color NVARCHAR(15) NOT NULL ,
      SafetyStockLevel INT NULL ,
      ReorderPoint INT NULL ,
      ListPrice NUMERIC(15, 2) NULL ,
      Size NVARCHAR(50) NULL ,
      SizeRange NVARCHAR(50) NULL ,
      Weight FLOAT NULL ,
      DaysToManufacture INT NULL ,
      ProductLine NCHAR(2) NULL ,
      DealerPrice NUMERIC(15, 2) NULL ,
      Class NCHAR(2) NULL ,
      Style NCHAR(2) NULL ,
      ModelName NVARCHAR(50) NULL ,
      Description NVARCHAR(400) NULL ,
      StartDate NVARCHAR(245) NULL ,
      EndDate NVARCHAR(245) NULL ,
      Status NVARCHAR(7) NULL ,
      CONSTRAINT PK_Product PRIMARY KEY ( ProductKey )
    ); 

CREATE TABLE IF NOT EXISTS fact_sales
    (
      ProductKey INT NOT NULL ,
      OrderDateKey INT NOT NULL distkey sortkey,
      DueDateKey INT NOT NULL ,
      ShipDateKey INT NOT NULL ,
      CustomerKey INT NOT NULL ,
      CurrencyKey INT NOT NULL ,
      SalesTerritoryKey INT NOT NULL ,
      SalesOrderNumber NVARCHAR(20) NOT NULL ,
      SalesOrderLineNumber INT NOT NULL ,
      ukcol NVARCHAR(245) NOT NULL,
      RevisionNumber INT NOT NULL ,
      OrderQuantity INT NOT NULL ,
      UnitPrice NUMERIC(15, 2) NOT NULL ,
      ExtendedAmount NUMERIC(15, 2) NOT NULL ,
      UnitPriceDiscountPct FLOAT NOT NULL ,
      DiscountAmount FLOAT NOT NULL ,
      ProductStandardCost NUMERIC(15, 2) NOT NULL ,
      TotalProductCost NUMERIC(15, 2) NOT NULL ,
      SalesAmount NUMERIC(15, 2) NOT NULL ,
      TaxAmt NUMERIC(15, 2) NOT NULL ,
      Freight NUMERIC(15, 2) NOT NULL ,
      CarrierTrackingNumber NVARCHAR(25) NULL ,
      CustomerPONumber NVARCHAR(25) NULL ,
      OrderDate NVARCHAR(245) NULL ,
      DueDate NVARCHAR(245) NULL ,
      ShipDate NVARCHAR(245) NULL ,
      CONSTRAINT PK_FactSales_ PRIMARY KEY
        ( SalesOrderNumber, SalesOrderLineNumber )
    );

ALTER TABLE fact_sales ADD CONSTRAINT FK_DimDate FOREIGN KEY(OrderDateKey)
REFERENCES dim_date (DateKey);
 
 
ALTER TABLE fact_sales  ADD CONSTRAINT FK_DimDate1 FOREIGN KEY(DueDateKey)
REFERENCES   dim_date  ( DateKey );
 
 
ALTER TABLE fact_sales ADD CONSTRAINT FK_DimDate2 FOREIGN KEY( ShipDateKey )
REFERENCES dim_date  ( DateKey );
 
 
ALTER TABLE fact_sales ADD CONSTRAINT  FK_DimProduct  FOREIGN KEY( ProductKey )
REFERENCES dim_product (ProductKey); 

/*
========================


DEMO 2 DDL


========================
*/
DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer (
  customer_skey int NOT NULL sortkey distkey,
  customer_id varchar(245) DEFAULT '',
  customer_name varchar(245) DEFAULT '',
  first_name varchar(245) DEFAULT NULL,
  last_name varchar(245) DEFAULT NULL,
  customer_type varchar(245) DEFAULT '',
  city varchar(245) DEFAULT '',
  state varchar(245) DEFAULT '',
  country varchar(245) DEFAULT '',
  effective_start_date date DEFAULT '1900-01-01',
  effective_end_date date DEFAULT '2999-12-31',
  CONSTRAINT PK_dim_customer PRIMARY KEY (customer_skey)
);

DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
  DateSkey int NOT NULL,
  TheDate date NULL sortkey,
  TheYear smallint DEFAULT NULL,
  TheQuarter smallint DEFAULT NULL,
  TheMonth smallint DEFAULT NULL,
  TheWeek smallint DEFAULT NULL,
  DayOfYear smallint DEFAULT NULL,
  DayOfMonth smallint DEFAULT NULL,
  DayOfWeek smallint DEFAULT NULL,
  CONSTRAINT PK_dim_date PRIMARY KEY (DateSkey)
);

DROP TABLE IF EXISTS dim_ship;

CREATE TABLE dim_ship (
  ship_skey int NOT NULL sortkey,
  ship_mode varchar(245) DEFAULT '',
  order_priority varchar(245) DEFAULT '',
  CONSTRAINT PK_dim_ship PRIMARY KEY (ship_skey)
);

DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product (
  product_skey int NOT NULL sortkey distkey,
  product_id varchar(245) DEFAULT '',
  category varchar(245) DEFAULT '',
  sub_category varchar(245) DEFAULT '',
  product_name varchar(245) DEFAULT '',
  effective_start_date date DEFAULT '1900-01-01',
  effective_end_date date DEFAULT '2999-12-31',
  CONSTRAINT PRIMARY KEY (product_skey)
);

DROP TABLE IF EXISTS fact_orders;


CREATE TABLE fact_orders(
  order_date_skey int,
  ship_date_skey int,
  customer_skey bigint NOT NULL DEFAULT '0',
  product_skey bigint NOT NULL DEFAULT '0',
  ship_skey int DEFAULT '0',
  order_id varchar(245) DEFAULT '',
  unit_sales_amout numeric DEFAULT NULL,
  sales_quantity int DEFAULT NULL,
  discount_percent numeric DEFAULT NULL,
  extended_sales_amount numeric DEFAULT NULL
);


ALTER TABLE fact_orders ADD CONSTRAINT FK_factorders_orderdate FOREIGN KEY (order_date_skey) REFERENCES dim_date(DateSkey);
ALTER TABLE fact_orders ADD CONSTRAINT FK_factorders_shipdate FOREIGN KEY (ship_date_skey) REFERENCES dim_date(DateSkey);
ALTER TABLE fact_orders ADD CONSTRAINT FK_factorders_customer FOREIGN KEY (customer_skey) REFERENCES dim_customer(customer_skey);
ALTER TABLE fact_orders ADD CONSTRAINT FK_factorders_product FOREIGN KEY (product_skey) REFERENCES dim_product(product_skey);
ALTER TABLE fact_orders ADD CONSTRAINT FK_factorders_ship FOREIGN KEY (ship_skey) REFERENCES dim_ship(ship_skey);