<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="total_price_of_items_select">      
      <querytext>
      select nvl(sum(price_charged),0) from ec_items where item_id in ([join $item_id_vars ", "])
      </querytext>
</fullquery>

 
<fullquery name="shipping_of_items_select">      
      <querytext>
      select nvl(sum(shipping_charged),0) from ec_items where item_id in ([join $item_id_vars ", "])
      </querytext>
</fullquery>

 
<fullquery name="total_tax_of_items_select">      
      <querytext>
      select ec_tax(:total_price_of_items, :total_shipping_of_items, :order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="insert_shipment_info">      
      <querytext>
      insert into ec_shipments
  (shipment_id, order_id, shipment_date, expected_arrival_date, carrier, tracking_number, shippable_p, last_modified, last_modifying_user, modified_ip_address)
  values
  (:shipment_id, :order_id, to_date(:shipment_date, 'YYYY-MM-DD HH12:MI:SSAM'), to_date(:expected_arrival_date, 'YYYY-MM-DD HH12:MI:SSAM'), :carrier, :tracking_number, :shippable_p_tf, sysdate, :customer_service_rep, :peeraddr)
  
      </querytext>
</fullquery>

 
<fullquery name="shipment_cost_select">      
      <querytext>
      select ec_shipment_cost(:shipment_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="order_cost_select">      
      <querytext>
      select ec_order_cost(:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="transaction_update">      
      <querytext>
      update ec_financial_transactions set shipment_id=:shipment_id, to_be_captured_p='t', to_be_captured_date=sysdate where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="problems_log_insert">      
      <querytext>
      insert into ec_problems_log
	(problem_id, problem_date, problem_details, order_id)
	values
	(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	
      </querytext>
</fullquery>

 
<fullquery name="transaction_success_update">      
      <querytext>
      update ec_financial_transactions set marked_date=sysdate where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="transaction_id_insert">      
      <querytext>
      insert into ec_financial_transactions
      (transaction_id, order_id, shipment_id, transaction_amount, transaction_type, to_be_captured_p, inserted_date, to_be_captured_date)
      values
      (:transaction_id, :order_id, :shipment_id, :shipment_cost, 'charge','t',sysdate,sysdate)
      
      </querytext>
</fullquery>

 
<fullquery name="problems_insert">      
      <querytext>
      
	insert into ec_problems_log
	(problem_id, problem_date, problem_details, order_id)
	values
	(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	
      </querytext>
</fullquery>

 
<fullquery name="transaction_authorized_udpate">      
      <querytext>
      update ec_financial_transactions set authorized_date=sysdate where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="problems_insert">      
      <querytext>
      insert into ec_problems_log
	  (problem_id, problem_date, problem_details, order_id)
	  values
	  (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	  
      </querytext>
</fullquery>

 
<fullquery name="transaction_success_update">      
      <querytext>
      update ec_financial_transactions set marked_date=sysdate where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
</queryset>