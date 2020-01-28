-- use this to verify the calculations in test_cardconex_account

USE sales_force;

SET @acct_id = '0013i00000EmHuvAAF';
SET @legacy_id = '0014P00001l9QNcQAM';
SELECT @acct_id, @legacy_id;

DROP TABLE IF EXISTS tmp_legacy_ids;

CREATE TEMPORARY TABLE tmp_legacy_ids SELECT DISTINCT legacy_id FROM test_cardconex_account;  -- must run cardconex_acct_

ALTER TABLE tmp_legacy_ids ADD INDEX(legacy_id);

DROP TABLE IF EXISTS tmp_updated;

CREATE TEMPORARY TABLE tmp_updated 
SELECT 
    legacy_id,
    sum(ach_credit_fee) AS sum_ach_credit_fee, 
    sum(bfach_discount_rate) AS sum_bfach_discount_rate, 
    sum(ach_monthly_fee) AS sum_ach_monthly_fee, 
    sum(ach_noc_fee) AS sum_ach_noc_fee, 
    sum(ach_per_gw_trans_fee) AS sum_ach_per_gw_trans_fee,
    sum(per_transaction_fee) AS sum_per_transaction_fee, 
    sum(ach_return_error_fee) AS sum_ach_return_error_fee, 
    sum(ach_transaction_fee) AS sum_ach_transaction_fee, 
    sum(bluefin_gateway_discount_rate) AS sum_bluefin_gateway_discount_rate, 
    sum(file_transfer_monthly_fee) AS sum_file_transfer_monthly_fee, 
    sum(gateway_monthly_fee) AS sum_gateway_monthly_fee, 
    sum(group_tag_fee) AS sum_group_tag_fee, 
    sum(gw_per_auth_decline_fee) AS sum_gw_per_auth_decline_fee, 
    sum(gw_per_credit_fee) AS sum_gw_per_credit_fee, 
    sum(gw_per_refund_fee) AS sum_gw_per_refund_fee, 
    sum(gw_per_sale_fee) AS sum_gw_per_sale_fee, 
    sum(gw_per_token_fee) AS sum_gw_per_token_fee, 
    sum(gw_reissued_fee) AS sum_gw_reissued_fee, 
    sum(misc_monthly_fees) AS sum_misc_monthly_fees, 
    sum(p2pe_device_activated) AS sum_p2pe_device_activated, 
    sum(p2pe_device_activating_fee) AS sum_p2pe_device_activating_fee, 
    sum(p2pe_device_stored_fee) AS sum_p2pe_device_stored_fee, 
    sum(p2pe_encryption_fee) AS sum_p2pe_encryption_fee, 
    sum(p2pe_monthly_flat_fee) AS sum_p2pe_monthly_flat_fee, 
    sum(one_time_key_injection_fees) AS sum_one_time_key_injection_fees, 
    sum(p2pe_tokenization_fee) AS sum_p2pe_tokenization_fee, 
    sum(pci_scans_monthly_fee) AS sum_pci_scans_monthly_fee, 
    sum(pci_compliance_fee) AS sum_pci_compliance_fee, 
    sum(pci_non_compliance_fee) AS sum_pci_non_compliance_fee
    FROM test_cardconex_account 
GROUP BY 1
;
ALTER TABLE tmp_updated ADD INDEX(legacy_id);

