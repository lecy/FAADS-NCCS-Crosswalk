
####
####  Match Nonprofits in FAADS to NCCS BMF Nonprofits
####

####  To link the FAADS and NCCS data we match on: 
####
####  First Name - use approximate string match agrep()
####
####  Then match two of three following:
####
####    State - exact match
####    City - exact match
####    Zip - exact match
#### 
####
####  Three data sets are generated:
####   
####     Strong matches - names match approximately and there are 
####        at least two exact matches on location.
####
####     Weak matches - names match approximately but there is only
####        one or zero matches on location.
####
####     No matches - the FAADS nonprofit name does not generate an
####        approximate match to any names in the NCCS set.

####
####  For info on the approximate matching algorithm see help( agrep ).
####
####  The function uses the Levenshtein edit distance metric.
####
####  See an example here: http://www.let.rug.nl/~kleiweg/lev/
####

####  Note that fuzzy matching is time intensive. Each nonprofit in the FAADS
####  is compared against over a million possible matches in the NCCS BMF.
####  
####  It may take up to a week to run!




### To start from this step source Step 1 and Step 2 so data is in memory.

# setwd( "...your directory here..." )

source( "Step 01 - Load and Clean FAADS Data.R" )

source( "Step 02 - Load and Clean NCCS Data.R" )





options(stringsAsFactors = FALSE)

nccs <- as.data.frame( nccs )

nccs <- data.frame( lapply(nccs, as.character), stringsAsFactors=FALSE)

faads5 <- as.data.frame( faads5 )





# faads5 is the simplified faads dataset

# start.point <- 1
# 
# end.point <- 13615

# faads.names <- faads5[ start.point:end.point , "recipient_name" ]





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

	    temp.dat <- data.frame( lapply(temp.dat, as.character), stringsAsFactors=FALSE

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





# Write match dataset to the Results folder in your directory

write.csv( yes.match, paste("./Results/","Matches",start.point,"to",end.point,".csv",sep="") )

write.csv( maybe.match, paste("./Results/","WeakMatches",start.point,"to",end.point,".csv",sep="") )

write.csv( no.match, paste("./Results/","NoMatches",start.point,"to",end.point,".csv",sep="") )



