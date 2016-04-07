# This is the R file for shipping rate prediction of the paper with Andres Musalem and Jeannette Song
setwd("/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Stata Code")
rm(list=ls())
library("foreign")
D <- read.dta("map_inuse_child3.dta")
D$distance <- NULL

####### Using existing partial price to predict full pricess #####################
D$number_of_shipments <- factor(D$number_of_shipments)
D$month[D$month==1] = 201301
D$month[D$month==2] = 201302
D$month[D$month==3] = 201303
D$month[D$month==4] = 201304
D$month[D$month==5] = 201305
D$month[D$month==6] = 201306
D$month[D$month==7] = 201307
D$month[D$month==8] = 201308
D$month[D$month==9] = 201309
D$month[D$month==10] = 201310
D$month[D$month==11] = 201311
D$month[D$month==12] = 201312
D$month <- factor(D$month)
Price <- read.dta("shipping_price.dta")
Price$month <- factor(Price$month)
Price$log_charges <- log(Price$weight_other_charges_usd)
library(mgcv)
model0 <- lm(log_charges ~ distance + chargeable_weight + weight_break
              + as.factor(number_of_shipments) + month +
               to_country, data = Price)
model1 <- lm(weight_other_charges_usd ~ distance + chargeable_weight + weight_break + 
               chargeable_weight:weight_break + as.factor(number_of_shipments) + month +
               to_country, data = Price)
model2 <- lm(weight_other_charges_usd ~ distance + chargeable_weight + weight_break + 
               chargeable_weight:weight_break + as.factor(number_of_shipments) + month +
               to_country + from_country, data = Price)
anova(model1, model2)
summary(model1)
logP_mat <- matrix(ncol=6, nrow=dim(D)[1])
for (i in 1: 6) {
  D[D[, 2*i+10]=="", 2*i+10] <- NA
  n1 = names(D)[2*i+10]
  n2 = names(D)[2*i+11]
  names(D)[2*i+10] <- "to_country"
  names(D)[2*i+11] <- "distance"
  logP_mat[, i] <- predict(model0, D)
  names(D)[2*i+10] <- n1
  names(D)[2*i+11] <- n2
}
drops <- c("weight_break", "chargeable_weight", "delay", "early",
           "to_country_1", "to_country_2", "to_country_3", "to_country_4", "to_country_5",
           "to_country_6", "to_country_7", "to_country_8", "to_country_9", "to_country_10",
           "distance_1", "distance_2", "distance_3", "distance_4", "distance_5", 
           "distance_6","distance_7", "distance_8", "distance_9", "distance_10",
           "complete_period", "number_of_shipments", "log_weight")
keep <- c("distance_1", "distance_2", "distance_3", "distance_4", "distance_5", 
            "distance_6")
Distance <- D[,(names(D) %in% keep)]
D$number_of_shipments <- as.numeric(D$number_of_shipments)
D$month <- as.numeric(D$month)
D <- D[,!(names(D) %in% drops)]
D <- D[with(D, order(child_id, start_period)), ]
D <- D[, c(5, 1, 2, 6)]
P_mat <- exp(logP_mat)
P_mat[P_mat>100000] <- 100000
###################################################################################
write.table(P_mat, file="P_mat.csv", sep=",", na="0", row.names=F, col.names=F)
write.table(logP_mat, file="logP_mat.csv", sep=",", na="0", row.names=F, col.names=F)
write.table(D, file="ID_mat.csv", sep=",", na="0", row.names=F, col.names=F)
write.table(Distance, file="Predictor.csv", sep=",", na="0", row.names=F, col.names=F)
save.image("R_result.RData")

#######################################################################################
mean(Price$distance, na.rm=T)
mean(Price$log_charges, na.rm=T)
sqrt(var(Price$distance, na.rm=T))
sqrt(var(Price$chargeable_weight, na.rm=T))



