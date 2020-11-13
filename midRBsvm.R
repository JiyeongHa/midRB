### read .mat file
library(R.matlab) 
library(e1071)
### memory performance
mem = c(1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1);
# mem = c(0.7476,0.47342,0.86968,1.0854,0.79231,1.19428,0.88878,
#         0.29685,0.64778,0.65383,0.97302,0.48465,1.20325,0.24413,0.35361,0.55043,0.46711,0.7173)
### get data
RN_post = readMat("/Users/se7enstar/Dropbox/2016-1_Paperstudy/project/Spearman/MAP_post_tak.mat")
RN_pre  = readMat("/Users/se7enstar/Dropbox/2016-1_Paperstudy/project/Spearman/MAP_pre_tak.mat")
RN_post_list = list() ; RN_pre_list  = list() ; RN_diff_list = list()
### rearrange data
for (i in 1:54){
  RN_post_list[[i]] = matrix(unlist(RN_post[[1]][i]),ncol=21,nrow=21)
  RN_pre_list[[i]]  = matrix(unlist(RN_pre[[1]][i]), ncol=21,nrow=21)
##### selecting ROIs as you wish #####
  # T+: '06IPS_roi','07FEF_roi','08IFG_roi','09MT+_roi','10MFG_roi','11IPS_roi','12FEF_roi','13IFG_roi','14MT+_roi',
  # T-: '15MPF_roi','16PCC_roi','17LPC_roi','18MTG_roi','19SFG_roi','20PHG_roi','21TMP_roi','22LPC_roi','23MTG_roi',
  #     '24SFG_roi','25PHG_roi','26TMP_roi'
###########################################################################  
  # roi = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21) # All ##
  roi = c(1,2,3,4,5,6,7,8,9) # T+                                      ## roi selection
  # roi = c(10,11,12,13,14,15,16,17,18,19,20,21) # T- 83(7,.009)           ##
###########################################################################
  RN_post_list[[i]] = RN_post_list[[i]][roi,roi] ; RN_pre_list[[i]]  = RN_pre_list[[i]][roi,roi]
#################################### take triangular matrix from full FC matrix
  RN_post_list[[i]][upper.tri(RN_post_list[[i]], diag = TRUE)] <- 0
  RN_pre_list[[i]][upper.tri(RN_pre_list[[i]],   diag = TRUE)] <- 0
  RN_post_list[[i]]=RN_post_list[[i]][RN_post_list[[i]]!=0]
  RN_pre_list[[i]]=RN_pre_list[[i]][RN_pre_list[[i]]!=0]
  RN_diff_list[[i]]=RN_post_list[[i]]-RN_pre_list[[i]]}
RN_post_mean_tri   = data.frame(cbind(t(simplify2array(RN_post_list))[1:18,],mem))
RN_post_median_tri = data.frame(cbind(t(simplify2array(RN_post_list))[19:36,],mem))
RN_post_max_tri    = data.frame(cbind(t(simplify2array(RN_post_list))[37:54,],mem))
RN_pre_mean_tri    = data.frame(cbind(t(simplify2array(RN_pre_list))[1:18,],mem))
RN_pre_median_tri  = data.frame(cbind(t(simplify2array(RN_pre_list))[19:36,],mem))
RN_pre_max_tri     = data.frame(cbind(t(simplify2array(RN_pre_list))[37:54,],mem))
RN_diff_mean_tri   = data.frame(cbind(t(simplify2array(RN_diff_list))[1:18, ],mem))
RN_diff_median_tri = data.frame(cbind(t(simplify2array(RN_diff_list))[19:36,],mem))
RN_diff_max_tri    = data.frame(cbind(t(simplify2array(RN_diff_list))[37:54,],mem))
######################### data input #########################
####################################################
# data <- RN_diff_mean_tri                        ##
data <- RN_pre_mean_tri                           ##
# data <- RN_post_max_tri                         ##
# data = data[,-c(6, 68, 151, 157, 161, 178)# ALL ## data selection
# data = data[,c(-7,-13,-17,-34)]  #DMN           ##
# data = data[,c(7,13,17,34,67)]  #DMN            ##
# data = data[,c(-6)]              #CCN           ##
####################################################
dSize = length(data[1,]) # data size
tdSize = dSize-1 # training data size
subSize = length(data[,1]) # subject number
######################### making header #########################
name=c() # make header name's vector
for (i in 1:tdSize){cor = sprintf('cor%s',i) ; name = c(name,cor)}
######################### making label as factor #########################
colnames(data) = c(name,"mem")
data[which(data$mem==1),dSize]='good'
data[which(data$mem==0),dSize]='bad'
data[,dSize] = as.factor(data[,dSize])
######################### logging confusion matrix & corr trials #########################
CMAT <- table(pred = c('bad','good'), true = c('bad','good'))-table(pred = c('bad','good'), true = c('bad','good'))
CORR <- matrix(nrow=1,ncol=subSize)
######################### leave 1 out SVM #########################
for (i in 1:subSize){
  data_Tst <- data[i,1:dSize]
  data_Trn <- data[-i,1:dSize]
  svm.model <- svm(data_Trn$mem ~ ., data = data_Trn, kernel = "sigmoid", cost = 10, gamma = 0.03)
  svm.pred <- predict(svm.model, data_Tst[,-dSize])
  conMAT <- table(pred = svm.pred, true = data_Tst[,dSize])
  CMAT <- CMAT + conMAT
  CORR[i] <- sum(diag(conMAT))
}
######################### show result #########################
accuracy <- sum(CORR)/nrow(data)*100
CMAT
accuracy
