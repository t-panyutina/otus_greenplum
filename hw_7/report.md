## Query 1: Retrieve Customer Orders with Order and Customer Details
```
explain analyze SELECT 
    hc.CustomerID,
    sc.CustomerName,
    sc.CustomerAddress,
    sc.CustomerPhone,
    ho.OrderID,
    so.OrderDate,
    so.ShipDate
FROM 
    Hub_Customer hc
JOIN 
    Link_Customer_Order lco ON hc.Customer_HashKey = lco.Customer_HashKey
JOIN 
    Hub_Order ho ON lco.Order_HashKey = ho.Order_HashKey
JOIN 
    Satellite_Customer sc ON hc.Customer_HashKey = sc.Customer_HashKey
JOIN 
    Satellite_Order so ON ho.Order_HashKey = so.Order_HashKey
WHERE 
    sc.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Customer WHERE Customer_HashKey = hc.Customer_HashKey)
AND 
    so.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Order WHERE Order_HashKey = ho.Order_HashKey)
```
Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..4497.80 rows=300000 width=77) (actual time=814.252..5134.567 rows=300000 loops=1)
  ->  Hash Join  (cost=0.00..4394.08 rows=150000 width=77) (actual time=750.835..3394.196 rows=151031 loops=1)
        Hash Cond: ((link_customer_order.customer_hashkey = hub_customer.customer_hashkey) AND (link_customer_order.customer_hashkey = satellite_customer.customer_hashkey))
        Extra Text: (seg1)   Hash chain length 1.2 avg, 5 max, using 12004 of 32768 buckets.Hash chain length 1.7 avg, 8 max, using 89561 of 131072 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..2886.13 rows=150000 width=45) (actual time=627.087..2577.551 rows=151031 loops=1)
              Hash Key: link_customer_order.customer_hashkey
              ->  Hash Join  (cost=0.00..2865.01 rows=150000 width=45) (actual time=743.174..3685.515 rows=150406 loops=1)
                    Hash Cond: ((link_customer_order.order_hashkey = hub_order.order_hashkey) AND (satellite_order.order_hashkey = hub_order.order_hashkey) AND (satellite_order.loaddate = (max(satellite_order_1.loaddate))))
                    Extra Text: (seg0)   Hash chain length 1.7 avg, 8 max, using 89561 of 131072 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                    ->  Hash Join  (cost=0.00..1219.03 rows=150000 width=115) (actual time=87.418..2304.617 rows=150406 loops=1)
                          Hash Cond: (link_customer_order.order_hashkey = satellite_order.order_hashkey)
                          Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                          ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..492.61 rows=150000 width=66) (actual time=0.031..1543.111 rows=150406 loops=1)
                                Hash Key: link_customer_order.order_hashkey
                                ->  Seq Scan on link_customer_order  (cost=0.00..443.21 rows=150000 width=66) (actual time=0.009..105.796 rows=150235 loops=1)
                          ->  Hash  (cost=438.43..438.43 rows=150000 width=49) (actual time=87.294..87.294 rows=150406 loops=1)
                                ->  Seq Scan on satellite_order  (cost=0.00..438.43 rows=150000 width=49) (actual time=0.011..35.377 rows=150406 loops=1)
                    ->  Hash  (cost=1165.23..1165.23 rows=300000 width=45) (actual time=654.984..654.984 rows=150406 loops=1)
                          ->  Result  (cost=0.00..1165.23 rows=300000 width=45) (actual time=322.982..571.002 rows=150406 loops=1)
                                ->  Hash Left Join  (cost=0.00..1151.73 rows=300000 width=45) (actual time=322.980..537.744 rows=150406 loops=1)
                                      Hash Cond: (hub_order.order_hashkey = satellite_order_1.order_hashkey)
                                      Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                                      ->  Seq Scan on hub_order  (cost=0.00..438.10 rows=150000 width=37) (actual time=0.022..34.661 rows=150406 loops=1)
                                      ->  Hash  (cost=472.00..472.00 rows=150000 width=41) (actual time=320.952..320.952 rows=150406 loops=1)
                                            ->  HashAggregate  (cost=0.00..472.00 rows=150000 width=41) (actual time=195.456..255.437 rows=150406 loops=1)
                                                  Group Key: satellite_order_1.order_hashkey
                                                  Extra Text: (seg0)   Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                                                  ->  Seq Scan on satellite_order satellite_order_1  (cost=0.00..438.43 rows=150000 width=41) (actual time=0.014..54.589 rows=150406 loops=1)
        ->  Hash  (cost=1377.45..1377.45 rows=15000 width=131) (actual time=274.409..274.409 rows=15034 loops=1)
              ->  Hash Join  (cost=0.00..1377.45 rows=15000 width=131) (actual time=246.577..262.957 rows=15034 loops=1)
                    Hash Cond: ((satellite_customer.customer_hashkey = hub_customer.customer_hashkey) AND (satellite_customer.loaddate = (max(satellite_customer_1.loaddate))))
                    Extra Text: (seg0)   Hash chain length 1.1 avg, 5 max, using 13399 of 65536 buckets.Hash chain length 1.1 avg, 4 max, using 13387 of 65536 buckets.Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                    ->  Seq Scan on satellite_customer  (cost=0.00..432.18 rows=15000 width=102) (actual time=0.010..4.242 rows=15034 loops=1)
                    ->  Hash  (cost=892.76..892.76 rows=30000 width=45) (actual time=245.682..245.682 rows=15034 loops=1)
                          ->  Result  (cost=0.00..892.76 rows=30000 width=45) (actual time=31.690..49.941 rows=15034 loops=1)
                                ->  Hash Left Join  (cost=0.00..891.41 rows=30000 width=45) (actual time=31.688..46.799 rows=15034 loops=1)
                                      Hash Cond: (hub_customer.customer_hashkey = satellite_customer_1.customer_hashkey)
                                      Extra Text: (seg0)   Hash chain length 1.1 avg, 4 max, using 13387 of 65536 buckets.Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                                      ->  Seq Scan on hub_customer  (cost=0.00..431.71 rows=15000 width=37) (actual time=0.016..3.308 rows=15034 loops=1)
                                      ->  Hash  (cost=435.54..435.54 rows=15000 width=41) (actual time=31.195..31.195 rows=15034 loops=1)
                                            ->  HashAggregate  (cost=0.00..435.54 rows=15000 width=41) (actual time=18.126..23.096 rows=15034 loops=1)
                                                  Group Key: satellite_customer_1.customer_hashkey
                                                  Extra Text: (seg0)   Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                                                  ->  Seq Scan on satellite_customer satellite_customer_1  (cost=0.00..432.18 rows=15000 width=41) (actual time=0.017..5.316 rows=15034 loops=1)
