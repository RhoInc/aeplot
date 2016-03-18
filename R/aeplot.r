##################################################################################
# aeplot() - generates summary Plots of AE Prevelance using lattice (in R)
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
  plot.data <- make_plot_data(ae.summary, cut, cut_organ_class)

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
  lattice::trellis.par.set("axis.line", list(col=NA, lty=1, lwd=1))
  thisPlot<-lattice::xyplot(index~max.percent | page, data = plot.data,
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
                 stringr::str_trim(current$pref) == "All",
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

             lattice::panel.abline(h = y[stringr::str_trim(current$pref) == "All"] - 0.5)
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
                 stringr::str_trim(
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
    return(thisPlot)
}
