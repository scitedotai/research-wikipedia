
library(readr)
library(dplyr)
library(reshape2)

df <- read_delim("wikipedia_dois.tsv","\t", escape_double = FALSE, trim_ws = TRUE)
df$page_id <- NULL
df$unclassified <- NULL
table(df$doi)
doi_freq <- table(df$doi)
mean(doi_freq)
sd(doi_freq)
median(doi_freq)
IQR(doi_freq)
range(doi_freq)
df_distinct <- distinct(df)

df_long <- melt(df, id=c("doi"))
df_long <- df_long[df_long$value > 0,]

df$total <- apply(df[2:4], 1, sum)

mean(df$total)
sd(df$total)
median(df$total)
IQR(df$total)
range(df$total)


mean(df$contradicting)
sd(df$contradicting)
median(df$total)
IQR(df$total)
range(df$total)

mean(df$supporting)
sd(df$supporting)
median(df$supporting)
IQR(df$supporting)
range(df$supporting)

mean(df$mentioning)
sd(df$mentioning)
median(df$mentioning)
IQR(df$mentioning)
range(df$mentioning)

hist(log(df$contradicting))
hist(log(df$supporting))
hist(log(df$mentioning))
