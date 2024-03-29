# Load Packages
library(dplyr)
library(ggplot2)
library(tidyverse)
library(RSQLite)
library(lubridate)

# Read Data file
## Read advertisements file
advertisement_list <- list()
for (ads in list.files(path = "data_uploads/", pattern = "advertisement", full.names = TRUE)) {
  advertisements_ind <- read.csv(ads)
  advertisement_list[[length(advertisement_list) + 1]] <- advertisements_ind
}
advertisements_file <- bind_rows(advertisement_list)

## Read advertisers file
advertisers_list <- list()
for (adv in list.files(path = "data_uploads/", pattern = "advertiser", full.names = TRUE)) {
  advertisers_ind <- read.csv(adv)
  advertisers_list[[length(advertisers_list) + 1]] <- advertisers_ind
}
advertisers_file <- bind_rows(advertisers_list)

## Read categories file
categories_list <- list()
for (cat in list.files(path = "data_uploads/", pattern = "categories", full.names = TRUE)) {
  categories_ind <- read.csv(cat)
  categories_list[[length(categories_list) + 1]] <- categories_ind
}
categories_file <- bind_rows(categories_list)

## Read customer_queries file
customer_queries_list <- list()
for (cat in list.files(path = "data_uploads/", pattern = "customer_queries", full.names = TRUE)) {
  customer_queries_ind <- read.csv(cat)
  customer_queries_list[[length(customer_queries_list) + 1]] <- customer_queries_ind
}
customer_queries_file <- bind_rows(customer_queries_list)

## Read customers file
customers_list <- list()
for (cust in list.files(path = "data_uploads/", pattern = "customers", full.names = TRUE)) {
  customers_ind <- read.csv(cust)
  customers_list[[length(customers_list) + 1]] <- customers_ind
}
customers_file <- bind_rows(customers_list)

## Read memberships file
memberships_list <- list()
for (memb in list.files(path = "data_uploads/", pattern = "membership", full.names = TRUE)) {
  memberships_ind <- read.csv(memb)
  memberships_list[[length(memberships_list) + 1]] <- memberships_ind
}
memberships_file <- bind_rows(memberships_list)

## Read orders file
orders_list <- list()
for (orders in list.files(path = "data_uploads/", pattern = "order", full.names = TRUE)) {
  orders_ind <- read.csv(orders)
  orders_list[[length(orders_list) + 1]] <- orders_ind
}
orders_file <- bind_rows(orders_list)

## Read payments file
payments_list <- list()
for (payments in list.files(path = "data_uploads/", pattern = "payment", full.names = TRUE)) {
  payments_ind <- read.csv(payments)
  payments_list[[length(payments_list) + 1]] <- payments_ind
}
payments_file <- bind_rows(payments_list)

## Read products file
products_list <- list()
for (products in list.files(path = "data_uploads/", pattern = "product", full.names = TRUE)) {
  products_ind <- read.csv(products)
  products_list[[length(products_list) + 1]] <- products_ind
}
products_file <- bind_rows(products_list)

## Read shipments file
shipments_list <- list()
for (shipments in list.files(path = "data_uploads/", pattern = "shipment", full.names = TRUE)) {
  shipments_ind <- read.csv(shipments)
  shipments_list[[length(shipments_list) + 1]] <- shipments_ind
}
shipments_file <- bind_rows(shipments_list)

## Read suppliers file
suppliers_list <- list()
for (suppliers in list.files(path = "data_uploads/", pattern = "suppliers", full.names = TRUE)) {
  suppliers_ind <- read.csv(suppliers)
  suppliers_list[[length(suppliers_list) + 1]] <- suppliers_ind
}
suppliers_file <- bind_rows(suppliers_list)

## Read supplies file
supplies_list <- list()
for (supplies in list.files(path = "data_uploads/", pattern = "supply", full.names = TRUE)) {
  supplies_ind <- read.csv(supplies)
  supplies_list[[length(supplies_list) + 1]] <- supplies_ind
}
supplies_file <- bind_rows(supplies_list)

