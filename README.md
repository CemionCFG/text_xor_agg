# text_xor_agg

Creates an aggregate function, providing XOR of md5(some_text) for postgres (9.* and up)

##Name: create_xor_aggregate.sh - run once to define in the DB's DDL

These functions create a postgres aggregate function
that implements a xor-over-md5() function for queries (works as sum(), max(), etc).

Uselful to compare if two queries resultsets are equivalent, with disordered rows.
Returns 32 hex chars, which are the XOR of every row's md5().

Uses the 'create aggregate' facility of postgres (!) (no extensions involved)
Uses also postgres' md5() and bit(128) features

##On its measured speed (after priming cached buffers):
  -   text_xor_agg(some_text_id)    is  5 times slower than select count(),sum(some_cnt),sum(other_cnt)
  -   text_xor_agg(tim_err.*::text) is 20 times slower select count(),sum(some_cnt),sum(other_cnt)

However, if the db cache is not primed, then text_xor_agg() will probably be HALF as fast as count(),sum(),sum()

##Example
 
select count(*), _text_xor_agg (x.*::text)_  from x;

