## Query 1: Retrieve Customer Orders with Order and Customer Details
```
explain analyze select o_orderstatus,
o_totalprice,
o_orderdate,
o_orderpriority,
o_clerk,
o_shippriority,
o_comment,
c_name,
c_address,
c_nationkey,
c_phone,
c_acctbal,
c_mktsegment,
c_comment
from orders o
join customer c
on c.c_custkey = o.o_custkey;
```
Gather Motion 2:1  (slice2; segments: 2)  (cost=0.00..871.93 rows=1 width=281) (actual time=2800.271..5493.958 rows=300000 loops=1)
  ->  Hash Join  (cost=0.00..871.93 rows=1 width=281) (actual time=2799.005..3119.445 rows=151208 loops=1)
        Hash Cond: (customer.c_custkey = orders.o_custkey)
        Extra Text: (seg1)   Hash chain length 15.6 avg, 67 max, using 9684 of 131072 buckets.
        ->  Seq Scan on customer  (cost=0.00..432.43 rows=15000 width=159) (actual time=0.534..24.515 rows=15031 loops=1)
        ->  Hash  (cost=431.00..431.00 rows=1 width=130) (actual time=2798.163..2798.163 rows=151208 loops=1)
              ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..431.00 rows=1 width=130) (actual time=13.231..2678.355 rows=151208 loops=1)
                    Hash Key: orders.o_custkey
                    ->  Sequence  (cost=0.00..431.00 rows=1 width=130) (actual time=9.661..1191.002 rows=150135 loops=1)
                          ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                                Partitions selected: 87 (out of 87)
                          ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..431.00 rows=1 width=130) (actual time=9.613..1134.322 rows=150135 loops=1)
                                Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
Planning time: 15.130 ms
  (slice0)    Executor memory: 976K bytes.
  (slice1)    Executor memory: 3382K bytes avg x 2 workers, 3382K bytes max (seg1).
  (slice2)    Executor memory: 34760K bytes avg x 2 workers, 34760K bytes max (seg0).  Work_mem: 20400K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 5555.860 ms


## Query 2: Retrieve Detailed Order Information with Line Items
```
explain analyze select 
o_orderstatus,
o_totalprice,
o_orderdate,
o_orderpriority,
o_comment,
l_linenumber,
l_quantity,
l_extendedprice,
l_discount,
l_tax,
l_returnflag,
l_linestatus,
l_shipdate,
l_receiptdate,
l_comment from orders join lineitem
on l_orderkey = o_orderkey;
```

Gather Motion 2:1  (slice2; segments: 2)  (cost=0.00..862.00 rows=1 width=197) (actual time=6742.808..14925.586 rows=1199969 loops=1)
  ->  Hash Join  (cost=0.00..862.00 rows=1 width=197) (actual time=6742.187..9132.508 rows=600656 loops=1)
        Hash Cond: (orders.o_orderkey = lineitem.l_orderkey)
        Extra Text: (seg1)   Hash chain length 6.7 avg, 39 max, using 89349 of 131072 buckets.
        ->  Sequence  (cost=0.00..431.00 rows=1 width=115) (actual time=4.195..965.152 rows=150135 loops=1)
              ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                    Partitions selected: 87 (out of 87)
              ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..431.00 rows=1 width=115) (actual time=4.169..893.876 rows=150135 loops=1)
                    Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
        ->  Hash  (cost=431.00..431.00 rows=1 width=98) (actual time=6737.670..6737.670 rows=600656 loops=1)
              ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..431.00 rows=1 width=98) (actual time=11.351..6252.777 rows=600656 loops=1)
                    Hash Key: lineitem.l_orderkey
                    ->  Sequence  (cost=0.00..431.00 rows=1 width=98) (actual time=18.127..2358.978 rows=600209 loops=1)
                          ->  Partition Selector for lineitem (dynamic scan id: 2)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                                Partitions selected: 87 (out of 87)
                          ->  Dynamic Seq Scan on lineitem (dynamic scan id: 2)  (cost=0.00..431.00 rows=1 width=98) (actual time=17.356..2100.026 rows=600209 loops=1)
                                Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
Planning time: 17.667 ms
  (slice0)    Executor memory: 179K bytes.
  (slice1)    Executor memory: 4898K bytes avg x 2 workers, 4898K bytes max (seg1).
  (slice2)    Executor memory: 94357K bytes avg x 2 workers, 94358K bytes max (seg1).  Work_mem: 68221K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 15127.694 ms


