#  www/[ec_url_concat [ec_url] /admin]/products/supporting-files-upload-2.tcl
ad_page_contract {
  Upload a file.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id supporting-files-upload-2.tcl,v 3.2.2.2 2000/07/22 07:57:46 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  upload_file:notnull
  upload_file.tmpfile
}

ad_require_permission [ad_conn package_id] admin

set tmp_filename ${upload_file.tmpfile}

set subdirectory [ec_product_file_directory $product_id]

set dirname [db_string dirname_select "select dirname from ec_products where product_id=:product_id"]
db_release_unused_handles

set full_dirname "[ec_data_directory][ec_product_directory]$subdirectory/$dirname"

if ![regexp {([^//\\]+)$} $upload_file match client_filename] {
    # couldn't find a match
    set client_filename $upload_file
}

set perm_filename "$full_dirname/$client_filename"

ns_cp $tmp_filename $perm_filename

ad_returnredirect "supporting-files-upload.tcl?[export_url_vars product_id]"
