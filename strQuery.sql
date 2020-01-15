USE sales_force;

-- does the new result set (billing table) have corresponding cardconex_acct_id's in the old result set (stg_cardconex_acct_id)?

SELECT COUNT(*) legacy_id FROM billing WHERE legacy_id NOT IN (SELECT acct_id FROM stg_cardconex_account);
-- no; all cc_acct_id's in the new result set also exist in the old result set.  
-- PASS

-- focus on one account.
-- compare results in the old result set to the new result set for a few fees.

SET @legacy_id = '001U00000109kHyIAI';
SET @account_id = (SELECT id FROM account WHERE legacy_id__c = @legacy_id);
SELECT @legacy_id, @account_id;

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
 WHERE acct_id = @legacy_id
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
  FROM test_cardconex_account   AS b
/*  LEFT JOIN identification_number   AS id_num 
    ON b.acct_id = id_num.account_id*/
 WHERE b.legacy_id = @legacy_id
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

SELECT * FROM account WHERE legacy_id__c = @legacy_id;
-- attributes     |accountnumber|site|accountsource|account_status__c|active_ach_ids__c|active_acquiring_ids__c|active_encryption_ids__c|active_gateway_ids__c|active_services__c|additional_documentation_needed__c|billingcity|billingcountry|billingcountrycode|billingpostalcode|billingstate|billingstatecode|billingstreet              |billing_contact_email_addresses__c|business_start_date__c|createdbyid       |createddate                 |customer_number__c|dba_name__c         |description|exemption_no__c|id                |industry|ispartner|is_501c3__c|lastactivitydate|lastmodifiedbyid  |lastmodifieddate            |lead_type__c|legacy_id__c      |legacy_source__c             |max_contract_end_date__c|months_in_business__c|name                |numberofemployees|open_opportunities__c|open_opportunity_amount__c|organizationid__c|ownerid           |parentid|partnership_type__c|partner_service_instructions__c|phone         |photourl                                 |recordtypeid      |revenue_segment__c     |shippingaddress|shippingcity|shippingcountry|shippingcountrycode|shippinggeocodeaccuracy|shippinglatitude|shippinglongitude|shippingpostalcode|shippingstate|shippingstatecode|shippingstreet             |sic|sicdesc|type|unique_count__c|website|
-- ---------------|-------------|----|-------------|-----------------|-----------------|-----------------------|------------------------|---------------------|------------------|----------------------------------|-----------|--------------|------------------|-----------------|------------|----------------|---------------------------|----------------------------------|----------------------|------------------|----------------------------|------------------|--------------------|-----------|---------------|------------------|--------|---------|-----------|----------------|------------------|----------------------------|------------|------------------|-----------------------------|------------------------|---------------------|--------------------|-----------------|---------------------|--------------------------|-----------------|------------------|--------|-------------------|-------------------------------|--------------|-----------------------------------------|------------------|-----------------------|---------------|------------|---------------|-------------------|-----------------------|----------------|-----------------|------------------|-------------|-----------------|---------------------------|---|-------|----|---------------|-------|
-- [object Object]|             |    |             |                 |0                |0                      |0                       |0                    |No Active Services|false                             |Chantilly  |United States |US                |20151            |Virginia    |VA              |14151 Newbrook Dr.- Ste 200|                                  |                      |0053i000000vhOxAAI|2014-11-20T12:18:21.000+0000|CU00021200        |3 Delta Systems Inc.|           |               |0013i00000Cg8YJAAZ|        |false    |false      |                |0053i000000vhOxAAI|2020-01-07T18:13:30.000+0000|            |001U00000109kHyIAI|Original SF MIgrated 20191209|                        |0                    |3 Delta Systems Inc.|                 |0                    |0                         |                 |0053i000001mBGHAA2|        |                   |                               |(703) 234-6010|/services/images/photo/0013i00000Cg8YJAAZ|0123i000000HCjlAAG|Decryptx Large Merchant|[object Object]|Chantilly   |United States  |US                 |                       |                |                 |20151             |Virginia     |VA               |14151 Newbrook Dr.- Ste 200|   |       |    |1              |       |            |    |             |                 |0                |0                      |0                       |0                    |No Active Services|false                             |Sanford    |United States |US                |32771            |Florida     |FL              |800 Central Park Dr|                                  |                      |0053i000001mBGHAA2|2016-11-18T14:26:41.000+0000|CU00023242        |Neulion College, Inc.|           |               |0013i00000Cg8RkAAJ|        |false    |false      |                |0053i000000vhOxAAI|2020-01-07T18:13:41.000+0000|            |0010B00001mlN0sQAE|Original SF MIgrated 20191209|                        |0                    |Neulion College, Inc.|                 |0                    |0                         |                 |0053i000001mBGHAA2|        |                   |                               |     |/services/images/photo/0013i00000Cg8RkAAJ|0123i000000HCjlAAG|Decryptx Partner Merchant|[object Object]|Sanford     |United States  |US                 |                       |                |                 |32771             |Florida      |FL               |800 Central Park Dr|   |       |    |1              |       |