# Normalising the Table into 3NF

##Normalising Products Table
products_table <- products_file %>%
  select(prod_id,prod_name,prod_desc,prod_unit_price,voucher,prod_url)

##Normalising Reviews Table
reviews_table <- products_file %>%
  select(review_id,prod_id, prod_rating, review_date)

##Normalising Memberships Table
memberships_table <- memberships_file %>%
  select(membership_type_id,membership_type)
memberships_table <- memberships_table[!duplicated(memberships_table$membership_type_id),]

##Normalising Customers Table
customers_table <- customers_file %>%
  select(cust_id, first_name, last_name, cust_email,password, cust_birth_date, block_num, postcode, address_type,cust_telephone)
customers_table <- merge(customers_table,memberships_file, by = "cust_id")
customers_table$X <- NULL
customers_table$membership_type <- NULL

##Normalising Orders Table
orders_table <- orders_file %>%
  select(order_id, cust_id)
orders_table <- orders_table[!duplicated(orders_table$order_id),]

##Normalising Order details Table
order_details_table <- orders_file %>%
  select(order_id,prod_id, order_quantity, order_date, order_value, order_price) 

##Normalising Payments Table
payments_table <- payments_file %>%
  select(payment_id,order_id,payment_amount,payment_method,payment_status,payment_date)

##Normalising Shipments Table
shipments_table <- shipments_file %>%
  select(shipment_id, order_id, prod_id, delivery_departed_date, delivery_received_date,est_delivery_date,shipper_name, delivery_recipient, delivery_fee,delivery_status)

##Normalising Suppliers Table
suppliers_table <- suppliers_file %>%
  select(supplier_id, supplier_name, supplier_contact, supplier_postcode)

##Normalising Supplies Table
supplies_table <- supplies_file %>%
  select(supply_id,supplier_id,prod_id,inventory_quantity,sold_quantity)

##Normalising Customer Queries Table
customer_queries_table <- customer_queries_file

##Normalising Categories Table
categories_table <- categories_file %>%
  select(category_id,category_name)
categories_table <- categories_table[!duplicated(categories_table$category_id),]

##Normalising Product Categories Table
product_categories_table <- categories_file %>%
  select(prod_id, category_id)

##Normalising Advertiser Table
advertisers_table <- advertisers_file

##Normalising Advertisement Table
advertisements_table <- advertisements_file

# Data Validation

## Advertisement table
### Checking the date format for ads_start_date and ads_end_date
if (all(!inherits(try(as.Date(advertisements_table$ads_start_date, format = "%d-%m-%Y")),"try-error"))) {
  print("Dates are already in the correct format")
} else {
  print("Dates are not in the correct format")
}

if (all(!inherits(try(as.Date(advertisements_table$ads_end_date, format = "%d-%m-%Y")),"try-error"))) {
  print("Dates are already in the correct format")
} else {
  print("Dates are not in the correct format")
}

## Ensuring advertisement end date is after the advertisement start date
for (i in 1:length(as.Date(advertisements_table$ads_start_date, format = "%d-%m-%Y"))) {
  if (as.Date(advertisements_table$ads_end_date, format = "%d-%m-%Y")[i] > as.Date(advertisements_table$ads_start_date, format = "%d-%m-%Y")[i]) {
    print("Ends date happened after the starts date")
  } else {
    print(paste("Error!","Query",i,": ends date happened before the starts date"))
  }
}

### Checking duplicate values for ads_id and prod_id
if(length(advertisements_table$ads_id[duplicated(advertisements_table$ads_id)]) > 0) {
  print("Duplicate ads_ids found")
} else {
  print("No duplicate ads_ids found")
}

if(length(advertisements_table$prod_id[duplicated(advertisements_table$prod_id)]) > 0) {
  print("Duplicate prod_ids found")
} else {
  print("No duplicate prod_ids found")
}

## Advertisers file
### Checking duplicate values for advertiser_id, advertiser_email, and advertisers name

