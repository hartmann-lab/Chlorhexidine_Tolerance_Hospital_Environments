# Dataframe cleaning and preparation ----
plasmids_qacEdelta1 <- rgi_plasmid_dis %>%
  filter(str_detect(Best_Hit_ARO_concat, "qacEdelta1"))

plasmids_qacEdelta1$sample_contig <- paste0(plasmids_qacEdelta1$sample_id, "_", plasmids_qacEdelta1$contig_id)
plasmids_qacEdelta1 <- plasmids_qacEdelta1 %>%
  mutate(scaffold_length = str_split_i(contig_id, "_", 4),
         scaffold_coverage = str_split_i(contig_id, "_", 6)
  )
#// write.xlsx(plasmids_qacEdelta1, "table/plasmids_qacEdelta1.xlsx")


plasmids_qacEdelta1_rgi <- rgi_mge %>%
  filter(sample_contig %in% plasmids_qacEdelta1$sample_contig) %>%
  droplevels()

# add column: logical format orientation
plasmids_qacEdelta1_rgi$Orientation_logi <- ifelse(plasmids_qacEdelta1_rgi$Orientation == "+", TRUE, FALSE)

plasmids_qacEdelta1_rgi <- plasmids_qacEdelta1_rgi %>%
  relocate(Orientation_logi, .after = Orientation)

# Order columns for plotting
plasmids_qacEdelta1_rgi$sample_id <- factor(plasmids_qacEdelta1_rgi$sample_id, levels = c("S5", 	"S44", 	"S37", 	"S13", 	"S14", 	"S30"))
# reorder ARGs
plasmids_qacEdelta1_rgi$Best_Hit_ARO <- as.factor(as.character(plasmids_qacEdelta1_rgi$Best_Hit_ARO))

#// write.xlsx(plasmids_qacEdelta1_rgi, "table/plasmids_qacEdelta1_rgi.xlsx")

# plot gggenes ----
p_plasmids_qacEdelta1 <- ggplot(plasmids_qacEdelta1_rgi, aes(xmin = Start, xmax = Stop, y = sample_id, fill = Best_Hit_ARO, label = Best_Hit_ARO, forward = Orientation_logi)) +
  geom_gene_arrow(arrowhead_height = unit(3, "mm"), arrowhead_width = unit(1, "mm")) +
  geom_gene_label(align = "left") +
  facet_wrap(~ sample_id, scales = "free", ncol = 1) +
  scale_y_discrete(breaks = c('S13', 'S14', 'S30', 'S37', 'S44', 'S5'), 
                   labels = c('S13\nCupriavidus metallidurans', 'S14\nCupriavidus metallidurans', 'S30\nCitrobacter amalonaticus\nor Citrobacter freundii', 'S37\nPseudomonas aeruginosa', 'S44\nPseudomonas aeruginosa', 'S5\nPseudomonas aeruginosa')) +
  labs(title = "", x = "Plasmid contig", y = "Bacterial isolate") +
  # color palette: "Set3" from RColorBrewer
  # brewer.pal(10, "Set3") -> re-order
  scale_fill_manual(name = "ARG",
                    values = c("#8DD3C7",  "#BEBADA",  "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#FFFFB3", "#D9D9D9", "#BC80BD", "#FB8072")) +
  theme_genes() + 
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "italic", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 


p_plasmids_qacEdelta1

ggsave(filename="figure/p_plasmids_qacEdelta1.pdf", plot=p_plasmids_qacEdelta1, device=cairo_pdf, width = 8.5, height = 5, units = "in", dpi = 300) 



# Extract these plasmid sequences for similarity checking ----
# extract sequences from fasta files and write to a single txt file
# file_input
# file_output
# parent_path = "/Users/jiaxianshen/Library/CloudStorage/OneDrive-NorthwesternUniversity/_FromNUBox/phd_chx/wgs/spades_scaffolds" in this case
extract_contig_seq <- function(parent_path, sample_id, contig_id, file_output){
  file_input <- paste0(parent_path, "/", sample_id, "/scaffolds.fasta")
  
  fin  <- file(file_input, open = "r")
  fout  <- file(file_output, open = "w")
  
  while (length(line <- readLines(fin, n = 1, warn = FALSE)) > 0) {
    contig_id <-  grep(">.*", line, value = TRUE)
    
    writeLines(contig_id, fout)
  }
  
  close(fin)
  close(fout)
  
}


# List the data frame for pairwise similarity checking ----
# Generate all unique pairwise combinations
plasmids_qacEdelta1_simi <- plasmids_qacEdelta1 %>%
  group_split(species) %>%
  lapply(as.data.frame)

plasmids_qacEdelta1_simi <- plasmids_qacEdelta1_simi[sapply(plasmids_qacEdelta1_simi, nrow) > 1]


for (ii in 1:length(plasmids_qacEdelta1_simi)){
  names(plasmids_qacEdelta1_simi)[ii] <- plasmids_qacEdelta1_simi[[ii]]$species[1]
    
  if (nrow(plasmids_qacEdelta1_simi[[ii]]) > 1){
  plasmids_qacEdelta1_simi[[ii]] <- as.data.frame(t(combn(plasmids_qacEdelta1_simi[[ii]]$sample_id, 2)))
  plasmids_qacEdelta1_simi[[ii]]$species <- names(plasmids_qacEdelta1_simi)[ii]
  }
}
# merge into one data frame
plasmids_qacEdelta1_simi <-  do.call("rbind", plasmids_qacEdelta1_simi)