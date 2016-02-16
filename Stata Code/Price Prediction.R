# This is the R file for shipping rate prediction of the paper with Andres Musalem and Jeannette Song
setwd("/Users/sunnieshang/Documents/Duke Study/Research/KN_2/Stata Code")
rm(list=ls())
library("foreign")
D <- read.dta("map_inuse_child3.dta")

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
model1 <- lm(weight_other_charges_usd ~ distance + chargeable_weight + weight_break + 
               chargeable_weight:weight_break + as.factor(number_of_shipments) + month +
               to_country, data = Price)
model2 <- lm(weight_other_charges_usd ~ distance + chargeable_weight + weight_break + 
               chargeable_weight:weight_break + as.factor(number_of_shipments) + month +
               to_country + from_country, data = Price)
anova(model1, model2)
summary(model1)
P_mat <- matrix(ncol=10, nrow=dim(D)[1])
for (i in 1: 10) {
  D[D[, 2*i+11]=="", 2*i+11] <- NA
  n1 = names(D)[2*i+11]
  n2 = names(D)[2*i+12]
  names(D)[2*i+11] <- "to_country"
  names(D)[2*i+12] <- "distance"
  P_mat[, i] <- predict(model1, D)
  names(D)[2*i+11] <- n1
  names(D)[2*i+12] <- n2
}
drops <- c("CARRIER_CODE", "weight_break", "chargeable_weight", "delay", "early",
           "to_country_1", "to_country_2", "to_country_3", "to_country_4", "to_country_5",
           "to_country_6", "to_country_7", "to_country_8", "to_country_9", "to_country_10",
           "distance_1", "distance_2", "distance_3", "distance_4", "distance_5", 
           "distance_6","distance_7", "distance_8", "distance_9", "distance_10",
           "complete_period", "number_of_shipments")
keep <- c("distance_1", "distance_2", "distance_3", "distance_4", "distance_5", 
            "distance_6","distance_7", "distance_8", "distance_9", "distance_10")
Distance <- D[,(names(D) %in% keep)]
D$number_of_shipments <- as.numeric(D$number_of_shipments)
D$month <- as.numeric(D$month)
D <- D[,!(names(D) %in% drops)]
D <- D[with(D, order(child_id, start_period)), ]
D <- D[, c(3, 1, 4, 6)]
###################################################################################
write.table(P_mat, file="P_mat.csv", sep=",", na="0", row.names=F, col.names=F)
write.table(D, file="ID_mat.csv", sep=",", na="0", row.names=F, col.names=F)
write.table(Distance, file="Predictor.csv", sep=",", na="0", row.names=F, col.names=F)
save.image("R_result.RData")
