USE sales_force;

-- does the new result set (billing table) have corresponding cardconex_acct_id's in the old result set (stg_cardconex_acct_id)?

SELECT COUNT(*) legacy_id FROM billing WHERE legacy_id NOT IN (SELECT acct_id FROM stg_cardconex_account);
-- no; all cc_acct_id's in the new result set also exist in the old result set.  
-- PASS

-- focus on one account.
-- compare results in the old result set to the new result set for a few fees.

SET @cc_acct_id = '0010B00001mlN0sQAE';

-- get data from old result set
SELECT 
     acct_id
    ,acct_name
    ,concat(mid_1, '-', mid_2, '-',mid_3, '-',mid_4, '-',mid_5, '-') AS mids
    ,dba_name
    ,dba_street
    ,dba_city 
    ,dba_state 
    ,dba_postal_code
    ,p2pe_device_activated
    ,p2pe_device_activating_fee
    ,p2pe_device_stored_fee
    ,p2pe_encryption_fee
    ,p2pe_tokenization_fee
  FROM stg_cardconex_account
 WHERE acct_id = @cc_acct_id
;

-- data from the old result set
-- acct_id           |acct_name            |mids |dba_name             |dba_street         |dba_city|dba_state|dba_postal_code|p2pe_device_activated|p2pe_device_activating_fee|p2pe_device_stored_fee|p2pe_encryption_fee|p2pe_tokenization_fee|
-- ------------------|---------------------|-----|---------------------|-------------------|--------|---------|---------------|---------------------|--------------------------|----------------------|-------------------|---------------------|
-- 0010B00001mlN0sQAE|Neulion College, Inc.|-----|Neulion College, Inc.|800 Central Park Dr|Sanford |FL       |32771          |              10.0000|                   10.0000|               10.0000|             0.0500|               0.0000|

-- notice that no mid fields are populated for this cc_acct_id 

-- new get data from new result set

SELECT 
     b.acct_id                      AS acct_id
    ,b.legacy_id                    AS legacy_id
    -- ,id_num.name                    AS mid
    ,b.acct_name 
    ,b.dba_name
    ,NULL                           AS dba_street
    ,NULL                           AS dba_city
    ,NULL                           AS dba_state
    ,NULL                           AS dba_postal_code 
    ,b.p2pe_device_activated
    ,b.p2pe_device_activating_fee
    ,b.p2pe_device_stored_fee
    ,b.p2pe_encryption_fee
    ,b.p2pe_tokenization_fee
  FROM billing                      AS b
/*  LEFT JOIN identification_number   AS id_num 
    ON b.acct_id = id_num.account_id*/
 WHERE legacy_id = @cc_acct_id
 ORDER BY 2, 3 
;  


-- acct_id           |legacy_id         |mid  |acct_name            |dba_name             |dba_street|dba_city|dba_state|dba_postal_code|p2pe_device_activated|p2pe_device_activating_fee|p2pe_device_stored_fee|p2pe_encryption_fee|p2pe_tokenization_fee|
-- ------------------|------------------|-----|---------------------|---------------------|----------|--------|---------|---------------|---------------------|--------------------------|----------------------|-------------------|---------------------|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|               10.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |              10.0000|                    0.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                   10.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|                0.0000|             0.0000|               0.0500|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|               10.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                   10.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |              10.0000|                    0.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|40507|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|                0.0000|             0.0000|               0.0500|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|                0.0000|             0.0000|               0.0500|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |              10.0000|                    0.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                   10.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|               10.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |              10.0000|                    0.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                   10.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|                0.0000|             0.0000|               0.0500|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|                0.0000|             0.0000|               0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|44849|Neulion College, Inc.|Neulion College, Inc.|          |        |         |               |               0.0000|                    0.0000|               10.0000|             0.0000|               0.0000|

-- some dba columns are missing.  these columns are not defined in the account object.
--    * unknown if these are used in billing / residuals / vap.
-- there are twenty rows in the new result set where there was only one in the old result set.
-- mids are present where that are not in the old result set.
--    * what is the impact of this in billing?  note that the billing result set is aggregated by cardconex_acct_id
--    * but a lot of other data starts with only the mid and is then mapped to a cardconex_acct_id.