## Query 3: Retrieve Supplier and Part Information for Each Supplier-Part Relationship
```
explain analyze select p_name,
p_mfgr,
p_brand,
p_type,
p_size,
p_container,
p_retailprice,
s_name,
s_address,
s_nationkey,
s_phone,
s_acctbal
from partsupp
join supplier on s_suppkey = ps_suppkey
join part on p_partkey = ps_partkey;
```

Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..1584.94 rows=158873 width=190) (actual time=305.363..1559.882 rows=160000 loops=1)
  ->  Hash Join  (cost=0.00..1449.41 rows=79437 width=190) (actual time=303.561..589.422 rows=80252 loops=1)
        Hash Cond: (partsupp.ps_suppkey = supplier.s_suppkey)
        Extra Text: (seg1)   Hash chain length 1.0 avg, 2 max, using 1973 of 65536 buckets.
        ->  Hash Join  (cost=0.00..937.71 rows=79437 width=116) (actual time=285.735..419.154 rows=80252 loops=1)
              Hash Cond: (part.p_partkey = partsupp.ps_partkey)
              Extra Text: (seg1)   Hash chain length 4.2 avg, 12 max, using 19248 of 262144 buckets.
              ->  Seq Scan on part  (cost=0.00..432.58 rows=20000 width=116) (actual time=0.711..32.563 rows=20063 loops=1)
              ->  Hash  (cost=441.15..441.15 rows=80000 width=8) (actual time=284.442..284.442 rows=80252 loops=1)
                    ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..441.15 rows=80000 width=8) (actual time=0.056..244.769 rows=80252 loops=1)
                          Hash Key: partsupp.ps_partkey
                          ->  Seq Scan on partsupp  (cost=0.00..437.95 rows=80000 width=8) (actual time=0.149..103.623 rows=80192 loops=1)
        ->  Hash  (cost=435.53..435.53 rows=2000 width=82) (actual time=19.987..19.987 rows=2000 loops=1)
              ->  Broadcast Motion 2:2  (slice2; segments: 2)  (cost=0.00..435.53 rows=2000 width=82) (actual time=2.182..8.824 rows=2000 loops=1)
                    ->  Seq Scan on supplier  (cost=0.00..431.09 rows=1000 width=82) (actual time=0.226..0.515 rows=1002 loops=1)
Planning time: 55.699 ms
  (slice0)    Executor memory: 1864K bytes.
  (slice1)    Executor memory: 284K bytes avg x 2 workers, 284K bytes max (seg0).
  (slice2)    Executor memory: 688K bytes avg x 2 workers, 688K bytes max (seg0).
  (slice3)    Executor memory: 8232K bytes avg x 2 workers, 8232K bytes max (seg0).  Work_mem: 2508K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 1586.043 ms


## Query 4: Retrieve Comprehensive Customer Order and Line Item Details
```
explain analyze select c_name,
c_address,
c_nationkey,
c_phone,
o_orderstatus,
o_totalprice, 
o_orderdate,
o_orderpriority,
l_linenumber,
l_quantity,
l_extendedprice,
l_discount,
l_tax,
l_returnflag,
l_linestatus
from customer 
join orders on c_custkey = o_custkey
join lineitem on l_orderkey = o_orderkey;
```

