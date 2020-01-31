-- use this to verify the calculations in test_cardconex_account

USE sales_force;

/*SELECT accountid, count(*) FROM asset GROUP BY 1 ORDER BY 1 DESC LIMIT 1;
-- accountid         |count(*)|
-- ------------------|--------|
-- 0013i00000EmHuvAAF|      28| --- this is the account with all 28 fees populated.

SET @acct_id = '0013i00000EmHuvAAF';
SET @legacy_id = '0014P00001l9QNcQAM';
SELECT @acct_id, @legacy_id;*/

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
   WHERE acct_id IN (SELECT legacy_id FROM tmp_legacy_ids)    -- only want the rows for which we have data in test_cardconex_account.
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

-- if there are no errors, every column below should be equal to zero
-- non-zero rows indicate an error.
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

-- need to identify the offending accounts; i.e., accounts for which there are errors.
-- first - create a table that is broken out by acct_id
DROP TABLE IF EXISTS tmp_r1;
CREATE TEMPORARY TABLE tmp_r1
SELECT 
    o.acct_id AS legacy_id,
    u.acct_id AS new_id,
    abs(sum(o.ach_credit_fee)-sum(u.ach_credit_fee)) AS ach_credit_fee,
    abs(sum(o.bfach_discount_rate)-sum(u.bfach_discount_rate)) AS bfach_discount_rate,
    abs(sum(o.ach_monthly_fee)-sum(u.ach_monthly_fee)) AS ach_monthly_fee,
    abs(sum(o.ach_noc_fee)-sum(u.ach_noc_fee)) AS ach_noc_fee,
    abs(sum(o.ach_per_gw_trans_fee)-sum(u.ach_per_gw_trans_fee)) AS ach_per_gw_trans_fee,
    abs(sum(o.ach_return_error_fee)-sum(u.ach_return_error_fee)) AS ach_return_error_fee,
    abs(sum(o.ach_transaction_fee)-sum(u.ach_transaction_fee)) AS ach_transaction_fee,
    abs(sum(o.bluefin_gateway_discount_rate)-sum(u.bluefin_gateway_discount_rate)) AS bluefin_gateway_discount_rate,
    abs(sum(o.file_transfer_monthly_fee)-sum(u.file_transfer_monthly_fee)) AS file_transfer_monthly_fee,
    abs(sum(o.gateway_monthly_fee)-sum(u.gateway_monthly_fee)) AS gateway_monthly_fee,
    abs(sum(o.group_tag_fee)-sum(u.group_tag_fee)) AS group_tag_fee,
    abs(sum(o.gw_per_auth_decline_fee)-sum(u.gw_per_auth_decline_fee)) AS gw_per_auth_decline_fee,
    abs(sum(o.per_transaction_fee)-sum(u.per_transaction_fee)) AS per_transaction_fee,
    abs(sum(o.gw_per_credit_fee)-sum(u.gw_per_credit_fee)) AS gw_per_credit_fee,
    abs(sum(o.gw_per_refund_fee)-sum(u.gw_per_refund_fee)) AS gw_per_refund_fee,
    abs(sum(o.gw_per_sale_fee)-sum(u.gw_per_sale_fee)) AS gw_per_sale_fee,
    abs(sum(o.gw_per_token_fee)-sum(u.gw_per_token_fee)) AS gw_per_token_fee,
    abs(sum(o.gw_reissued_fee)-sum(u.gw_reissued_fee)) AS gw_reissued_fee,
    abs(sum(o.misc_monthly_fees)-sum(u.misc_monthly_fees)) AS misc_monthly_fees,
    abs(sum(o.p2pe_device_activated)-sum(u.p2pe_device_activated)) AS p2pe_device_activated,
    abs(sum(o.p2pe_device_activating_fee)-sum(u.p2pe_device_activating_fee)) AS p2pe_device_activating_fee,
    abs(sum(o.p2pe_device_stored_fee)-sum(u.p2pe_device_stored_fee)) AS p2pe_device_stored_fee,
    abs(sum(o.p2pe_encryption_fee)-sum(u.p2pe_encryption_fee)) AS p2pe_encryption_fee,
    abs(sum(o.p2pe_monthly_flat_fee)-sum(u.p2pe_monthly_flat_fee)) AS p2pe_monthly_flat_fee,
    abs(sum(o.one_time_key_injection_fees)-sum(u.one_time_key_injection_fees)) AS one_time_key_injection_fees,
    abs(sum(o.p2pe_tokenization_fee)-sum(u.p2pe_tokenization_fee)) AS p2pe_tokenization_fee,
    abs(sum(o.pci_scans_monthly_fee)-sum(u.pci_scans_monthly_fee)) AS pci_scans_monthly_fee
  FROM      test_cardconex_account   u 
  LEFT JOIN stg_cardconex_account    o 
    ON u.legacy_id = o.acct_id
 GROUP BY 1, 2;
 
 -- identify suspect rows.  
 -- to do this, delete from this table where all of the numeric columns are zero; these correspond to fees with no errors.
  DELETE FROM tmp_r1 
  WHERE 
    ach_credit_fee = 0 AND 
    bfach_discount_rate = 0 AND 
    ach_monthly_fee = 0 AND 
    ach_noc_fee = 0 AND 
    ach_per_gw_trans_fee = 0 AND 
    ach_return_error_fee = 0 AND 
    ach_transaction_fee = 0 AND 
    bluefin_gateway_discount_rate = 0 AND 
    file_transfer_monthly_fee = 0 AND 
    gateway_monthly_fee = 0 AND 
    group_tag_fee = 0 AND 
    gw_per_auth_decline_fee = 0 AND 
    per_transaction_fee = 0 AND 
    gw_per_credit_fee = 0 AND 
    gw_per_refund_fee = 0 AND 
    gw_per_sale_fee = 0 AND 
    gw_per_token_fee = 0 AND 
    gw_reissued_fee = 0 AND 
    misc_monthly_fees = 0 AND 
    p2pe_device_activated = 0 AND 
    p2pe_device_activating_fee = 0 AND 
    p2pe_device_stored_fee = 0 AND 
    p2pe_encryption_fee = 0 AND 
    p2pe_monthly_flat_fee = 0 AND 
    one_time_key_injection_fees = 0 AND 
    p2pe_tokenization_fee = 0 AND 
    pci_scans_monthly_fee = 0
