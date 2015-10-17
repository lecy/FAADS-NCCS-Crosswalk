
####  Merge FAADS and NCCS data based upon matches made in Step 3




# setwd( "...your directory here..." )
 





# Load NCCS Data

library( foreign )
 
nccs <- read.spss( "./Data/NCCS BMF June 2012.por", to.data.frame=T, use.value.labels = F )

# make sure the merge id is not a factor

nccs$EIN <- as.numeric( as.character( nccs$EIN ) )





# Merge NCCS data to the matched cases

yes.match$EIN <- as.numeric( yes.match$EIN )

merged.data <- merge( yes.match, nccs, by.x="EIN", by.y="EIN" )





write.csv( merged.data, "./Results/merged_faads_nccs.csv", row.names = FALSE )




### Clean Up

rm( yes.match )
rm( no.match )
rm( maybe.match )
rm( nccs )
rm( merged.data )