DROP TABLE IF EXISTS tmp_original;
CREATE TEMPORARY TABLE tmp_original 
SELECT 
    acct_id,
    sum(ach_credit_fee) AS sum_ach_credit_fee, 
    sum(bfach_discount_rate) AS sum_bfach_discount_rate, 
    sum(ach_monthly_fee) AS sum_ach_monthly_fee, 
    sum(ach_noc_fee) AS sum_ach_noc_fee, 
    sum(ach_per_gw_trans_fee) AS sum_ach_per_gw_trans_fee,
    sum(per_transaction_fee) AS sum_per_transaction_fee, 
    sum(ach_return_error_fee) AS sum_ach_return_error_fee, 
    sum(ach_transaction_fee) AS sum_ach_transaction_fee, 
    sum(bluefin_gateway_discount_rate) AS sum_bluefin_gateway_discount_rate, 
    sum(file_transfer_monthly_fee) AS sum_file_transfer_monthly_fee, 
    sum(gateway_monthly_fee) AS sum_gateway_monthly_fee, 
    sum(group_tag_fee) AS sum_group_tag_fee, 
    sum(gw_per_auth_decline_fee) AS sum_gw_per_auth_decline_fee, 
    sum(gw_per_credit_fee) AS sum_gw_per_credit_fee, 
    sum(gw_per_refund_fee) AS sum_gw_per_refund_fee, 
    sum(gw_per_sale_fee) AS sum_gw_per_sale_fee, 
    sum(gw_per_token_fee) AS sum_gw_per_token_fee, 
    sum(gw_reissued_fee) AS sum_gw_reissued_fee, 
    sum(misc_monthly_fees) AS sum_misc_monthly_fees, 
    sum(p2pe_device_activated) AS sum_p2pe_device_activated, 
    sum(p2pe_device_activating_fee) AS sum_p2pe_device_activating_fee, 
    sum(p2pe_device_stored_fee) AS sum_p2pe_device_stored_fee, 
    sum(p2pe_encryption_fee) AS sum_p2pe_encryption_fee, 
    sum(p2pe_monthly_flat_fee) AS sum_p2pe_monthly_flat_fee, 
    sum(one_time_key_injection_fees) AS sum_one_time_key_injection_fees, 
    sum(p2pe_tokenization_fee) AS sum_p2pe_tokenization_fee, 
    sum(pci_scans_monthly_fee) AS sum_pci_scans_monthly_fee, 
    sum(pci_compliance_fee) AS sum_pci_compliance_fee, 
    sum(pci_non_compliance_fee) AS sum_pci_non_compliance_fee
    FROM stg_cardconex_account 
   WHERE acct_id IN (SELECT legacy_id FROM tmp_legacy_ids)
GROUP BY 1
;
ALTER TABLE tmp_original ADD INDEX(acct_id);

DROP TABLE IF EXISTS test_results;
CREATE TEMPORARY TABLE test_results
SELECT 
    ids.legacy_id,
    u.sum_ach_credit_fee - o.sum_ach_credit_fee AS delta_ach_credit_fee,
    u.sum_bfach_discount_rate - o.sum_bfach_discount_rate AS delta_bfach_discount_rate,
    u.sum_ach_monthly_fee - o.sum_ach_monthly_fee AS delta_ach_monthly_fee,
    u.sum_ach_noc_fee - o.sum_ach_noc_fee AS delta_ach_noc_fee,
    u.sum_ach_per_gw_trans_fee - o.sum_ach_per_gw_trans_fee AS delta_sum_ach_per_gw_trans_fee,
    u.sum_per_transaction_fee - o.sum_per_transaction_fee AS delta_per_transaction_fee,
    u.sum_ach_return_error_fee - o.sum_ach_return_error_fee AS delta_ach_return_error_fee,
    u.sum_ach_transaction_fee - o.sum_ach_transaction_fee AS delta_ach_transaction_fee,
    u.sum_bluefin_gateway_discount_rate - o.sum_bluefin_gateway_discount_rate AS delta_bluefin_gateway_discount_rate,
    u.sum_file_transfer_monthly_fee - o.sum_file_transfer_monthly_fee AS delta_file_transfer_monthly_fee,
    u.sum_gateway_monthly_fee - o.sum_gateway_monthly_fee AS delta_gateway_monthly_fee,
    u.sum_group_tag_fee - o.sum_group_tag_fee AS delta_group_tag_fee,
    u.sum_gw_per_auth_decline_fee - o.sum_gw_per_auth_decline_fee AS delta_gw_per_auth_decline_fee,
    u.sum_gw_per_credit_fee - o.sum_gw_per_credit_fee AS delta_gw_per_credit_fee,
    u.sum_gw_per_refund_fee - o.sum_gw_per_refund_fee AS delta_gw_per_refund_fee,
    u.sum_gw_per_sale_fee - o.sum_gw_per_sale_fee AS delta_gw_per_sale_fee,
    u.sum_gw_per_token_fee - o.sum_gw_per_token_fee AS delta_gw_per_token_fee,
    u.sum_gw_reissued_fee - o.sum_gw_reissued_fee AS delta_gw_reissued_fee,
    u.sum_misc_monthly_fees - o.sum_misc_monthly_fees AS delta_misc_monthly_fees,
    u.sum_p2pe_device_activated - o.sum_p2pe_device_activated AS delta_p2pe_device_activated,
    u.sum_p2pe_device_activating_fee - o.sum_p2pe_device_activating_fee AS delta_p2pe_device_activating_fee,
    u.sum_p2pe_device_stored_fee - o.sum_p2pe_device_stored_fee AS delta_p2pe_device_stored_fee,
    u.sum_p2pe_encryption_fee - o.sum_p2pe_encryption_fee AS delta_p2pe_encryption_fee,
    u.sum_p2pe_monthly_flat_fee - o.sum_p2pe_monthly_flat_fee AS delta_p2pe_monthly_flat_fee,
    u.sum_one_time_key_injection_fees - o.sum_one_time_key_injection_fees AS delta_one_time_key_injection_fees,
    u.sum_p2pe_tokenization_fee - o.sum_p2pe_tokenization_fee AS delta_p2pe_tokenization_fee,
    u.sum_pci_scans_monthly_fee - o.sum_pci_scans_monthly_fee AS delta_pci_scans_monthly_fee,
    u.sum_pci_compliance_fee - o.sum_pci_compliance_fee AS delta_pci_compliance_fee,
    u.sum_pci_non_compliance_fee - o.sum_pci_non_compliance_fee AS delta_pci_non_compliance_fee
  FROM tmp_legacy_ids     ids
  LEFT JOIN tmp_updated   u
    ON ids.legacy_id = u.legacy_id
  LEFT JOIN tmp_original  o 
    ON ids.legacy_id = o.acct_id
