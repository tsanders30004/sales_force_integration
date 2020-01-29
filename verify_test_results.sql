-- use this to verify the calculations in test_cardconex_account

USE sales_force;

SELECT accountid, count(*) FROM asset GROUP BY 1 ORDER BY 1 DESC LIMIT 1;
-- accountid         |count(*)|
-- ------------------|--------|
-- 0013i00000EmHuvAAF|      28| --- this is the account with all 28 fees populated.

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

SELECT 
     acct_id
    ,acct_name 
    ,misc_monthly_fees
  FROM stg_cardconex_account 
 WHERE acct_id = @legacy_id
;

SELECT 
    *
  FROM asset 
 WHERE fee_name__c = 'Misc Monthly Fee(s)'
--  WHERE fee_amount__c IN (16, 24)
;

SELECT 
     acct_id
    ,acct_name
    ,accountnumber
/*
    ,cardconex_status
    ,mid_1
    ,mid_1_type
    ,mid_2
    ,mid_2_type
    ,mid_3
    ,mid_3_type
    ,mid_4
    ,mid_4_type
    ,mid_5
    ,mid_5_type
*/
    ,dba_name
    ,dba_street
    ,dba_city
    ,dba_state
    ,dba_postal_code
    ,dba_phone
    ,date_agreement_signed
--  ,lead_created_date
    ,closure_date
--  ,invoicing_start_date
    ,months_in_business
    ,sic
    ,owner_name
    ,owner_firstname
    ,owner_lastname
--  ,sales_representative
--  ,business_dev_credit
--  ,referring_organization_text
    ,bluefin_contract_start_date
    ,industry
    ,segment
--  ,chain
--  ,relationship_chain
--  ,platform
--  ,p2pe_transaction_fee
    ,p2pe_device_activated
    ,ach_transaction_fee
    ,p2pe_device_activating_fee
    ,ach_per_gw_trans_fee
    ,p2pe_device_stored_fee
    ,ach_credit_fee
    ,p2pe_encryption_fee
    ,bfach_discount_rate
    ,p2pe_tokenization_fee
    ,ach_noc_fee
    ,p2pe_monthly_flat_fee
    ,ach_return_error_fee
    ,one_time_key_injection_fees
    ,ach_monthly_fee
    ,per_transaction_fee
    ,misc_monthly_fees
    ,gw_per_auth_decline_fee
    ,bluefin_gateway_discount_rate
    ,gw_per_sale_fee
    ,file_transfer_monthly_fee
    ,gw_per_credit_fee
    ,pci_scans_monthly_fee
    ,gw_per_refund_fee
    ,gw_per_token_fee
    ,group_tag_fee
    ,gw_reissued_fee
    ,gateway_monthly_fee
    ,parent_acct_id
    ,hold_billing
    ,stop_billing
    ,billing_situation
    ,billing_frequency
    ,pci_compliance_fee
    ,pci_non_compliance_fee
    ,date_modified
--  ,date_created
    ,date_updated
  FROM stg_cardconex_account
  -- FROM test_cardconex_account
 WHERE acct_id = @legacy_id
   OR acct_id = @acct_id
;

-- scratch

SELECT fee_name__c, fee_amount__c FROM asset WHERE fee_amount__c = 16;
-- fee_name__c        |fee_amount__c|
-- -------------------|-------------|
-- Misc Monthly Fee(s)|      16.0000|

SELECT * FROM fee_map ORDER BY 2;
-- fee_name                      |fee                          |
-- Misc Monthly Fee(s)           |misc_monthly_fees            |








SELECT acct_id, fee_name__c, misc_monthly_fees FROM (
SELECT 
     asst.accountid AS acct_id
    ,asst.fee_name__c
    ,COALESCE(fee_amount__c, 0) * (fee='ach_credit_fee')                AS ach_credit_fee
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
    ,COALESCE(fee_amount__c, 0) * (fee='misc_monthly_fees')             AS misc_monthly_fees
    ,COALESCE(fee_amount__c, 0) * (fee='one_time_key_injection_fees')   AS one_time_key_injection_fees
    ,COALESCE(fee_amount__c, 0) * (fee='p2pe_device_activated')         AS p2pe_device_activated
    ,COALESCE(fee_amount__c, 0) * (fee='p2pe_device_activating_fee')    AS p2pe_device_activating_fee
    ,COALESCE(fee_amount__c, 0) * (fee='p2pe_device_stored_fee')        AS p2pe_device_stored_fee
    ,COALESCE(fee_amount__c, 0) * (fee='p2pe_encryption_fee')           AS p2pe_encryption_fee
    ,COALESCE(fee_amount__c, 0) * (fee='p2pe_monthly_flat_fee')         AS p2pe_monthly_flat_fee
    ,COALESCE(fee_amount__c, 0) * (fee='p2pe_tokenization_fee')         AS p2pe_tokenization_fee
    ,COALESCE(fee_amount__c, 0) * (fee='p2pe_transaction_fee')          AS p2pe_transaction_fee
    ,COALESCE(fee_amount__c, 0) * (fee='pci_compliance_fee')            AS pci_compliance_fee
    ,COALESCE(fee_amount__c, 0) * (fee='pci_non_compliance_fee')        AS pci_non_compliance_fee
    ,COALESCE(fee_amount__c, 0) * (fee='pci_scans_monthly_fee')         AS pci_scans_monthly_fee
    ,COALESCE(fee_amount__c, 0) * (fee='per_transaction_fee')           AS per_transaction_fee
  FROM asset          AS asst
  LEFT JOIN fee_map   AS fm
    ON asst.fee_name__c = fm.fee_name
 WHERE asst.accountid = @acct_id
 ORDER BY accountid
) t1 WHERE misc_monthly_fees != 0
;

-- acct_id           |fee_name__c        |misc_monthly_fees|
-- ------------------|-------------------|-----------------|
-- 0013i00000EmHuvAAF|Misc Monthly Fee(s)|          16.0000|
-- 0013i00000EmHuvAAF|Misc Monthly Fee(s)|          24.0000|

SELECT accountid, fee_name__c, fee_amount__c FROM asset WHERE accountid = @acct_id AND fee_amount__c IN (16, 24);
SELECT * FROM stg_cardconex_account WHERE acct_id = @legacy_id;


SELECT * FROM tmp_updated WHERE legacy_id = @legacy_id;
SELECT * FROM tmp_updated;