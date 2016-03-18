make_summary_data<-function(ae.long, groups, ngroups, numerator){
  names(ae.long) <- tolower(names(ae.long))

  #Drop "disorder" from each preferred name
  ae.long$systemorganclass <- as.character(ae.long$systemorganclass)
  ae.long$systemorganclass[
    substr(
      ae.long$systemorganclass,
      nchar(ae.long$systemorganclass) - 8,
      nchar(ae.long$systemorganclass)
    ) == "disorders"
    ] <- substr(
      ae.long$systemorganclass[
        substr(
          ae.long$systemorganclass,
          nchar(ae.long$systemorganclass) - 8,
          nchar(ae.long$systemorganclass)
        ) == "disorders"
        ],
      1,
      nchar(
        ae.long$systemorganclass[
          substr(ae.long$systemorganclass,nchar(ae.long$systemorganclass) - 8,
                 nchar(ae.long$systemorganclass)) == "disorders"
          ]
      ) - 10
    )
  ae.long$systemorganclass <- factor(ae.long$systemorganclass)

  ### Define our group variables
  sys <- levels(ae.long$systemorganclass)

  #list of system organ classes
  syspref.cat <- unique(
    paste(ae.long$systemorganclass,"!",ae.long$preferredname,sep="")
  )

  #list of systemorganclasses + preferred term
  syspref.all <- paste(sys,"!  All",sep="")
  syspref <- c(syspref.cat,syspref.all)
  syspref <- syspref[order(syspref)]

  ### Flag first record in a given system organ class and preferred term for
  ### Participant level plots
  ae.long <- ae.long[with(ae.long ,order(systemorganclass, preferredname, id, group)),]

  #sort
  ae.long$organ.flag <- duplicated(
    paste(ae.long$id, ae.long$systemorganclass)
  ) == F
  ae.long$pref.flag <- duplicated(
    paste(ae.long$id,ae.long$systemorganclass,ae.long$preferredname)
  ) == F


  # Count the # of Participants/AEs in each Organ Class / Preferred Name combo
  # Create shell data frame
  ae.summary <- data.frame(
    sys=character(0),
    pref=character(0),
    syspref=character(0),
    groups=character(0),
    n=numeric(0),
    tot=numeric(0),
    percent=numeric(0)
  )

  # Fill in prevelance n and prevelance for each group (data is one record per
  # participant per group)

  for (i in syspref){
    current.sys <- strsplit(i,"!")[[1]][1]
    current.pref <- strsplit(i,"!")[[1]][2]
    for (j in groups){
      current <- data.frame(
        sys=current.sys,
        pref=current.pref,
        syspref=i,
        group=j)
      if (current.pref == "  All"){
        current$n.ae <- length(
          ae.long$systemorganclass[
            ae.long$systemorganclass == current.sys & ae.long$group == j
            ]
        )
        current$n.pt <- length(
          ae.long$systemorganclass[
            ae.long$systemorganclass == current.sys &
              ae.long$group == j & ae.long$organ.flag == T
            ]
        )
      }else{
        current$n.ae <- length(
          ae.long$systemorganclass[
            ae.long$systemorganclass == current.sys &
              ae.long$preferredname == current.pref &
              ae.long$group == j
            ]
        )
        current$n.pt <- length(
          ae.long$systemorganclass[
            ae.long$systemorganclass == current.sys &
              ae.long$preferredname == current.pref &
              ae.long$group == j &
              ae.long$pref.flag == T
            ]
        )
      }
      current$tot <- ngroups[groups == j]
      if (numerator == "ae") current$n <- current$n.ae
      if (numerator == "pt") current$n <- current$n.pt
      current$percent <- current$n / current$tot * 100
      ae.summary <- rbind(ae.summary, current)
    }
  }
  return(ae.summary)
}
