ad_page_contract {
    @param address_id:optional
    @param address_type
    @param attn
    @param line1
    @param line2:optional
    @param city
    @param usps_abbrev
    @param zip_code
    @param phone
    @param phone_time:optional
    @param action

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    address_type
    address_id:optional
    attn
    line1
    line2:optional
    city
    usps_abbrev
    zip_code
    phone
    phone_time:optional
    action
}

set possible_exception_list [list [list attn name] [list line1 address] [list city city] [list usps_abbrev state] [list zip_code "zip code"] [list phone "telephone number"]]
set exception_count 0
set exception_text ""

foreach possible_exception $possible_exception_list {
    if { ![info exists [lindex $possible_exception 0]] || [empty_string_p [set [lindex $possible_exception 0]]] } {
	incr exception_count
	append exception_text "<li>You forgot to enter your [lindex $possible_exception 1]."
    }
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# We need them to be logged in

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# Make sure they have an in_basket order unless they are ordering a
# gift certificate, otherwise they've probably gotten here by pushing
# Back, so return them to index.tcl

set user_session_id [ec_get_user_session_id]
set order_id [db_string get_order_id "
    select order_id 
    from ec_orders 
    where user_session_id = :user_session_id 
    and order_state = 'in_basket'" -default ""]
if { $action != "https://www.7-sisters.com:8443/store/gift-certificate-billing" } {
    if { [empty_string_p $order_id] } {

	# They probably got here by pushing "Back", so just redirect
	# them to index.tcl

	ad_returnredirect index.tcl
	return
    }
}

if { [info exists address_id] && $address_id != "" } {

    # This is an existing address that has been edited.

    db_transaction {
	db_dml update_address "
	    update ec_addresses 
             set attn=:attn, line1=:line1, line2=:line2, city=:city, usps_abbrev=:usps_abbrev, zip_code=:zip_code, phone=:phone, phone_time=:phone_time
             where address_id = :address_id"
	db_dml set_shipping_on_order "
	    update ec_orders 
	    set shipping_address = :address_id 
	    where order_id = :order_id"
    }
    db_release_unused_handles

} else {

    # This is a new address which requires an address_id.

    set address_id [db_nextval ec_address_id_sequence]
    db_transaction {
	db_dml insert_new_address "
	    insert into ec_addresses
            (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, zip_code, country_code, phone, phone_time)
            values
            (:address_id, :user_id, 'shipping', :attn, :line1,:line2,:city,:usps_abbrev,:zip_code,'US',:phone,:phone_time)"
	db_dml set_shipping_on_order "
	    update ec_orders 
	    set shipping_address = :address_id 
	    where order_id = :order_id"
    }
}

set formatted_address [ec_display_as_html [ec_pretty_mailing_address_from_args $line1 $line2 $city $usps_abbrev $zip_code "US" \
						"" $attn $phone $phone_time]]
set hidden_form_vars ""
set form_set [ns_getform]
for {set i 0} {$i < [ns_set size $form_set]} {incr i} {
    set [ns_set key $form_set $i] [ns_set value $form_set $i]
    append hidden_form_vars "[export_form_vars [ns_set key $form_set $i]]"
}