-- tables which use mid columns:
-- +----------------------+------------------------------+-------------+
-- | db                   | table_name                   | column_name |
-- +----------------------+------------------------------+-------------+
-- | auto_billing_staging | cardconex_mid                | mid         |  -- table used to associate mids with cardconex_acct_id's FOR RESIDUALS
-- | auto_billing_staging | stg_cardconex_account        | mid_1       |  -- used in billing and probably other places
-- | auto_billing_staging | stg_cardconex_account        | mid_2       |
-- | auto_billing_staging | stg_cardconex_account        | mid_3       |
-- | auto_billing_staging | stg_cardconex_account        | mid_4       |
-- | auto_billing_staging | stg_cardconex_account        | mid_5       |
-- | auto_billing_staging | stg_cardconex_mid_summary    | mid_field   |
-- | auto_billing_staging | stg_cardconex_mid_summary    | mid         |
-- | auto_billing_staging | stg_payconex_volume          | mid         |  - this table only has mid but not cardconex_acct_id.  will have to derive cardconex_acct_id somehere.
-- +----------------------+------------------------------+-------------+

-- punchline:  there are many places where the cardconex_acct_id and mid have to associated.
--             the current result set may not support this.

-- what other columns are missing?


-- scratch


SELECT 
     acct.id                                AS acct_id
    ,acct.name                              AS acct_name
    ,acct.accountnumber                     AS accountnumber
    ,id_num.name                            AS mid_1
    ,id_num.type__c                         AS mid_1_type
    ,acct.dba_name__c                       AS dba_name
    ,cont.startdate                         AS date_agreement_signed
    ,id_num.close_date__c                   AS closure_date
    ,acct.sic                               AS sic
    ,usr.name                               AS owner_name 
    ,usr.firstname                          AS owner_firstname
    ,usr.lastname                           AS owner_lastname
    ,cont.startdate                         AS bluefin_contract_start_date
    ,acct.industry                          AS industry
    ,acct.revenue_segment__c                AS segment
    ,acct.parentid                          AS parent_acct_id
    ,cont.hold_billing__c                   AS hold_billing
    ,cont.billing_hold_reason__c            AS stop_billing
    ,cont.billing_preference__c             AS billing_situation
    ,cont.billing_frequency__c              AS billing_frequency
    ,acct.lastmodifieddate                  AS date_modified 
    ,acct.createddate                       AS date_updated
  FROM account                              acct 
  JOIN asset                                asst 
    ON acct.id = asst.account_id
  JOIN bank_account                         bank                -- is this table really used?
    ON acct.id = bank.accountid__c
  JOIN identification_number                id_num
    ON acct.id = id_num.accountid__c
  JOIN contract                             cont 
    ON acct.id = cont.accountid
  JOIN `user`                               usr 
    ON acct.ownerid = usr.id
;
  

-- 

USE sales_force;

SET @cc_acct_id = '001U00000109kHyIAI';

SELECT * FROM billing                     WHERE legacy_id = @cc_acct_id;
SELECT * FROM stg_cardconex_account       WHERE acct_id   = @cc_acct_id;

SELECT
     n.legacy_id 
    ,n.acct_name 
    ,n.mid_1 AS new_mid_1
    ,o.mid_1 AS old_mid_1
    ,n.dba_name
    ,n.p2pe_device_activating_fee
    ,o.p2pe_device_activating_fee
  FROM billing                      n
  LEFT JOIN stg_cardconex_account   o
    ON n.legacy_id = o.acct_id
 WHERE n.legacy_id = '001U00000109kHyIAI'
; 