;  

SELECT 
    sum(delta_ach_credit_fee),
    sum(delta_bfach_discount_rate),
    sum(delta_ach_monthly_fee),
    sum(delta_ach_noc_fee),
    sum(delta_sum_ach_per_gw_trans_fee),
    sum(delta_per_transaction_fee),
    sum(delta_ach_return_error_fee),
    sum(delta_ach_transaction_fee),
    sum(delta_bluefin_gateway_discount_rate),
    sum(delta_file_transfer_monthly_fee),
    sum(delta_gateway_monthly_fee),
    sum(delta_group_tag_fee),
    sum(delta_gw_per_auth_decline_fee),
    sum(delta_gw_per_credit_fee),
    sum(delta_gw_per_refund_fee),
    sum(delta_gw_per_sale_fee),
    sum(delta_gw_per_token_fee),
    sum(delta_gw_reissued_fee),
    sum(delta_misc_monthly_fees),
    sum(delta_p2pe_device_activated),
    sum(delta_p2pe_device_activating_fee),
    sum(delta_p2pe_device_stored_fee),
    sum(delta_p2pe_encryption_fee),
    sum(delta_p2pe_monthly_flat_fee),
    sum(delta_one_time_key_injection_fees),
    sum(delta_p2pe_tokenization_fee),
    sum(delta_pci_scans_monthly_fee),
    sum(delta_pci_compliance_fee),
    sum(delta_pci_non_compliance_fee)
FROM test_results;

-- to test an indivudal cardconex_acct_id

-- 22 jan 2020

-- legacy_id           delta_per_transaction_fee
-- 0010B00001zUAODQA4  [NULL]
-- 001U000001RzapUIAR  [NULL]
-- 001U000001V2Z7fIAF  -0.05

SET @legacy_id = '001U000001V2Z7fIAF';
SET @acct_id = (SELECT id FROM account WHERE legacy_id__c = @legacy_id);
SELECT @acct_id, @legacy_id;

SELECT 
     acct_id
    ,dba_name
    ,p2pe_device_activated     
    ,p2pe_device_activating_fee
    ,p2pe_device_stored_fee    
    ,p2pe_encryption_fee       
    ,gw_per_auth_decline_fee                     
    ,gw_per_credit_fee         
    ,gw_per_refund_fee         
    ,gw_per_token_fee          
  FROM stg_cardconex_account 
WHERE acct_id = @legacy_id;

-- Name                      |Value               |
-- --------------------------|--------------------|
-- acct_id                   |001U000001V2Z7fIAF  |
-- dba_name                  |Interstate Batteries|
-- p2pe_device_activated     |5.0000              |
-- p2pe_device_activating_fee|5.0000              |
-- p2pe_device_stored_fee    |0.0000              |
-- p2pe_encryption_fee       |0.0500              |
-- gw_per_auth_decline_fee   |0.0500              |
-- gw_per_credit_fee         |0.0500              |
-- gw_per_refund_fee         |0.0500              |
-- gw_per_token_fee          |0.0000              |

