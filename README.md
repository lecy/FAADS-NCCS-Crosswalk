# FAADS-NCCS-Crosswalk

This directory contains scripts in the R language that provide a crosswalk between the Federal Assistance Award Data System (FAADS) that contains federal grants information, and the National Center for Charitable Statistics (NCCS) Core Data files, which provide IRS financial data on nonprofits.

The FAADS uses the DUNS Number as the organizational ID field, and NCCS uses the EIN as the unique ID. The federal government currently provides no crosswalk between these ID systems, so the datafiles are impossible to merge in a traditional fashion.

We present a method of fuzzy matching in order to create a bridge between the two data sources using the name and location of nonprofits. The methodology is described here:

*Lecy, Jesse D. and Thornton, Jeremy P., What Big Data Can Tell Us About Government Awards to the Nonprofit Sector: Using the FAADS (November 25, 2013).* [Available at SSRN](http://ssrn.com/abstract=2359490 or http://dx.doi.org/10.2139/ssrn.2359490)

The code to replicate the methodology is available in this repository.

