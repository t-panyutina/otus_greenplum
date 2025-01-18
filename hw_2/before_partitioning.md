Gather Motion 2:1  (slice4; segments: 2)  (cost=0.00..1752.15 rows=1 width=120) (actual time=724.294..757.614 rows=116 loops=1)
  ->  Hash Join  (cost=0.00..1752.15 rows=1 width=120) (actual time=609.171..634.116 rows=64 loops=1)
        Hash Cond: (part.p_partkey = lineitem.l_partkey)
        Extra Text: (seg1)   Hash chain length 4.0 avg, 4 max, using 16 of 65536 buckets.
        ->  Seq Scan on part  (cost=0.00..432.58 rows=20000 width=29) (actual time=4.077..24.478 rows=20063 loops=1)
        ->  Hash  (cost=1314.65..1314.65 rows=1 width=99) (actual time=585.451..585.451 rows=64 loops=1)
              ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..1314.65 rows=1 width=99) (actual time=573.114..584.777 rows=64 loops=1)
                    Hash Key: partsupp.ps_partkey
                    ->  Hash Join  (cost=0.00..1314.65 rows=1 width=103) (actual time=596.753..633.313 rows=60 loops=1)
                          Hash Cond: (partsupp.ps_partkey = lineitem.l_partkey)
                          Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 29 of 65536 buckets.
                          ->  Seq Scan on partsupp  (cost=0.00..437.95 rows=80000 width=4) (actual time=14.492..38.999 rows=80192 loops=1)
                          ->  Hash  (cost=862.00..862.00 rows=1 width=99) (actual time=600.665..600.665 rows=29 loops=1)
                                ->  Broadcast Motion 2:2  (slice2; segments: 2)  (cost=0.00..862.00 rows=1 width=99) (actual time=547.219..600.623 rows=29 loops=1)
                                      ->  Hash Join  (cost=0.00..862.00 rows=1 width=99) (actual time=155.020..542.248 rows=15 loops=1)
                                            Hash Cond: (orders.o_orderkey = lineitem.l_orderkey)
                                            Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 15 of 262144 buckets.
                                            ->  Sequence  (cost=0.00..431.00 rows=1 width=87) (actual time=5.779..373.244 rows=150135 loops=1)
                                                  ->  Partition Selector for orders (dynamic scan id: 2)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                                                        Partitions selected: 87 (out of 87)
                                                  ->  Dynamic Seq Scan on orders (dynamic scan id: 2)  (cost=0.00..431.00 rows=1 width=87) (actual time=5.710..344.916 rows=150135 loops=1)
                                                        Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
                                            ->  Hash  (cost=431.00..431.00 rows=1 width=20) (actual time=110.508..110.508 rows=15 loops=1)
                                                  ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..431.00 rows=1 width=20) (actual time=2.936..110.483 rows=15 loops=1)
                                                        Hash Key: lineitem.l_orderkey
                                                        ->  Result  (cost=0.00..431.00 rows=1 width=20) (actual time=115.367..116.084 rows=16 loops=1)
                                                              ->  Sequence  (cost=0.00..431.00 rows=1 width=32) (actual time=115.363..116.078 rows=16 loops=1)
                                                                    ->  Partition Selector for lineitem (dynamic scan id: 1)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                                                                          Partitions selected: 1 (out of 87)
                                                                    ->  Dynamic Seq Scan on lineitem (dynamic scan id: 1)  (cost=0.00..431.00 rows=1 width=32) (actual time=115.328..116.039 rows=16 loops=1)
                                                                          Filter: ((l_shipdate = '1992-02-28'::date) AND (l_shipmode = 'AIR'::bpchar))
                                                                          Partitions scanned:  Avg 1.0 (out of 87) x 2 workers.  Max 1 parts (seg0).
Planning time: 314.388 ms
  (slice0)    Executor memory: 720K bytes.
  (slice1)    Executor memory: 771K bytes avg x 2 workers, 774K bytes max (seg1).
  (slice2)    Executor memory: 4814K bytes avg x 2 workers, 4814K bytes max (seg1).  Work_mem: 1K bytes max.
  (slice3)    Executor memory: 744K bytes avg x 2 workers, 744K bytes max (seg0).  Work_mem: 3K bytes max.
  (slice4)    Executor memory: 944K bytes avg x 2 workers, 952K bytes max (seg1).  Work_mem: 7K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 829.165 ms