if(length(advertisers_table$advertiser_id[duplicated(advertisers_table$advertiser_id)]) > 0) {
  print("Duplicate advertiser_ids found")
} else {
  print("No duplicate advertiser_ids found")
}

if(length(advertisers_table$advertiser_email[duplicated(advertisers_table$advertiser_email)]) > 0) {
  print("Duplicate advertisers' emails found")
} else {
  print("No duplicate advertisers' emails found")
}

if(length(advertisers_table$advertiser_name[duplicated(advertisers_table$advertiser_name)]) > 0) {
  print("Duplicate advertisers' names found")
} else {
  print("No duplicate advertisers' names found")
}

## Checking the advertiser_email format
if(length(grep(("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.com$"),advertisers_table$advertiser_email, value = TRUE)) == length(advertisers_table$advertiser_email)) {
  print("All email format are correct")
} else {
  print(paste("There are:", length(advertisers_table$advertiser_email) - length(grep(("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.com$"),advertisers_table$advertiser_email, value = TRUE)),"wrong emails found"))
}

## Customer_queries file
### Checking duplicate values for query_id

if(length(customer_queries_table$query_id[duplicated(customer_queries_table$query_id)]) > 0) {
  print("Duplicate queries_ids found")
} else {
  print("No duplicate queries_ids found")
}

### Checking the date format for query_submission_date and query_closure_date
correct_date_format <- function(date_column) {
  converted_dates <- try(as.Date(date_column, format = "%d-%m-%Y"), silent = TRUE)
  if (inherits(converted_dates, "try-error")) {
    return(format(mdy(date_column), "%d-%m-%Y"))
  } else {
    return(date_column)
  }
}
customer_queries_table$query_submission_date <- correct_date_format(customer_queries_table$query_submission_date)
customer_queries_table$query_closure_date <- correct_date_format(customer_queries_table$query_closure_date)

if (all(!inherits(try(as.Date(customer_queries_table$query_submission_date, format = "%d-%m-%Y")), "try-error"))) {
  print("Query Submission Dates are now in the correct format")
} else {
  print("There was an issue with converting the Query Submission Dates")
}

if (all(!inherits(try(as.Date(customer_queries_table$query_closure_date, format = "%d-%m-%Y")), "try-error"))) {
  print("Query Closure Dates are now in the correct format")
} else {
  print("There was an issue with converting the Query Closure Dates")
}

## Memberships file
### Checking NA values inside membership_id and membership_type
if (any(!is.na(memberships_table))) {
  print("There are no NA values in the dataset")
} else {
  print("Error! There are NA values in the dataset")
}

## Orders file
### Checking NA values inside order_id, cust_id, order_quantity, order_price, prod_id
if (any(!is.na(order_details_table[,c("order_id", "order_quantity", "order_price", "prod_id")]))) {
  print("There are no NA values in the dataset")
} else {
  print("Error! There are NA values in the dataset")
}

### Checking date format for the order_date
correct_date_format <- function(date_column) {
  converted_dates <- try(as.Date(date_column, format = "%d-%m-%Y"), silent = TRUE)
  if (inherits(converted_dates, "try-error")) {
    return(format(mdy(date_column), "%d-%m-%Y"))
  } else {
    return(date_column)
  }
}
order_details_table$order_date <- correct_date_format(order_details_table$order_date)

# Print a message based on the result
if (all(!inherits(try(as.Date(order_details_table$order_date, format = "%d-%m-%Y")), "try-error"))) {
  print("Dates are now in the correct format")
} else {
  print("There was an issue with converting the dates")
}
## Payment_file
### Checking NA values inside payment_id, payment_method, payment_status, and order_id 
if (any(!is.na(payments_table[,c("payment_id", "payment_method", "payment_status", "order_id")]))) {
  print("There are no NA values in the dataset")
} else {
  print("Error! There are NA values in the dataset")
}

