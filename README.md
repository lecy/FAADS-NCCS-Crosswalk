# FAADS-NCCS-Crosswalk

This directory contains scripts in the R language that provide a crosswalk between the Federal Assistance Award Data System (FAADS) that contains federal grants information, and the National Center for Charitable Statistics (NCCS) Core Data files, which provide IRS financial data on nonprofits.

The FAADS uses the DUNS Number as the organizational ID field, and NCCS uses the EIN as the unique ID. The federal government currently provides no crosswalk between these ID systems, so the datafiles are impossible to merge in a traditional fashion.

We present a method of fuzzy matching in order to create a bridge between the two data sources using the name and location of nonprofits. The methodology is described here:

*Lecy, Jesse D. and Thornton, Jeremy P., What Big Data Can Tell Us About Government Awards to the Nonprofit Sector: Using the FAADS (November 25, 2013).* [Available at SSRN](http://ssrn.com/abstract=2359490 or http://dx.doi.org/10.2139/ssrn.2359490)

The FAADS data can be optained through the usaspending.gov website:

https://www.usaspending.gov/DownloadCenter/Pages/dataarchives.aspx

NCCS data is available through the Urban Institute (but unfortunately is not free):

http://nccs.urban.org/database/overview.cfm

The code to replicate the methodology described in the paper cited above is available in this repository.



# Matching Strategy

The goal of the program is to match nonprofits in the 2012 FAADS grants database to nonprofits in the 2012 NCCS Business Master Files.

To create the cross-walk of EIN to DUNS numbers we deploy a two-tiered strategy. We apply a fuzzy matching algorithm to the nonprofit name fields in the two datasets. This algorithm returns a list of candidates that fall within a range of matches based upon the match distance using the generalized Levenshtein edit distance (the minimal possibly weighted number of insertions, deletions and substitutions needed to transform one string into another).

We then refine the potential matches by comparing the candidates based upon an exact match of the state, city, and zip fields. If two candidates match on at least two of the three geographic fields, they are added to the list of strong matches.

The script in Step 03 will generate three datasets. 

* Strong Matches - names approximately match and at least two geographic fields match exactly
* Weak Matches - names approximately match and only 1 or 0 geographic fields match
* Non-Match - the name does not approximately match with another organization

Note that fuzzy matching is time-intensive. Each nonprofit in the FAADS is compared against over a million possible matches in the NCCS BMF.

Warning - with large datasets it may take up to a week to run!

See an example of the Levenshtein edit distance metric here: http://www.let.rug.nl/~kleiweg/lev/



# Running the Matching Program

If you would like to apply the matching algorithm to your own data (links to FAADS and NCCS data downloads are above), you would need to download and deploy the following R scripts:

## Step 01 - [Cleaning FAADS Data](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/Step%2001%20-%20Load%20and%20Clean%20FAADS%20Data.R)

Pre-processing steps necessary to compare organizational names and geographies such as converting all text to lower case, removing special characters, and standardizing abbreviations (Incorporated -> Inc, Avenue -> Ave, etc.).

## Step 02 - [Cleaning NCCS Data](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/Step%2002%20-%20Load%20and%20Clean%20NCCS%20Data.R)

Pre-processing steps necessary to compare organizational names and geographies such as converting all text to lower case, removing special characters, and standardizing abbreviations (Incorporated -> Inc, Avenue -> Ave, etc.).

## Step 03 - [Matching FAADS to NCCS](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/Step%2003%20-%20Match%20FAADS%20and%20NCCS.R)

Apply a fuzzy matching algorithm to the name fields of the FAADS and NCCS data, then apply an exact match to three geographic fields (city, state, zip). If the case matches on name and 2+ geographic fields, it is assigned to the *yes.match* set. If it matches on names and 1 or 0 geographic fields, it is assigned to the *maybe.match* set (each FAADS case may have multiple possible matches in the NCCS dataset). And if there is no match on name, the case is assigned to the *no.match* set.

## Step 04 - [Merging Datasets](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/Step%2004%20-%20Combining%20Datasets.R)

Steps to merge matched cases in FAADS and NCCS.

## Step 05 - [Comparing Matched and Unmatched Cases](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/Step%2005%20-%20Compare%20Matched%20and%20Unmatched%20Samples.R)

Steps for calculating the match rates and comparing characteristics of matched and unmatched samples to test for selection bias. 



# Matching Example

This section demonstrates the matching algorithm using two small datasets:

[FAADS Demo Data](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/FAADS%20Demo%20Data.csv): 22 organizations
[NCCS Demo Data](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/NCCS%20Demo%20Data.csv): 35 organizations

The program will generate three results files:

[yes.match](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/yes.match.csv): organizations that match by name AND geography
[maybe.match](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/maybe.match.csv): organizations that match by name only
[no.match](https://github.com/lecy/FAADS-NCCS-Crosswalk/blob/master/no.match.csv): organizations that do not match by name

Note that all code is in the R programming language. 

## Load Sample Data

We have created small samples of FAADS and NCCS data and saved them in this repository as "FAADS Demo Data.csv" and "NCCS Demo Data.csv". The data has already been cleaned using the procedures from Step 01 and Step 02 above, resulting in uniform formats in the organizational name and address fields.

~~~{r}
# Load required packages 
library( RCurl )

# Create an object for the URL where your data is stored.
url.faads <- "https://raw.githubusercontent.com/lecy/FAADS-NCCS-Crosswalk/master/FAADS%20Demo%20Data.csv"

# Use getURL from RCurl to download the file.
faads.sample <- getURL( url.faads, ssl.verifypeer = FALSE )

# Finally let R know that the file is in .csv format so that it can create a data frame.
faads.sample <- read.csv(textConnection( faads.sample ), stringsAsFactors=FALSE )  

# Load the NCCS Sample Data
url.nccs <- "https://raw.githubusercontent.com/lecy/FAADS-NCCS-Crosswalk/master/NCCS%20Demo%20Data.csv"
nccs.sample <- getURL( url.nccs, ssl.verifypeer = FALSE )
nccs.sample <- read.csv( textConnection( nccs.sample ), stringsAsFactors=FALSE ) 

rm( url.faads )
rm( url.nccs )

~~~

## Apply the Matching Algorithm

Run through the matching example below, and you will see how the algorithm operates.

Note at the end you will have three cases. One dataset provides the matched and merged files for the cases in FAADS that are strongly matched to cases in NCCS.

The second dataset contains lists of possible matches. For each FAADS case, there is a list of NCCS cases that have an approximate name match, but do not match on at least two geographic fields. This list could potentially be refined using the Doing Business As field in NCCS (this step was not implemented here).

The last dataset contains all cases from FAADS that had no approximate name matches with NCCS cases.

*There can be myriad reasons why the matches do not occur. The FAADS case may be a field office, and the NCCS case uses the address of the headquarters, and thus the geographies do not align. They may use different names or abbreviations in each dataset. The address might be a registered agent or law office, not a nonprofit location. Despite these possibilities, we achieved approximately a 70% match rate in test cases using the 2012 FAADS data and the 2012 NCCS BMF data.*

~~~{r}

#  For info on the approximate matching algorithm see help(agrep)

faads5 <- faads.sample
nccs <- nccs.sample

###  Create potential match lists using names.
###
###  Each name in FAADS can match to zero or many names in 
###  the NCCS dataset. The results list contains a potential
###  match vector for each unique FAADS nonprofit based upon.
###  approximate string matches on nonprofit names.


faads.names <- faads5[ , "recipient_name" ]

nccs.names <- nccs[ , "NAME" ]


results <- list()

for( i in 1:length(faads.names) )
{

  results[[i]] <- agrep( faads.names[i], nccs.names, ignore.case=T, value=F, max.distance=0.1 )

}

how.many.matches <- lapply( results, length )

sum( how.many.matches > 100 )





###  Identify the best approximate name match using location information.
###  
###  


start.point <- 1
 
end.point <- nrow( faads5 )

no.match <- NULL

yes.match <- NULL

maybe.match <- NULL

loop.count <- 0


for( i in 1:length(faads.names) )
{



  loop.count <- loop.count + 1
  
  print( loop.count )
  
  
  
  # Extract the vector of potential matches from the results list
  
  these <- results[[i]]
  
  
  # If there are over 100 potential matches then 
  # specificity is low; treat it as a no match.
  
  if( length(these) >= 100 )
  {
     no.match <- rbind( no.match, faads5[ start.point -1 +i , ] )
  }


  if( length(these) < 100 )
  {

	  # If there are no potential matches, write FAADS case to no.match list.

	  if( length(these) == 0 )
	  {
	      no.match <- rbind( no.match, faads5[ start.point -1 +i , ] )

	      # match.score <- 99

	  }




	  temp.dat <- NULL

	  match.dat <- NULL

	  match.score <- NULL

	  # For cases with only one case returned from the fuzzy match
	  if( length(these) == 1 )
	  {

	      temp.dat <- data.frame( faads5[ start.point -1 +i , ], nccs[ these , ] )

	      # Calculate match distance based on fuzzy match - see help(adist)
	      match.dist <- t( adist( faads5[ start.point -1 +i , "recipient_name" ], nccs[ these , "NAME" ] ) )

	      match.score <- sum(  temp.dat$recipient_state_code ==  temp.dat$STATE, 
				   temp.dat$recipient_city_name  ==  temp.dat$CITY,
				   temp.dat$recipient_zip        ==  temp.dat$ZIP5  )

	      match.dat <- data.frame( temp.dat, m.dist=match.dist, m.score=match.score )



	      # find the top match from the list

	      if( match.score >= 2 )
	      {
		yes.match <- rbind( yes.match, match.dat )  
	      }

	      if( match.score < 2 )
	      {    
		  maybe.match <- rbind( maybe.match, match.dat )    
	      }

	  } # end of length(these)==1



          # For cases with more than one potential match
	  if( length(these) > 1 )
	  {


	    for( j in 1:length(these) )
	    {

	       temp.dat <- rbind( temp.dat, c( faads5[ start.point -1 +i , ], nccs[ these[j] , ] )  ) 

	    } # end of j loop
	    

	    temp.dat <- as.data.frame( temp.dat )

	    temp.dat <- data.frame( lapply(temp.dat, as.character), stringsAsFactors=FALSE )

	    match.dist <- t( adist( faads5[ start.point -1 +i , "recipient_name" ], nccs[ these , "NAME" ] ) )



	    for( k in 1:nrow(temp.dat) )
	    {

	      match.score[k] <- sum( temp.dat[ k, "recipient_state_code" ] ==  temp.dat[ k, "STATE" ], 
				     temp.dat[ k, "recipient_city_name" ] ==  temp.dat[ k, "CITY" ],
				     temp.dat[ k, "recipient_zip" ] ==  temp.dat[ k, "ZIP5" ]  )   

	    } # end of k loop 


	    match.dat <- data.frame( temp.dat, m.dist=match.dist, m.score=match.score ) # add string distance to df



	    # find the closest match from the list based on name
	    if( max(match.score) >= 2 )
	    {
	       this.one <- match.dat[ which( match.score >= 2 ), ]
	       this.one <- this.one[ which( this.one$m.dist==min(this.one$m.dist) ), ]
	       yes.match <- rbind( yes.match, this.one )

	    }

            
            # if don't match on at least two geographic ids then maybe.match
	    if( max(match.score) < 2 )
	    {    
		maybe.match <- rbind( maybe.match, match.dat )    
	    }



	  } # end of if length(these) > 1

  } # end of if length(these) < 100
  
  
} # end of matching loop





# List the three datasets that were created

# One-to-one match between FAADS and NCCS
yes.match

# List of several possible NCCS matches for each FAADS case
maybe.match

# No matches found in NCCS - returns FAADS unmatched cases
no.match



~~~



