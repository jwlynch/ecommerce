#  www/[ec_url_concat [ec_url] /admin]/products/upload-2.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id upload-2.tcl,v 3.1.2.4 2000/10/27 23:17:11 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  csv_file
  csv_file.tmpfile:tmpfile
}

# We need them to be logged in

ad_require_permission [ad_conn package_id] admin
set user_id [ad_get_user_id]
set peeraddr [ns_conn peeraddr]

# Grab package_id as context_id

set context_id [ad_conn package_id]

doc_body_append "[ad_admin_header "Uploading Products"]

<h2>Uploading Products</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Uploading Products"]

<hr>

<blockquote>
"

# Get the name of the transfered CSV file

set unix_file_name ${csv_file.tmpfile}

# Check that the file is readable.

if { ![file readable $unix_file_name] } {
    doc_body_append "Cannot read file $unix_file_name"
    return
}

# Accept only field names that exist in the ec_product table and are
# not set automatically like creation_date.

set legal_field_names {sku product_name one_line_description detailed_description search_keywords price no_shipping_avail_p \
			   shipping shipping_additional weight present_p active_p url template_id stock_status color_list \ 
    			   size_list style_list email_on_purchase_list}

# Check each entry in the CSV for the following required fields.
# These fields are required so that we can check if a product already
# in the products table and should be update rather than created.

set required_field_names {sku product_name}

# Initialize each legal field name as the CSV file might not mention
# each and every one of them.

foreach legal_field_name $legal_field_names {
    set $legal_field_name ""
}

# Start reading.

set csvfp [open $unix_file_name]
set count 0
set errors 0
set success_count 0

# Continue reading the file till the end but stop when an error
# occured.

while { [ns_getcsv $csvfp elements] != -1 && !$errors} {
    incr count
    if { $count == 1 } {

	# First row, grab the field names and their number.

	set field_names $elements
	set number_of_fields [llength $elements]

	# Check the field names against the list of legal names

	foreach field_name $field_names {
	    if {[lsearch -exact $legal_field_names $field_name] == -1} {
		incr errors
		doc_body_append "<p><font color=red>FAILURE!</font> $field_name is not an allowed field name.</p>"
	    }
	}
    } else {

	# Subsequent rows, thus a product

	# Reset the required fields to NULL so that we can later check
	# if the CSV file gave them a value.

	foreach required_field_name $required_field_names {
	    set $required_field_name ""
	}

	# Assign the values in the CSV to the field names.

	for { set i 0 } { $i < $number_of_fields } { incr i } {
	    set [lindex $field_names $i] [lindex $elements $i]
	}

	# Check if all the required fields have been given a value

	foreach required_field_name $required_field_names {
	    if {[set $required_field_name] == ""} {
		incr errors
	    }
	}

	# Create or update the product if all the required fields were
	# given values.

	if {!$errors} {

	    # Check if there is already product with the give sku.
	    # Set product_id to NULL so that ACS picks a unique id if
	    # there no product with the gicen sku.

	    set product_id [db_string product_check {select product_id from ec_products where sku = :sku;} -default ""]
	    if { $product_id != ""} {

		# We found a product_id for the given sku, let's
		# update the product.

		if { [catch {db_dml product_update "
		    update ec_products set
		    user_id = :user_id,
		    product_name = :product_name,
		    price = :price,
		    one_line_description = :one_line_description,
		    detailed_description = :detailed_description,
		    search_keywords = :search_keywords,
		    present_p = :present_p,
		    stock_status = :stock_status,
		    now(),
		    color_list = :color_list,
		    size_list = :size_list,
		    style_list = :style_list,
		    email_on_purchase_list = :email_on_purchase_list,
		    url = :url,
		    no_shipping_avail_p = :no_shipping_avail_p,
		    shipping = :shipping,
		    shipping_additional = :shipping_additional,
		    weight = :weight,
		    active_p = 't',
		    template_id = :template_id
		    where product_id = :product_id;
		"} errmsg] } {
		    doc_body_append "<p><font color=red>FAILURE!</font> Product update of <i>$product_name</i> failed with error:<\p><p>$errmsg</p>"
		} else {
		    doc_body_append "<p>Updated $product_name</p>"
		}
	    } else {

		# Generate a product_id

		set product_id [db_nextval acs_object_id_seq]

		# Dirname will be the first four letters (lowercase)
		# of the product_name followed by the product_id (for
		# uniqueness)
		
		regsub -all {[^a-zA-Z]} $product_name "" letters_in_product_name 
		set letters_in_product_name [string tolower $letters_in_product_name]
		if [catch {set dirname "[string range $letters_in_product_name 0 3]$product_id"}] {
		    #maybe there aren't 4 letters in the product name
		    set dirname "${letters_in_product_name}$product_id"
		}

		# Get the directory where dirname is stored
		set subdirectory "[ec_data_directory][ec_product_directory][ec_product_file_directory $product_id]"
		ec_assert_directory $subdirectory

		set full_dirname "$subdirectory/$dirname"
		ec_assert_directory $full_dirname

		# There is no product with sku :sku so create a new
		# product.

		if { [catch {db_exec_plsql product_insert "
		    select ec_product__new(
		    :product_id,
		    :user_id,
		    :context_id,
		    :product_name,
		    :price,
		    :sku,
		    :one_line_description,
		    :detailed_description,
		    :search_keywords,
		    :present_p,
		    :stock_status,
		    :dirname,
		    now(),
		    :color_list,
		    :size_list,
		    :peeraddr
		)"} errmsg] } {
		    doc_body_append "<font color=red>FAILURE!</font> Product creation of <i>$product_name</i> failed with error:<\p><p>$errmsg</p>"
		} else {
		    doc_body_append "<p>Created $product_name</p>"
		}

	        if { [catch {db_dml product_insert_2 "
		    update ec_products set 
			style_list = :style_list,
		    email_on_purchase_list = :email_on_purchase_list,
		    url = :url,
		    no_shipping_avail_p = :no_shipping_avail_p,
		    shipping = :shipping,
		    shipping_additional = :shipping_additional,
		    weight = :weight,
		    active_p = 't',
		    template_id = :template_id
		    where product_id = :product_id;
		"} errmsg] } {
		    doc_body_append "<font color=red>FAILURE!</font> Product update of new product <i>$product_name</i> failed with error:<\p><p>$errmsg</p>"
		}
	    }

	    # Product line is completed, increase counter

	    incr success_count
	} 
    } 
} 

if { $success_count == 1 } {
    set product_string "product"
} else {
    set product_string "products"
}

doc_body_append "</blockquote>

<p>Successfully loaded $success_count $product_string out of [ec_decode $count "0" "0" [expr $count -1]].

[ad_admin_footer]
"
