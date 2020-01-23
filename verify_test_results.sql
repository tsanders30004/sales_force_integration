-- use this to verify the calculations in test_cardconex_account

USE sales_force;

DROP TABLE IF EXISTS tmp_legacy_ids;
CREATE TEMPORARY TABLE tmp_legacy_ids SELECT DISTINCT legacy_id FROM test_cardconex_account;
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

SELECT * FROM asset WHERE accountid = @acct_id AND fee_amount__c = 0.05 ORDER BY fee_name__c;



CREATE TEMPORARY TABLE null_fees
SELECT legacy_id 
FROM test_results
WHERE delta_ach_credit_fee IS NULL;

SELECT * FROM null_fees;

SELECT * FROM test_cardconex_account WHERE legacy_id IN (SELECT legacy_id FROM null_fees);
SELECT * FROM  stg_cardconex_account WHERE   acct_id IN (SELECT legacy_id FROM null_fees);


SELECT * FROM fee_map;

UPDATE fee_map SET name = 'P2PE Token Flat Monthly Fee' WHERE name = 'P2PE Flat Monthly Fee';