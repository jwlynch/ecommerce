ad_page_contract {
    @param usca_p:optional

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002
} {
    usca_p:optional
}

ec_redirect_to_https_if_possible_and_necessary

# Make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set user_id [ad_verify_and_get_user_id]
set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary

ec_log_user_as_user_id_for_this_session

set order_id [db_string  get_order_id "
    select order_id
    from ec_orders
    where user_session_id = :user_session_id
    and order_state='in_basket'" -default "" ]

if { [empty_string_p $order_id] } {

    # Then they probably got here by pushing "Back", so just redirect
    # them to index.tcl

    ad_returnredirect index
    template::adp_abort
} else {
    db_dml update_ec_order_set_uid "
	update ec_orders 
	set user_id = :user_id
	where order_id = :order_id"
}

# See if there are any saved shipping addresses for this user

set address_type "shipping"

# Check if the order requires shipping

if {[db_0or1row shipping_avail "
    select p.no_shipping_avail_p
    from ec_items i, ec_products p
    where i.product_id = p.product_id
    and p.no_shipping_avail_p = 'f' 
    and i.order_id = :order_id
    group by no_shipping_avail_p"]} {

    set shipping_required true

    # Present all saved addresses

    template::query get_user_addresses addresses multirow "
    select address_id, attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time, address_type
    from ec_addresses
    where user_id=:user_id
    and address_type = 'shipping'" -eval {

	set row(formatted) [ec_display_as_html [ec_pretty_mailing_address_from_args $row(line1) $row(line2) $row(city) $row(usps_abbrev) $row(zip_code) $row(country_code) \
						    $row(full_state_name) $row(attn) $row(phone) $row(phone_time)]]
	set address_id $row(address_id)
	set row(delete) "[export_form_vars address_id]"
	set row(edit) "[export_form_vars address_id address_type]"
	set row(use) "[export_form_vars address_id]"
    }
    set hidden_form_vars [export_form_vars address_type]
} else {
    set address_id ""
    set hidden_form_vars [export_form_vars address_id address_type]
    set shipping_required false
}

db_release_unused_handles
