<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="recommendation_insert">      
      <querytext>
      insert into ec_product_recommendations
(recommendation_id, product_id, user_class_id, recommendation_text, active_p, category_id, subcategory_id, subsubcategory_id, 
last_modified, last_modifying_user, modified_ip_address)
values
(:recommendation_id, :product_id, :user_class_id, :recommendation_text, 't', :category_id, :subcategory_id, :subsubcategory_id,
sysdate, :user_id, :peeraddr)

      </querytext>
</fullquery>

 
</queryset>