Planning time: 422.266 ms
  (slice0)    Executor memory: 291K bytes.
  (slice1)    Executor memory: 60K bytes avg x 2 workers, 60K bytes max (seg0).
  (slice2)    Executor memory: 76032K bytes avg x 2 workers, 76032K bytes max (seg0).  Work_mem: 11751K bytes max.
  (slice3)    Executor memory: 13824K bytes avg x 2 workers, 13824K bytes max (seg0).  Work_mem: 2416K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 5231.405 ms

## Query 2: Retrieve Detailed Order Information with Line Items
```
explain analyze SELECT 
    ho.OrderID,
    so.OrderDate,
    so.ShipDate,
    hl.LineItemID,
    sl.Quantity,
    sl.Price,
    sl.Discount
FROM 
    Hub_Order ho
JOIN 
    Link_Order_LineItem lol ON ho.Order_HashKey = lol.Order_HashKey
JOIN 
    Hub_LineItem hl ON lol.LineItem_HashKey = hl.LineItem_HashKey
JOIN 
    Satellite_Order so ON ho.Order_HashKey = so.Order_HashKey
JOIN 
    Satellite_LineItem sl ON hl.LineItem_HashKey = sl.LineItem_HashKey
WHERE 
    so.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Order WHERE Order_HashKey = ho.Order_HashKey)
AND 
    sl.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_LineItem WHERE LineItem_HashKey = hl.LineItem_HashKey)
```
Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..8400.06 rows=1199969 width=32) (actual time=15992.999..22926.710 rows=1199969 loops=1)
  ->  Hash Join  (cost=0.00..8227.64 rows=599985 width=32) (actual time=15965.680..20375.629 rows=600609 loops=1)
        Hash Cond: ((hub_lineitem.lineitem_hashkey = link_order_lineitem.lineitem_hashkey) AND ((max(satellite_lineitem.loaddate)) = satellite_lineitem_1.loaddate))
        Extra Text: (seg1)   Initial batch 0:
(seg1)     Wrote 26911K bytes to inner workfile.
(seg1)     Wrote 17551K bytes to outer workfile.
(seg1)   Initial batch 1:
(seg1)     Read 26911K bytes from inner workfile.
(seg1)     Read 17551K bytes from outer workfile.
(seg1)   Hash chain length 2.5 avg, 12 max, using 235743 of 262144 buckets.Initial batch 0:

        ->  Result  (cost=0.00..2077.51 rows=1199969 width=45) (actual time=3078.878..5610.169 rows=600609 loops=1)
              ->  Hash Left Join  (cost=0.00..2023.51 rows=1199969 width=45) (actual time=3078.876..5399.917 rows=600609 loops=1)
                    Hash Cond: (hub_lineitem.lineitem_hashkey = satellite_lineitem.lineitem_hashkey)
                    Extra Text: (seg1)   Initial batch 0:
(seg1)     Wrote 17587K bytes to inner workfile.
(seg1)     Wrote 15242K bytes to outer workfile.
(seg1)   Initial batch 1:
(seg1)     Read 17587K bytes from inner workfile.
(seg1)     Read 15242K bytes from outer workfile.
(seg1)   Hash chain length 2.5 avg, 11 max, using 235906 of 262144 buckets.600609 groups total in 32 batches; 1 overflows; 600609 spill groups.

                    ->  Seq Scan on hub_lineitem  (cost=0.00..459.38 rows=599985 width=37) (actual time=0.016..334.368 rows=600609 loops=1)
                    ->  Hash  (cost=597.65..597.65 rows=599985 width=41) (actual time=3078.669..3078.669 rows=600609 loops=1)
                          ->  HashAggregate  (cost=0.00..597.65 rows=599985 width=41) (actual time=1892.977..2803.293 rows=600609 loops=1)
                                Group Key: satellite_lineitem.lineitem_hashkey
                                Extra Text: (seg1)   600609 groups total in 32 batches; 1 overflows; 600609 spill groups.
(seg1)   Hash chain length 4.6 avg, 17 max, using 194431 of 196608 buckets; total 11 expansions.

                                ->  Seq Scan on satellite_lineitem  (cost=0.00..463.34 rows=599985 width=41) (actual time=0.058..172.990 rows=600609 loops=1)
        ->  Hash  (cost=4573.19..4573.19 rows=599985 width=69) (actual time=12886.644..12886.644 rows=600609 loops=1)
              ->  Hash Join  (cost=0.00..4573.19 rows=599985 width=69) (actual time=11162.936..12434.023 rows=600609 loops=1)
                    Hash Cond: (satellite_lineitem_1.lineitem_hashkey = link_order_lineitem.lineitem_hashkey)
                    Extra Text: (seg1)   Initial batch 0:
(seg1)     Wrote 17587K bytes to inner workfile.
(seg1)     Wrote 24027K bytes to outer workfile.
(seg1)   Initial batch 1:
(seg1)     Read 17587K bytes from inner workfile.
(seg1)     Read 24027K bytes from outer workfile.
(seg1)   Hash chain length 2.5 avg, 11 max, using 235906 of 262144 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 2.6 avg, 11 max, using 58961 of 65536 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                    ->  Seq Scan on satellite_lineitem satellite_lineitem_1  (cost=0.00..463.34 rows=599985 width=57) (actual time=8.900..195.164 rows=600609 loops=1)
                    ->  Hash  (cost=3103.35..3103.35 rows=599985 width=45) (actual time=11153.873..11153.873 rows=600609 loops=1)
                          ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..3103.35 rows=599985 width=45) (actual time=1014.493..10125.397 rows=600609 loops=1)
                                Hash Key: link_order_lineitem.lineitem_hashkey
                                ->  Hash Join  (cost=0.00..3018.85 rows=599985 width=45) (actual time=1045.753..6981.784 rows=601215 loops=1)
                                      Hash Cond: (link_order_lineitem.order_hashkey = hub_order.order_hashkey)
                                      Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 2.6 avg, 11 max, using 58961 of 65536 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                                      ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..677.44 rows=599985 width=66) (actual time=0.030..3540.654 rows=601215 loops=1)
                                            Hash Key: link_order_lineitem.order_hashkey
                                            ->  Seq Scan on link_order_lineitem  (cost=0.00..479.84 rows=599985 width=66) (actual time=0.194..656.038 rows=600609 loops=1)
                                      ->  Hash  (cost=1950.29..1950.29 rows=150000 width=45) (actual time=1045.522..1045.522 rows=150406 loops=1)
                                            ->  Hash Join  (cost=0.00..1950.29 rows=150000 width=45) (actual time=419.054..943.273 rows=150406 loops=1)
                                                  Hash Cond: ((hub_order.order_hashkey = satellite_order_1.order_hashkey) AND ((max(satellite_order.loaddate)) = satellite_order_1.loaddate))
                                                  Extra Text: (seg0)   Hash chain length 2.6 avg, 11 max, using 58961 of 65536 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                                                  ->  Result  (cost=0.00..1165.23 rows=300000 width=45) (actual time=289.102..608.603 rows=150406 loops=1)
                                                        ->  Hash Left Join  (cost=0.00..1151.73 rows=300000 width=45) (actual time=289.099..572.910 rows=150406 loops=1)
                                                              Hash Cond: (hub_order.order_hashkey = satellite_order.order_hashkey)
                                                              Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                                                              ->  Seq Scan on hub_order  (cost=0.00..438.10 rows=150000 width=37) (actual time=0.016..40.971 rows=150406 loops=1)
                                                              ->  Hash  (cost=472.00..472.00 rows=150000 width=41) (actual time=288.619..288.619 rows=150406 loops=1)
                                                                    ->  HashAggregate  (cost=0.00..472.00 rows=150000 width=41) (actual time=147.354..213.939 rows=150406 loops=1)
                                                                          Group Key: satellite_order.order_hashkey
                                                                          Extra Text: (seg0)   Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                                                                          ->  Seq Scan on satellite_order  (cost=0.00..438.43 rows=150000 width=41) (actual time=0.011..36.892 rows=150406 loops=1)
                                                  ->  Hash  (cost=438.43..438.43 rows=150000 width=49) (actual time=129.860..129.860 rows=150406 loops=1)
                                                        ->  Seq Scan on satellite_order satellite_order_1  (cost=0.00..438.43 rows=150000 width=49) (actual time=0.011..46.978 rows=150406 loops=1)
Planning time: 362.436 ms
  (slice0)    Executor memory: 323K bytes.
  (slice1)    Executor memory: 60K bytes avg x 2 workers, 60K bytes max (seg0).
  (slice2)    Executor memory: 75520K bytes avg x 2 workers, 75520K bytes max (seg0).  Work_mem: 11751K bytes max.
* (slice3)    Executor memory: 152641K bytes avg x 2 workers, 152641K bytes max (seg0).  Work_mem: 30578K bytes max, 60998K bytes wanted.
Memory used:  128000kB
Memory wanted:  489781kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 23156.200 ms