SELECT * FROM asset WHERE accountid = @account_id;
-- accountid         |assetlevel|contractid__c|createdbyid       |createddate                 |description|fee_amount_text__c|fee_amount__c|fee_group__c|fee_name__c               |id                |identification_numberid__c|id_number_text__c|installdate|lastmodifiedbyid  |lastmodifieddate            |name                      |ownerid           |parentid|price|product2id|productcode|purchasedate|quantity|quote_line_itemid__c|serialnumber|status|usageenddate|
-- ------------------|----------|-------------|------------------|----------------------------|-----------|------------------|-------------|------------|--------------------------|------------------|--------------------------|-----------------|-----------|------------------|----------------------------|--------------------------|------------------|--------|-----|----------|-----------|------------|--------|--------------------|------------|------|------------|
-- 0013i00000Cg8YJAAZ|1         |             |0053i000000vhOxAAI|2019-12-09T18:51:44.000+0000|           |5                 |       5.0000|Encryption  |P2PE Device Activating Fee|02i3i000000cZRCAA2|                          |                 |           |0053i000000vhOxAAI|2019-12-13T14:52:16.000+0000|P2PE Device Activating Fee|0053i000000vhOxAAI|        |     |          |           |            |        |                    |            |Active|            |
-- 0013i00000Cg8YJAAZ|1         |             |0053i000000vhOxAAI|2019-12-09T18:51:44.000+0000|           |5                 |       5.0000|Encryption  |P2PE Device Stored Fee    |02i3i000000cZRlAAM|                          |                 |           |0053i000000vhOxAAI|2019-12-13T14:52:16.000+0000|P2PE Device Stored Fee    |0053i000000vhOxAAI|        |     |          |           |            |        |                    |            |Active|            |
-- 0013i00000Cg8YJAAZ|1         |             |0053i000000vhOxAAI|2019-12-09T18:51:44.000+0000|           |.01               |       0.0100|Encryption  |P2PE Encryption Fee       |02i3i000000cZSdAAM|                          |                 |           |0053i000000vhOxAAI|2019-12-13T14:52:16.000+0000|P2PE Encryption Fee       |0053i000000vhOxAAI|        |     |          |           |            |        |                    |            |Active|            |
-- 0013i00000Cg8YJAAZ|1         |             |0053i000000vhOxAAI|2019-12-09T18:51:44.000+0000|           |5                 |       5.0000|Encryption  |P2PE Device Activated Fee |02i3i000000cZQbAAM|                          |                 |           |0053i000000vhOxAAI|2019-12-13T14:52:16.000+0000|P2PE Device Activated Fee |0053i000000vhOxAAI|        |     |          |           |            |        |                    |            |Active|            |