;

-- so these are the rows to check...
-- the question is:  do there exist fees in asset for any of these accounts?

SELECT *
  FROM asset 
 WHERE accountid IN (SELECT new_id FROM tmp_r1);
SELECT * FROM tmp_r1;
-- no.  so fees for the accounts in question were not loaded into sales force.  -- the data is what is different; calcs appear ok.

-- spot check...  pick a few accounts and look in sales force.

SELECT *
  FROM tmp_r1 
;
-- as expected, a spot check on three accounts showed that fees were not loaded.




-- look in detail at the data for the account that has all 28 fees
SET @new_acct_id = (SELECT accountid FROM asset GROUP BY 1 ORDER BY 1 DESC LIMIT 1);
SET @legacy_id   = (SELECT legacy_id__c FROM account WHERE id = @new_acct_id);
SELECT @acct_id, @legacy_id;

-- @acct_id          |@legacy_id        |
-- ------------------|------------------|
-- 0013i00000EmHuvAAF|0014P00001l9QNcQAM|

SELECT accountid, fee_name__c, fee_amount__c FROM asset WHERE accountid = @new_acct_id ORDER BY 3;
-- accountid         |fee_name__c                   |fee_amount__c|
-- ------------------|------------------------------|-------------|
-- 0013i00000EmHuvAAF|P2PE Device Activated Fee     |       1.0000|
-- 0013i00000EmHuvAAF|ACH Transaction Fee           |       2.0000|
-- 0013i00000EmHuvAAF|P2PE Device Activating Fee    |       3.0000|
-- 0013i00000EmHuvAAF|ACH GW Trans Fee              |       4.0000|
-- 0013i00000EmHuvAAF|P2PE Device Stored Fee        |       5.0000|
-- 0013i00000EmHuvAAF|ACH Credit Fee                |       6.0000|
-- 0013i00000EmHuvAAF|P2PE Encryption Fee           |       7.0000|
-- 0013i00000EmHuvAAF|ACH Discount Rate             |       8.0000|
-- 0013i00000EmHuvAAF|P2PE Token Fee                |       9.0000|
-- 0013i00000EmHuvAAF|ACH NOC Fee                   |      10.0000|
-- 0013i00000EmHuvAAF|P2PE Monthly Flat Fee         |      11.0000|
-- 0013i00000EmHuvAAF|ACH Return/Error Fee          |      12.0000|
-- 0013i00000EmHuvAAF|P2PE Token Flat Monthly Fee   |      13.0000|
-- 0013i00000EmHuvAAF|ACH Monthly Fee               |      14.0000|
-- 0013i00000EmHuvAAF|GW Auth Fee                   |      15.0000|
-- 0013i00000EmHuvAAF|Misc Monthly Fee(s)           |      16.0000|
-- 0013i00000EmHuvAAF|GW Auth Decline Fee           |      17.0000|
-- 0013i00000EmHuvAAF|Apriva Monthly Fee            |      18.0000|
-- 0013i00000EmHuvAAF|GW Tran Fee                   |      19.0000|
-- 0013i00000EmHuvAAF|File Transfer Monthly Fee     |      20.0000|
-- 0013i00000EmHuvAAF|GW Credit Fee                 |      21.0000|
-- 0013i00000EmHuvAAF|PCI Transaction Fee           |      22.0000|
-- 0013i00000EmHuvAAF|GW Refund Fee                 |      23.0000|
-- 0013i00000EmHuvAAF|PC Account Updater Monthly Fee|      24.0000|
-- 0013i00000EmHuvAAF|GW Token Fee                  |      25.0000|
-- 0013i00000EmHuvAAF|Group/Tag Fee                 |      26.0000|
-- 0013i00000EmHuvAAF|GW Reissued Fee               |      27.0000|
-- 0013i00000EmHuvAAF|GW Monthly Fee                |      28.0000|