SELECT 
     t1.accountid
    ,t2.dba_name__c
    ,t1.fee_name__c
    ,t1.fee_amount__c
    ,fm.name
    ,fm.fee
  FROM asset      t1
  JOIN account    t2 
    ON t1.accountid = t2.id
  LEFT JOIN fee_map fm 
    ON t1.fee_name__c = fm.name
 WHERE t1.accountid = @acct_id
;

-- accountid         |dba_name__c         |fee_name__c               |fee_amount__c|name                      |fee                       |
-- ------------------|--------------------|--------------------------|-------------|--------------------------|--------------------------|
-- 0013i00000Cg8RiAAJ|Interstate Batteries|P2PE Device Activated Fee |       5.0000|P2PE Device Activated Fee |p2pe_device_activated     |
-- 0013i00000Cg8RiAAJ|Interstate Batteries|P2PE Device Activating Fee|       5.0000|P2PE Device Activating Fee|p2pe_device_activating_fee|
-- 0013i00000Cg8RiAAJ|Interstate Batteries|P2PE Device Stored Fee    |       0.0000|P2PE Device Stored Fee    |p2pe_device_stored_fee    |
-- 0013i00000Cg8RiAAJ|Interstate Batteries|P2PE Encryption Fee       |       0.0500|P2PE Encryption Fee       |p2pe_encryption_fee       |
-- 0013i00000Cg8RiAAJ|Interstate Batteries|GW Auth Decline Fee       |       0.0500|GW Auth Decline Fee       |gw_per_auth_decline_fee   |
-- 0013i00000Cg8RiAAJ|Interstate Batteries|GW Auth Fee               |       0.0500|                          |                          |
-- 0013i00000Cg8RiAAJ|Interstate Batteries|GW Credit Fee             |       0.0500|GW Credit Fee             |gw_per_credit_fee         |
-- 0013i00000Cg8RiAAJ|Interstate Batteries|GW Refund Fee             |       0.0500|GW Refund Fee             |gw_per_refund_fee         |
-- 0013i00000Cg8RiAAJ|Interstate Batteries|GW Token Fee              |       0.0000|GW Token Fee              |gw_per_token_fee          |


-- scratch

DROP TABLE IF EXISTS tmp_kif;

CREATE TEMPORARY TABLE tmp_kif AS 
SELECT acct_id, sum(one_time_key_injection_fees)
  FROM stg_cardconex_account 
 GROUP BY 1 
 ORDER BY 2 DESC 
; 

SELECT * FROM tmp_kif;

SET @cc_acct_id = '001U000000lXJcgIAG';

SELECT 
     acct_id 
    ,one_time_key_injection_fees
  FROM stg_cardconex_account 
 -- WHERE acct_id = @cc_acct_id;
 WHERE one_time_key_injection_fees > 0
 ORDER BY 2 DESC
;

-- acct_id           |one_time_key_injection_fees|
-- ------------------|---------------------------|
-- 001U000000lXJcgIAG|                  1000.0000|
-- 0014P000028DL2cQAG|                    10.0000|
-- 0014P00002RSn1lQAD|                     0.0500|

SELECT 
     a.accountid
    ,ac.legacy_id__c
    ,a.name AS asst_name
    ,f.name AS fee_map_name
    ,f.fee AS fee_map_fee
    ,a.fee_amount__c
  FROM asset          a 
  LEFT JOIN fee_map   f
    ON a.name = f.name
  LEFT JOIN account   ac 
    ON ac.id = a.accountid
 WHERE ac.legacy_id__c = @cc_acct_id
 ;
 
 
 
 
 
 SELECT * FROM asset;
 
 SELECT 
     accountid
    ,name AS fee_name
    ,count(*)
  FROM asset 
 GROUP BY 1, 2
 ORDER BY 3 desc
;


DROP TABLE IF EXISTS tmp_fees;
CREATE TEMPORARY TABLE tmp_fees
SELECT 
    accountid
   ,count(DISTINCT name) count_distinct_names
  FROM asset
 WHERE abs(fee_amount__c) > 0
 GROUP BY 1
 ORDER BY 2 desc
