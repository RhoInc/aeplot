##################################################################################
#                                aeplot() Documentation
# (1) Overview
# AEplot() is a function that generates summary Plots of AE Prevelance using lattice (in R)
#
# (2) File Summary
# Input: CSV file (1 record per AE + a header row) with the following 4 columns:
# 1. ID (text or numeric)
# 2. SystemOrganClass (text)
# 3. PreferredName(text)
# 4. Group (text)
#
# Output: Summary figure saved as a pdf
#
# (3) Funtion Arguements (default) - details.
# Note: The 3 required arguments are "groups", "ngroups", and "pathin"
#
# 3.1 Metadata
# groups (None - REQUIRED) -  list of the groups to be included in the plot. wording must match the raw data.
#                             e.g. c("placebo","treatment")
#
# ngroups (None - REQUIRED) - # of participants in each group. Array of Numeric with same # of elements as /groups/.
#                             order should match /groups/. If groups is not specified, the values should be listed
#                             in alphabetical order according to group name. e.g. c(149,147)
#
# 3.2 Graphic options (All for pdf only. Interactive version allows many of these options to be toggled in the webpage)
# cut (0) - only include terms with prevalence >= /cut/
# cut_organ_class (FALSE) - apply cut to organ class as well as pref name?
#                         if F all systemOrganClasses will be shown regardless of /cut/.
#                         if T,  they will be removed according to /cut/.
# numerator ("pt") - What should the numerator for your rates be? "pt" = participants w. 1+ ae , "ae" = total # of AEs
# colors (see details) - group colors default to "set1" in RColorBrewer, but can be specified using c("#200","#020",etc...)
# grouplabels (/groups/) - how should the group names be printed in the column header.
#
# 3c. Input/Output
# pathin ("None - REQUIRED") - name of the csv  containing the 1 record per AE data set
# pathout (paste(getwd(),"fig/AEplot.pdf")) - path where the pdf figure is stored
#
# (4) Sample Function Calls
# 4a. Basic Plot with defaults. Includes all observered organ classes & prefferred names
# AEPlot(pathin="O:/Asthma/VizLibrary/AEfedex/data/ACE.csv",                        #Required
#       groups=c("intervention","placebo"),ngroups=c(280,272))                      #Required
#
# 4b. Customized plot with custom title and group names. Includes classes & preferred names >= 3%.
# AEPlot(pathin="O:/Asthma/VizLibrary/AEfedex/data/ace.csv",                        #Required
#       groups=c("intervention","placebo"),ngroups=c(280,272),                      #Required
#       pathout="O:/Asthma/VizLibrary/AEfedex/fig/AEPlot_3percent.csv",             #Optional
#       grouplabel=c("FeNO Group","Non-FeNO Group"),                                #Optional
#       cut=3,cut_organ_class=F,title="AE Prevelance in ACE (3% or greater)")         #Optional
#
# (5) Change Log
# 10Oct2011 - jwildfire - Version 1.0 released.
# 13Jan2014 - jwildfire - bugfix for certain sort patterns addressed (see line 99)
# 17Mar2016 - jwildfire - updates for R package
###########################################################################################



aeplot <- function(
  data,
  groups,
  ngroups,
  cut=0,
  cut_organ_class=F,
  numerator="pt",
  colors=NA,
  grouplabels=NA,
  title="",
  pathout=paste(getwd(),"fig","AEplot.pdf",sep="/")){

  ######### Part 1: Restructure the data #######################################
  # RE-format 1 record per AE data set in to a 1 record per category
  # (systemorganclass*preferred term) data set with colums for
  # systemorganclass, preferredname and each group of interest
  #
  # Note: a summary row for each organ class is added where
  # preferred term is set to NA
  ##############################################################################
  ae.summary <- make_summary_data(data, groups, ngroups, numerator)

  ######### Part 2: Prepare the data for plotting ##############################
  plot.data <- make_plot_data(ae.summary, cut)

  ######## Part 3: Create the Lattice Figure ###################################
  # Creates a 1 record per Prefferred Name plot of AE Prevelance with annotated
  # values
  #############################################################################

  #Set up basic layout
  groupcount <- length(levels(ae.summary$group))
  upper <- ceiling(max(plot.data$max.percent) / 20) * 20
  segment <- upper / 3
  s.below <- 4.5 + groupcount #increase to move dotplot to the right
  lower <- s.below * segment * (-1)
  anno.pos <- lower + (4.75 * segment) + (segment * c(0:(groupcount - 1)))
  #increase to move percents to the right

  #check for customization in function call
  groups <- levels(ae.summary$group)                    #Group variable names
  if(is.na( grouplabels[1])) grouplabels <- groups       #Group labels
  if(is.na(colors[1])) colors <- RColorBrewer::brewer.pal(9, "Set1")   #Colors
  sym <- c(1:groupcount)                                 #Symbols

  ## Create the pdf
  pdf(file=pathout, height=11, width=8.5)
  trellis.par.set("axis.line", list(col=NA, lty=1, lwd=1))

  print(
    lattice::xyplot(index~max.percent | page, data = plot.data,
           main = title,
           layout = c(1,1),
           as.table = T,
           xlim = c(lower,upper + 3),
           ylim = c(50,-2.5),
           xlab = "",
           ylab = "",
           scales = list(draw=F),
           strip = F,
           panel = function(x, y, subscripts){
             current <- plot.data[subscripts, ]
             current$printname <- as.character(current$printname)
             label <- ifelse(nchar(current$printname) > 52,
               paste(substr(current$printname, 0, 52), "...", sep=""),
               substr(current$printname, 0, 52)
             )
             lattice::panel.text(
               label,
               y = y,
               x = lower,
               pos = 4,
               cex = 0.8,
               font = ifelse(
                 trim(current$pref) == "All",
                 2,
                 1
               )
             )

             lattice::panel.text(
               seq(from = 0, to = upper, by = 20),
               y = -0.6,
               seq(from = 0, to = upper, by = 20),
               col = "gray80",
               cex = 0.6,
               pos = 3
             )

             lattice::panel.segments(
               x0 = seq(from = 0, to = upper, by = 20),
               x1 = seq(from = 0, to = upper, by = 20),
               y0 = min(y) - 0.7, y1= max(y) + 0.5, col = "gray80"
             )

             lattice::panel.abline(h = y[trim(current$pref) == "All"] - 0.5)
             lattice::panel.abline(h = c(max(y) + 0.5, -0.5))

             group.num <- 0
             for (i in groups){
               group.num <- group.num + 1
               lattice::panel.xyplot(
                 x = current[ ,c(paste(i, ".percent", sep = ""))],
                 y = y,
                 col = colors[group.num],
                 pch=sym[group.num],
                 cex=1.2
                )
               lattice::panel.text(
                 grouplabels[group.num],
                 y = -2,
                 x=anno.pos[group.num],
                 cex=0.8
               )
               lattice::panel.text(
                 paste("(n=", ngroups[group.num], ")", sep=""),
                 y=-1,
                 x=anno.pos[group.num],
                 cex=0.8
               )
               anno <- paste(
                 current[,c(paste(i,".n",sep=""))],
                 " (",
                 trim(
                   format(
                     round(
                       current[ ,c(paste(i,".percent",sep=""))],
                       1
                     ),
                   nsmall=1
                   )
                 ),
                 "%)",
                 sep=""
               )
               lattice::panel.text(
                 anno,
                 y=y,
                 x=anno.pos[group.num],
                 col=colors[group.num],
                 cex=0.8
               )
             }
           }
    )
  )
  dev.off()
}
