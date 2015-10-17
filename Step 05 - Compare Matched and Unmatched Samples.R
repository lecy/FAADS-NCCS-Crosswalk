

### Calculate the rate of successfully matched nonprofit cases in the FAADS data



# setwd( "...your directory here..." )

setwd( "C:/Users/jdlecy/Dropbox/04 - PAPERS/02 - Under Review/02 - Nonprofits and FAADS Data (Thornton)/Matching FAADS to Nonprofit Data" )



### Load FAADS Grant Data

faads <- read.csv( "./Data/Grants_All_2012_complete.csv", colClasses = "character"  )

faads2 <- faads[ faads$recipient_type == "12: Other nonprofit" , ]

faads3 <- faads2[ faads2$recipient_country_code == "USA" | faads2$recipient_country_code == "" , ]


### CLEANING STEP

duns <- faads$duns_no

duns[ duns=="" ] <- NA
duns[ duns=="0000" ] <- NA
duns <- substr( duns, 1, 9 )

head( duns, 20 )


### Load the nonprofits in FAADS that we were able to match to NCCS data

dat <- read.csv( "./Results/Matches1to13615.csv" )

# vector of duns ids of all matched nonprofits 

matched.np <- unique(dat$duns_no)



# Percentage of matched unique cases

length( matched.np  ) / length( unique( faads3$duns_no ) )




# Create a set for matched nonprofits and a set for unmatched

set1 <- faads3[ faads3$duns_no %in% matched.np  , ]

set2 <- faads3[ !faads3$duns_no %in% matched.np  , ]



# Total grants that are matched (one grant per row)

nrow( set1 ) / nrow( faads3 )

nrow( set2 ) / nrow( faads3 )




# Test for difference in grant amounts

t.test( as.numeric(set1$total_funding_amount), as.numeric(set2$total_funding_amount) )

grants1 <- as.numeric(set1$total_funding_amount)
grants1[ grants1 < 0 ] <- NA

grants2 <- as.numeric(set2$total_funding_amount)
grants2[ grants2 < 0 ] <- NA

t.test( grants1, grants2 )


# Can compare on different characteristics as well...

recipient_city_code





place <- data.frame( state=c(set1$principal_place_state_code, set2$principal_place_state_code), 
                 match=c( rep("Matched",nrow(set1)) , rep("Unmatched",nrow(set2)) ) )

table.place <- table( place$state, place$match )

chisq.test( table.place, simulate.p.value = TRUE )

#         Pearson's Chi-squared test with simulated p-value (based on 2000 replicates)
# 
# data:  table.place
# X-squared = 591.4688, df = NA, p-value = 0.0004998




table( faads$agency_name )

agency <- data.frame( agency.name=c(set1$agency_name, set2$agency_name), 
                 match=c( rep("Matched",nrow(set1)) , rep("Unmatched",nrow(set2)) ) )

table.agency <- table( agency$agency.name, agency$match )
                           
# > chisq.test( table.agency, simulate.p.value = TRUE )
# 
#         Pearson's Chi-squared test with simulated p-value (based on 2000 replicates)
# 
# data:  table.agency
# X-squared = 1968.096, df = NA, p-value = 0.0004998



sum( faads3$total_funding_amount < 0 ) / length( faads3$total_funding_amount )

sum( set1$total_funding_amount < 0 ) / length( faads3$total_funding_amount )

sum( set2$total_funding_amount < 0 ) / length( faads3$total_funding_amount )

# none at zero

sum( faads3$total_funding_amount == 0 ) / length( faads3$total_funding_amount )


