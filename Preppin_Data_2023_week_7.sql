/*For the Transaction Path table:
Make sure field naming convention matches the other tables
i.e. instead of Account_From it should be Account From
For the Account Information table:
Make sure there are no null values in the Account Holder ID
Ensure there is one row per Account Holder ID
Joint accounts will have 2 Account Holders, we want a row for each of them
For the Account Holders table:
Make sure the phone numbers start with 07
Bring the tables together
Filter out cancelled transactions 
Filter to transactions greater than £1,000 in value 
Filter out Platinum accounts*/
with cte as
(
SELECT --h.account_holder_id
      h.name
      ,h.date_of_birth
      ,concat(0,h.contact_number)as contact_number
      ,h.first_line_of_address
      ,i.account_number
      ,i.account_type
      ,trim(value) as account_holder_id
      ,i.balance_date
      ,i.balance
    FROM      
TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_INFORMATION i, lateral split_to_table(i.account_holder_id,',')
join TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_HOLDERS h
ON h.ACCOUNT_HOLDER_ID=trim(value)
WHERE trim(value) IS not NULL
)
,cte1 as
(
SELECT d.*,p.account_from, p.account_to
FROM
TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_DETAIL d
join 
TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_PATH p on p.transaction_id=d.transaction_id
)
select cte.*, cte1.*
from cte
join cte1 on cte.account_number=cte1.account_from
where cancelled_ in ('N')
AND value > 1000
and account_type NOT in ('Platinum')