## Query 3: Retrieve Supplier and Part Information for Each Supplier-Part Relationship
```
explain analyze SELECT 
    hs.SupplierID,
    ss.SupplierName,
    ss.SupplierAddress,
    ss.SupplierPhone,
    hp.PartID,
    sp.PartName,
    sp.PartDescription,
    sp.PartPrice
FROM 
    Hub_Supplier hs
JOIN 
    Link_Supplier_Part lsp ON hs.Supplier_HashKey = lsp.Supplier_HashKey
JOIN 
    Hub_Part hp ON lsp.Part_HashKey = hp.Part_HashKey
JOIN 
    Satellite_Supplier ss ON hs.Supplier_HashKey = ss.Supplier_HashKey
JOIN 
    Satellite_Part sp ON hp.Part_HashKey = sp.Part_HashKey
WHERE 
    ss.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Supplier WHERE Supplier_HashKey = hs.Supplier_HashKey)
AND 
    sp.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Part WHERE Part_HashKey = hp.Part_HashKey)
```
Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..3411.83 rows=160000 width=123) (actual time=189.056..1944.460 rows=160000 loops=1)
  ->  Hash Join  (cost=0.00..3323.46 rows=80000 width=123) (actual time=174.442..882.191 rows=80072 loops=1)
        Hash Cond: (link_supplier_part.part_hashkey = hub_part.part_hashkey)
        Extra Text: (seg1)   Hash chain length 1.3 avg, 6 max, using 14925 of 32768 buckets.Hash chain length 1.0 avg, 3 max, using 1928 of 32768 buckets.Hash chain length 1.0 avg, 2 max, using 1019 of 65536 buckets.Hash chain length 1.0 avg, 2 max, using 1021 of 65536 buckets.Hash chain length 4.1 avg, 10 max, using 252 of 256 buckets; total 3 expansions.

        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..1824.73 rows=80000 width=98) (actual time=71.904..573.691 rows=80072 loops=1)
              Hash Key: link_supplier_part.part_hashkey
              ->  Hash Join  (cost=0.00..1800.19 rows=80000 width=98) (actual time=152.359..435.801 rows=80048 loops=1)
                    Hash Cond: (link_supplier_part.supplier_hashkey = hub_supplier.supplier_hashkey)
                    Extra Text: (seg1)   Hash chain length 1.0 avg, 3 max, using 1928 of 32768 buckets.Hash chain length 1.0 avg, 2 max, using 1019 of 65536 buckets.Hash chain length 1.0 avg, 2 max, using 1021 of 65536 buckets.Hash chain length 4.1 avg, 10 max, using 252 of 256 buckets; total 3 expansions.

                    ->  Seq Scan on link_supplier_part  (cost=0.00..437.51 rows=80000 width=66) (actual time=0.016..75.446 rows=80048 loops=1)
                    ->  Hash  (cost=1303.65..1303.65 rows=2000 width=98) (actual time=172.616..172.616 rows=2000 loops=1)
                          ->  Broadcast Motion 2:2  (slice1; segments: 2)  (cost=0.00..1303.65 rows=2000 width=98) (actual time=103.724..169.189 rows=2000 loops=1)
                                ->  Hash Join  (cost=0.00..1298.51 rows=1000 width=98) (actual time=122.743..127.523 rows=1027 loops=1)
                                      Hash Cond: ((satellite_supplier.supplier_hashkey = hub_supplier.supplier_hashkey) AND (satellite_supplier.loaddate = (max(satellite_supplier_1.loaddate))))
                                      Extra Text: (seg1)   Hash chain length 1.0 avg, 2 max, using 1019 of 65536 buckets.Hash chain length 1.0 avg, 2 max, using 1021 of 65536 buckets.Hash chain length 4.1 avg, 10 max, using 252 of 256 buckets; total 3 expansions.

                                      ->  Seq Scan on satellite_supplier  (cost=0.00..431.08 rows=1000 width=102) (actual time=0.009..1.421 rows=1027 loops=1)
                                      ->  Hash  (cost=864.05..864.05 rows=2000 width=45) (actual time=121.615..121.615 rows=1027 loops=1)
                                            ->  Result  (cost=0.00..864.05 rows=2000 width=45) (actual time=119.859..121.047 rows=1027 loops=1)
                                                  ->  Hash Left Join  (cost=0.00..863.96 rows=2000 width=45) (actual time=119.858..120.807 rows=1027 loops=1)
                                                        Hash Cond: (hub_supplier.supplier_hashkey = satellite_supplier_1.supplier_hashkey)
                                                        Extra Text: (seg1)   Hash chain length 1.0 avg, 2 max, using 1021 of 65536 buckets.Hash chain length 4.1 avg, 10 max, using 252 of 256 buckets; total 3 expansions.

                                                        ->  Seq Scan on hub_supplier  (cost=0.00..431.05 rows=1000 width=37) (actual time=0.014..0.223 rows=1027 loops=1)
                                                        ->  Hash  (cost=431.30..431.30 rows=1000 width=41) (actual time=24.730..24.730 rows=1027 loops=1)
                                                              ->  HashAggregate  (cost=0.00..431.30 rows=1000 width=41) (actual time=6.871..7.189 rows=1027 loops=1)
                                                                    Group Key: satellite_supplier_1.supplier_hashkey
                                                                    Extra Text: (seg1)   Hash chain length 4.1 avg, 10 max, using 252 of 256 buckets; total 3 expansions.

                                                                    ->  Seq Scan on satellite_supplier satellite_supplier_1  (cost=0.00..431.08 rows=1000 width=41) (actual time=0.014..1.365 rows=1027 loops=1)
        ->  Hash  (cost=1402.31..1402.31 rows=20000 width=91) (actual time=102.013..102.013 rows=20018 loops=1)
              ->  Hash Join  (cost=0.00..1402.31 rows=20000 width=91) (actual time=71.958..92.334 rows=20018 loops=1)
                    Hash Cond: ((satellite_part.part_hashkey = hub_part.part_hashkey) AND (satellite_part.loaddate = (max(satellite_part_1.loaddate))))
                    Extra Text: (seg1)   Hash chain length 1.2 avg, 5 max, using 17237 of 65536 buckets.Hash chain length 1.2 avg, 4 max, using 17196 of 65536 buckets.Hash chain length 4.9 avg, 13 max, using 4067 of 4096 buckets; total 7 expansions.

                    ->  Seq Scan on satellite_part  (cost=0.00..432.50 rows=20000 width=95) (actual time=0.011..5.532 rows=20018 loops=1)
                    ->  Hash  (cost=902.94..902.94 rows=40000 width=45) (actual time=71.846..71.846 rows=20018 loops=1)
                          ->  Result  (cost=0.00..902.94 rows=40000 width=45) (actual time=42.713..64.298 rows=20018 loops=1)
                                ->  Hash Left Join  (cost=0.00..901.14 rows=40000 width=45) (actual time=42.711..60.133 rows=20018 loops=1)
                                      Hash Cond: (hub_part.part_hashkey = satellite_part_1.part_hashkey)
                                      Extra Text: (seg1)   Hash chain length 1.2 avg, 4 max, using 17196 of 65536 buckets.Hash chain length 4.9 avg, 13 max, using 4067 of 4096 buckets; total 7 expansions.

                                      ->  Seq Scan on hub_part  (cost=0.00..431.95 rows=20000 width=37) (actual time=0.011..4.283 rows=20018 loops=1)
                                      ->  Hash  (cost=436.97..436.97 rows=20000 width=41) (actual time=42.602..42.602 rows=20018 loops=1)
                                            ->  HashAggregate  (cost=0.00..436.97 rows=20000 width=41) (actual time=32.018..36.223 rows=20018 loops=1)
                                                  Group Key: satellite_part_1.part_hashkey
                                                  Extra Text: (seg1)   Hash chain length 4.9 avg, 13 max, using 4067 of 4096 buckets; total 7 expansions.

                                                  ->  Seq Scan on satellite_part satellite_part_1  (cost=0.00..432.50 rows=20000 width=41) (actual time=0.015..14.762 rows=20018 loops=1)