;
 
SELECT * FROM tmp_fees ORDER BY count_distinct_names DESC LIMIT 10;
-- accountid         |count_distinct_names|
-- ------------------|--------------------|
-- 0013i00000Cg8RHAAZ|                   7|
-- 0013i00000Cg8RiAAJ|                   7|
-- 0013i00000Cg8RFAAZ|                   7|
-- 0013i00000Cg8SEAAZ|                   4|
-- 0013i00000Cg8RuAAJ|                   4|
-- 0013i00000Cg8RmAAJ|                   4|
-- 0013i00000Cg8SBAAZ|                   4|
-- 0013i00000Cg8YJAAZ|                   4|
-- 0013i00000Cg8RkAAJ|                   4|
-- 0013i00000Cg8RsAAJ|                   4|

SET @new_acct_id = '0013i00000Cg8RHAAZ';
SET @legacy_acct_id = (SELECT legacy_id__c FROM account WHERE id = @new_acct_id);
SELECT @new_acct_id, @legacy_acct_id;

SELECT * FROM stg_cardconex_account WHERE acct_id = @legacy_acct_id;

SELECT accountid, fee_name__c, fee_amount__c FROM asset WHERE fee_amount__c != 0 AND accountid = @new_acct_id;

SELECT sum_one_time_key_injection_fees FROM tmp_original WHERE sum_one_time_key_injection_fees!= 0;
SELECT sum_one_time_key_injection_fees FROM tmp_updated WHERE sum_one_time_key_injection_fees!= 0;
-- sum_one_time_key_injection_fees|
-- -------------------------------|
--                       9375.0000|
--                      15000.0000|
--                      23333.0000|
--                      20000.0000|
--                      





SELECT * FROM asset;

SELECT fee_name__c, sum(fee_amount__c) FROM asset GROUP BY 1 ORDER BY 2 DESC;









SELECT asset.fee_name__c, count(*) FROM asset GROUP BY 1;

SELECT asst.fee_name__c, fm.name, fm.fee, sf.field_label, sf.api_name
  FROM (SELECT asset.fee_name__c, count(*) FROM asset GROUP BY 1) asst
  LEFT JOIN fee_map   fm 
    ON asst.fee_name__c = fm.name
  LEFT JOIN tmp_account_custom_fields sf 
    ON asst.fee_name__c = sf.field_label
;






SELECT 
     asst.accountid AS acct_id
    ,asst.name
    ,fm.name
    ,fm.fee
