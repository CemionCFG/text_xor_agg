# text_xor_agg

Creates an aggregate function, providing XOR of md5(some_text) for postgres (9.* and up)

## Name: create_xor_aggregate.sh

Run once to create the functiono in the DB.

These functions create a postgres aggregate function
that implements a xor-over-md5() function for queries.

Once created, this new function works as any other aggregate function: sum(), max(), etc.

## Purpuse
Uselful to compare if two queries resultsets are equivalent, with disordered rows.
Returns 32 hex chars, which are the XOR of every row's md5().

Uses the 'create aggregate' facility of postgres (!) (no extensions involved)
Uses also postgres' md5() and bit(128) features

## Measured speed (after priming cached buffers):
  -   text_xor_agg(some_text_id)    is  5 times slower than **select count(),sum(some_cnt),sum(other_cnt) from x**
  -   text_xor_agg(tim_err.*::text) is 20 times slower than **select count(),sum(some_cnt),sum(other_cnt) from x**

However, if the db cache is not primed, then text_xor_agg() will be comparatively better.

##Example
 
select count(*), _text_xor_agg (x.*::text)_  from x;