Planning time: 490.615 ms
  (slice0)    Executor memory: 291K bytes.
  (slice1)    Executor memory: 1720K bytes avg x 2 workers, 1720K bytes max (seg0).  Work_mem: 73K bytes max.
  (slice2)    Executor memory: 856K bytes avg x 2 workers, 856K bytes max (seg0).  Work_mem: 254K bytes max.
  (slice3)    Executor memory: 13792K bytes avg x 2 workers, 13792K bytes max (seg0).  Work_mem: 2428K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 1984.708 ms

## Query 4: Retrieve Comprehensive Customer Order and Line Item Details
```
explain analyze SELECT 
    hc.CustomerID,
    sc.CustomerName,
    ho.OrderID,
    so.OrderDate,
    so.ShipDate,
    hl.LineItemID,
    sl.Quantity,
    sl.Price,
    sl.Discount
FROM 
    Hub_Customer hc
JOIN 
    Link_Customer_Order lco ON hc.Customer_HashKey = lco.Customer_HashKey
JOIN 
    Hub_Order ho ON lco.Order_HashKey = ho.Order_HashKey
JOIN 
    Link_Order_LineItem lol ON ho.Order_HashKey = lol.Order_HashKey
JOIN 
    Hub_LineItem hl ON lol.LineItem_HashKey = hl.LineItem_HashKey
JOIN 
    Satellite_Customer sc ON hc.Customer_HashKey = sc.Customer_HashKey
JOIN 
    Satellite_Order so ON ho.Order_HashKey = so.Order_HashKey
JOIN 
    Satellite_LineItem sl ON hl.LineItem_HashKey = sl.LineItem_HashKey
WHERE 
    sc.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Customer WHERE Customer_HashKey = hc.Customer_HashKey)
AND 
    so.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Order WHERE Order_HashKey = ho.Order_HashKey)
AND 
    sl.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_LineItem WHERE LineItem_HashKey = hl.LineItem_HashKey)
```
Gather Motion 2:1  (slice5; segments: 2)  (cost=0.00..11818.05 rows=1199969 width=55) (actual time=19590.028..29030.085 rows=1199969 loops=1)
  ->  Hash Join  (cost=0.00..11521.72 rows=599985 width=55) (actual time=19522.826..26215.554 rows=600609 loops=1)
        Hash Cond: ((hub_lineitem.lineitem_hashkey = link_order_lineitem.lineitem_hashkey) AND (satellite_lineitem_1.lineitem_hashkey = link_order_lineitem.lineitem_hashkey))
        Extra Text: (seg1)   Initial batch 0:
(seg1)     Wrote 24613K bytes to inner workfile.
(seg1)     Wrote 31599K bytes to outer workfile.
(seg1)   Initial batch 1:
(seg1)     Read 24613K bytes from inner workfile.
(seg1)     Read 31599K bytes from outer workfile.
(seg1)   Hash chain length 2.5 avg, 13 max, using 235573 of 262144 buckets.Initial batch 0:

        ->  Hash Join  (cost=0.00..4131.37 rows=599985 width=86) (actual time=2773.226..7248.377 rows=600609 loops=1)
              Hash Cond: ((hub_lineitem.lineitem_hashkey = satellite_lineitem_1.lineitem_hashkey) AND ((max(satellite_lineitem.loaddate)) = satellite_lineitem_1.loaddate))
              Extra Text: (seg1)   Initial batch 0:
(seg1)     Wrote 36051K bytes to inner workfile.
(seg1)     Wrote 26387K bytes to outer workfile.
(seg1)   Initial batches 1..3:
(seg1)     Read 36051K bytes from inner workfile: 12017K avg x 3 nonempty batches, 12073K max.
(seg1)     Read 26387K bytes from outer workfile: 8796K avg x 3 nonempty batches, 8836K max.
(seg1)   Hash chain length 2.5 avg, 12 max, using 235743 of 262144 buckets.Initial batch 0:

              ->  Result  (cost=0.00..2077.51 rows=1199969 width=45) (actual time=2260.460..4883.114 rows=600609 loops=1)
                    ->  Hash Left Join  (cost=0.00..2023.51 rows=1199969 width=45) (actual time=2260.458..4613.593 rows=600609 loops=1)
                          Hash Cond: (hub_lineitem.lineitem_hashkey = satellite_lineitem.lineitem_hashkey)
                          Extra Text: (seg1)   Initial batch 0:
(seg1)     Wrote 26359K bytes to inner workfile.
(seg1)     Wrote 22845K bytes to outer workfile.
(seg1)   Initial batches 1..3:
(seg1)     Read 26359K bytes from inner workfile: 8787K avg x 3 nonempty batches, 8809K max.
(seg1)     Read 22845K bytes from outer workfile: 7615K avg x 3 nonempty batches, 7634K max.
(seg1)   Hash chain length 2.5 avg, 11 max, using 235906 of 262144 buckets.600609 groups total in 32 batches; 1 overflows; 600609 spill groups.

                          ->  Seq Scan on hub_lineitem  (cost=0.00..459.38 rows=599985 width=37) (actual time=0.010..304.200 rows=600609 loops=1)
                          ->  Hash  (cost=597.65..597.65 rows=599985 width=41) (actual time=2259.983..2259.983 rows=600609 loops=1)
                                ->  HashAggregate  (cost=0.00..597.65 rows=599985 width=41) (actual time=1260.392..1991.856 rows=600609 loops=1)
                                      Group Key: satellite_lineitem.lineitem_hashkey
                                      Extra Text: (seg1)   600609 groups total in 32 batches; 1 overflows; 600609 spill groups.
