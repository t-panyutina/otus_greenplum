--before partitioning 
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
    
    
select l_orderkey, l_quantity, o_comment,
p_brand, p_comment
from lineitem l
join orders o
on l.l_orderkey = o.o_orderkey
join partsupp ps
on ps.ps_partkey = l.l_partkey
join part p
on l.l_partkey = p.p_partkey
where l_shipdate = '1992-02-28' and l_shipmode = 'AIR';


--after new partitioning
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
	    SUBPARTITION BY LIST (l_shipmode)
     SUBPARTITION TEMPLATE (
       SUBPARTITION air VALUES ('AIR'),
       SUBPARTITION truck VALUES ('TRUCK'),
       SUBPARTITION fob VALUES ('FOB'),
       SUBPARTITION rail VALUES ('RAIL'),
       SUBPARTITION ship VALUES ('SHIP'),
       SUBPARTITION mail VALUES ('MAIL'),
       SUBPARTITION reg_air VALUES ('REG_AIR'),
       DEFAULT SUBPARTITION other_rg
     )
    (start('1992-01-01') INCLUSIVE end ('1998-12-31') INCLUSIVE every (30), default partition others)
;

