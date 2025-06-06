#####################################################################################-
#          LOAD LIBRARIES  ----
#####################################################################################-
# library(dendsort)
# #install.packages("FactoMineR")
# library(FactoMineR)
# library("pheatmap")
# #install.packages("dendextend")
# library(dendextend)

#
library(factoextra)





#####################################################################################-
#         FUNCTIONS  ----
#####################################################################################-

workdir = "~/Bureau/tdefreitas_genobioinfo/PROJET_H2AV_2025/"
source(paste0(workdir,"functionR/func_do_acp_and_clustering.R"))

outfig = paste0(workdir,"FIGURES/ACP/")

GNref = readRDS(paste0(workdir, "DATA/LIST_FEATURES/LIST_GN_ACTIFS.RDS"))


#####################################################################################-
#         DATA  ----
#####################################################################################-

K27C = readRDS(paste0(workdir,"DATA/QUANTIF/K27C_readsCounts_GB_SCALED.RDS"))
H3K4me1 = readRDS(paste0(workdir,"DATA/QUANTIF/H3K4me1_rep1_readsCounts_GB_SCALED.RDS"))
H3K4me3 = readRDS(paste0(workdir,"DATA/QUANTIF/H3K4me3_rep1_readsCounts_GB_SCALED.RDS"))
C9 = readRDS(paste0(workdir,"DATA/QUANTIF/C9_1_RPGC_readsCounts_GB_SCALED.RDS"))

H3K36me3_2C4 = readRDS(paste0(workdir,"DATA/QUANTIF/H3K36me3_2C4_RPGC_readsCounts_GB_SCALED.RDS"))
H3K36me3_2N4 = readRDS(paste0(workdir,"DATA/QUANTIF/H3K36me3_2N4_RPGC_readsCounts_GB_SCALED.RDS"))
H3K36me2_2C3 = readRDS(paste0(workdir,"DATA/QUANTIF/H3K36me2_2C3_RPGC_readsCounts_GB_SCALED.RDS"))
H3K36me2_2N3 = readRDS(paste0(workdir,"DATA/QUANTIF/H3K36me2_2N3_RPGC_readsCounts_GB_SCALED.RDS"))

pol2_ctrl_N = readRDS(paste0(workdir,"DATA/QUANTIF/pol2_ctrl_N_RPGC_readsCounts_GB_SCALED.RDS"))
pol2_nelf_N = readRDS(paste0(workdir,"DATA/QUANTIF/pol2_nelf_N_RPGC_readsCounts_GB_SCALED.RDS"))

pol2ser2P_ctrl_N = readRDS(paste0(workdir,"DATA/QUANTIF/pol2ser2P_ctrl_N_RPGC_readsCounts_GB_SCALED.RDS"))
pol2ser2P_nelf_N = readRDS(paste0(workdir,"DATA/QUANTIF/pol2ser2P_nelf_N_RPGC_readsCounts_GB_SCALED.RDS"))

H2AV_ctrl = readRDS(paste0(workdir,"DATA/QUANTIF/Q_H2AV_GB_PW_R1_f.RDS"))
H2AV_nelf = readRDS(paste0(workdir,"DATA/QUANTIF/Q_H2AV_GB_PN_R1_f.RDS"))

RAD51_ctrl = readRDS(paste0(workdir,"DATA/QUANTIF/Q_Rad51_GB_WT_bis_R1_f.RDS"))
RAD51_nelf = readRDS(paste0(workdir,"DATA/QUANTIF/Q_Rad51_GB_N_bis_R1_f.RDS"))

LIST_QUANTIF_K36=readRDS(paste0(workdir,"DATA/LIST_FEATURES/LIST_QUANTIF_K36.RDS"))
ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f=LIST_QUANTIF_K36$ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f


PAUSE_INDICE_VEC = readRDS(paste0(workdir, "DATA/LIST_FEATURES/PAUSE_INDICE_VEC.RDS"))
PAUSE_IND_pol2_start_TSS_WT_KD = PAUSE_INDICE_VEC$PAUSE_IND_pol2_start_TSS_WT_KD
ZSCORE_pol2ser2P_2C2_2N2 = PAUSE_INDICE_VEC$ZSCORE_pol2ser2P_2C2_2N2_1000_1500_WT_KD
ZSCORE_pol2ser2P_2C2_2N2_BY_WT = PAUSE_INDICE_VEC$ZSCORE_pol2ser2P_2C2_2N2_1000_1500_WT_KD_BY_WT