(seg1)   Hash chain length 4.7 avg, 16 max, using 162243 of 163840 buckets; total 10 expansions.

                                      ->  Seq Scan on satellite_lineitem  (cost=0.00..463.34 rows=599985 width=41) (actual time=0.073..226.833 rows=600609 loops=1)
              ->  Hash  (cost=463.34..463.34 rows=599985 width=57) (actual time=503.097..503.097 rows=600609 loops=1)
                    ->  Seq Scan on satellite_lineitem satellite_lineitem_1  (cost=0.00..463.34 rows=599985 width=57) (actual time=0.052..178.291 rows=600609 loops=1)
        ->  Hash  (cost=6070.88..6070.88 rows=599985 width=68) (actual time=16749.425..16749.425 rows=600609 loops=1)
              ->  Redistribute Motion 2:2  (slice4; segments: 2)  (cost=0.00..6070.88 rows=599985 width=68) (actual time=4818.814..15718.660 rows=600609 loops=1)
                    Hash Key: link_order_lineitem.lineitem_hashkey
                    ->  Hash Join  (cost=0.00..5943.18 rows=599985 width=68) (actual time=4922.884..11814.946 rows=601215 loops=1)
                          Hash Cond: ((link_order_lineitem.order_hashkey = hub_order.order_hashkey) AND (link_order_lineitem.order_hashkey = link_customer_order.order_hashkey) AND (link_order_lineitem.order_hashkey = satellite_order.order_hashkey))
                          Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 11450K bytes to inner workfile.
(seg0)     Wrote 24630K bytes to outer workfile.
(seg0)   Initial batch 1:
(seg0)     Read 11450K bytes from inner workfile.
(seg0)     Read 24630K bytes from outer workfile.
(seg0)   Hash chain length 2.6 avg, 11 max, using 58895 of 65536 buckets.Initial batch 0:

                          ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..677.44 rows=599985 width=66) (actual time=0.018..3785.137 rows=601215 loops=1)
                                Hash Key: link_order_lineitem.order_hashkey
                                ->  Seq Scan on link_order_lineitem  (cost=0.00..479.84 rows=599985 width=66) (actual time=108.404..833.836 rows=600609 loops=1)
                          ->  Hash  (cost=4404.00..4404.00 rows=150000 width=134) (actual time=4922.579..4922.579 rows=150406 loops=1)
                                ->  Hash Join  (cost=0.00..4404.00 rows=150000 width=134) (actual time=987.216..4560.281 rows=150406 loops=1)
                                      Hash Cond: ((link_customer_order.order_hashkey = hub_order.order_hashkey) AND (satellite_order.order_hashkey = hub_order.order_hashkey) AND (satellite_order.loaddate = (max(satellite_order_1.loaddate))))
                                      Extra Text: (seg0)   Initial batch 0:
(seg0)     Wrote 4393K bytes to inner workfile.
(seg0)     Wrote 9079K bytes to outer workfile.
(seg0)   Initial batch 1:
(seg0)     Read 4393K bytes from inner workfile.
(seg0)     Read 9079K bytes from outer workfile.
(seg0)   Hash chain length 1.7 avg, 8 max, using 89561 of 131072 buckets.Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 1.5 avg, 6 max, using 9802 of 16384 buckets.Hash chain length 1.2 avg, 6 max, using 12048 of 32768 buckets.Hash chain length 1.3 avg, 6 max, using 12000 of 32768 buckets.Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                                      ->  Hash Join  (cost=0.00..2712.21 rows=150000 width=105) (actual time=98.170..2905.363 rows=150406 loops=1)
                                            Hash Cond: (link_customer_order.order_hashkey = satellite_order.order_hashkey)
                                            Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 1.5 avg, 6 max, using 9802 of 16384 buckets.Hash chain length 1.2 avg, 6 max, using 12048 of 32768 buckets.Hash chain length 1.3 avg, 6 max, using 12000 of 32768 buckets.Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                                            ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..1991.96 rows=150000 width=56) (actual time=0.053..2059.654 rows=150406 loops=1)
                                                  Hash Key: link_customer_order.order_hashkey
                                                  ->  Hash Join  (cost=0.00..1965.67 rows=150000 width=56) (actual time=87.796..2674.853 rows=151031 loops=1)
                                                        Hash Cond: ((link_customer_order.customer_hashkey = hub_customer.customer_hashkey) AND (link_customer_order.customer_hashkey = satellite_customer_1.customer_hashkey))
                                                        Extra Text: (seg1)   Hash chain length 1.5 avg, 6 max, using 9802 of 16384 buckets.Hash chain length 1.2 avg, 6 max, using 12048 of 32768 buckets.Hash chain length 1.3 avg, 6 max, using 12000 of 32768 buckets.Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                                                        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..492.61 rows=150000 width=66) (actual time=0.047..1980.642 rows=151031 loops=1)
                                                              Hash Key: link_customer_order.customer_hashkey
                                                              ->  Seq Scan on link_customer_order  (cost=0.00..443.21 rows=150000 width=66) (actual time=0.035..159.942 rows=150235 loops=1)
                                                        ->  Hash  (cost=1365.97..1365.97 rows=15000 width=89) (actual time=697.988..697.988 rows=15034 loops=1)
                                                              ->  Hash Join  (cost=0.00..1365.97 rows=15000 width=89) (actual time=654.595..688.319 rows=15034 loops=1)
                                                                    Hash Cond: ((hub_customer.customer_hashkey = satellite_customer_1.customer_hashkey) AND ((max(satellite_customer.loaddate)) = satellite_customer_1.loaddate))
                                                                    Extra Text: (seg0)   Hash chain length 1.2 avg, 6 max, using 12048 of 32768 buckets.Hash chain length 1.3 avg, 6 max, using 12000 of 32768 buckets.Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                                                                    ->  Result  (cost=0.00..892.76 rows=30000 width=45) (actual time=604.739..625.908 rows=15034 loops=1)
                                                                          ->  Hash Left Join  (cost=0.00..891.41 rows=30000 width=45) (actual time=604.734..622.457 rows=15034 loops=1)
                                                                                Hash Cond: (hub_customer.customer_hashkey = satellite_customer.customer_hashkey)
                                                                                Extra Text: (seg0)   Hash chain length 1.3 avg, 6 max, using 12000 of 32768 buckets.Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                                                                                ->  Seq Scan on hub_customer  (cost=0.00..431.71 rows=15000 width=37) (actual time=0.052..4.802 rows=15034 loops=1)
                                                                                ->  Hash  (cost=435.54..435.54 rows=15000 width=41) (actual time=604.411..604.411 rows=15034 loops=1)
                                                                                      ->  HashAggregate  (cost=0.00..435.54 rows=15000 width=41) (actual time=13.426..18.377 rows=15034 loops=1)
                                                                                            Group Key: satellite_customer.customer_hashkey
                                                                                            Extra Text: (seg0)   Hash chain length 3.8 avg, 12 max, using 3998 of 4096 buckets; total 7 expansions.

                                                                                            ->  Seq Scan on satellite_customer  (cost=0.00..432.18 rows=15000 width=41) (actual time=0.009..3.948 rows=15034 loops=1)
                                                                    ->  Hash  (cost=432.18..432.18 rows=15000 width=60) (actual time=47.309..47.309 rows=15034 loops=1)
                                                                          ->  Seq Scan on satellite_customer satellite_customer_1  (cost=0.00..432.18 rows=15000 width=60) (actual time=0.051..5.391 rows=15034 loops=1)
                                            ->  Hash  (cost=438.43..438.43 rows=150000 width=49) (actual time=98.002..98.002 rows=150406 loops=1)
                                                  ->  Seq Scan on satellite_order  (cost=0.00..438.43 rows=150000 width=49) (actual time=0.013..37.104 rows=150406 loops=1)
                                      ->  Hash  (cost=1165.23..1165.23 rows=300000 width=45) (actual time=888.111..888.111 rows=150406 loops=1)
                                            ->  Result  (cost=0.00..1165.23 rows=300000 width=45) (actual time=502.859..792.942 rows=150406 loops=1)
                                                  ->  Hash Left Join  (cost=0.00..1151.73 rows=300000 width=45) (actual time=502.854..758.909 rows=150406 loops=1)
                                                        Hash Cond: (hub_order.order_hashkey = satellite_order_1.order_hashkey)
                                                        Extra Text: (seg0)   Hash chain length 2.6 avg, 12 max, using 58879 of 65536 buckets.Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                                                        ->  Seq Scan on hub_order  (cost=0.00..438.10 rows=150000 width=37) (actual time=0.041..54.275 rows=150406 loops=1)
                                                        ->  Hash  (cost=472.00..472.00 rows=150000 width=41) (actual time=502.403..502.403 rows=150406 loops=1)
                                                              ->  HashAggregate  (cost=0.00..472.00 rows=150000 width=41) (actual time=372.975..436.397 rows=150406 loops=1)
                                                                    Group Key: satellite_order_1.order_hashkey
                                                                    Extra Text: (seg0)   Hash chain length 4.6 avg, 16 max, using 32446 of 32768 buckets; total 10 expansions.

                                                                    ->  Seq Scan on satellite_order satellite_order_1  (cost=0.00..438.43 rows=150000 width=41) (actual time=0.027..123.985 rows=150406 loops=1)
