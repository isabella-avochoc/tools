#!/bin/bash
#--------------------------------------------------------------------------------
# This will output the SQL needed to delete an order.
# Read the instructions. Please.
#--------------------------------------------------------------------------------

#-- prompt ----------------------------------------------------------------------
proceed() {

  printf "\nContinue? [y/n]: "
  read goOn
  echo
  onward=$(echo $goOn | awk '{print tolower($0)}')
  if [[ ${onward} != "y" ]] ; then
    echo "Stopping here..."
    exit
  fi
  echo
}

#--------------------------------------------------------------------------------
# -- main
#--------------------------------------------------------------------------------

printf "\nEnter a comma separated list of order numbers: "
read orders
echo

# -- checking for payments:
# ------------------------

printf "[33m\nselect * from payment where order_id in (select id from order_table where order_number in (${orders}));\n\n[0m"
printf "\nContinue only if there are no payment records!!\n"
proceed

# -- checking Axians updates:
# ---------------------------

printf "[33m\nselect o.axians_case_id, o.id, o.order_number, o.customer_id, o.sales_person_id from order_table o, customer c, salesperson s where o.order_number in (${orders}) and o.customer_id = c.id and o.sales_person_id = s.id\n\n[0m"
printf "\nTake note of the Axians case IDs.\n\
  Axians Case ID with matching  order numbers (B-000001) must be sent to Dean or Michael\n\
  so that they can notify Axians to delete the orders on their side.\n"
proceed

# -- backup data statements:
# --------------------------

printf "Giving you the SQL and opportunity to save the CSV output in a file before you destroy the data...\n\n"
sleep 1
printf "[33m\n\\copy (select * from order_table where order_number in (${orders})) TO STDOUT WITH (DELIMITER ',', FORMAT CSV, HEADER);\n\n"
printf "\n\\copy (select * from payment where order_id in (select id from order_table where order_number in (${orders}))) TO STDOUT WITH (DELIMITER ',', FORMAT CSV, HEADER);\n\n"
printf "\n\\copy (select * from order_product where order_id in (select id from order_table where order_number in (${orders}))) TO STDOUT WITH (DELIMITER ',', FORMAT CSV, HEADER);\n\n"
printf "\n\\copy (select * from contract where order_id in (select id from order_table where order_number in (${orders}))) TO STDOUT WITH (DELIMITER ',', FORMAT CSV, HEADER);\n\n"
printf "\n\\copy (select * from order_state_tracking where order_id in (select id from order_table where order_number in (${orders}))) TO STDOUT WITH (DELIMITER ',', FORMAT CSV, HEADER);\n\n"
printf "\n\\copy (select * from customer where id in (select customer_id from order_table where order_number in (${orders}))) TO STDOUT WITH (DELIMITER ',', FORMAT CSV, HEADER);\n\n[0m"
proceed

# -- SQL delete statements:
# -------------------------
printf "Do you want the delete statements?\n \
  Double check before you execute.\n \
  Disclaimer: this is a blunt instrument and the deleted data is still your responsibility!\n"
proceed
printf "[33m\ndelete from order_product where order_id in (select id from order_table where order_number in (${orders}))\n\n"
printf "delete from contract where order_id in (select id from order_table where order_number in (${orders}))\n\n"
printf "delete from order_state_tracking where order_id in (select id from order_table where order_number in (${orders}))\n\n[0m"
# -- jot down the customer numbers
printf "\n\nCopy each customer ID before the order table records are deleted!\n\n\n"
printf "[33mselect customer_id from order_table where order_number in (${orders})\n\n"
printf "select * from customer where id in (...IDs you copied...)\n\n\n[0m"
proceed
printf "[33mdelete from order_table where order_number in (${orders})\n\n"
printf "delete from customer where id in (...)\n\n[0m"
printf "\nYou are done.\n\
  Hopefully you did not break something. Good day.\n\n"
