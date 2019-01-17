###################################################################################################################################
#Program Copyright, 2019, Mark J. Lamias, The Stochastic Group, Inc.
#Data is Copyrighted by Palo Alto Networks
#
#About this Program:  Use these key-value pair to modify the http hearder information used when accessing urls
###################################################################################################################################

headers<-c(
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
  "X-Requested-With" = "XMLHttpRequest")