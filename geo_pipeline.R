############################################################
# GEO Differential Expression Pipeline
# Dataset : GSE63514
# Disease : Cervical Cancer
############################################################

# ---------- Install/Load Packages ----------
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

pkgs <- c(
  "GEOquery","Biobase","limma","preprocessCore",
  "ggplot2","pheatmap"
)

for (p in pkgs){
  if(!requireNamespace(p, quietly = TRUE))
    BiocManager::install(p, ask = FALSE, update = FALSE)
  library(p, character.only = TRUE)
}

dir.create("results", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

# ---------- Download Dataset ----------
geo_id <- "GSE63514"

dir.create("data", showWarnings = FALSE)
options(timeout = 600)

gse <- getGEO(geo_id, GSEMatrix = TRUE, destdir = "data")
eset <- gse[[1]]

# ---------- Explore ----------
mat <- exprs(eset)
meta <- pData(eset)

cat("Dimensions:\n")
print(dim(mat))
cat("\nMetadata columns:\n")
print(colnames(meta))

# ---------- Missing Values ----------
cat("\nMissing values:", sum(is.na(mat)), "\n")

# ---------- Log2 transform if needed ----------
qx <- quantile(mat, c(0,0.25,0.5,0.75,0.99,1), na.rm=TRUE)

LogC <- (qx[5] > 100) ||
  (qx[6]-qx[1] > 50 && qx[2] > 0)

if(LogC){
  mat[mat<=0] <- NA
  mat <- log2(mat)
}

# ---------- QC Plots ----------
png("figures/boxplot_before.png",1200,700)
boxplot(mat, outline=FALSE, las=2,
        main="Before Normalization")
dev.off()

png("figures/density_before.png",1200,700)
plot(density(mat[,1], na.rm=TRUE),
     main="Density Before Normalization")
for(i in 2:ncol(mat)){
  lines(density(mat[,i], na.rm=TRUE))
}
dev.off()

# ---------- Quantile Normalization ----------
mat_norm <- normalize.quantiles(mat)
rownames(mat_norm) <- rownames(mat)
colnames(mat_norm) <- colnames(mat)

png("figures/boxplot_after.png",1200,700)
boxplot(mat_norm, outline=FALSE, las=2,
        main="After Quantile Normalization")
dev.off()

# ---------- Experimental Design ----------
group <- ifelse(grepl("Normal", meta$title),
                "Control","Case")

group <- factor(group,
                levels=c("Control","Case"))

design <- model.matrix(~group)
colnames(design) <- c("Intercept","Case_vs_Control")

# ---------- Differential Expression ----------
fit <- lmFit(mat_norm, design)
fit <- eBayes(fit)

results <- topTable(
  fit,
  coef="Case_vs_Control",
  number=Inf,
  sort.by="P"
)

sig <- subset(
  results,
  adj.P.Val < 0.05 &
    abs(logFC) > 1
)

up <- subset(sig, logFC > 0)
down <- subset(sig, logFC < 0)

cat("Upregulated:", nrow(up), "\n")
cat("Downregulated:", nrow(down), "\n")

# ---------- Volcano Plot ----------
volcano <- results
volcano$Status <- "Not Significant"
volcano$Status[
  volcano$adj.P.Val < 0.05 &
    volcano$logFC > 1] <- "Up"
volcano$Status[
  volcano$adj.P.Val < 0.05 &
    volcano$logFC < -1] <- "Down"

p <- ggplot(volcano,
            aes(logFC,-log10(adj.P.Val),
                colour=Status)) +
  geom_point(size=1.2) +
  theme_minimal() +
  ggtitle("Volcano Plot")

ggsave("figures/volcano_plot.png",
       p,width=8,height=6)

# ---------- PCA ----------

gene_var <- apply(mat_norm, 1, var)

mat_pca <- mat_norm[gene_var > 0, ]

pca <- prcomp(t(mat_pca), scale. = TRUE)

png("figures/PCA.png",900,700)

plot(
  pca$x[,1],
  pca$x[,2],
  col=group,
  pch=19,
  xlab="PC1",
  ylab="PC2",
  main="PCA"
)

legend(
  "topright",
  legend=levels(group),
  col=1:2,
  pch=19
)

dev.off()


# ---------- Heatmap ----------
top50 <- head(rownames(sig),50)

if(length(top50)>2){
  png("figures/heatmap.png",1000,900)
  pheatmap(mat_norm[top50,],
           scale="row")
  dev.off()
}

# ---------- Export ----------
results$ProbeID <- rownames(results)
sig$ProbeID <- rownames(sig)
up$ProbeID <- rownames(up)
down$ProbeID <- rownames(down)

write.csv(results,
          "results/GSE63514_all_results.csv",
          row.names=FALSE)

write.csv(sig,
          "results/GSE63514_significant_genes.csv",
          row.names=FALSE)

write.csv(up,
          "results/GSE63514_upregulated.csv",
          row.names=FALSE)

write.csv(down,
          "results/GSE63514_downregulated.csv",
          row.names=FALSE)

cat("\nPipeline completed successfully!\n")