Planning time: 1384.463 ms
  (slice0)    Executor memory: 586K bytes.
  (slice1)    Executor memory: 60K bytes avg x 2 workers, 60K bytes max (seg0).
  (slice2)    Executor memory: 60K bytes avg x 2 workers, 60K bytes max (seg0).
  (slice3)    Executor memory: 13184K bytes avg x 2 workers, 13184K bytes max (seg0).  Work_mem: 1762K bytes max.
* (slice4)    Executor memory: 92384K bytes avg x 2 workers, 92384K bytes max (seg0).  Work_mem: 12346K bytes max, 24676K bytes wanted.
* (slice5)    Executor memory: 102617K bytes avg x 2 workers, 102617K bytes max (seg0).  Work_mem: 28179K bytes max, 56308K bytes wanted.
Memory used:  128000kB
Memory wanted:  734892kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 29312.256 ms

## Query 5: Retrieve All Parts Supplied by a Specific Supplier with Supplier Details
```
explain analyze SELECT 
    hs.SupplierID,
    ss.SupplierName,
    hp.PartID,
    sp.PartName,
    sp.PartDescription,
    sp.PartPrice
FROM 
    Hub_Supplier hs
JOIN 
    Link_Supplier_Part lsp ON hs.Supplier_HashKey = lsp.Supplier_HashKey
JOIN 
    Hub_Part hp ON lsp.Part_HashKey = hp.Part_HashKey
JOIN 
    Satellite_Supplier ss ON hs.Supplier_HashKey = ss.Supplier_HashKey
JOIN 
    Satellite_Part sp ON hp.Part_HashKey = sp.Part_HashKey
WHERE 
    hs.SupplierID = 470 -- Replace 123 with the actual SupplierID
AND 
    ss.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Supplier WHERE Supplier_HashKey = hs.Supplier_HashKey)
AND 
    sp.LoadDate = (SELECT MAX(LoadDate) FROM Satellite_Part WHERE Part_HashKey = hp.Part_HashKey)
```
Hash Join  (cost=0.00..3168.54 rows=80000 width=81) (actual time=192.076..213.420 rows=80 loops=1)
  Hash Cond: ((satellite_supplier.supplier_hashkey = hub_supplier.supplier_hashkey) AND (satellite_supplier.supplier_hashkey = link_supplier_part.supplier_hashkey) AND (satellite_supplier.loaddate = (max(satellite_supplier_1.loaddate))))
  Extra Text: Hash chain length 80.0 avg, 80 max, using 1 of 32768 buckets.
  ->  Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..431.73 rows=2000 width=60) (actual time=0.012..15.285 rows=2000 loops=1)
        ->  Seq Scan on satellite_supplier  (cost=0.00..431.08 rows=1000 width=60) (actual time=0.011..0.630 rows=1027 loops=1)
  ->  Hash  (cost=2689.97..2689.97 rows=80 width=136) (actual time=191.160..191.160 rows=80 loops=1)
        Buckets: 32768  Batches: 1  Memory Usage: 14kB
        ->  Gather Motion 2:1  (slice4; segments: 2)  (cost=0.00..2689.97 rows=160 width=136) (actual time=177.494..191.120 rows=80 loops=1)
              ->  Hash Join  (cost=0.00..2689.88 rows=80 width=136) (actual time=114.178..147.900 rows=46 loops=1)
                    Hash Cond: ((hub_part.part_hashkey = link_supplier_part.part_hashkey) AND (hub_part.part_hashkey = satellite_part_1.part_hashkey) AND ((max(satellite_part.loaddate)) = satellite_part_1.loaddate))
                    Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 46 of 32768 buckets.Hash chain length 1.2 avg, 4 max, using 17196 of 65536 buckets.Hash chain length 4.9 avg, 13 max, using 4067 of 4096 buckets; total 7 expansions.

                    ->  Result  (cost=0.00..902.94 rows=40000 width=45) (actual time=35.383..62.452 rows=20018 loops=1)
                          ->  Hash Left Join  (cost=0.00..901.14 rows=40000 width=45) (actual time=35.376..57.857 rows=20018 loops=1)
                                Hash Cond: (hub_part.part_hashkey = satellite_part.part_hashkey)
                                Extra Text: (seg1)   Hash chain length 1.2 avg, 4 max, using 17196 of 65536 buckets.Hash chain length 4.9 avg, 13 max, using 4067 of 4096 buckets; total 7 expansions.

                                ->  Seq Scan on hub_part  (cost=0.00..431.95 rows=20000 width=37) (actual time=0.042..6.286 rows=20018 loops=1)
                                ->  Hash  (cost=436.97..436.97 rows=20000 width=41) (actual time=34.899..34.899 rows=20018 loops=1)
                                      ->  HashAggregate  (cost=0.00..436.97 rows=20000 width=41) (actual time=17.247..23.956 rows=20018 loops=1)
                                            Group Key: satellite_part.part_hashkey
                                            Extra Text: (seg1)   Hash chain length 4.9 avg, 13 max, using 4067 of 4096 buckets; total 7 expansions.

                                            ->  Seq Scan on satellite_part  (cost=0.00..432.50 rows=20000 width=41) (actual time=0.009..5.014 rows=20018 loops=1)
                    ->  Hash  (cost=1768.03..1768.03 rows=80 width=206) (actual time=77.998..77.998 rows=46 loops=1)
                          ->  Hash Join  (cost=0.00..1768.03 rows=80 width=206) (actual time=66.092..77.843 rows=46 loops=1)
                                Hash Cond: (satellite_part_1.part_hashkey = link_supplier_part.part_hashkey)
                                Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 46 of 32768 buckets.Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.Hash chain length 3.9 avg, 12 max, using 252 of 256 buckets; total 3 expansions.

                                ->  Seq Scan on satellite_part satellite_part_1  (cost=0.00..432.50 rows=20000 width=95) (actual time=0.050..8.176 rows=20018 loops=1)
                                ->  Hash  (cost=1327.10..1327.10 rows=80 width=111) (actual time=64.572..64.572 rows=46 loops=1)
                                      ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..1327.10 rows=80 width=111) (actual time=57.111..64.506 rows=46 loops=1)
                                            Hash Key: link_supplier_part.part_hashkey
                                            ->  Hash Join  (cost=0.00..1327.07 rows=80 width=111) (actual time=18.751..63.213 rows=46 loops=1)
                                                  Hash Cond: (link_supplier_part.supplier_hashkey = hub_supplier.supplier_hashkey)
                                                  Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.Hash chain length 3.9 avg, 12 max, using 252 of 256 buckets; total 3 expansions.

                                                  ->  Seq Scan on link_supplier_part  (cost=0.00..437.51 rows=80000 width=66) (actual time=0.048..32.103 rows=80048 loops=1)
                                                  ->  Hash  (cost=862.59..862.59 rows=2 width=45) (actual time=17.056..17.056 rows=1 loops=1)
                                                        ->  Result  (cost=0.00..862.59 rows=2 width=45) (actual time=14.552..14.555 rows=1 loops=1)
                                                              ->  Broadcast Motion 2:2  (slice2; segments: 2)  (cost=0.00..862.59 rows=2 width=45) (actual time=14.187..14.188 rows=1 loops=1)
                                                                    ->  Hash Right Join  (cost=0.00..862.58 rows=1 width=45) (actual time=6.215..7.094 rows=1 loops=1)
                                                                          Hash Cond: (satellite_supplier_1.supplier_hashkey = hub_supplier.supplier_hashkey)
                                                                          Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.Hash chain length 3.9 avg, 12 max, using 252 of 256 buckets; total 3 expansions.

                                                                          ->  HashAggregate  (cost=0.00..431.30 rows=1000 width=41) (actual time=1.701..1.916 rows=973 loops=1)
                                                                                Group Key: satellite_supplier_1.supplier_hashkey
                                                                                Extra Text: (seg0)   Hash chain length 3.9 avg, 12 max, using 252 of 256 buckets; total 3 expansions.

                                                                                ->  Seq Scan on satellite_supplier satellite_supplier_1  (cost=0.00..431.08 rows=1000 width=41) (actual time=0.026..0.947 rows=973 loops=1)
                                                                          ->  Hash  (cost=431.08..431.08 rows=1 width=37) (actual time=3.673..3.673 rows=1 loops=1)
                                                                                ->  Seq Scan on hub_supplier  (cost=0.00..431.08 rows=1 width=37) (actual time=0.074..3.657 rows=1 loops=1)
                                                                                      Filter: (supplierid = 470)
Planning time: 655.637 ms
  (slice0)    Executor memory: 869K bytes.  Work_mem: 14K bytes max.
  (slice1)    Executor memory: 44K bytes avg x 2 workers, 44K bytes max (seg0).
  (slice2)    Executor memory: 680K bytes avg x 2 workers, 772K bytes max (seg0).  Work_mem: 1K bytes max.
  (slice3)    Executor memory: 592K bytes avg x 2 workers, 592K bytes max (seg0).  Work_mem: 1K bytes max.
  (slice4)    Executor memory: 7185K bytes avg x 2 workers, 7185K bytes max (seg0).  Work_mem: 1408K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 276.948 ms

## Выводы
В целом запросы, построенные на основе Data Vault выполняются дольше, но преимуществом архитектуры является простота изменений данных.
Выбирать между архитектурами сложно, нужно смотреть на задачи.