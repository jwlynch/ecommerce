ad_page_contract {

    Users should get here from
    process-order-quantity-payment-shipping.tcl; this page just
    summarizes their order before they submit it.

    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    usca_p:optional
}

ec_redirect_to_https_if_possible_and_necessary

# Make sure we have all their necessary info, otherwise they probably got
# here via url surgery or by pushing Back

# 1. There should be an in_basket order for their user_session_id.
# 2. The order should have the correct user_id associated with it.
# 3. The order should contain items.
# 4. The order should have an address associated with it.
# 5. The order should have credit card and shipping method associated with it.

# We need them to be logged in

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# Make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary
set order_id [db_string get_order_id "
    select order_id 
    from ec_orders 
    where user_session_id=:user_session_id 
    and order_state='in_basket'" -default ""]
if { [empty_string_p $order_id] } {

    # Then they probably got here by pushing "Back", so just redirect
    # them to index.tcl

    ad_returnredirect index
    return
}

# Make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them that it's
# empty.

if { [db_string get_ec_item_count "
    select count(*) 
    from ec_items 
    where order_id=:order_id"] == 0 } {
    ad_returnredirect shopping-cart
    return
}

# Make sure the order belongs to this user_id, otherwise they managed
# to skip past checkout.tcl, or they messed w/their user_session_id
# cookie

set order_owner [db_string get_order_owner "
    select user_id 
    from ec_orders 
    where order_id=:order_id"]
if { $order_owner != $user_id } {
    ad_returnredirect checkout
    return
}

# Make sure there is an address for this order, otherwise they've
# probably gotten here via url surgery, so redirect them to
# checkout.tcl

set address_id [db_string  get_address_id "
    select shipping_address 
    from ec_orders 
    where order_id=$order_id" -default ""]
if { [empty_string_p $address_id] } {

    # No shipping address is needed if the order only consists of soft
    # goods not requiring shipping.

    if {[db_0or1row shipping_avail "
	select p.no_shipping_avail_p, count (*)
	from ec_items i, ec_products p
	where i.product_id = p.product_id
	and p.no_shipping_avail_p = 'f' 
	and i.order_id = :order_id
	group by no_shipping_avail_p"]} {
	ad_returnredirect [ec_securelink [ec_url]checkout]
	return
    }
}

# Make sure there is a credit card (or that the
# gift_certificate_balance covers the cost) and a shipping method for
# this order, otherwise they've probably gotten here via url surgery,
# so redirect them to checkout-2.tcl

set creditcard_id [db_string  get_creditcard_id "
    select creditcard_id 
    from ec_orders 
    where order_id=:order_id" -default ""]
if { [empty_string_p $creditcard_id] } {

    # Ec_order_cost returns price + shipping + tax - gift_certificate
    # BUT no gift certificates have been applied to in_basket orders,
    # so this just returns price + shipping + tax

    set order_total_price_pre_gift_certificate [db_string get_pre_gc_price "
	select ec_order_cost(:order_id) 
	from dual"]
    set gift_certificate_balance [db_string get_gc_balance "
	select ec_gift_certificate_balance(:user_id) 
	from dual"]
    if { $gift_certificate_balance < $order_total_price_pre_gift_certificate } {
	set gift_certificate_covers_cost_p "f"
    } else {
	set gift_certificate_covers_cost_p "t"
    }
}

set shipping_method [db_string get_shipping_method "
    select shipping_method 
    from ec_orders 
    where order_id=:order_id" -default ""]
if { [empty_string_p $shipping_method] || ([empty_string_p $creditcard_id] && (![info exists gift_certificate_covers_cost_p] || $gift_certificate_covers_cost_p == "f")) } {
    ad_returnredirect checkout-2
    return
}

# Done with all the checks.  Their order is ready to go!  Now show
# them a summary before they submit their order

set order_summary [ec_order_summary_for_customer $order_id $user_id]
db_release_unused_handles