Gather Motion 2:1  (slice4; segments: 2)  (cost=0.00..1299.59 rows=1 width=131) (actual time=4945.862..12528.005 rows=1199969 loops=1)
  ->  Hash Join  (cost=0.00..1299.59 rows=1 width=131) (actual time=4942.208..7742.049 rows=600656 loops=1)
        Hash Cond: (orders.o_orderkey = lineitem.l_orderkey)
        Extra Text: (seg1)   Hash chain length 6.7 avg, 39 max, using 89349 of 131072 buckets.
        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..868.59 rows=1 width=101) (actual time=0.024..1225.479 rows=150135 loops=1)
              Hash Key: orders.o_orderkey
              ->  Hash Join  (cost=0.00..868.59 rows=1 width=101) (actual time=1662.760..2078.750 rows=151208 loops=1)
                    Hash Cond: (customer.c_custkey = orders.o_custkey)
                    Extra Text: (seg1)   Hash chain length 15.6 avg, 67 max, using 9684 of 131072 buckets.
                    ->  Seq Scan on customer  (cost=0.00..432.43 rows=15000 width=69) (actual time=0.627..23.206 rows=15031 loops=1)
                    ->  Hash  (cost=431.00..431.00 rows=1 width=40) (actual time=1662.027..1662.027 rows=151208 loops=1)
                          ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..431.00 rows=1 width=40) (actual time=0.010..1497.877 rows=151208 loops=1)
                                Hash Key: orders.o_custkey
                                ->  Sequence  (cost=0.00..431.00 rows=1 width=40) (actual time=3.354..791.191 rows=150135 loops=1)
                                      ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                                            Partitions selected: 87 (out of 87)
                                      ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..431.00 rows=1 width=40) (actual time=3.344..753.402 rows=150135 loops=1)
                                            Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
        ->  Hash  (cost=431.00..431.00 rows=1 width=46) (actual time=4942.010..4942.010 rows=600656 loops=1)
              ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..431.00 rows=1 width=46) (actual time=21.901..4578.327 rows=600656 loops=1)
                    Hash Key: lineitem.l_orderkey
                    ->  Sequence  (cost=0.00..431.00 rows=1 width=46) (actual time=16.703..2350.941 rows=600209 loops=1)
                          ->  Partition Selector for lineitem (dynamic scan id: 2)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                                Partitions selected: 87 (out of 87)
                          ->  Dynamic Seq Scan on lineitem (dynamic scan id: 2)  (cost=0.00..431.00 rows=1 width=46) (actual time=16.687..2116.626 rows=600209 loops=1)
                                Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
Planning time: 57.669 ms
  (slice0)    Executor memory: 804K bytes.
  (slice1)    Executor memory: 3147K bytes avg x 2 workers, 3148K bytes max (seg1).
  (slice2)    Executor memory: 26216K bytes avg x 2 workers, 26216K bytes max (seg0).  Work_mem: 11778K bytes max.
  (slice3)    Executor memory: 3498K bytes avg x 2 workers, 3498K bytes max (seg1).
  (slice4)    Executor memory: 91256K bytes avg x 2 workers, 91256K bytes max (seg0).  Work_mem: 46714K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 12703.955 ms


## Query 5: Retrieve All Parts Supplied by a Specific Supplier with Supplier Details
```
explain analyze select 
s_name,
s_address,
s_phone,
s_acctbal,
p_name, 
p_type,
p_brand
from partsupp
join supplier on s_suppkey = ps_suppkey
join part on p_partkey = ps_partkey
where s_name = 'Supplier#000000002       ';
```

Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..1324.19 rows=80 width=139) (actual time=55.042..56.730 rows=80 loops=1)
  ->  Hash Join  (cost=0.00..1324.14 rows=40 width=139) (actual time=42.955..53.920 rows=47 loops=1)
        Hash Cond: (part.p_partkey = partsupp.ps_partkey)
        Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 47 of 65536 buckets.
        ->  Seq Scan on part  (cost=0.00..432.58 rows=20000 width=69) (actual time=0.573..6.453 rows=20063 loops=1)
        ->  Hash  (cost=884.58..884.58 rows=40 width=78) (actual time=41.723..41.723 rows=47 loops=1)
              ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..884.58 rows=40 width=78) (actual time=41.679..41.694 rows=47 loops=1)
                    Hash Key: partsupp.ps_partkey
                    ->  Hash Join  (cost=0.00..884.57 rows=40 width=78) (actual time=1.977..33.886 rows=40 loops=1)
                          Hash Cond: (partsupp.ps_suppkey = supplier.s_suppkey)
                          Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 1 of 65536 buckets.
                          ->  Seq Scan on partsupp  (cost=0.00..437.95 rows=80000 width=8) (actual time=0.075..17.083 rows=80192 loops=1)
                          ->  Hash  (cost=431.12..431.12 rows=1 width=78) (actual time=0.007..0.007 rows=1 loops=1)
                                ->  Broadcast Motion 2:2  (slice1; segments: 2)  (cost=0.00..431.12 rows=1 width=78) (actual time=0.005..0.005 rows=1 loops=1)
                                      ->  Seq Scan on supplier  (cost=0.00..431.12 rows=1 width=78) (actual time=0.120..0.339 rows=1 loops=1)
                                            Filter: (s_name = 'Supplier#000000002       '::bpchar)