LIST_QUANTIF=readRDS(paste0(workdir,"DATA/LIST_FEATURES/LIST_QUANTIF.RDS"))
ZSCORE_H2AV_GB_WT_N = LIST_QUANTIF$ZSCORE_H2AV_GB_WT_N
ZSCORE_RAD51_GB_WT_N = LIST_QUANTIF$ZSCORE_RAD51_GB_WT_N


getNameList = function(Vec, topdown = "top", prct = 10){
  Vec = Vec[order(Vec, decreasing=T)]
  if(topdown %in% "top"){
    GN = names(Vec[Vec > quantile(Vec, (100-prct)/100)])
  }
  if(topdown %in% "down"){
    GN = names(Vec[Vec < quantile(Vec, (prct)/100)])
  }
  if(topdown %in% "mid"){
    tmp1 = names(Vec[Vec < quantile(Vec, (100/2-prct/2)/100)])
    tmp2 = names(Vec[Vec < quantile(Vec, (100/2-prct/2+prct)/100)])
    GN = tmp2[tmp2 %ni% tmp1]
  }
  return(GN)
}

UNPAUSED_GN = getNameList(PAUSE_IND_pol2_start_TSS_WT_KD, topdown = "down", prct = 25)
PAUSED_GN = getNameList(PAUSE_IND_pol2_start_TSS_WT_KD, topdown = "top", prct = 25)

LOW_H3K36me3 = getNameList(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f, topdown = "top", prct = 25)
HIGH_H3K36me3 = getNameList(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f, topdown = "down", prct = 25)

#####################################################################################-
#         PCA LIST  ----
#####################################################################################-

LIST_ACP_PAUSED <- list(
  H3K4me1 = H3K4me1[names(H3K4me1) %in% PAUSED_GN],
  H3K4me3 = H3K4me3[names(H3K4me3) %in% PAUSED_GN],
  H3K36me3_2C4 = H3K36me3_2C4[names(H3K36me3_2C4) %in% PAUSED_GN],
  #H3K36me3_2N4 = H3K36me3_2N4[names(H3K36me3_2N4) %in% PAUSED_GN],
  pol2_ctrl = pol2_ctrl_N[names(pol2_ctrl_N) %in% PAUSED_GN],
  H2AV_ctrl = -H2AV_ctrl[names(H2AV_ctrl) %in% PAUSED_GN],
  RAD51_ctrl = -RAD51_ctrl[names(RAD51_ctrl) %in% PAUSED_GN],
  ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f = ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f[names(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f) %in% PAUSED_GN],
  PAUSE_IND_pol2_start_TSS_WT_KD = PAUSE_IND_pol2_start_TSS_WT_KD[names(PAUSE_IND_pol2_start_TSS_WT_KD) %in% PAUSED_GN],
  ZSCORE_pol2ser2P_2C2_2N2_BY_WT = ZSCORE_pol2ser2P_2C2_2N2_BY_WT[names(ZSCORE_pol2ser2P_2C2_2N2_BY_WT) %in% PAUSED_GN],
  ZSCORE_H2AV_GB_WT_N = ZSCORE_H2AV_GB_WT_N[names(ZSCORE_H2AV_GB_WT_N) %in% PAUSED_GN],
  ZSCORE_RAD51_GB_WT_N = ZSCORE_RAD51_GB_WT_N[names(ZSCORE_RAD51_GB_WT_N) %in% PAUSED_GN]
)

LIST_ACP_UNPAUSED <- list(
  H3K4me1 = H3K4me1[names(H3K4me1) %in% UNPAUSED_GN],
  H3K4me3 = H3K4me3[names(H3K4me3) %in% UNPAUSED_GN],
  H3K36me3_2C4 = H3K36me3_2C4[names(H3K36me3_2C4) %in% UNPAUSED_GN],
  #H3K36me3_2N4 = H3K36me3_2N4[names(H3K36me3_2N4) %in% UNPAUSED_GN],
  pol2_ctrl = pol2_ctrl_N[names(pol2_ctrl_N) %in% UNPAUSED_GN],
  H2AV_ctrl = -H2AV_ctrl[names(H2AV_ctrl) %in% UNPAUSED_GN],
  RAD51_ctrl = -RAD51_ctrl[names(RAD51_ctrl) %in% UNPAUSED_GN],
  ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f = ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f[names(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f) %in% UNPAUSED_GN],
  PAUSE_IND_pol2_start_TSS_WT_KD = PAUSE_IND_pol2_start_TSS_WT_KD[names(PAUSE_IND_pol2_start_TSS_WT_KD) %in% UNPAUSED_GN],
  ZSCORE_pol2ser2P_2C2_2N2_BY_WT = ZSCORE_pol2ser2P_2C2_2N2_BY_WT[names(ZSCORE_pol2ser2P_2C2_2N2_BY_WT) %in% UNPAUSED_GN],
  ZSCORE_H2AV_GB_WT_N = ZSCORE_H2AV_GB_WT_N[names(ZSCORE_H2AV_GB_WT_N) %in% UNPAUSED_GN],
  ZSCORE_RAD51_GB_WT_N = ZSCORE_RAD51_GB_WT_N[names(ZSCORE_RAD51_GB_WT_N) %in% UNPAUSED_GN]
)

