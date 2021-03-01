---
--- create_xor_aggregate.sh - run once to define in the DB's DDL
---
--  These functions create a postgres aggregate function
--  that implement a xor-over-md5() function for queries (works as sum(), max(), etc).
--
--  Uselful to compare if two query's resultsets are equivalent, with disordered rows.
--  Returns a 128 bit array (32 hex chars), which is a XOR of each row's md5(row_val).
--
--  since the XOR yields ZEROES in that case
--
--  Uses the 'create aggregate' facility of postgres (!)
--  Uses also md5 and bit(128) features
--
--  On its measured speed (after priming cached buffers):
--  -   text_xor_agg(textvalue)       is  5 times slower than count(),sum(),sum()
--  -   text_xor_agg(testtbl.*::text) is 20 times slower than count(),sum(),sum()
--
--  If db cache is not primed, then text_xor_agg() will probably be HALF as fast as count(),sum(),sum()
--

create or replace function md5bit (in txt_ text) returns bit as $$
        select ('x' || md5(txt_))::bit(128) ;
$$ LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;

create or replace function text_xor_acc (inout acc_ bit, in txt_ text) returns bit
    as 'select acc_ # md5bit(txt_)'
LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;

create or replace function text_xor_final (bit) returns text as $$
    select
    (
        to_hex(substring ($1 from  1 for 32)::int) ||
        to_hex(substring ($1 from 33 for 32)::int) ||
        to_hex(substring ($1 from 65 for 32)::int) ||
        to_hex(substring ($1 from 97 for 32)::int)
    ) :: text;
$$ LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;

drop aggregate if exists text_xor_agg (text);

create aggregate text_xor_agg (text) (
    sfunc = text_xor_acc,
    stype = bit,
    finalfunc = text_xor_final,
    initcond = 'x00000000000000000000000000000000'
);
