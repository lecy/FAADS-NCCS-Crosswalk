

#####  Load and clean Federal Assistant Award Data System (FAADS) grant data 

##### 
#####  FAADS Data has been downloaded from http://www.usaspending.gov/data
#####
#####  For help see: https://www.usaspending.gov/references/Pages/FAQs.aspx
#####   

#####  Data Dictionary:
#####
#####  https://www.usaspending.gov/DownloadCenter/Documents/USAspending.govDownloadsDataDictionary.pdf
#####

#####  FAADS 2012 Download page:
#####
#####  https://www.usaspending.gov/DownloadCenter/Pages/dataarchives.aspx
#####
#####  Agency:  ALL
#####  Fiscal Year:  2012
#####  Select the Spending Type:  GRANTS
#####
#####  Link:   2012_All_Grants_Full_20151015.csv.zip
#####



# setwd( "...your directory here..." )



# Load FAADS Data

faads <- read.csv( "./Data/Grants_All_2012_complete.csv", colClasses = "character"  )



# Keep a limited set of variables

faads2 <- faads[ , c("recipient_name", "recipient_city_code", "recipient_city_name",
                    "recipient_county_code", "recipient_county_name" , 
                    "recipient_zip", "recipient_state_code", 
                    "recipient_country_code", "recipient_type",
                    "receip_addr1", "receip_addr2", "receip_addr3", 
                    "duns_no" ) ]

# Extract five-digit zip code

faads2$recipient_zip <- substr( faads2$recipient_zip, start=1, stop=5 )



# Keep all nonprofits located in the US

faads3 <- faads2[ faads2$recipient_type == "12: Other nonprofit" , ]

faads4 <- faads3[ faads3$recipient_country_code == "USA" | faads3$recipient_country_code == "" , ]



nrow( faads2 ) # All orgs in FAADS

nrow( faads3 ) # Only nonprofits

nrow( faads4 ) # Restrict to only US data






# Note that names are used inconsistently because of 
# abbreviations and alternative spellings.
# Use the Duns number to identify unique orgs.

nrow( unique( faads4 ) )

length( unique( faads4$recipient_name ) )  

length( unique( faads4$duns_no ) ) 






# Create a data set with each nonprofit appearing only once

faads5 <- faads4[ !duplicated( faads4$duns_no ), ]  







# Pre-processing steps to simplify text

faads5 <- apply( faads5,  MARGIN=c(1, 2), FUN=tolower )



### The metacharacters for regexpr() are . \ | ( ) [ { ^ $ * + ?
### 
### They are proceeded by double backslashes in pattern matching - see help(regexpr).

# Remove special characters from nonprofit names:

faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\.", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\(", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\)", replacement=""  )

faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="/", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="'", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="&amp", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern=";", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern=",", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="`", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\"", replacement=""  )



# Replacement commonly abbreviated words with their abbreviations

# \\b is an anchor for beginning and end of words (space, punctuation, or end of line).

faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\bstreet\\b", replacement="st"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\bdrive\\b", replacement="dr"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="boulevard", replacement="blvd"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="highway", replacement="hwy"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="plaza", replacement="plz"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\bplace\\b", replacement="pl"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\broad\\b", replacement="rd"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="suite", replacement="ste"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\bnorth\\b", replacement="n"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\bsouth\\b", replacement="s"  )

faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\beast\\b", replacement="e"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\bwest\\b", replacement="w"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="northeast", replacement="ne"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="northwest", replacement="nw"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="southeast", replacement="se"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="southwest", replacement="sw"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\band\\b", replacement="&"  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="\\binc\\b", replacement=""  )
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="#", replacement="num"  )

faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern="  ", replacement=" "  ) # double spaced
faads5 <- apply( faads5, MARGIN=c(1, 2), FUN=gsub, pattern=" $", replacement=""  ) # space at end of line



### Clean up

rm( faads )
rm( faads2 )
rm( faads3 )
rm( faads4 )