/*,COALESCE(fee_amount__c, 0) * (fee='ach_credit_fee')                AS ach_credit_fee
,COALESCE(fee_amount__c, 0) * (fee='ach_monthly_fee')               AS ach_monthly_fee
,COALESCE(fee_amount__c, 0) * (fee='ach_noc_fee')                   AS ach_noc_fee
,COALESCE(fee_amount__c, 0) * (fee='ach_per_gw_trans_fee')          AS ach_per_gw_trans_fee
,COALESCE(fee_amount__c, 0) * (fee='ach_return_error_fee')          AS ach_return_error_fee
,COALESCE(fee_amount__c, 0) * (fee='ach_transaction_fee')           AS ach_transaction_fee
,COALESCE(fee_amount__c, 0) * (fee='bfach_discount_rate')           AS bfach_discount_rate
,COALESCE(fee_amount__c, 0) * (fee='bluefin_gateway_discount_rate') AS bluefin_gateway_discount_rate
,COALESCE(fee_amount__c, 0) * (fee='file_transfer_monthly_fee')     AS file_transfer_monthly_fee
,COALESCE(fee_amount__c, 0) * (fee='gateway_monthly_fee')           AS gateway_monthly_fee
,COALESCE(fee_amount__c, 0) * (fee='group_tag_fee')                 AS group_tag_fee
,COALESCE(fee_amount__c, 0) * (fee='gw_per_auth_decline_fee')       AS gw_per_auth_decline_fee
,COALESCE(fee_amount__c, 0) * (fee='gw_per_credit_fee')             AS gw_per_credit_fee
,COALESCE(fee_amount__c, 0) * (fee='gw_per_refund_fee')             AS gw_per_refund_fee
,COALESCE(fee_amount__c, 0) * (fee='gw_per_sale_fee')               AS gw_per_sale_fee
,COALESCE(fee_amount__c, 0) * (fee='gw_per_token_fee')              AS gw_per_token_fee
,COALESCE(fee_amount__c, 0) * (fee='gw_reissued_fee')               AS gw_reissued_fee
,COALESCE(fee_amount__c, 0) * (fee='misc_monthly_fees')             AS misc_monthly_fees*/
,COALESCE(fee_amount__c, 0) * (fee='one_time_key_injection_fees')   AS one_time_key_injection_fees
,COALESCE(fee_amount__c, 0) * (fee='p2pe_flat_monthly_fee')   AS one_time_key_injection_fees_test
/*,COALESCE(fee_amount__c, 0) * (fee='p2pe_device_activated')         AS p2pe_device_activated
,COALESCE(fee_amount__c, 0) * (fee='p2pe_device_activating_fee')    AS p2pe_device_activating_fee
,COALESCE(fee_amount__c, 0) * (fee='p2pe_device_stored_fee')        AS p2pe_device_stored_fee
,COALESCE(fee_amount__c, 0) * (fee='p2pe_encryption_fee')           AS p2pe_encryption_fee
,COALESCE(fee_amount__c, 0) * (fee='p2pe_monthly_flat_fee')         AS p2pe_monthly_flat_fee
,COALESCE(fee_amount__c, 0) * (fee='p2pe_tokenization_fee')         AS p2pe_tokenization_fee
,COALESCE(fee_amount__c, 0) * (fee='p2pe_transaction_fee')          AS p2pe_transaction_fee
,COALESCE(fee_amount__c, 0) * (fee='pci_compliance_fee')            AS pci_compliance_fee
,COALESCE(fee_amount__c, 0) * (fee='pci_non_compliance_fee')        AS pci_non_compliance_fee
,COALESCE(fee_amount__c, 0) * (fee='pci_scans_monthly_fee')         AS pci_scans_monthly_fee
,COALESCE(fee_amount__c, 0) * (fee='per_transaction_fee')           AS per_transaction_fee*/
  FROM asset          AS asst
  LEFT JOIN fee_map   AS fm
    ON asst.name = fm.name
 ORDER BY 5 desc
;


'0013i00000Cg8SCAAZ',
'0013i00000Cg8RjAAJ',
'0013i00000Cg8RgAAJ',
'0013i00000Cg8S0AAJ',
'0013i00000Cg8RCAAZ'

SELECT accountid, fee_name__c, fee_amount__c 
  FROM asset 
 WHERE accountid IN 
   ('0013i00000Cg8SCAAZ',
  '0013i00000Cg8RjAAJ',
  '0013i00000Cg8RgAAJ',
  '0013i00000Cg8S0AAJ',
  '0013i00000Cg8RCAAZ')
   AND fee_amount__c > 1
ORDER BY 1, 3, 2
;


SELECT * FROM fee_map;




-- problem:  one_time_key_injection_fee is not correct.  why?

-- consider the SELECT statements in the first step of the version 1 and version 2 ktr:

-- version 1:
-- SELECT fee, sum(fee_amount__c) FROM (
SELECT 
     asst.accountid
    ,asst.name 
    ,fm.fee
    ,asst.fee_amount__c
  FROM asset          AS asst
  LEFT JOIN fee_map   AS fm
    ON asst.name = fm.name
 WHERE fee IN ('one_time_key_injection_fees', 'p2pe_monthly_flat_fee')
 ORDER BY 1, 4, 3
-- ) t1 GROUP BY 1;
 