SELECT * FROM bank_account ba WHERE accountid__c = @account_id;
-- attributes     |bank_name__c|aba__c   |accountid__c      |account_type__c|ach_debit_account_name__c|ach_descriptor__c|bank_account_number__c|bank_account_type__c|bank_city__c|bank_contact_name__c|bank_phone__c|bank_postal_code__c|bank_state__c|bank_street_address__c|business_person_named_on_teh_account__c|createdbyid       |createddate                 |id                |lastmodifieddate            |name           |
-- ---------------|------------|---------|------------------|---------------|-------------------------|-----------------|----------------------|--------------------|------------|--------------------|-------------|-------------------|-------------|----------------------|---------------------------------------|------------------|----------------------------|------------------|----------------------------|---------------|
-- [object Object]|            |051400549|0013i00000Cg8YJAAZ|Billing Account|3DELTA                   |CU00021200       |*********0222         |Checking            |            |                    |             |                   |             |                      |                                       |0053i000000vhOxAAI|2018-04-09T21:27:47.000+0000|a1W3i000000hTwPEAU|2019-12-09T19:46:45.000+0000|a1W3i000000hTwP|
-- [object Object]|Wells Fargo |056007604|0013i00000Cg8YJAAZ|               |3DELTA                   |CU00021200       |*********0222         |Corporate           |            |                    |             |                   |             |                      |                                       |0053i000001mBGoAAM|2017-01-30T20:14:52.000+0000|a1W3i000000hTwEEAU|2019-12-09T19:46:45.000+0000|a1W3i000000hTwE|

SELECT * FROM identification_number WHERE accountid__c = @account_id;
-- attributes     |accountid__c      |category__c|close_date__c|createdbyid       |createddate                 |id                |lastmodifiedbyid  |lastmodifieddate            |name|ownerid           |recordtypeid      |start_date__c|status__c|type__c|unique_id__c           |
-- ---------------|------------------|-----------|-------------|------------------|----------------------------|------------------|------------------|----------------------------|----|------------------|------------------|-------------|---------|-------|-----------------------|
-- [object Object]|0013i00000Cg8YJAAZ|           |             |0053i000000vhOxAAI|2019-12-10T15:03:07.000+0000|a0H3i000001xAWiEAM|0053i000000vhOxAAI|2019-12-10T15:03:10.000+0000|43  |0053i000000vhOxAAI|0123i000000HC32AAG|2019-12-10   |Active   |       |0013i00000Cg8YJAAZ - 43|

SELECT * FROM contract WHERE accountid = @account_id;
-- attributes     |accountid         |activatedbyid     |activateddate               |additional_documentation_needed__c|billingcity|billingcountry|billingcountrycode|billingpostalcode|billingstate|billingstatecode|billingstreet|billing_accountid__c|billing_frequency__c|billing_month__c|billing_preference__c|collection_method__c|companysigneddate|companysignedid|contractnumber|contractterm|createdbyid       |createddate                 |customersignedid|customersignedtitle|description|enddate|ia_crm__ship_to__c|id                |isdeleted|lastactivitydate|lastapproveddate|lastmodifiedbyid  |lastmodifieddate            |opportunityid__c|ownerexpirationnotice|ownerid           |pricebook2id|recordtypeid      |revenue_segment__c|shippingcity|shippingcountry|shippingcountrycode|shippingpostalcode|shippingstate|shippingstatecode|shippingstreet|specialterms|startdate|status   |statuscode|billing_hold_reason__c|billing_hold_release_date__c|hold_billing__c|
-- ---------------|------------------|------------------|----------------------------|----------------------------------|-----------|--------------|------------------|-----------------|------------|----------------|-------------|--------------------|--------------------|----------------|---------------------|--------------------|-----------------|---------------|--------------|------------|------------------|----------------------------|----------------|-------------------|-----------|-------|------------------|------------------|---------|----------------|----------------|------------------|----------------------------|----------------|---------------------|------------------|------------|------------------|------------------|------------|---------------|-------------------|------------------|-------------|-----------------|--------------|------------|---------|---------|----------|----------------------|----------------------------|---------------|
-- [object Object]|0013i00000Cg8YJAAZ|0053i000000vhOxAAI|2019-12-09T20:46:03.000+0000|false                             |           |United States |US                |                 |            |                |             |                    |Monthly             |                |Direct               |PayConex CC         |                 |               |00000172      |            |0053i000000vhOxAAI|2019-12-09T19:14:41.000+0000|                |                   |           |       |                  |8003i000000Y1RBAA0|false    |                |                |0053i000000vhOxAAI|2019-12-09T20:46:03.000+0000|                |                     |0053i000000vhOxAAI|            |0123i000000IC5VAAW|                  |            |United States  |US                 |                  |             |                 |              |            |         |Activated|Activated |                      |                            |false          |