LIST_ACP_LOW_H3K36me3  <- list(
  H3K4me1 = H3K4me1[names(H3K4me1) %in% LOW_H3K36me3 ],
  H3K4me3 = H3K4me3[names(H3K4me3) %in% LOW_H3K36me3 ],
  H3K36me3_2C4 = H3K36me3_2C4[names(H3K36me3_2C4) %in% LOW_H3K36me3 ],
  H3K36me3_2N4 = H3K36me3_2N4[names(H3K36me3_2N4) %in% LOW_H3K36me3 ],
  pol2_ctrl = pol2_ctrl_N[names(pol2_ctrl_N) %in% LOW_H3K36me3 ],
  H2AV_ctrl = -H2AV_ctrl[names(H2AV_ctrl) %in% LOW_H3K36me3 ],
  RAD51_ctrl = -RAD51_ctrl[names(RAD51_ctrl) %in% LOW_H3K36me3 ],
  ZSCORE_H3K36me3 = ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f[names(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f) %in% LOW_H3K36me3 ],
  PAUSE_IND_pol2 = PAUSE_IND_pol2_start_TSS_WT_KD[names(PAUSE_IND_pol2_start_TSS_WT_KD) %in% LOW_H3K36me3 ],
  ZSCORE_pol2ser2P = ZSCORE_pol2ser2P_2C2_2N2_BY_WT[names(ZSCORE_pol2ser2P_2C2_2N2_BY_WT) %in% LOW_H3K36me3 ],
  ZSCORE_H2AV = ZSCORE_H2AV_GB_WT_N[names(ZSCORE_H2AV_GB_WT_N) %in% LOW_H3K36me3 ],
  ZSCORE_RAD51 = ZSCORE_RAD51_GB_WT_N[names(ZSCORE_RAD51_GB_WT_N) %in% LOW_H3K36me3 ]
)

LIST_ACP_HIGH_H3K36me3  <- list(
  H3K4me1 = H3K4me1[names(H3K4me1) %in% HIGH_H3K36me3 ],
  H3K4me3 = H3K4me3[names(H3K4me3) %in% HIGH_H3K36me3 ],
  H3K36me3_2C4 = H3K36me3_2C4[names(H3K36me3_2C4) %in% HIGH_H3K36me3 ],
  H3K36me3_2N4 = H3K36me3_2N4[names(H3K36me3_2N4) %in% HIGH_H3K36me3 ],
  pol2_ctrl = pol2_ctrl_N[names(pol2_ctrl_N) %in% HIGH_H3K36me3 ],
  H2AV_ctrl = -H2AV_ctrl[names(H2AV_ctrl) %in% HIGH_H3K36me3 ],
  RAD51_ctrl = -RAD51_ctrl[names(RAD51_ctrl) %in% HIGH_H3K36me3 ],
  ZSCORE_H3K36me3 = ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f[names(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f) %in% HIGH_H3K36me3 ],
  PAUSE_IND_pol2 = PAUSE_IND_pol2_start_TSS_WT_KD[names(PAUSE_IND_pol2_start_TSS_WT_KD) %in% HIGH_H3K36me3 ],
  ZSCORE_pol2ser2P = ZSCORE_pol2ser2P_2C2_2N2_BY_WT[names(ZSCORE_pol2ser2P_2C2_2N2_BY_WT) %in% HIGH_H3K36me3 ],
  ZSCORE_H2AV = ZSCORE_H2AV_GB_WT_N[names(ZSCORE_H2AV_GB_WT_N) %in% HIGH_H3K36me3 ],
  ZSCORE_RAD51 = ZSCORE_RAD51_GB_WT_N[names(ZSCORE_RAD51_GB_WT_N) %in% HIGH_H3K36me3 ]
)