(
SELECT 
    'stg_cardconex_account' AS table_name,
    acct_id,
    acct_name,
    accountnumber,
    cardconex_status,
    mid_1,
    mid_1_type,
    mid_2,
    mid_2_type,
    mid_3,
    mid_3_type,
    mid_4,
    mid_4_type,
    mid_5,
    mid_5_type,
    dba_name,
    dba_street,
    dba_city,
    dba_state,
    dba_postal_code,
    dba_phone,
    date_agreement_signed,
    lead_created_date,
    closure_date,
    invoicing_start_date,
    months_in_business,
    sic,
    owner_name,
    owner_firstname,
    owner_lastname,
    sales_representative,
    business_dev_credit,
    referring_organization_text,
    bluefin_contract_start_date,
    industry,
    segment,
    chain,
    relationship_chain,
    platform,
    ach_credit_fee,
    bfach_discount_rate,
    ach_monthly_fee,
    ach_noc_fee,
    ach_per_gw_trans_fee,
    ach_return_error_fee,
    ach_transaction_fee,
    bluefin_gateway_discount_rate,
    file_transfer_monthly_fee,
    gateway_monthly_fee,
    group_tag_fee,
    gw_per_auth_decline_fee,
    per_transaction_fee,
    gw_per_credit_fee,
    gw_per_refund_fee,
    gw_per_sale_fee,
    gw_per_token_fee,
    gw_reissued_fee,
    misc_monthly_fees,
    p2pe_device_activated,
    p2pe_device_activating_fee,
    p2pe_device_stored_fee,
    p2pe_encryption_fee,
    p2pe_monthly_flat_fee,
    one_time_key_injection_fees,
    p2pe_tokenization_fee,
    pci_scans_monthly_fee,
    parent_acct_id,
    hold_billing,
    stop_billing,
    billing_situation,
    billing_frequency,
    pci_compliance_fee,
    pci_non_compliance_fee
  FROM stg_cardconex_account
 WHERE acct_id IN (SELECT legacy_id FROM billing))
UNION 
(SELECT 
'billing',
legacy_id,
acct_name,
accountnumber,
NULL,
mid_1,
mid_1_type,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
dba_name,
NULL,
NULL,
NULL,
NULL,
NULL,
date_agreement_signed,
NULL,
closure_date,
NULL,
NULL,
sic,
owner_name,
owner_firstname,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
ach_monthly_fee,
ach_noc_fee,
NULL,
ach_return_error_fee,
ach_transaction_fee,
bluefin_gateway_discount_rate,
file_transfer_monthly_fee,
gateway_monthly_fee,
group_tag_fee,
gw_per_auth_decline_fee,
per_transaction_fee,
gw_per_credit_fee,
gw_per_refund_fee,
gw_per_sale_fee,
gw_per_token_fee,
gw_reissued_fee,
misc_monthly_fees,
p2pe_device_activated,
p2pe_device_activating_fee,
p2pe_device_stored_fee,
p2pe_encryption_fee,
p2pe_monthly_flat_fee,
one_time_key_injection_fees,
p2pe_tokenization_fee,
pci_scans_monthly_fee,
NULL,
NULL,
NULL,
NULL,
NULL,
pci_compliance_fee,
pci_non_compliance_fee
  FROM billing
)
ORDER BY 2, 1
;




SELECT * FROM tsanders.v_desc_rc WHERE column_name LIKE 'leg%';

DESC billing;

SET @cc_acct_id = '0010B00001mlN0sQAE';

SELECT
     asst.account_id                            AS new_acct_id
    ,acct.legacy_id__c                          AS legacy_id
--    ,id_num.name                                AS mid
    ,asst.description
    ,asst.fee_name 
    ,asst.fee_amount 
  FROM asset                                    AS asst
  JOIN account                                  AS acct
    ON asst.account_id = acct.id
--   JOIN identification_number                    AS id_num
--     ON asst.account_id = id_num.accountid__c
 WHERE acct.legacy_id__c = @cc_acct_id
 -- ORDER BY 2, 3, 5
;

SELECT 
     b.acct_id                                                  AS new_acct_id
    ,sca.acct_id                                              AS old_cardconex_acct_id
    ,sca.mid_1
    ,sca.mid_2    ,sca.mid_3
    ,sca.mid_4 
    ,sca.mid_5
    ,sca.p2pe_device_activated
    ,sca.p2pe_device_activating_fee
    ,sca.p2pe_device_stored_fee
    ,sca.p2pe_encryption_fee
    ,sca.gw_per_sale_fee
  FROM billing                                                AS b 
  LEFT JOIN  stg_cardconex_account                            AS sca
    ON b.legacy_id = sca.acct_id
--  WHERE acct_id = @cc_acct_id 
--  WHERE acct_id IN (SELECT legacy_id__c FROM account)
;
 

SELECT *
  FROM account 
  


SELECT acct_id, count(*) FROM stg_cardconex_account GROUP BY 1 ORDER BY 2 DESC;


DESC stg_cardconex_account;

SELECT * FROM identification_number id;