### Checking date format for the payment_date
if (all(!inherits(try(as.Date(payments_table$payment_date, format = "%d-%m-%Y")),"try-error"))) {
  print("Dates are already in the correct format")
} else {
  print("Dates are not in the correct format")
}

## Products_file
### Checking duplicate values in prod_id and review_id
if(length(products_table$prod_id[duplicated(products_table$prod_id)]) == 0) {
  print("No duplicate prod_ids found")
} else {
  print("Duplicate ad_ids found")
}

if(length(reviews_table$review_id[duplicated(reviews_table$review_id)]) == 0) {
  print("No duplicate review_ids found")
} else {
  print("Duplicate review_ids found")
}

### Checking NA values inside prod_id, prod_url, prod_unit_price
if (any(!is.na(products_table[,c("prod_id", "prod_url", "prod_unit_price")]))) {
  print("There are no NA values in the dataset")
} else {
  print("Error! There are NA values in the dataset")
}

### Checking date format for the review_date
check_and_correct_date_format <- function(date_column_data) {
  if (all(!inherits(try(as.Date(date_column_data, format = "%d-%m-%Y")), "try-error"))) {
    return(date_column_data) 
  } else {
    return(format(mdy(date_column_data), "%d-%m-%Y"))
  }
}
reviews_table$review_date <- check_and_correct_date_format(reviews_table$review_date)
if (all(!inherits(try(as.Date(reviews_table$review_date, format = "%d-%m-%Y")), "try-error"))) {
  print("Review Dates are now in the correct format")
} else {
  print("There was an issue with converting the Review Dates")
}

### Checking the URL format of the prod_url
if(length(grep(("^(http|https)://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}(\\S*)$"),products_table$prod_url, value = TRUE)) == length(products_table$prod_url)) {
  print("All product url format are correct")
} else {
  print(paste("There are:", length(products_table$prod_url) - length(grep(("^(http|https)://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}(\\S*)$"),products_table$prod_url, value = TRUE)),"wrong product urls found"))
}

## Shipments file 
### Checking duplicate values in shipment_id
if(length(shipments_table$shipment_id[duplicated(shipments_table$shipment_id)]) == 0) {
  print("No duplicate shipment_ids found")
} else {
  print("Duplicate shipment_ids found")
}

### Checking NA values inside shipment_id, prod_id, order_id
if (any(!is.na(shipments_table[,c("prod_id", "order_id", "shipment_id")]))) {
  print("There are no NA values in the dataset")
} else {
  print("Error! There are NA values in the dataset")
}

### Checking date format for the delivery_departed_date, delivery_received_date, est_delivery_date
check_and_correct_date_format <- function(date_column_data) {
  if (all(!inherits(try(as.Date(date_column_data, format = "%d-%m-%Y")), "try-error"))) {
    return(date_column_data)  # Return the original data if format is correct
  } else {
    # Correcting the format assuming the original format is mm-dd-yyyy, adjust as necessary
    return(format(mdy(date_column_data), "%d-%m-%Y"))
  }
}

shipments_table$delivery_departed_date <- check_and_correct_date_format(shipments_table$delivery_departed_date)
shipments_table$delivery_received_date <- check_and_correct_date_format(shipments_table$delivery_received_date)
shipments_table$est_delivery_date <- check_and_correct_date_format(shipments_table$est_delivery_date)

columns_to_check <- list(
  "Delivery Departed Date" = shipments_table$delivery_departed_date,
  "Delivery Received Date" = shipments_table$delivery_received_date,
  "Estimated Delivery Date" = shipments_table$est_delivery_date
)

for (column_name in names(columns_to_check)) {
  if (all(!inherits(try(as.Date(columns_to_check[[column_name]], format = "%d-%m-%Y")), "try-error"))) {
    print(paste(column_name, "are now in the correct format"))
  } else {
    print(paste("There was an issue with converting the", column_name))
  }
}

### Checking whether the recipient names contains ' and ,
if (any(grepl("[',]",shipments_table$delivery_recipient))) {
  print("Error! Some names contain invalid characters")
} else {
  print("All names are valid")
}

