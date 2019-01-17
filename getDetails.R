###################################################################################################################################
#Program Copyright, 2019, Mark J. Lamias, The Stochastic Group, Inc.
#Data is Copyrighted by Palo Alto Networks
#
#About getDetails
#About this Program:  This function is meant to be called with a source statement from GetPaloAltoAppInfo.R.
#The function looks up application detail information based on the appID, appname, and "ottowagroup".
#
#
#Inputs/Global Variables Set by User:  
#parameters:  This is a vector of length 3 that contains the appId, appName, and ottawagroup.
###################################################################################################################################
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
  
  #paste(gsub("[\r\n\t]", "", as.character(description)))
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