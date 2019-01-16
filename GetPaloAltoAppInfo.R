###################################################################################################################################
#Program Copyright, 2019, Mark Lamias
#Data is Copyrighted by Palo Alto Networks
#
#Terms of Service
#Please read and understand the Palo Alto License and Terms of Service (ToS) of the applipedia website prior to use.
#You may read the ToS here in its entirety here:  https://www.paloaltonetworks.com/legal-notices/terms-of-use.
#Users Require Palo Alto License Prior to Use under Palo Alto Networks Terms of Service which reads:
#Palo Alto Networks hereby grants you a license under its and other applicable copyrights to (1) download 
#one copy of the information or software ("Materials") found on the Site on to a single computer solely for 
#your personal, non-commercial internal use in support of the use or marketing of Palo Alto Networks products or, 
#(2) if you have a pre-existing business relationship with Palo Alto Networks, you may download Materials for use 
#in the furtherance of, and subject to the terms and conditions of, the provisions of your separate written agreement 
#with Palo Alto Networks. 
#
#About this Program:  This program fetches a complete list of applipedia application names and app ids from 
#https://applipedia.paloaltonetworks.com/ and then displays retrieves detailed information associated with each app by
#"clicking" each app name link and downloading the details.  Information is dumped to a CSV file and alternatively uploaded
#to a google sheets document as provided in ToS.
#
#
#Inputs/Global Variables Set by User:  
#CSV_FILE_NAME:  Name of the CSV file that is temporarily created in the R working Directory Prior to upload to Google Sheets
#GSHEET_TITLE:  The Google Sheets Title
#GSHEET_WSHEET_TITLE:  The Google Sheets Worksheet Title
#WEBSITE_DETAIL_URL:  The Detail Summary page called by the App Summary Page
#WEBSITE_SUMMARY_URL:  The Main Application Web Page that is Publicly Viewable.

#Set the number of rows you want to limit.  This will select the top N rows from the main Palo Alto webpage.
###################################################################################################################################
#gs_ls() #Uncomment and Run the first time you want to do use this program
#N<-50000

#Set Global Options
CSV_FILE_NAME<-"PaloAltoDetails.csv"
GSHEET_TITLE<-"Palo Alto Firewall"
GSHEET_WSHEET_TITLE<-"Firewall Ports"
WEBSITE_DETAIL_URL<-"https://applipedia.paloaltonetworks.com/Home/GetApplicationDetailView"
WEBSITE_SUMMARY_URL<-"https://applipedia.paloaltonetworks.com/Home/GetApplicationListView"

library(googlesheets)
library(httr)
library(XML)
library(xml2)
library(rvest)

#Parse MainPage Data to obtain parameters passed to getDetails Function (i.e. the pop-up window)
GetAppID <- function(x){
  x[1]<-noquote(gsub("[a-zA-Z]|\\(|'", "", x[1]))
  x[2]<-noquote(gsub("\'| '", "", x[2]))
  x[3]<-noquote(gsub("[a-zA-Z]|\\(|'|;|\\)", "", x[3]))
  x[3]<-noquote(gsub("[a-zA-Z;)\' ]", "", x[3]))
  x
}

#Get Application Detail information from the pop-up window
getDetails<-function(parameters){
  
  details_i<-POST(WEBSITE_DETAIL_URL, 
                  add_headers(
                    "Accept" = "*/*",
                    "DNT" = "1",
                    "Connection" = "keep-alive",            
                    "Content-Type" = "application/x-www-form-urlencoded",
                    "Accept-Language" = "en-US,en;q=0.9",
                    "Content-Type" = "application/x-www-form-urlencoded",
                    "Accept-Encoding" = "gzip, deflate, br",
                    "Host" = "applipedia.paloaltonetworks.com",
                    "Origin" = "https://applipedia.paloaltonetworks.com",
                    "Referer" = "https://applipedia.paloaltonetworks.com/",
                    "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
                    "X-Requested-With" = "XMLHttpRequest"   
                  ),
                  query = as.list(parameters),
                  verbose()
  )
  
  description<-html_node(read_html(details_i), "table") %>% html_node("div") %>% html_text()
  description<-gsub("[\r\n\t]", "", description)
  names(description)<-"Description"
  
  
  #If length > 1 then this is a detail row, not a grouping row
  if (length(readHTMLTable(htmlParse(details_i), stringsAsFactors=FALSE)) > 1) {
    
    details_j<-readHTMLTable(htmlParse(details_i), stringsAsFactors=FALSE)[[2]]
    risk<-html_node(read_html(details_i), "tr~ tr+ tr .charvalue") %>% html_node("img") %>% html_attr("title")
    details_j$V2[3]<-risk
    col2info<-details_j$V2[1:5]
    names(col2info)<-details_j$V1[1:5]
    col4info<-details_j$V4
    names(col4info)<-details_j$V3
  } else   #This happens when it's a grouping row
  {
    col2info<-rep("------------", 5)
    names(col2info)<-c("Category", "Subcategory", "Risk", "Standard Ports", "Technology")
    col4info<-rep("---", 9)
    names(col4info)<-c("Evasive", "Excessive Bandwidth", "Prone to Misuse", "Capable of File Transfer", "Tunnels Other Applications", "Used by Malware", "Has Known Vulnerabilities", "Widely Used", "SaaS")
  }
  
  paste(gsub("[\r\n\t]", "", as.character(description)))
  collinfo<-data.frame((c(parameters, col2info, col4info, description)), stringsAsFactors = FALSE)
  
  #Cleanup
  if (exists("details_i")) {rm("details_i")}
  if (exists("details_j")) {rm("details_j")}
  
  #Indent for appearance.  This can be removed later if desired.
  if (collinfo[3]==2) {
    collinfo[,2]<-paste("  ", collinfo[,2], sep="")
  }
  collinfo
  
}

#######################BEGIN MAIN Program Execution#######################

#Get Application Names and IDs from the main Page.
main_page_raw<-POST(WEBSITE_SUMMARY_URL, 
                    add_headers(
                      "Accept" = "*/*",
                      "DNT" = "1",
                      "Connection" = "keep-alive",            
                      "Content-Type" = "application/x-www-form-urlencoded",
                      "Accept-Language" = "en-US,en;q=0.9",
                      "Content-Type" = "application/x-www-form-urlencoded",
                      "Accept-Encoding" = "gzip, deflate, br",
                      "Host" = "applipedia.paloaltonetworks.com",
                      "Origin" = "https://applipedia.paloaltonetworks.com",
                      "Referer" = "https://applipedia.paloaltonetworks.com/",
                      "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
                      "X-Requested-With" = "XMLHttpRequest"   
                    ),
                    verbose()
)


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

allDetails <-lapply(1:numrows, function(i) getDetails(controlList[i,]))
finalDetails<-bind_rows(allDetails, .id = "order")
names(finalDetails)<-gsub("\\.", " ", names(finalDetails))
names(finalDetails)[1:4]<-c("Order", "ID", "Application Name", "Grouping")


#delete existing google sheet with this name
google_sheet_id<-gs_title(GSHEET_TITLE)
gs_delete(google_sheet_id, verbose = TRUE)

#To to bug in googlesheets, export to csv first
write.csv(finalDetails, CSV_FILE_NAME, row.names=FALSE)

#upload CSV file to Google Sheets
google_sheet_id<-gs_upload(CSV_FILE_NAME, sheet_title=GSHEET_TITLE, overwrite=TRUE)

#print(google_sheet_id)
if (file.exists(CSV_FILE_NAME)) {file.remove(CSV_FILE_NAME)}
print(google_sheet_id)