Planning time: 50.653 ms
  (slice0)    Executor memory: 1384K bytes.
  (slice1)    Executor memory: 592K bytes avg x 2 workers, 592K bytes max (seg0).
  (slice2)    Executor memory: 832K bytes avg x 2 workers, 832K bytes max (seg0).  Work_mem: 1K bytes max.
  (slice3)    Executor memory: 1032K bytes avg x 2 workers, 1032K bytes max (seg0).  Work_mem: 5K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 62.297 ms


## Изменения структуры таблиц через дистрибуцию и индексы
Добавим дистрибуцию по полям, используемым в джойнах
Добавим индекс на поле s_name

## Новые замеры производительности для отдельных запросов
Внимание! Изменения произведены только для orders и supplier
Производительность 1го запроса почти не изменилась, несмотря на добавление к ключу дистрибуции O_CUSTKEY, вероятно стоит попробовать индексы
Странным образом изменилась производительность второго запроса, время выполнения сократилось с 15 тыс до 10 тыс мсек

Hash Join  (cost=0.00..862.00 rows=1 width=197) (actual time=6934.440..10520.387 rows=1199969 loops=1)
  Hash Cond: (orders.o_orderkey = lineitem.l_orderkey)
  Extra Text: Initial batch 0:
  Wrote 61062K bytes to inner workfile.
  Wrote 16413K bytes to outer workfile.
Overflow batch 1:
  Read 61062K bytes from inner workfile.
  Read 16413K bytes from outer workfile.
Hash chain length 6.7 avg, 41 max, using 178828 of 262144 buckets.
  ->  Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..431.00 rows=1 width=115) (actual time=0.028..1467.866 rows=300000 loops=1)
        ->  Sequence  (cost=0.00..431.00 rows=1 width=115) (actual time=10.886..1130.640 rows=150271 loops=1)
              ->  Partition Selector for orders (dynamic scan id: 1)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                    Partitions selected: 87 (out of 87)
              ->  Dynamic Seq Scan on orders (dynamic scan id: 1)  (cost=0.00..431.00 rows=1 width=115) (actual time=10.870..1079.126 rows=150271 loops=1)
                    Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
  ->  Hash  (cost=431.00..431.00 rows=1 width=98) (actual time=6933.558..6933.558 rows=1199969 loops=1)
        Buckets: 131072  Batches: 2 (originally 1)  Memory Usage: 127501kB
        ->  Gather Motion 2:1  (slice2; segments: 2)  (cost=0.00..431.00 rows=1 width=98) (actual time=24.938..5156.358 rows=1199969 loops=1)
              ->  Sequence  (cost=0.00..431.00 rows=1 width=98) (actual time=16.336..2240.857 rows=600209 loops=1)
                    ->  Partition Selector for lineitem (dynamic scan id: 2)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                          Partitions selected: 87 (out of 87)
                    ->  Dynamic Seq Scan on lineitem (dynamic scan id: 2)  (cost=0.00..431.00 rows=1 width=98) (actual time=15.856..1951.033 rows=600209 loops=1)
                          Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
Planning time: 22.424 ms
* (slice0)    Executor memory: 165114K bytes.  Work_mem: 127501K bytes max, 136280K bytes wanted.
  (slice1)    Executor memory: 3177K bytes avg x 2 workers, 3178K bytes max (seg1).
  (slice2)    Executor memory: 4899K bytes avg x 2 workers, 4901K bytes max (seg0).
Memory used:  128000kB
Memory wanted:  137179kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 10707.947 ms

