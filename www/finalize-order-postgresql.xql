<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="get_gc_balance">      
    <querytext>
      select ec_gift_certificate_balance(:user_id)
    </querytext>
  </fullquery>

  <fullquery name="get_applied_certificate_amount">
    <querytext>
      select ec_order_gift_cert_amount(:order_id)
    </querytext>
  </fullquery>

  <fullquery name="get_soft_goods_cost">      
    <querytext>
      select coalesce(sum(i.price_charged),0) - coalesce(sum(i.price_refunded),0) as soft_goods_cost
      from ec_items i, ec_products p
      where i.order_id = :order_id
      and i.item_state <> 'void'
      and i.product_id = p.product_id
      and p.no_shipping_avail_p = 't'
    </querytext>
  </fullquery>

  <fullquery name="get_hard_goods_cost">      
    <querytext>
      select coalesce(sum(i.price_charged),0) - coalesce(sum(i.price_refunded),0) as hard_goods_cost
      from ec_items i, ec_products p
      where i.order_id = :order_id
      and i.item_state <> 'void'
      and i.product_id = p.product_id
      and p.no_shipping_avail_p = 'f'
    </querytext>
  </fullquery>

  <fullquery name="insert_financial_transaction">
    <querytext>
      insert into ec_financial_transactions
      (transaction_id, order_id, transaction_amount, transaction_type, inserted_date)
      values
      (:transaction_id, :order_id, :transaction_amount, 'charge', current_timestamp)
    </querytext>
  </fullquery>

  <fullquery name="update_authorized_date">
    <querytext>
      update ec_financial_transactions 
      set authorized_date = current_timestamp
      where transaction_id = :transaction_id
    </querytext>*op
  </fullquery>

  <fullquery name="schedule_settlement">
    <querytext>
      update ec_financial_transactions 
      set authorized_date = current_timestamp, to_be_captured_p = 't', to_be_captured_date = current_timestamp
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

  <fullquery name="schedule_settlement_soft_goods">
    <querytext>
      update ec_financial_transactions 
      set to_be_captured_p = 't', to_be_captured_date = current_timestamp
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

  <fullquery name="record_marking_problem">
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
    </querytext>
  </fullquery>

  <fullquery name="update_marked_date">
    <querytext>
      update ec_financial_transactions 
      set marked_date = current_timestamp
      where transaction_id = :pgw_transaction_id
    </querytext>
  </fullquery>

</queryset>
