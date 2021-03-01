
-- create_xor_aggregate.sh 
-- See documentation: https://github.com/artejera/text_xor_agg/blob/main/README.md

create or replace function text_xor_final (bit) returns text as $$
    select
    (
        lpad(to_hex(substring ($1 from  1 for 32)::int),8, '0') ||
        lpad(to_hex(substring ($1 from 33 for 32)::int),8, '0') ||
        lpad(to_hex(substring ($1 from 65 for 32)::int),8, '0') ||
        lpad(to_hex(substring ($1 from 97 for 32)::int),8, '0')
    ) :: text;
$$ LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;

drop aggregate if exists text_xor_agg (text);

create aggregate text_xor_agg (text) (
    sfunc = text_xor_acc,
    stype = bit,
    finalfunc = text_xor_final,
    initcond = 'x00000000000000000000000000000000'
);
