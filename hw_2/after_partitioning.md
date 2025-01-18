Gather Motion 2:1  (slice4; segments: 2)  (cost=0.00..1752.15 rows=1 width=120) (actual time=660.104..663.253 rows=116 loops=1)
  ->  Hash Join  (cost=0.00..1752.15 rows=1 width=120) (actual time=650.836..661.379 rows=64 loops=1)
        Hash Cond: (part.p_partkey = lineitem.l_partkey)
        Extra Text: (seg1)   Hash chain length 4.0 avg, 4 max, using 16 of 65536 buckets.
        ->  Seq Scan on part  (cost=0.00..432.58 rows=20000 width=29) (actual time=0.168..5.318 rows=20063 loops=1)
        ->  Hash  (cost=1314.65..1314.65 rows=1 width=99) (actual time=650.478..650.478 rows=64 loops=1)
              ->  Redistribute Motion 2:2  (slice3; segments: 2)  (cost=0.00..1314.65 rows=1 width=99) (actual time=648.736..650.459 rows=64 loops=1)
                    Hash Key: partsupp.ps_partkey
                    ->  Hash Join  (cost=0.00..1314.65 rows=1 width=103) (actual time=615.151..648.949 rows=60 loops=1)
                          Hash Cond: (partsupp.ps_partkey = lineitem.l_partkey)
                          Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 29 of 65536 buckets.
                          ->  Seq Scan on partsupp  (cost=0.00..437.95 rows=80000 width=4) (actual time=0.097..17.152 rows=80192 loops=1)
                          ->  Hash  (cost=862.00..862.00 rows=1 width=99) (actual time=592.242..592.242 rows=29 loops=1)
                                ->  Broadcast Motion 2:2  (slice2; segments: 2)  (cost=0.00..862.00 rows=1 width=99) (actual time=519.598..592.219 rows=29 loops=1)
                                      ->  Hash Join  (cost=0.00..862.00 rows=1 width=99) (actual time=36.310..599.092 rows=15 loops=1)
                                            Hash Cond: (orders.o_orderkey = lineitem.l_orderkey)
                                            Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 15 of 262144 buckets.
                                            ->  Sequence  (cost=0.00..431.00 rows=1 width=87) (actual time=3.150..458.625 rows=150135 loops=1)
                                                  ->  Partition Selector for orders (dynamic scan id: 2)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                                                        Partitions selected: 87 (out of 87)
                                                  ->  Dynamic Seq Scan on orders (dynamic scan id: 2)  (cost=0.00..431.00 rows=1 width=87) (actual time=3.131..418.882 rows=150135 loops=1)
                                                        Partitions scanned:  Avg 87.0 (out of 87) x 2 workers.  Max 87 parts (seg0).
                                            ->  Hash  (cost=431.00..431.00 rows=1 width=20) (actual time=2.017..2.017 rows=15 loops=1)
                                                  ->  Redistribute Motion 2:2  (slice1; segments: 2)  (cost=0.00..431.00 rows=1 width=20) (actual time=0.154..2.005 rows=15 loops=1)
                                                        Hash Key: lineitem.l_orderkey
                                                        ->  Result  (cost=0.00..431.00 rows=1 width=20) (actual time=5.350..5.445 rows=16 loops=1)
                                                              ->  Sequence  (cost=0.00..431.00 rows=1 width=32) (actual time=5.348..5.441 rows=16 loops=1)
                                                                    ->  Partition Selector for lineitem (dynamic scan id: 1)  (cost=10.00..100.00 rows=50 width=4) (never executed)
                                                                          Partitions selected: 1 (out of 696)
                                                                    ->  Dynamic Seq Scan on lineitem (dynamic scan id: 1)  (cost=0.00..431.00 rows=1 width=32) (actual time=5.342..5.432 rows=16 loops=1)
                                                                          Filter: ((l_shipdate = '1992-02-28'::date) AND (l_shipmode = 'AIR'::bpchar))
                                                                          Partitions scanned:  Avg 1.0 (out of 696) x 2 workers.  Max 1 parts (seg0).
Planning time: 150.501 ms
  (slice0)    Executor memory: 720K bytes.
  (slice1)    Executor memory: 684K bytes avg x 2 workers, 684K bytes max (seg0).
  (slice2)    Executor memory: 4814K bytes avg x 2 workers, 4814K bytes max (seg1).  Work_mem: 1K bytes max.
  (slice3)    Executor memory: 744K bytes avg x 2 workers, 744K bytes max (seg0).  Work_mem: 3K bytes max.
  (slice4)    Executor memory: 944K bytes avg x 2 workers, 952K bytes max (seg1).  Work_mem: 7K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 669.921 ms