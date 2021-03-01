# text_xor_agg ()

Creates a postgres aggregate function that:

- works like any other sql aggregate functions: count(\*), sum(xx), etc
- calculates the md5() of each value received as its argument (text type)
- performs XOR operations on the list of calculated md5() results
- returns 32-hex-char resulting value
- works in plain postgres without any contrib extensions
- uses, however, postgres-only extensions to the sql standard

## Script name: create_xor_aggregate.sh

- This script creates a postgres aggregate function
- It also declares a few auxiliary functions (beware of name collisions)
- Run once to create the aggregate function in your postgres DB.

## Created function profile:  text_xor_agg (text) returns text;

Once created, this new function works as any other aggregate function: sum(), max(), etc.

## Purpuse

Uselful to compare if two queries resultsets are equivalent, but without having to re-order the rows
Returns 32 hex chars, which are the XOR of every row's md5().

Uses the 'create aggregate' facility of postgres (!) (no extensions involved)
Uses also postgres' md5() and bit(128) features

## Measured speed (after priming cached buffers):
  -   text_xor_agg(some_text_id)    is  5 times slower than **select count(),sum(some_cnt),sum(other_cnt) from x**
  -   text_xor_agg(tim_err.*::text) is 20 times slower than **select count(),sum(some_cnt),sum(other_cnt) from x**

However, if the db cache is not primed, then text_xor_agg() will be comparatively better.

## Example
 
select count(*), _text_xor_agg (x.*::text)_  from x;

## Bugs:

While calling the to_hex() function, zero (left) padding is required to make 8 bytes per integer.
