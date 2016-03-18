make_plot_data<-function(ae.summary, cut, cut_organ_class){

  ## Clean up a label to be plotted
  trim <- function (x) gsub("^\\s+|\\s+$", "", x)
  ae.summary$printname <- factor(
    ifelse(
      trim(ae.summary$pref) == "All",
      trim(ae.summary$sys),
      trim(paste("-", trim(ae.summary$pref), sep = ""))
    )
  )

  ## Collapse the data set to one row per category
  anly <- data.frame(
    sys=character(0),
    pref=character(0),
    printname=character(0),
    syspref=character(0)
  )

  for(j in levels(ae.summary$group)){
    groupdata <- data.frame(
      n=character(0),
      percent=character(0)
    )
    names(groupdata) <- paste(j, names(groupdata), sep = ".")
    anly <- cbind(anly, groupdata)
  }

  for(i in levels(ae.summary$syspref)){
    current <- data.frame(
      sys = ae.summary$sys[ae.summary$syspref == i],
      pref = ae.summary$pref[ae.summary$syspref == i],
      printname = ae.summary$printname[ae.summary$syspref == i],
      syspref = i
    )
    current <- current[1, ]
    for(j in levels(ae.summary$group)){
      current.group <- data.frame(n = NA, percent = NA)
      current.group$n <- ae.summary$n[
        ae.summary$syspref == i & ae.summary$group == j
      ]
      current.group$percent <- ae.summary$percent[
        ae.summary$syspref == i & ae.summary$group == j
      ]
      names(current.group) <- paste(j, names(current.group), sep=".")
      current <- cbind(current, current.group)
    }
    anly <- rbind(anly, current)
  }

  ## Set the order of the data set (default: sort first by system prevelance
  ## then by preferred term prevelance)
  #get the maximum percent for each row
  percents <- paste(levels(ae.summary$group), "percent", sep=".")
  anly$max.percent <- 0
  for (i in percents){
    anly$max.percent <- pmax(anly$max.percent, anly[ ,i])
  }

  #Get the maximum prevelance for each the system class
  anly.sysclass <- anly[anly$pref == "  All",]
  anly.sysclass <- anly.sysclass[order(-anly.sysclass$max.percent), ]
  anly.sysclass$order.main <- 1:dim(anly.sysclass)[1]
  anly.sysclass <- anly.sysclass[,c("sys","order.main")]
  anly <- merge(anly,anly.sysclass,by="sys")
  anly <- anly[order(anly$order.main,-anly$max.percent),]

  #Subset the data to be plotted based on function calls
  anly <- anly[anly$pref == "  All" | anly$max.percent >= cut, ]
  if (cut_organ_class == T) anly <- anly[anly$max.percent >= cut, ]

  #set page numbers
  anly$index <- 0:(dim(anly)[1] - 1) %% 50
  anly$page <- floor(0:(dim(anly)[1] - 1) / 50) + 1

  return(anly)
}
