###################################################################################################################################
#Program Copyright, 2019, Mark J. Lamias, The Stochastic Group, Inc.
#Data is Copyrighted by Palo Alto Networks
#
#Terms of Service
#Please read and understand the Palo Alto License and Terms of Service (ToS) of the applipedia website prior to use.
#You may read the ToS here in its entirety here:  https://www.paloaltonetworks.com/legal-notices/terms-of-use.
#Users Require Palo Alto License Prior to Use under Palo Alto Networks Terms of Service which reads.
#
#About this Program:  This program fetches a complete list of applipedia application names and app ids from 
#https://applipedia.paloaltonetworks.com/ and then displays retrieves detailed information associated with each app by
#"clicking" each app name link and downloading the details.  Information is dumped to a CSV file and alternatively uploaded
#to a google sheets document as provided in ToS.
#
#Inputs/Global Variables Set by User:  
#CSV_FILE_NAME:  Name of the CSV file that is temporarily created in the R working Directory Prior to upload to Google Sheets
#GSHEET_TITLE:  The Google Sheets Title
#GSHEET_WSHEET_TITLE:  The Google Sheets Worksheet Title
#WEBSITE_DETAIL_URL:  The Detail Summary page called by the App Summary Page
#WEBSITE_SUMMARY_URL:  The Main Application Web Page that is Publicly Viewable.

#Set the number of rows you want to limit.  This will select the top N rows from the main Palo Alto webpage.
#Then you must set controlList<-main_page_df[1:N,] near line 73 instead of the next line.
#N<-25
###################################################################################################################################
#gs_ls() #Uncomment and Run the first time you want to use this program

#Set Global Options
  CSV_FILE_NAME<-"PaloAltoDetails.csv"
  GSHEET_TITLE<-"Palo Alto Firewall"
  GSHEET_WSHEET_TITLE<-"Firewall Ports"
  WEBSITE_SUMMARY_URL<-"https://applipedia.paloaltonetworks.com/Home/GetApplicationListView"
  WEBSITE_DETAIL_URL<-"https://applipedia.paloaltonetworks.com/Home/GetApplicationDetailView"
  
#Curl URL Request Headers can be configured
  source("headersConfig.R")

#Initialize Libraries
  source("libraryInitialization.R")

#Parse MainPage Data to obtain parameters passed to getDetails Function (i.e. the pop-up window)
  source("getAppID.R")

#Get Application Detail information from the pop-up window
  source("getDetails.R")

#######################BEGIN MAIN Program Execution#######################

#Get Application Names and IDs from the main Page.
  main_page_raw<-POST(WEBSITE_SUMMARY_URL, add_headers(headers), verbose())

#Parse main page data read parsed html and also raw data
  main_page_table<-readHTMLTable(htmlParse(main_page_raw))[[2]]
  main_page_html<-read_html(main_page_raw) 
#navigate down to the javascript that executes the details lookup on-click event from the main page and obtain the parameters for lookup
  main_page_html_rows<-html_nodes(main_page_html, 'td:nth-child(1)') %>% html_nodes('a') %>% html_attr("onclick") %>% strsplit(split=",") 
  
#"loop" through the parameters and clean-up the code to leave only the parameters behind
  main_page_html_rows<-lapply(main_page_html_rows, GetAppID)

#collapse list into dataframe
  main_page_df<-data.frame(do.call(rbind, main_page_html_rows), stringsAsFactors=FALSE)
  names(main_page_df)<-c("id", "appName", "ottawagroup")

#Can edit this to lookup up top N records. Change N at top of program.
#controlList<-main_page_df[1:N,]  #Uncomment if you want the top N rows
  controlList<-main_page_df
#Get Number of Applications to lookup
  numrows<-dim(controlList)[1]

#Get Detailed App Info via repeated URL look-ups  
  allDetails <-lapply(1:numrows, function(i) getDetails(controlList[i,]))

  #Collapse list of lists of detailed info into dataframe and assign names
  finalDetails<-bind_rows(allDetails, .id = "order")
  names(finalDetails)<-gsub("\\.", " ", names(finalDetails))
  names(finalDetails)[1:4]<-c("Order", "ID", "Application Name", "Grouping")

#delete existing google sheet with this name
  google_sheet_id<-gs_title(GSHEET_TITLE)

#Due to bug in googlesheets package, export to csv first
  write.csv(finalDetails, CSV_FILE_NAME, row.names=FALSE)

#upload CSV file to Google Sheets
  google_sheet_id<-gs_upload(CSV_FILE_NAME, sheet_title=GSHEET_TITLE, overwrite=TRUE)

#print(google_sheet_id)
  if (file.exists(CSV_FILE_NAME)) {file.remove(CSV_FILE_NAME)}
  print(google_sheet_id)
  