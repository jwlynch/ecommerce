#  www/[ec_url_concat [ec_url] /admin]/orders/creditcard-add-2.tcl
ad_page_contract {
  Credit card confirm.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id creditcard-add-2.tcl,v 3.1.6.2 2000/08/16 18:49:04 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
  creditcard_number
  creditcard_type
  creditcard_expire_1
  creditcard_expire_2
  billing_zip_code
}

ad_require_permission [ad_conn package_id] admin

# get rid of spaces and dashes
regsub -all -- "-" $creditcard_number "" creditcard_number
regsub -all " " $creditcard_number "" creditcard_number

# error checking
set exception_count 0
set exception_text ""

if { [regexp {[^0-9]} $creditcard_number] } {
    # I've already removed spaces and dashes, so only numbers should remain
    incr exception_count
    append exception_text "<li> Your credit card number contains invalid characters."
}

if { ![info exists creditcard_type] || [empty_string_p $creditcard_type] } {
    incr exception_count
    append exception_text "<li> You forgot to enter your credit card type."
}

# make sure the credit card type is right & that it has the right number
# of digits
set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type]

set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
append exception_text [lindex $additional_count_and_text 1]

if { ![info exists creditcard_expire_1] || [empty_string_p $creditcard_expire_1] || ![info exists creditcard_expire_2] || [empty_string_p $creditcard_expire_2] } {
    incr exception_count
    append exception_text "<li> Please enter your full credit card expiration date (month and year)"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

doc_body_append "[ad_admin_header "Confirm Credit Card"]

<h2>Confirm Credit Card</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "Confirm Credit Card"]

<hr>
Please confirm that this is correct:

<blockquote>
<pre>
[ec_pretty_creditcard_type $creditcard_type]
$creditcard_number
exp: $creditcard_expire_1/$creditcard_expire_2
zip: $billing_zip_code
</pre>
</blockquote>

<form method=post action=creditcard-add-3>
[export_entire_form]

<center>
<input type=submit value=\"Confirm\">
</center>

[ad_admin_footer]
"
