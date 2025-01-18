CREATE TABLE customer (
    C_CUSTKEY INT,
    C_NAME VARCHAR(25),
    C_ADDRESS VARCHAR(40),
    C_NATIONKEY INTEGER,
    C_PHONE CHAR(15),
    C_ACCTBAL DECIMAL(15, 2),
    C_MKTSEGMENT CHAR(10),
    C_COMMENT VARCHAR(117)
) WITH (appendonly = true, orientation = column) 
DISTRIBUTED BY (C_CUSTKEY);

CREATE TABLE lineitem (
    L_ORDERKEY BIGINT,
    L_PARTKEY INT,
    L_SUPPKEY INT,
    L_LINENUMBER INTEGER,
    L_QUANTITY DECIMAL(15, 2),
    L_EXTENDEDPRICE DECIMAL(15, 2),
    L_DISCOUNT DECIMAL(15, 2),
    L_TAX DECIMAL(15, 2),
    L_RETURNFLAG CHAR(1),
    L_LINESTATUS CHAR(1),
    L_SHIPDATE DATE,
    L_COMMITDATE DATE,
    L_RECEIPTDATE DATE,
    L_SHIPINSTRUCT CHAR(25),
    L_SHIPMODE CHAR(10),
    L_COMMENT VARCHAR(44)
) WITH (
    appendonly = true,
    orientation = column,
    compresstype = ZSTD
) 
DISTRIBUTED BY (L_ORDERKEY, L_LINENUMBER) 
PARTITION BY RANGE (L_SHIPDATE) 
    (start('1992-01-01') INCLUSIVE end ('1998-12-31') INCLUSIVE every (30), default partition others);

CREATE TABLE nation (
    N_NATIONKEY INTEGER,
    N_NAME CHAR(25),
    N_REGIONKEY INTEGER,
    N_COMMENT VARCHAR(152)
) WITH (appendonly = true, orientation = column) 
DISTRIBUTED BY (N_NATIONKEY);

--добавим O_CUSTKEY к ключу дистрибуции
CREATE TABLE orders (
    O_ORDERKEY BIGINT,
    O_CUSTKEY INT,
    O_ORDERSTATUS CHAR(1),
    O_TOTALPRICE DECIMAL(15, 2),
    O_ORDERDATE DATE,
    O_ORDERPRIORITY CHAR(15),
    O_CLERK CHAR(15),
    O_SHIPPRIORITY INTEGER,
    O_COMMENT VARCHAR(79)
) WITH (
    appendonly = true,
    orientation = column,
    compresstype = ZSTD
) 
DISTRIBUTED BY (O_ORDERKEY, O_CUSTKEY) 
PARTITION BY RANGE (O_ORDERDATE) 
    (start('1992-01-01') INCLUSIVE end ('1998-12-31') INCLUSIVE every (30), default partition others);

CREATE TABLE part (
    P_PARTKEY INT,
    P_NAME VARCHAR(55),
    P_MFGR CHAR(25),
    P_BRAND CHAR(10),
    P_TYPE VARCHAR(25),
    P_SIZE INTEGER,
    P_CONTAINER CHAR(10),
    P_RETAILPRICE DECIMAL(15, 2),
    P_COMMENT VARCHAR(23)
) WITH (appendonly = true, orientation = column) 
DISTRIBUTED BY (P_PARTKEY);

CREATE TABLE partsupp (
    PS_PARTKEY INT,
    PS_SUPPKEY INT,
    PS_AVAILQTY INTEGER,
    PS_SUPPLYCOST DECIMAL(15, 2),
    PS_COMMENT VARCHAR(199)
) WITH (appendonly = true, orientation = column) 
DISTRIBUTED BY (PS_PARTKEY, PS_SUPPKEY);

CREATE TABLE region (
    R_REGIONKEY INTEGER,
    R_NAME CHAR(25),
    R_COMMENT VARCHAR(152)
) WITH (appendonly = true, orientation = column) 
DISTRIBUTED BY (R_REGIONKEY);

CREATE TABLE supplier (
    S_SUPPKEY INT,
    S_NAME CHAR(25),
    S_ADDRESS VARCHAR(40),
    S_NATIONKEY INTEGER,
    S_PHONE CHAR(15),
    S_ACCTBAL DECIMAL(15, 2),
    S_COMMENT VARCHAR(101)
) WITH (appendonly = true, orientation = column) 
DISTRIBUTED BY (S_SUPPKEY);

create index my_index on supplier using bitmap(s_name);

drop index my_index;

create index my_index on supplier using btree(s_name);