--  accountid        |name                       |fee                        |fee_amount__c|
-- ------------------|---------------------------|---------------------------|-------------|
-- 0013i00000Cg8RCAAZ|P2PE Token Flat Monthly Fee|one_time_key_injection_fees|    2916.6700|
-- 0013i00000Cg8RCAAZ|P2PE Monthly Flat Fee      |p2pe_monthly_flat_fee      |    2916.6700|
-- 0013i00000Cg8RgAAJ|P2PE Token Flat Monthly Fee|one_time_key_injection_fees|   15000.0000|
-- 0013i00000Cg8RgAAJ|P2PE Monthly Flat Fee      |p2pe_monthly_flat_fee      |   15000.0000|
-- 0013i00000Cg8RjAAJ|P2PE Token Flat Monthly Fee|one_time_key_injection_fees|   20000.0000|
-- 0013i00000Cg8RjAAJ|P2PE Monthly Flat Fee      |p2pe_monthly_flat_fee      |   20000.0000|
-- 0013i00000Cg8S0AAJ|P2PE Token Flat Monthly Fee|one_time_key_injection_fees|    9375.0000|
-- 0013i00000Cg8S0AAJ|P2PE Monthly Flat Fee      |p2pe_monthly_flat_fee      |    9375.0000|
-- 0013i00000Cg8SCAAZ|P2PE Token Flat Monthly Fee|one_time_key_injection_fees|   23333.0000|
-- 0013i00000Cg8SCAAZ|P2PE Monthly Flat Fee      |p2pe_monthly_flat_fee      |   23333.0000|

-- fee                        |sum(fee_amount__c)|
-- ---------------------------|------------------|
-- one_time_key_injection_fees|        70624.6700|
-- p2pe_monthly_flat_fee      |        70624.6700|

-- conclusion:  there is a non-zero amount of one_time_key_injection_fees from version 1

-- version 2
SELECT 
     asst.accountid AS acct_id
    ,asst.name
,COALESCE(fee_amount__c, 0) * (fee='one_time_key_injection_fees')   AS one_time_key_injection_fees
,COALESCE(fee_amount__c, 0) * (fee='p2pe_monthly_flat_fee')         AS p2pe_monthly_flat_fee
  FROM asset          AS asst
  LEFT JOIN fee_map   AS fm
    ON asst.name = fm.name
 WHERE fee IN ('one_time_key_injection_fees', 'p2pe_monthly_flat_fee')
 ORDER BY accountid
;

-- acct_id           |name                       |one_time_key_injection_fees|p2pe_monthly_flat_fee|
-- ------------------|---------------------------|---------------------------|---------------------|
-- 0013i00000Cg8RCAAZ|P2PE Monthly Flat Fee      |                     0.0000|            2916.6700|
-- 0013i00000Cg8RCAAZ|P2PE Token Flat Monthly Fee|                  2916.6700|               0.0000|
-- 0013i00000Cg8RgAAJ|P2PE Monthly Flat Fee      |                     0.0000|           15000.0000|
-- 0013i00000Cg8RgAAJ|P2PE Token Flat Monthly Fee|                 15000.0000|               0.0000|
-- 0013i00000Cg8RjAAJ|P2PE Monthly Flat Fee      |                     0.0000|           20000.0000|
-- 0013i00000Cg8RjAAJ|P2PE Token Flat Monthly Fee|                 20000.0000|               0.0000|
-- 0013i00000Cg8S0AAJ|P2PE Monthly Flat Fee      |                     0.0000|            9375.0000|
-- 0013i00000Cg8S0AAJ|P2PE Token Flat Monthly Fee|                  9375.0000|               0.0000|
-- 0013i00000Cg8SCAAZ|P2PE Monthly Flat Fee      |                     0.0000|           23333.0000|
-- 0013i00000Cg8SCAAZ|P2PE Token Flat Monthly Fee|                 23333.0000|               0.0000|

-- same results...  so the SELECT statements IN EACH KTR produce the same results.

-- so what about the aggregation?

-- version 1
-- one_time_key_injection_fees is null for every row in the denormalize_asset_rows result set.
-- note the configuration in that KTR for one_time_key_injection_fees and p2pe_monthly_flat_fee:
-- one_time_key_injection_fees / P2PE Flat Monthly Fee
-- p2pe_monthly_flat_fee       / P2PE Token Flat Monthly Fee

-- version 2
-- one_time_key_injection_fees = p2pe_monthly_flat_fee for every row.  
-- so the aggregation is different!!!  

-- what is the correct result from stg_cardconex_account?
SELECT acct_id, sum(one_time_key_injection_fees), sum(p2pe_monthly_flat_fee) 
  FROM stg_cardconex_account
 WHERE acct_id IN (SELECT distinct legacy_id__c FROM account)
;

-- acct_id           |sum(one_time_key_injection_fees)|sum(p2pe_monthly_flat_fee)|
-- ------------------|--------------------------------|--------------------------|
-- 001U000001YpBHAIA3|                          0.0000|                70624.6700|

