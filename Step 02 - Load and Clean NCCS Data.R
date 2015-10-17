
#### Load and clean the NCCS Nonprofit Data - Business Master Data Files


####   Data dictionary available at 
####
####   http://nccsweb.urban.org/PubApps/dd2.php?close=1&form=BMF+06/2012+501c3
####
####



# setwd( "...your directory here..." )

# install.packages( "foreign" )

library( foreign )



# Load NCCS Data

dat <- read.spss( "./Data/NCCS BMF June 2012.por", to.data.frame=F, use.value.labels = F )

# should be characters
#
# class( dat$NAME ) 
# class( dat$STATE )
# class( dat$CITY )
# class( dat$ZIP5 )


# Keep five variables only

nccs <-  data.frame( dat$NAME, dat$STATE, dat$CITY, dat$ZIP5, dat$EIN, stringsAsFactors=F )  

names( nccs ) <- c("NAME","STATE","CITY","ZIP5","EIN")

rm( dat )





###
### Pre-Processing Steps
###


# Convert all to lower case text for matching

nccs <- apply( nccs,  MARGIN=c(1, 2), FUN=tolower )


### The metacharacters for regexpr() are . \ | ( ) [ { ^ $ * + ?
### 
### They are proceeded by double backslashes in pattern matching - see help(regexpr).

# Remove special characters from nonprofit names:

nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\.", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\(", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\)", replacement=""  )

nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="/", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="'", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="&amp", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern=";", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern=",", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="`", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\"", replacement=""  )



# Replacement commonly abbreviated words with their abbreviations

# \\b is an anchor for beginning and end of words (space, punctuation, or end of line).

nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="  ", replacement=" "  ) # double spaced
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern=" $", replacement=""  ) # space at end of line

nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\bstreet\\b", replacement="st"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\bdrive\\b", replacement="dr"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="boulevard", replacement="blvd"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="highway", replacement="hwy"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="plaza", replacement="plz"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\bplace\\b", replacement="pl"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\broad\\b", replacement="rd"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="suite", replacement="ste"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\bnorth\\b", replacement="n"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\bsouth\\b", replacement="s"  )

nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\beast\\b", replacement="e"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\bwest\\b", replacement="w"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="northeast", replacement="ne"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="northwest", replacement="nw"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="southeast", replacement="se"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="southwest", replacement="sw"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\band\\b", replacement="&"  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="\\binc\\b", replacement=""  )
nccs <- apply( nccs, MARGIN=c(1, 2), FUN=gsub, pattern="#", replacement="num"  )