-- compare stg_cardconex_account;
SELECT 
     acct_id
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
  FROM stg_cardconex_account
 WHERE acct_id = @legacy_id
;

-- name                         |value             |
-- -----------------------------|------------------|
-- acct_id                      |0014p00001l9qncqam|
-- p2pe_device_activated        |1.0000            |
-- ach_transaction_fee          |2.0000            |
-- p2pe_device_activating_fee   |3.0000            |
-- ach_per_gw_trans_fee         |4.0000            |
-- p2pe_device_stored_fee       |5.0000            |
-- ach_credit_fee               |6.0000            |
-- p2pe_encryption_fee          |7.0000            |
-- bfach_discount_rate          |8.0000            |
-- p2pe_tokenization_fee        |9.0000            |
-- ach_noc_fee                  |10.0000           |
-- p2pe_monthly_flat_fee        |11.0000           |
-- ach_return_error_fee         |12.0000           |
-- one_time_key_injection_fees  |13.0000           |
-- ach_monthly_fee              |14.0000           |
-- per_transaction_fee          |15.0000           |
-- misc_monthly_fees            |16.0000           |
-- gw_per_auth_decline_fee      |17.0000           |
-- bluefin_gateway_discount_rate|18.0000           |
-- gw_per_sale_fee              |19.0000           |
-- file_transfer_monthly_fee    |20.0000           |
-- gw_per_credit_fee            |21.0000           |
-- pci_scans_monthly_fee        |22.0000           |
-- gw_per_refund_fee            |23.0000           |
-- gw_per_token_fee             |25.0000           |
-- group_tag_fee                |26.0000           |
-- gw_reissued_fee              |27.0000           |
-- gateway_monthly_fee          |28.0000           |



