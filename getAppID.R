###################################################################################################################################
#Program Copyright, 2019, Mark J. Lamias, The Stochastic Group, Inc.
#Data is Copyrighted by Palo Alto Networks
#
#Terms of Service
#Please read and understand the Palo Alto License and Terms of Service (ToS) of the applipedia website prior to use.
#You may read the ToS here in its entirety here:  https://www.paloaltonetworks.com/legal-notices/terms-of-use.
#Users Require Palo Alto License Prior to Use under Palo Alto Networks Terms of Service which reads.
#
#About this Program:  This program is just a function that takes character input and cleans up the text by stripping
#unwanted characters from the input.  
#
#Inputs/Global Variables Set by User:  The input is a character list of length 3. 
#
#Outputs:  The function returns a single list of cleaned character data received from the input
#
###################################################################################################################################

getAppID <- function(x){
  x[1]<-noquote(gsub("[a-zA-Z]|\\(|'", "", x[1]))
  x[2]<-noquote(gsub("\'| '", "", x[2]))
  x[3]<-noquote(gsub("[a-zA-Z]|\\(|'|;|\\)", "", x[3]))
  x[3]<-noquote(gsub("[a-zA-Z;)\' ]", "", x[3]))
  x
}