## Customer Table
### Checking duplicate values in customer_id
if(length(customers_table$cust_id[duplicated(customers_table$cust_id)]) == 0) {
  print("No duplicate customer_ids found")
} else {
  print("Duplicate customer_ids found")
}

### Checking whether the customer's first name and last name contains ' and ,
clean_name <- function(name) {
  gsub("['\",]", "-", name)
}

if (any(grepl("[',]", customers_table$first_name))) {
  print("Error! Some first names contain invalid characters")
  customers_table$first_name <- sapply(customers_table$first_name, clean_name)
} else {
  print("All first names are valid")
}

if (any(grepl("[',]", customers_table$last_name))) {
  print("Error! Some last names contain invalid characters")
  customers_table$last_name <- sapply(customers_table$last_name, clean_name)
} else {
  print("All last names are valid")
}


### Checking the customer_email format
if(length(grep(("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.com$"),customers_table$cust_email, value = TRUE)) == length(customers_table$cust_email)) {
  print("All customer email format are correct")
} else {
  print(paste("There are:", length(customers_table$cust_email) - length(grep(("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.com$"),customers_table$cust_email, value = TRUE)),"wrong emails found"))
}

### Checking the customer birth_date format
if (all(!inherits(try(as.Date(customers_table$cust_birth_date, format = "%d-%m-%Y")),"try-error"))) {
  print("Dates are already in the correct format")
} else {
  print("Dates are not in the correct format")
}


# Create connection to SQL database
db_connection <- RSQLite::dbConnect(RSQLite::SQLite(),"IB9HP0_9.db")

# Inserting Dataframe into the sql database
write_log <- function(message, path) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  message <- paste(timestamp, message, sep=" - ")
  write(message, file = path, append = TRUE, sep = "\n")
}

# Path for the error log file
log_file_path <- "error_log.txt"

## Inserting Products table
for(i in 1:nrow(products_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO products(prod_id, prod_name, prod_desc, voucher, prod_url, prod_unit_price) VALUES('",
      products_table$prod_id[i], "','",
      products_table$prod_name[i], "','",
      products_table$prod_desc[i], "','",
      products_table$voucher[i], "','",
      products_table$prod_url[i], "',",
      products_table$prod_unit_price[i], ");", sep = "")
    )
    write_log(sprintf("Product %s inserted successfully.", products_table$prod_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert product %s: %s", products_table$prod_id[i], e$message), log_file_path)
  })
}

## Inserting Reviews table
for(i in 1:nrow(reviews_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO reviews(review_id, prod_rating, review_date, prod_id) VALUES('",
      reviews_table$review_id[i], "',",
      reviews_table$prod_rating[i], ",'",
      reviews_table$review_date[i], "','",
      reviews_table$prod_id[i], "');", sep = "")
    )
    write_log(sprintf("Review %s inserted successfully.", reviews_table$review_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert review %s: %s", reviews_table$review_id[i], e$message), log_file_path)
  })
}

## Inserting Memberships table
for(i in 1:nrow(memberships_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO memberships(membership_type_id, membership_type) VALUES(",
      "'", memberships_table$membership_type_id[i], "',",
      "'", memberships_table$membership_type[i], "');", sep = "")
    )
    write_log(sprintf("Membership %s inserted successfully.", memberships_table$membership_type_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert membership %s: %s", memberships_table$membership_type_id[i], e$message), log_file_path)
  })
}

## Inserting Customers table
for(i in 1:nrow(customers_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO customers(cust_id, first_name, last_name, cust_email, password, cust_birth_date, address_type, block_num, postcode, cust_telephone, membership_type_id) VALUES(",
      "'", customers_table$cust_id[i], "',",
      "'", customers_table$first_name[i], "',",
      "'", customers_table$last_name[i], "',",
      "'", customers_table$cust_email[i], "',",
      "'", customers_table$password[i], "',",
      "'", customers_table$cust_birth_date[i], "',",
      "'", customers_table$address_type[i], "',",
      "'", customers_table$block_num[i], "',",
      "'", customers_table$postcode[i], "',",
      "'", customers_table$cust_telephone[i], "',",
      "'", customers_table$membership_type_id[i], "');", sep = "")
    )
    write_log(sprintf("Customer %s inserted successfully.", customers_table$cust_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert customer %s: %s", customers_table$cust_id[i], e$message), log_file_path)
  })
}