-- which columns to use for the dba name and address?
SELECT 
     dba_name__c
    ,billingcity       
    ,billingcountry    
    ,billingcountrycode
    ,billingpostalcode 
    ,billingstate      
    ,billingstatecode  
    ,billingstreet  
    ,shippingaddress        
    ,shippingcity           
    ,shippingcountry        
    ,shippingcountrycode    
    ,shippinggeocodeaccuracy
    ,shippinglatitude       
    ,shippinglongitude      
    ,shippingpostalcode     
    ,shippingstate          
    ,shippingstatecode      
    ,shippingstreet         
  FROM account 
;

-- The folliwing query works.  No dupes are present except for 3 Delta Systems Inc.
-- what happens if we do the query in MySQL instead of node?
SELECT 
     legacy_id
    ,acct_name
    ,fee_name__c
    ,fee_col
    ,fee_amount__c
FROM (
  SELECT 
       acct.id                            AS acct_id
      ,acct.legacy_id__c                  AS legacy_id
      ,acct.name                          AS acct_name
      ,acct.accountnumber                 AS accountnumber 
      -- ,id_num.name                     AS mid_1 
      -- ,id_num.type__c                  AS mid_1_type 
      ,acct.dba_name__c                   AS dba_name 
      ,con.startdate                      AS date_agreement_signed 
      -- ,id_num.close_date__c            AS closure_date 
      ,acct.sic                           AS sic 
      ,usr.name                           AS owner_name
      ,usr.firstname                      AS owner_firstname
      ,usr.lastname                       AS owner_lastname
      ,con.startdate                      AS bluefin_contract_start_date
      ,acct.industry                      AS industry 
      ,acct.revenue_segment__c            AS segment
      ,acct.parentid                      AS parent_acct_id 
      ,con.hold_billing__c                AS hold_billing
      ,con.billing_hold_release_date__c   AS stop_billing
      ,con.billing_preference__c          AS billing_situation
      ,con.billing_frequency__c           AS billing_frequency
      ,acct.lastmodifieddate              AS date_modified
      ,acct.createddate                   AS date_updated 
      ,asst.fee_name__c
      ,asst.fee_amount__c
    FROM account                          acct
    LEFT JOIN asset                            asst
      ON acct.Id = asst.AccountId 
    LEFT JOIN bank_account                     ba 
      ON acct.Id = ba.AccountId__c 
  -- JOIN identification_number           id_num
  -- ON acct.Id = idnum.AccountId__c 
    LEFT JOIN contract                         con
      ON acct.Id = con.AccountId 
    LEFT JOIN usr              
      ON acct.OwnerId = usr.Id 
) t1 
LEFT JOIN fee_map ON t1.fee_name__c = fee_map.fee_desc
--  WHERE legacy_id = @legacy_id
 ORDER BY 2, 3
;

