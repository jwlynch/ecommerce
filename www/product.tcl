ad_page_contract {

    Display a single product and possibly comments on that
    product or professional reviews

    @param product_id:integer
    @param offer_code:optional
    @param comments_sort_by:optional
    @param usca_p:optional

    @author Eve Andersson (eveander@arsdigita.com) 
    @creation-date June 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    product_id:integer
    offer_code:optional
    comments_sort_by:optional
    usca_p:optional
}


# Default to empty string (date)

if { ![info exists comments_sort_by] } {
    set comments_sort_by ""
}

# Users don't need to be logged in but if they are the could get a
# lower price

set user_id [ad_verify_and_get_user_id]

# user sessions:
# 1. get user_session_id from cookie

# 2. if user has no session (i.e. user_session_id=0), attempt to set
#    it if it hasn't been attempted before

# 3. if it has been attempted before,
#    (a) if they have no offer_code, then do nothing
#    (b) if they have a offer_code, tell them they need cookies on if
#       they want their offer price

# 4. Log this product_id into the user session

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary [export_url_vars product_id offer_code] cookies_are_not_required

# Valid offer codes must be <= 20 characters, so if it's more than 20
# characters, pretend it isn't there

if { ![info exists user_session_id] } {
    if { [info exists offer_code] && [string length $offer_code] <= 20 } {
	ad_return_complaint 1 "
            <p>You need to have cookies turned on in order to have
            special offers take effect (we use cookies to remember that you are a
            recipient of this special offer.</p>

            <p>Please turn on cookies in your browser, or if you don't wish
            to take advantage of this offer, you can still <a
            href=\"index\">continue shopping at [ec_system_name]</a>"
	return
    }
}

set product_id_temp $product_id
if { [db_0or1row get_ec_product_info "
    select *
    from ec_products p, ec_custom_product_field_values v
    where p.product_id = :product_id
    and p.product_id = v.product_id(+)"] == 0 } {

    doc_return  200 text/html "
	[ad_header "Product Not Found"]
	<p>The product you have requested was not found in the database.</p>
	<p>Please contact <a href=\"mailto:[ec_system_owner]\">[ec_system_owner]</a> to report the error.</p>"
    return
}

# Finishing up the kludge from a few lines back

set product_id $product_id_temp

if { [string compare $user_session_id "0"] != 0 } {
    db_dml insert_user_session_info "
	insert into ec_user_session_info 
	(user_session_id, product_id) 
	values 
	(:user_session_id, :product_id)"
}

if { [info exists offer_code] && [string compare $user_session_id "0"] != 0} {

    # Insert into or update ec_user_session_offer_codes

    if { [db_string get_offer_code_p "
	select count(*) 
	from ec_user_session_offer_codes 
	where user_session_id=:user_session_id
	and product_id=:product_id"] == 0 } {
	db_dml inert_uc_offer_code "
	    insert into ec_user_session_offer_codes
	    (user_session_id, product_id, offer_code) 
	    values 
	    (:user_session_id, :product_id, :offer_code)"
    } else {
	db_dml update_ec_us_offers "
	    update ec_user_session_offer_codes 
	    set offer_code = :offer_code
	    where user_session_id = :user_session_id
	    and product_id = :product_id"
    }
}

if { ![info exists offer_code] && [string compare $user_session_id "0"] != 0} {
    set offer_code [db_string  get_offer_code "
	select offer_code
	from ec_user_session_offer_codes
	 where user_session_id=:user_session_id 
	and product_id=:product_id" -default "" ]
}

if { ![info exists offer_code] } {
    set offer_code ""
}

set currency [ad_parameter -package_id [ec_id] Currency ecommerce]
set allow_pre_orders_p [ad_parameter -package_id [ec_id] AllowPreOrdersP ecommerce]

# Get all the information from both the products table and any custom
# product fields added by this publisher

# But first...  This is a major kludge but it is not as bad as the
# query that follows.

if { ![empty_string_p $template_id] } {

    # Template specified by Url

    set template [db_string get_template "
    	select template
      	from ec_templates
     	where template_id=:template_id"]

} else {

    # Template specified by Product category

    set template_list [db_list get_template_list "
	select template
  	from ec_templates t, ec_category_template_map ct, ec_category_product_map cp
 	where t.template_id = ct.template_id
   	and ct.category_id = cp.category_id
   	and cp.product_id = :product_id"]
    set template [lindex $template_list 0]

    if [empty_string_p $template] {

	# Template specified by... well, just use the default

	set template [db_string get_template_finally "
            select template
            from ec_templates
            where template_id=(select default_template
                from ec_admin_settings)" -default ""]
    }
}

db_foreach find_a_good_category "
    select * 
    from (select category_id, (select count(*)
	from ec_subcategories s
	where s.category_id = m.category_id) subcount, 
        (select count(*)
	    from ec_subsubcategories ss
            where ss.subcategory_id = m.category_id) subsubcount
         from ec_category_product_map m
         where product_id = :product_id
    order by subcount, subsubcount, category_id)
    where rownum = 1" {
}

db_release_unused_handles
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list $product_name]]]
set ec_system_owner [ec_system_owner]

set formatted_product [ns_adp_parse -string $template]
