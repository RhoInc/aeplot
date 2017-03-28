# Overview

aeplot() is an R package that generates summary Plots of Adverse Event Prevelance using lattice.

# Typical usage
A typical call to aeplot() creates output like this: 
![sample aeplot](/example/sample_plot.png)

Using code like this: 

```R
install_github("rhoinc/aeplot")
library(aeplot)

myData<-read.csv("myData.csv")
plot1<- aeplot(
    myData,                        
    groups=c("intervention","placebo"),
    ngroups=c(280,272),                     
    grouplabel=c("Treatment","Control"),                                
    cut=3,
    cut_organ_class=F,
    title="AE Prevelance (3% or greater)"
)    

pdf(file="myplot.pdf", height=11, width=8.5)
    print(plot1)
dev.off()
```

# Configuration

`aeplot()` takes several arguements:

## data
*RData* _required_

An Rdata file with one record per AE, and (at a minimum) the following 4 columns:
 1. ID (text or numeric)
 2. SystemOrganClass (text)
 3. PreferredName(text)
 4. Group (text)

## groups 
*array* _required_   

Array specifying the groups to be included in the plot. wording must match the raw data,  like `c("placebo","treatment")`

## ngroups 
*array* _required_

 Array of integers indicating the number of participants in each group. The number and order of the elements should match those given `groups` like `c(149,147)`

## cut 
*numeric* 

A cutpoint for filtering low prevelence events. Rows with no group prevelance above this value are supressed. 

**default:** `0`

## cut_organ_class
*boolean*

Flag to indicate whether `cut` should be applied to organ class as well as preferred name.

**default:** `false`

##  numerator
*character*

Indicates the numerator for rates given in the adverse event plot. Valid options are: 

- "pt" = participants w. 1+ ae 
- "ae" = total # of AEs

**default:** `"pt"`

## colors 
*array*

Sets group colors in the adverse event plot. Group colors default to "set1" in RColorBrewer, but can be specified using c("#200","#020",etc...)

**default:** `c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628", "#F781BF","#999999")`

## grouplabels 
*array*

Group names to be printed in the column header.
