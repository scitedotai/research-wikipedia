library(readr)
library(dplyr)
library(reshape2)

df <- read_delim("Data/wikipedia_dois.tsv","\t", escape_double = FALSE, trim_ws = TRUE)
df$page_id <- NULL
df$unclassified <- NULL
table(df$doi)
doi_freq <- table(df$doi)
mean(doi_freq)
sd(doi_freq)
df_distinct <- distinct(df)

df_long <- melt(df, id=c("doi"))
df_long <- df_long[df_long$value > 0,]

df$total <- apply(df[2:4], 1, sum)

hist(log(df$contradicting))
hist(log(df$supporting))
hist(log(df$mentioning))