## Inserting Orders table
for(i in 1:nrow(orders_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO orders(order_id, cust_id) VALUES('",
      orders_table$order_id[i], "','",
      orders_table$cust_id[i], "');", sep = "")
    )
    write_log(sprintf("Order %s inserted successfully.", orders_table$order_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert order %s: %s", orders_table$order_id[i], e$message), log_file_path)
  })
}

## Inserting Payment table
for(i in 1:nrow(payments_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO payments(payment_id, payment_method, payment_amount, payment_status, payment_date, order_id) VALUES(",
      "'", payments_table$payment_id[i], "',",
      "'", payments_table$payment_method[i], "',",
      payments_table$payment_amount[i], ",",
      "'", payments_table$payment_status[i], "',",
      "'", payments_table$payment_date[i], "',",
      "'", payments_table$order_id[i], "');",sep = "") 
    )
    write_log(sprintf("Payment %s inserted successfully.", payments_table$payment_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert payment %s: %s", payments_table$payment_id[i], e$message), log_file_path)
  })
}

## Inserting Shipment table
for(i in 1:nrow(shipments_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO shipments(shipment_id, delivery_status, delivery_fee, delivery_recipient, shipper_name, est_delivery_date, delivery_departed_date, delivery_received_date
, prod_id, order_id) VALUES(",
      "'", shipments_table$shipment_id[i], "',",
      "'", shipments_table$delivery_status[i], "',",
      shipments_table$delivery_fee[i], ",",
      "'", shipments_table$delivery_recipient[i], "',",
      "'", shipments_table$shipper_name[i], "',",
      "'", format(as.Date(shipments_table$est_delivery_date[i], format = "%d-%m-%Y"), "%Y-%m-%d"), "',",
      "'", format(as.Date(shipments_table$delivery_departed_date[i], format = "%d-%m-%Y"), "%Y-%m-%d"), "',",
      "'", format(as.Date(shipments_table$delivery_received_date[i], format = "%d-%m-%Y"), "%Y-%m-%d"), "',",
      "'", shipments_table$prod_id[i], "',",
      "'", shipments_table$order_id[i], "');", sep = "")
    )
    write_log(sprintf("Shipment %s inserted successfully.", shipments_table$shipment_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert shipment %s: %s", shipments_table$shipment_id[i], e$message), log_file_path)
  })
}

## Inserting Order details table
for(i in 1:nrow(order_details_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO order_details(order_quantity,order_date,order_price,order_value,prod_id,order_id) VALUES(",
      order_details_table$order_quantity[i], ",",
      "'", order_details_table$order_date[i], "',",
      order_details_table$order_price[i], ",",
      order_details_table$order_value[i], ",",
      "'", order_details_table$prod_id[i], "',",
      "'", order_details_table$order_id[i], "');",sep = "") 
    )
    
    write_log(sprintf("Order detail %s inserted successfully.", order_details_table$order_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert order detail %s: %s", order_details_table$order_id[i], e$message), log_file_path)
  })
}

## Inserting Suppliers table
for(i in 1:nrow(suppliers_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO suppliers(supplier_id, supplier_name, supplier_postcode, supplier_contact) VALUES('",
      suppliers_table$supplier_id[i], "','",
      suppliers_table$supplier_name[i], "','",
      suppliers_table$supplier_postcode[i], "','",
      suppliers_table$supplier_contact[i], "');", sep = "")
    )
    write_log(sprintf("Supplier %s inserted successfully.", suppliers_table$supplier_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert supplier %s: %s", suppliers_table$supplier_id[i], e$message), log_file_path)
  })
}