Производительность 3го запроса без изменений
Производительность 4го запроса без изменений
Производительность 5го запроса ухудшилась во много раз после добавления bitmap индекса

Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..1289.62 rows=80 width=139) (actual time=37548.346..37563.570 rows=80 loops=1)
  ->  Hash Join  (cost=0.00..1289.57 rows=40 width=139) (actual time=37536.460..37546.569 rows=47 loops=1)
        Hash Cond: (part.p_partkey = partsupp.ps_partkey)
        Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 47 of 65536 buckets.
        ->  Seq Scan on part  (cost=0.00..432.58 rows=20000 width=69) (actual time=0.207..9.702 rows=20063 loops=1)
        ->  Hash  (cost=850.01..850.01 rows=40 width=78) (actual time=37535.329..37535.329 rows=47 loops=1)
              ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..850.01 rows=40 width=78) (actual time=37535.296..37535.299 rows=47 loops=1)
                    Hash Key: partsupp.ps_partkey
                    ->  Nested Loop  (cost=0.00..850.00 rows=40 width=78) (actual time=2.830..37528.093 rows=80 loops=1)
                          Join Filter: true
                          ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..441.10 rows=80000 width=8) (actual time=0.051..302.408 rows=80160 loops=1)
                                Hash Key: partsupp.ps_suppkey
                                ->  Seq Scan on partsupp  (cost=0.00..437.91 rows=80000 width=8) (actual time=0.212..40.820 rows=80192 loops=1)
                          ->  Bitmap Heap Scan on supplier  (cost=0.00..408.50 rows=1 width=74) (actual time=0.000..0.449 rows=0 loops=80160)
                                Recheck Cond: (s_name = 'Supplier#000000002       '::bpchar)
                                Filter: (s_suppkey = partsupp.ps_suppkey)
                                ->  Bitmap Index Scan on my_index  (cost=0.00..0.00 rows=0 width=0) (actual time=0.000..0.078 rows=1 loops=80160)
                                      Index Cond: (s_name = 'Supplier#000000002       '::bpchar)
Planning time: 69.734 ms
  (slice0)    Executor memory: 760K bytes.
  (slice1)    Executor memory: 284K bytes avg x 2 workers, 284K bytes max (seg0).
  (slice2)    Executor memory: 11521603K bytes avg x 2 workers, 11544838K bytes max (seg0).
  (slice3)    Executor memory: 1040K bytes avg x 2 workers, 1048K bytes max (seg0).  Work_mem: 5K bytes max.
  (slice4)    
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 37565.887 ms

С BTree индексом время выполнения намного лучше, чем с bitmap

Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..1279.62 rows=80 width=139) (actual time=25971.907..25977.067 rows=80 loops=1)
  ->  Hash Join  (cost=0.00..1279.57 rows=40 width=139) (actual time=25955.863..25970.880 rows=47 loops=1)
        Hash Cond: (part.p_partkey = partsupp.ps_partkey)
        Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 47 of 65536 buckets.
        ->  Seq Scan on part  (cost=0.00..432.58 rows=20000 width=69) (actual time=0.180..21.293 rows=20063 loops=1)
        ->  Hash  (cost=840.01..840.01 rows=40 width=78) (actual time=25955.407..25955.407 rows=47 loops=1)
              ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..840.01 rows=40 width=78) (actual time=25955.370..25955.376 rows=47 loops=1)
                    Hash Key: partsupp.ps_partkey
                    ->  Nested Loop  (cost=0.00..840.00 rows=40 width=78) (actual time=125.544..25942.611 rows=80 loops=1)
                          Join Filter: true
                          ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..441.10 rows=80000 width=8) (actual time=0.049..188.231 rows=80160 loops=1)
                                Hash Key: partsupp.ps_suppkey
                                ->  Seq Scan on partsupp  (cost=0.00..437.91 rows=80000 width=8) (actual time=0.190..34.535 rows=80192 loops=1)
                          ->  Bitmap Heap Scan on supplier  (cost=0.00..398.50 rows=1 width=74) (actual time=0.000..0.319 rows=0 loops=80160)
                                Recheck Cond: (s_name = 'Supplier#000000002       '::bpchar)
                                Filter: (s_suppkey = partsupp.ps_suppkey)
                                ->  Bitmap Index Scan on my_index  (cost=0.00..0.00 rows=0 width=0) (actual time=0.000..0.021 rows=1 loops=80160)
                                      Index Cond: (s_name = 'Supplier#000000002       '::bpchar)
Planning time: 64.291 ms
  (slice0)    Executor memory: 792K bytes.
  (slice1)    Executor memory: 284K bytes avg x 2 workers, 284K bytes max (seg0).
  (slice2)    Executor memory: 11521328K bytes avg x 2 workers, 11544385K bytes max (seg0).  Work_mem: 9K bytes max.
  (slice3)    Executor memory: 1040K bytes avg x 2 workers, 1048K bytes max (seg0).  Work_mem: 5K bytes max.
  (slice4)    
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 25979.170 ms

Из этого делаю вывод, что индексы могут быть даже вредны в некоторых случаях

Analyze после первого заполнения таблиц существенно повышает произодительность запросов

Больше идей по улучшению производительности не нашла