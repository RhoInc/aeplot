#Run using library on github
require(devtools)
install_github("rhoinc/aeplot")
library(aeplot)

myData<-read.csv("./example/sample_data.csv")
plot1<- aeplot(
  myData,
  groups=c("intervention","control"),
  ngroups=c(350,350),
  grouplabel=c("Treatment","Control"),
  cut=6,
  cut_organ_class=F,
  title="AE Prevelance (6% or greater)"
)

pdf(file="./example/sample_plot.pdf", height=11, width=8.5)
print(plot1)
dev.off()
