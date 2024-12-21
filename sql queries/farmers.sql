use agrihelpers;
select * from farmers;
update farmers set CustomerID=NULL WHERE farmer_id>=04;
update farmers set f_availability=1 where farmer_id>=0;