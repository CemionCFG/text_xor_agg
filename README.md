# text_xor_agg
create aggregate providing XOR of md5(row) for postgres (9.* and up)

create_xor_aggregate.sh - run once to define in the DB's DDL

These functions create a postgres aggregate function
that implements a xor-over-md5() function for queries (works as sum(), max(), etc).

Uselful to compare if two queries resultsets are equivalent, with disordered rows.
Returns a 128 bit array (32 hex chars), which is a XOR of each row's md5(row_val).

The algorithm degenerates if row values are equal in the same table,
since the XOR yields ZEROES in that case

Uses the 'create aggregate' facility of postgres (!)
Uses also md5 and bit(128) features (of postgres)

On its measured speed (after priming cached buffers):
  -   text_xor_agg(rfc_emisor)      is  5 times slower than count(),sum(),sum()
  -   text_xor_agg(tim_err.*::text) is 20 times slower than count(),sum(),sum()

 If db cache is not primed, then text_xor_agg() will probably be HALF as fast as count(),sum(),sum()

Example
 
select count(*), text_xor_agg (x.*::text)  from x;

