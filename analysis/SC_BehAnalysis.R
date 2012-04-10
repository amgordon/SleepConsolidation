library("lme4")

#read in raw data
d0 <- read.csv("groupBehDat.csv")

#remove trials for which both B and C were mistakenly cued.
d0<-d0[!(d0$BCue==TRUE & d0$CCue==TRUE)]

#test of effects of accuracy and cuing on likelihood of correct recall
res.TestAccuracyByInterferenceAndCuing <- glmer(cor ~ Int + BCue + CCue + corRehB + corRehC + (1| subs), data=d0, family="binomial")

#test of B vs. C cuing
res.TestAccuracyByBVsCCuing <- glmer(cor ~ Int + BCue + corRehB + corRehC + (BCue| subs), data=d1, family="binomial")