LIST_ACP_1 <- list(
  H3K4me1 = H3K4me1[names(H3K4me1) %in% GNref],
  H3K4me3 = H3K4me3[names(H3K4me3) %in% GNref],
  H3K36me3_2C4 = H3K36me3_2C4[names(H3K36me3_2C4) %in% GNref],
  H3K36me3_2N4 = H3K36me3_2N4[names(H3K36me3_2N4) %in% GNref],
  pol2_ctrl = pol2_ctrl_N[names(pol2_ctrl_N) %in% GNref],
  H2AV_ctrl = -H2AV_ctrl[names(H2AV_ctrl) %in% GNref],
  RAD51_ctrl = -RAD51_ctrl[names(RAD51_ctrl) %in% GNref],
  ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f = ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f[names(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f) %in% GNref],
  PAUSE_IND_pol2_start_TSS_WT_KD = PAUSE_IND_pol2_start_TSS_WT_KD[names(PAUSE_IND_pol2_start_TSS_WT_KD) %in% GNref],
  ZSCORE_pol2ser2P_2C2_2N2_BY_WT = ZSCORE_pol2ser2P_2C2_2N2_BY_WT[names(ZSCORE_pol2ser2P_2C2_2N2_BY_WT) %in% GNref],
  ZSCORE_H2AV_GB_WT_N = ZSCORE_H2AV_GB_WT_N[names(ZSCORE_H2AV_GB_WT_N) %in% GNref],
  ZSCORE_RAD51_GB_WT_N = ZSCORE_RAD51_GB_WT_N[names(ZSCORE_RAD51_GB_WT_N) %in% GNref]
)


LIST_ACP_2 <- list(
  K27C = K27C[names(K27C) %in% GNref],
  H3K36me3_2C4 = H3K36me3_2C4[names(H3K36me3_2C4) %in% GNref],
  H3K36me3_2N4 = H3K36me3_2N4[names(H3K36me3_2N4) %in% GNref],
  H3K36me2_2C3 = H3K36me2_2C3[names(H3K36me2_2C3) %in% GNref],
  H3K36me2_2N3 = H3K36me2_2N3[names(H3K36me2_2N3) %in% GNref],
  pol2_ctrl_N = pol2_ctrl_N[names(pol2_ctrl_N) %in% GNref],
  pol2_nelf_N = pol2_nelf_N[names(pol2_nelf_N) %in% GNref],
  pol2ser2P_ctrl_N = pol2ser2P_ctrl_N[names(pol2ser2P_ctrl_N) %in% GNref],
  pol2ser2P_nelf_N = pol2ser2P_nelf_N[names(pol2ser2P_nelf_N) %in% GNref],
  H2AV_ctrl = H2AV_ctrl[names(H2AV_ctrl) %in% GNref],
  H2AV_nelf = H2AV_nelf[names(H2AV_nelf) %in% GNref],
  RAD51_ctrl = RAD51_ctrl[names(RAD51_ctrl) %in% GNref],
  RAD51_nelf = RAD51_nelf[names(RAD51_nelf) %in% GNref],
  ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f = ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f[names(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f) %in% GNref],
  PAUSE_IND_pol2_start_TSS_WT_KD = PAUSE_IND_pol2_start_TSS_WT_KD[names(PAUSE_IND_pol2_start_TSS_WT_KD) %in% GNref],
  ZSCORE_pol2ser2P_2C2_2N2 = ZSCORE_pol2ser2P_2C2_2N2[names(ZSCORE_pol2ser2P_2C2_2N2) %in% GNref],
  ZSCORE_pol2ser2P_2C2_2N2_BY_WT = ZSCORE_pol2ser2P_2C2_2N2_BY_WT[names(ZSCORE_pol2ser2P_2C2_2N2_BY_WT) %in% GNref],
  ZSCORE_H2AV_GB_WT_N = ZSCORE_H2AV_GB_WT_N[names(ZSCORE_H2AV_GB_WT_N) %in% GNref],
  ZSCORE_RAD51_GB_WT_N = ZSCORE_RAD51_GB_WT_N[names(ZSCORE_RAD51_GB_WT_N) %in% GNref]
)


