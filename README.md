# Palo-Alto-Applipedia-App-IDs
R Project Used to Query Detailed Applipedia Application IDs for Palo Alto Firewall Network

# About this Program
This program fetches a complete list of applipedia application names and app ids from 
https://applipedia.paloaltonetworks.com/ and then displays retrieves detailed information associated with each app by
"clicking" each app name link and downloading the details.  Information is dumped to a CSV file and alternatively uploaded
to a google sheets document as provided in ToS.

# Inputs/Global Variables Set by User:  
CSV_FILE_NAME:  Name of the CSV file that is temporarily created in the R working Directory Prior to upload to Google Sheets

GSHEET_TITLE:  The Google Sheets Title

GSHEET_WSHEET_TITLE:  The Google Sheets Worksheet Title

WEBSITE_DETAIL_URL:  The Detail Summary page called by the App Summary Page

WEBSITE_SUMMARY_URL:  The Main Application Web Page that is Publicly Viewable.

# Terms of Service
Please read and understand the Palo Alto License and Terms of Service (ToS) of the applipedia website prior to use.
You may read the ToS here in its entirety here:  https://www.paloaltonetworks.com/legal-notices/terms-of-use.
Users Require Palo Alto License Prior to Use under Palo Alto Networks Terms of Service which reads:
Palo Alto Networks hereby grants you a license under its and other applicable copyrights to (1) download 
one copy of the information or software ("Materials") found on the Site on to a single computer solely for 
your personal, non-commercial internal use in support of the use or marketing of Palo Alto Networks products or, 
(2) if you have a pre-existing business relationship with Palo Alto Networks, you may download Materials for use 
in the furtherance of, and subject to the terms and conditions of, the provisions of your separate written agreement 
with Palo Alto Networks. 
