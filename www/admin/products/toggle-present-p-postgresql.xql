<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="toggle_present_p_update">      
      <querytext>
      
update ec_products 
set present_p = util__logical_negation(present_p),
    last_modified = current_timestamp, 
    last_modifying_user = :user_id,
    modified_ip_address = :peeraddr
where product_id = :product_id

      </querytext>
</fullquery>

 
</queryset>
