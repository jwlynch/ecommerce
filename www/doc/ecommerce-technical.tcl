ad_page_contract {

    Technical documentation of the ecommerce package, a package to implement
    business-to-consumer web services.

    @author Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @creation-date May 2002

} {
} -properties {
    title:onevalue
    context_bar:onevalue
}

# Authenticate the user

set user_id [ad_maybe_redirect_for_registration]

# Check for read privileges

set package_id [ad_conn package_id]
set admin_p [ad_permission_p $package_id read]

set package_name "Ecommerce"
set title "$package_name Documentation: Technical details"
set package_url [apm_package_url_from_key "ecommerce"]

set shipping_gateway_installed [apm_package_installed_p "shipping-gateway"]
set payment_gateway_installed [apm_package_installed_p "payment-gateway"]
set authorize_gateway_installed [apm_package_installed_p "authorize-gateway"]
set payflowpro_gateway_installed [apm_package_installed_p "payflowpro"]

# Set the context bar.

set context_bar [ad_context_bar [list "." "$package_name Documentation"] "Technical details"]

# Set signatory for at the bottom of the page

set signatory "bart.teeuwisse@7-sisters.com"