-- conclusion:  p2pe_monthly_flat_fee is calculated correctly in both ktrs, 
-- but one_time_key_injection_fees is not.
-- the issue must be the caused by the following line in version 2:
-- COALESCE(fee_amount__c, 0) * (fee='one_time_key_injection_fees') AS one_time_key_injection_fees

-- version 1
-- one_time_key_injection_fees / P2PE Flat Monthly Fee
-- p2pe_monthly_flat_fee       / P2PE Token Flat Monthly Fee

-- version 2
SELECT fee, name FROM fee_map WHERE fee in ('one_time_key_injection_fees', 'p2pe_monthly_flat_fee');
-- fee                        |name                       |
-- ---------------------------|---------------------------|
-- p2pe_monthly_flat_fee      |P2PE Monthly Flat Fee      |
-- one_time_key_injection_fees|P2PE Token Flat Monthly Fee|

-- what does sales force day?
SELECT lower(api_name), field_label FROM tmp_account_custom_fields WHERE api_name like 'p2pe%' or api_name like '%injection%';

-- lower(api_name)                     |field_label                       | matches v1   matched v2 
-- ------------------------------------|----------------------------------|------------------------
-- one_time_key_injection_fees__c      |P2PE Token Flat Monthly Fee       | no           yes
-- p2pe_monthly_flat_fee__c            |P2PE Monthly Flat Fee             | no           yes

-- conclusion: v2 matches sales force but does not tally.
-- how is one_time_key_injection_fees__c calculated in billing?
-- 1.  nothing suspicious in src_cardconex_account.ktr
-- 2.  what other ktr's have 'injection'?
--       grep -i -l injection *.ktr   
--       --------------------------
--       dw_d_pricing.ktr               
--       dw_f_billing_month.ktr         
--       rpt_billing.ktr                
-- 3. dw_d_pricing
--    (a) renames one_time_key_injection_fees to one_time_key_injection_fee
--    (b) nothing else special about one_time_key_injection_fee
-- 4. dw_f_billing_month.ktr
--    (a) one_time_key_injection_fees is renamed to one_time_key_injection_fee in the stg_cardconex_service step.
--    (b) but one_time_key_injection_fee column is not in the 'Select values 2' step.  
--    (c) i checked and there is no column in f_billing_month like '%injection%'!
--    (d) but there is in f_auto_billing_complete:
USE auto_billing_dw;
SELECT table_name, column_name FROM tsanders.v_desc_rc WHERE db=database() AND table_name = 'f_auto_billing_complete' AND column_name LIKE '%injection%' ORDER BY column_name;
-- table_name             |column_name                       |
-- -----------------------|----------------------------------|
-- f_auto_billing_complete|pricing_one_time_key_injection_fee|

--    (e) so how is one_time_key_injection_fee calculated?
--  5. rpt_billing.ktr
--    (a) one_time_key_injection_fee is calculated in d_pricing as follows:

          SELECT sum(p.one_time_key_injection_fee) as pricing_one_time_key_injection_fee
          FROM f_billing_month f
          JOIN d_day d
            ON d.day_key = f.day_key
          JOIN d_pricing p
            ON p.pricing_key = f.pricing_key
          JOIN d_merchant m
            ON m.merchant_key = f.merchant_key
          WHERE true
            AND d.year_mon = (SELECT date_format(current_date - interval 1 MONTH, '%Y%m'))
            AND f.pricing_key != 1
          ;
  
-- pricing_one_time_key_injection_fee|
-- ----------------------------------|
--                          1010.0000|
                         
--     (b) I am using billing data for the december billing period and it's possible that the data in the account object 

-- we are back to where we started.the key lies in how one_time_key_injection_fee is calculated in d_pricing
--         has changed sufficiently that the results are inaccurate.  let's check anyway.

-- IMPORTANT!!! 
-- one_time_key_injection_fee is calculated in the d_pricing KTR which gets the data from stg_cardconex_account.


        
        
        
USE sales_force;
SET @acct_id = '0013i00000Cg8RgAAJ';
SET @legacy_id = (SELECT legacy_id__c FROM account WHERE id = @acct_id);
SELECT @acct_id, @legacy_id;

SELECT * FROM asset WHERE accountid = @acct_id;