## Inserting Supplies table
for(i in 1:nrow(supplies_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO supplies(supply_id, inventory_quantity, sold_quantity, supplier_id, prod_id) VALUES('",
      supplies_table$supply_id[i], "',",
      supplies_table$inventory_quantity[i], ",",
      supplies_table$sold_quantity[i], ",'",
      supplies_table$supplier_id[i], "','",
      supplies_table$prod_id[i], "');", sep = "")
    )
    write_log(sprintf("Supply %s inserted successfully.", supplies_table$supply_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert supply %s: %s", supplies_table$supply_id[i], e$message), log_file_path)
  })
}

## Inserting Customer queries table
for(i in 1:nrow(customer_queries_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO customer_queries(query_id, query_title, query_submission_date, query_closure_date, query_status, cust_id) VALUES(",
      "'", customer_queries_table$query_id[i], "',",
      "'", customer_queries_table$query_title[i], "',",
      "'", customer_queries_table$query_submission_date[i], "',",
      "'", customer_queries_table$query_closure_date[i], "',",
      "'", customer_queries_table$query_status[i], "',",
      "'", customer_queries_table$cust_id[i], "');", sep = "")
    )
    write_log(sprintf("Customer query %s inserted successfully.", customer_queries_table$query_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert customer query %s: %s", customer_queries_table$query_id[i], e$message), log_file_path)
  })
}

## Inserting Categories table
for(i in 1:nrow(categories_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO categories(category_id, category_name) VALUES('",
      categories_table$category_id[i], "','",
      categories_table$category_name[i], "');", sep = "")
    )
    write_log(sprintf("Category %s inserted successfully.", categories_table$category_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert category %s: %s", categories_table$category_id[i], e$message), log_file_path)
  })
}

## Inserting Product Categories table
for(i in 1:nrow(product_categories_table)){
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO product_categories(category_id, prod_id) VALUES('",
      product_categories_table$category_id[i], "','",
      product_categories_table$prod_id[i], "');", sep = "")
    )
    write_log(sprintf("Product category link for product %s and category %s inserted successfully.", product_categories_table$prod_id[i], product_categories_table$category_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert product category link for product %s and category %s: %s", product_categories_table$prod_id[i], product_categories_table$category_id[i], e$message), log_file_path)
  })
}

## Inserting Advertisers table
for(i in 1:nrow(advertisers_table)) {
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO advertisers(advertiser_id, advertiser_name, advertiser_email) VALUES(",
      "'", advertisers_table$advertiser_id[i], "',",
      "'", advertisers_table$advertiser_name[i], "',",
      "'", advertisers_table$advertiser_email[i], "');",sep = "")
    )
    write_log(sprintf("Advertiser %s inserted successfully.", advertisers_table$advertiser_id[i]), log_file_path)
  }, error = function(e) {
    write_log(sprintf("Failed to insert advertiser %s: %s", advertisers_table$advertiser_id[i], e$message), log_file_path)
  })
}

## Inserting Advertisements table
for(i in 1:nrow(advertisements_table)) {
  tryCatch({
    dbExecute(db_connection, paste(
      "INSERT INTO advertisements(ads_id, ads_start_date, ads_end_date, prod_id, advertiser_id) VALUES(",
      "'", advertisements_table$ads_id[i], "',",
      "'", advertisements_table$ads_start_date[i], "',",
      "'", advertisements_table$ads_end_date[i], "',",
      "'", advertisements_table$prod_id[i], "',",
      "'", advertisements_table$advertiser_id[i], "');", sep = "")
    )
    write_log(sprintf("Advertisement %s inserted successfully.", advertisements_table$ads_id[i]), log_file_path)
  }, error = function(e) {
    error_message <- sprintf("Failed to insert advertisement %s: %s", advertisements_table$ads_id[i], e$message)
    write_log(error_message, log_file_path)
  })
}
