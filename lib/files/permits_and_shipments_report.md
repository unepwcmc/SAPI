# Duplicated permit numbers

SELECT permit_number, 
count(*) 
FROM permit_details 
group by permit_number 
having count(*) > 1;

# Total: 1,972,339

# Examples
"718370"
"08CA00153/CWHQ"
"679012"
"679012"
"677204"

#Shipments with 2 or more permits

SELECT shipment_number, 
count(*) 
FROM permit_details 
group by shipment_number 
having count(*) > 1;

#Total: 2,457,845

#Examples (Maximum 2)

1532003
1535162
1535276
1536065
1577701

#Odd Permit Numbers

SELECT COUNT(*) 
FROM permits_import 
WHERE permit_number 
SIMILAR TO '%(~|,|`|\?)%'

#Total: 24429

#Examples

4376981 "04762~LN-2000"
10591257 "08CH027207?09"
11183582 "046????? (unleserlich)"
11944719 "#NAME?"
245679 "4291,,,"
3795216 "~~~~~~~4"