-- acct_id           |legacy_id         |acct_name            |accountnumber|dba_name             |date_agreement_signed|sic|owner_name|owner_firstname|owner_lastname|bluefin_contract_start_date|industry|segment                  |parent_acct_id|hold_billing|stop_billing|billing_situation|billing_frequency|date_modified               |date_updated                |fee_name__c               |fee_amount__c|
-- ------------------|------------------|---------------------|-------------|---------------------|---------------------|---|----------|---------------|--------------|---------------------------|--------|-------------------------|--------------|------------|------------|-----------------|-----------------|----------------------------|----------------------------|--------------------------|-------------|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|Neulion College, Inc.|             |Neulion College, Inc.|                     |   |Terry Ford|Terry          |Ford          |                           |        |Decryptx Partner Merchant|              |false       |            |Direct           |Monthly          |2020-01-07T18:13:41.000+0000|2016-11-18T14:26:41.000+0000|P2PE Device Stored Fee    |      10.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|Neulion College, Inc.|             |Neulion College, Inc.|                     |   |Terry Ford|Terry          |Ford          |                           |        |Decryptx Partner Merchant|              |false       |            |Direct           |Monthly          |2020-01-07T18:13:41.000+0000|2016-11-18T14:26:41.000+0000|P2PE Encryption Fee       |       0.0500|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|Neulion College, Inc.|             |Neulion College, Inc.|                     |   |Terry Ford|Terry          |Ford          |                           |        |Decryptx Partner Merchant|              |false       |            |Direct           |Monthly          |2020-01-07T18:13:41.000+0000|2016-11-18T14:26:41.000+0000|P2PE Device Activated Fee |      10.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|Neulion College, Inc.|             |Neulion College, Inc.|                     |   |Terry Ford|Terry          |Ford          |                           |        |Decryptx Partner Merchant|              |false       |            |Direct           |Monthly          |2020-01-07T18:13:41.000+0000|2016-11-18T14:26:41.000+0000|P2PE Transaction Fee      |       0.0000|
-- 0013i00000Cg8RkAAJ|0010B00001mlN0sQAE|Neulion College, Inc.|             |Neulion College, Inc.|                     |   |Terry Ford|Terry          |Ford          |                           |        |Decryptx Partner Merchant|              |false       |            |Direct           |Monthly          |2020-01-07T18:13:41.000+0000|2016-11-18T14:26:41.000+0000|P2PE Device Activating Fee|      10.0000|

-- how does this compare with the original data?

-- tsanders@localhost [sales_force] select @cc_acct_id;
-- +--------------------+                              
-- | @cc_acct_id        |                              
-- +--------------------+                              
-- | 0010B00001mlN0sQAE |                              
-- +--------------------+                              
-- 1 row in set (0.00 sec)                             

SELECT acct_id, acct_name, concat(mid_1, mid_2, mid_3, mid_4, mid_5) as mids, p2pe_device_stored_fee, p2pe_encryption_fee, p2pe_device_activated, '\'P2PE Transaction Fee\'?', p2pe_device_activating_fee 
FROM stg_cardconex_account 
WHERE acct_id = @cc_acct_id;
-- +--------------------+-----------------------+------+------------------------+---------------------+-----------------------+-------------------------+----------------------------+
-- | acct_id            | acct_name             | mids | p2pe_device_stored_fee | p2pe_encryption_fee | p2pe_device_activated | 'P2PE Transaction Fee'? | p2pe_device_activating_fee |
-- +--------------------+-----------------------+------+------------------------+---------------------+-----------------------+-------------------------+----------------------------+
-- | 0010B00001mlN0sQAE | Neulion College, Inc. |      |                10.0000 |              0.0500 |               10.0000 | 'P2PE Transaction Fee'? |                    10.0000 |
-- +--------------------+-----------------------+------+------------------------+---------------------+-----------------------+-------------------------+----------------------------+

-- it matches...





-- scratch