LIST_ACP_3 <- list(
  K27C = K27C[names(K27C) %in% GNref],
  H3K4me1 = H3K4me1[names(H3K4me1) %in% GNref],
  H3K4me3 = H3K4me3[names(H3K4me3) %in% GNref],
  C9 = C9[names(C9) %in% GNref],
  H3K36me3_2C4 = H3K36me3_2C4[names(H3K36me3_2C4) %in% GNref],
  H3K36me3_2N4 = H3K36me3_2N4[names(H3K36me3_2N4) %in% GNref],
  pol2_ctrl_N = pol2_ctrl_N[names(pol2_ctrl_N) %in% GNref],
  H2AV_ctrl = -H2AV_ctrl[names(H2AV_ctrl) %in% GNref],
  H2AV_nelf = -H2AV_nelf[names(H2AV_nelf) %in% GNref],
  RAD51_ctrl = -RAD51_ctrl[names(RAD51_ctrl) %in% GNref],
  RAD51_nelf = -RAD51_nelf[names(RAD51_nelf) %in% GNref],
  ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f = ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f[names(ZSCORE_H3K36me3_2C4_H3K36me3_2N4_f) %in% GNref],
  PAUSE_IND_pol2_start_TSS_WT_KD = PAUSE_IND_pol2_start_TSS_WT_KD[names(PAUSE_IND_pol2_start_TSS_WT_KD) %in% GNref],
  ZSCORE_pol2ser2P_2C2_2N2_BY_WT = ZSCORE_pol2ser2P_2C2_2N2_BY_WT[names(ZSCORE_pol2ser2P_2C2_2N2_BY_WT) %in% GNref],
  ZSCORE_H2AV_GB_WT_N = ZSCORE_H2AV_GB_WT_N[names(ZSCORE_H2AV_GB_WT_N) %in% GNref],
  ZSCORE_RAD51_GB_WT_N = ZSCORE_RAD51_GB_WT_N[names(ZSCORE_RAD51_GB_WT_N) %in% GNref]
)






#####################################################################################-
#         FUNCTION  ----
#####################################################################################-

run_pca_and_dendrogram <- function(LIST_ACP, outfig, axes_var = c(1, 2), list.clust = list(c(1:2),c(1:3))) {
  df_acp <- as.data.frame(LIST_ACP)
  df_acp_clean <- na.omit(df_acp)
  
  res_pca <- prcomp(df_acp_clean, scale. = TRUE)
  pdf(outfig)
  
  fviz_eig = fviz_eig(res_pca,
           addlabels = TRUE, ncp = length(res_pca$sdev)) +
    ggtitle("Eigen values by PC") +
    theme_minimal()
  
  fviz_pca_ind = fviz_pca_ind(res_pca, 
               geom = "point",
               col.ind = "cos2", # Qualité de représentation
               epel = TRUE)
  
  fviz_pca_var = fviz_pca_var(res_pca, 
               axes = axes_var,
               col.var = "contrib", # Contribution à l'axe
               repel = TRUE)
  
  print(fviz_eig)
  print(fviz_pca_ind)
  print(fviz_pca_var)  
  
  # for (clust in list.clust) {
  #   cor_mat <- cor(t(res_pca$rotation[, clust]), method = "pearson")  # corr entre variables
  #   dist <- as.dist((1 - cor_mat) / 2)
  #   hc <- hclust(dist, method = "ward.D")
  #   plot(hc, main = paste0("Dendrogram of variables on PCA axes ", paste(clust, collapse = ",")),
  #        xlab = "", sub = "")
  # }
  
  for (clust in list.clust){
    dist <- dist(res_pca$rotation[, clust], method = "euclidian")
    hc <- hclust(dist, method = "ward.D")
    plot(hc, main = paste0("Dendrogram of variables projected on PCA axes ", paste(clust, collapse = ",")),
         xlab = "", sub = "")
  }
  
  dev.off()
}


#####################################################################################-
#         PLOT  ----
#####################################################################################-

run_pca_and_dendrogram(LIST_ACP_1, outfig = paste0(outfig,"ACP_LIST_1.pdf"), axes_var = c(1,2), list.clust = list(c(1:5),c(1:9)))

run_pca_and_dendrogram(LIST_ACP_2, outfig = paste0(outfig,"ACP_LIST_2.pdf"), axes_var = c(1,2), list.clust = list(c(1:4),c(1:10)))




run_pca_and_dendrogram(LIST_ACP_PAUSED, outfig = paste0(outfig,"ACP_LIST_PAUSED_GN.pdf"), axes_var = c(1,2), list.clust = list(c(1:5),c(1:9),c(1:10)))
run_pca_and_dendrogram(LIST_ACP_UNPAUSED, outfig = paste0(outfig,"ACP_LIST_UNPAUSED_GN.pdf"), axes_var = c(1,2), list.clust = list(c(1:4),c(1:9),c(1:10)))


run_pca_and_dendrogram(LIST_ACP_LOW_H3K36me3, outfig = paste0(outfig,"ACP_LIST_LOW_H3K36me3.pdf"), axes_var = c(1,2), list.clust = list(c(1:3),c(1:7),c(1:9)))
run_pca_and_dendrogram(LIST_ACP_HIGH_H3K36me3, outfig = paste0(outfig,"ACP_LIST_HIGH_H3K36me3.pdf"), axes_var = c(1,2), list.clust = list(c(1:5),c(1:9)))