SELECT 
     acct.id                            AS acct_id
    ,acct.legacy_id__c                  AS legacy_id
    ,acct.name                          AS acct_name
    ,acct.accountnumber                 AS accountnumber 
    -- ,id_num.name                     AS mid_1 
    -- ,id_num.type__c                  AS mid_1_type 
    ,acct.dba_name__c                   AS dba_name 
    ,con.startdate                      AS date_agreement_signed 
    -- ,id_num.close_date__c            AS closure_date 
    ,acct.sic                           AS sic 
    ,usr.name                           AS owner_name
    ,usr.firstname                      AS owner_firstname
    ,usr.lastname                       AS owner_lastname
    ,con.startdate                      AS bluefin_contract_start_date
    ,acct.industry                      AS industry 
    ,acct.revenue_segment__c            AS segment
    ,acct.parentid                      AS parent_acct_id 
    ,con.hold_billing__c                AS hold_billing
    ,con.billing_hold_release_date__c   AS stop_billing
    ,con.billing_preference__c          AS billing_situation
    ,con.billing_frequency__c           AS billing_frequency
    ,acct.lastmodifieddate              AS date_modified
    ,acct.createddate                   AS date_updated 
    ,asst.fee_name__c
    ,asst.fee_amount__c
  FROM account                          acct
  JOIN asset                            asst
    ON acct.Id = asst.AccountId 
  JOIN bank_account                     ba 
    ON acct.Id = ba.AccountId__c 
  JOIN identification_number           id_num
    ON acct.Id = id_num.AccountId__c 
  JOIN contract                         con
    ON acct.Id = con.AccountId 
  JOIN usr              
    ON acct.OwnerId = usr.Id 
 WHERE acct.id = @account_id
;





SELECT 
     acct_id
    ,acct_name
    ,p2pe_device_activated
    ,p2pe_device_activating_fee
    ,p2pe_device_stored_fee
    ,p2pe_encryption_fee
    ,gw_per_auth_decline_fee
    ,gw_per_credit_fee
    ,gw_per_refund_fee  
    ,gw_per_token_fee
    ,p2pe_monthly_flat_fee
    ,gw_per_sale_fee
FROM stg_cardconex_account
WHERE acct_id IN (SELECT legacy_id__c FROM account)
ORDER BY 2;



SELECT DISTINCT id, legacy_id__c, name FROM account ORDER BY 3;

DESC account;






SELECT count(DISTINCT legacy_id__c) FROM account;



SELECT @legacy_id, @account_id;







SELECT 
     acct.id                            AS acct_id
    ,acct.legacy_id__c                  AS legacy_id
    ,acct.name                          AS acct_name
    ,acct.accountnumber                 AS accountnumber 
    -- ,id_num.name                     AS mid_1 
    -- ,id_num.type__c                  AS mid_1_type 
    ,acct.dba_name__c                   AS dba_name 
    ,con.startdate                      AS date_agreement_signed 
    -- ,id_num.close_date__c            AS closure_date 
    ,acct.sic                           AS sic 
    ,usr.name                           AS owner_name
    ,usr.firstname                      AS owner_firstname
    ,usr.lastname                       AS owner_lastname
    ,con.startdate                      AS bluefin_contract_start_date
    ,acct.industry                      AS industry 
    ,acct.revenue_segment__c            AS segment
    ,acct.parentid                      AS parent_acct_id 
    ,con.hold_billing__c                AS hold_billing
    ,con.billing_hold_release_date__c   AS stop_billing
    ,con.billing_preference__c          AS billing_situation
    ,con.billing_frequency__c           AS billing_frequency
    ,acct.lastmodifieddate              AS date_modified
    ,acct.createddate                   AS date_updated 
    ,asst.fee_name__c
    ,asst.fee_amount__c
  FROM account                          acct
  LEFT JOIN asset                            asst
    ON acct.Id = asst.AccountId 
--   LEFT JOIN bank_account                     ba 
--     ON acct.Id = ba.AccountId__c 
-- JOIN identification_number           id_num
-- ON acct.Id = idnum.AccountId__c 
  LEFT JOIN contract                         con
    ON acct.Id = con.AccountId 
  LEFT JOIN usr              
    ON acct.OwnerId = usr.Id 
 ORDER BY 3
;