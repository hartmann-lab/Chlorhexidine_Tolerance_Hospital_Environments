# Clean the entire rgi_mge dataframe ----
# rgi_mge$mic[which(is.na(rgi_mge$mic))] <- "Not available"

rgi_mge <- rgi_mge %>% mutate_if(is.character, as.factor)

# order factor levels
rgi_mge$mic <- factor(rgi_mge$mic, levels = c('<=4',	'4', 	'8',	'16', 	'32', 	'64', 	'128', '256',	'512',	'Not available'))
rgi_mge$mge_carried_yes <- factor(rgi_mge$mge_carried_yes, levels = c("No", "Yes"))
rgi_mge$mge_associated_yes <- factor(rgi_mge$mge_associated_yes, levels = c("No", "Yes"))

# Weird, with Rank converted to factor, Best_Hit_ARO has to remain character to get the correct y-axis order
rgi_mge$Rank <- factor(rgi_mge$Rank, levels = c("Q1", "Q2", "Q3", "Q4", "RI=0", "Not available"))
rgi_mge$Best_Hit_ARO <- as.character(rgi_mge$Best_Hit_ARO)



# * add order_help column ----
# by MIC
rgi_mge <- rgi_mge %>%                                        # Create ID by group
  group_by(mic) %>%
  dplyr::mutate(order_help_mic = cur_group_id()) %>%
  ungroup()

# by MIC and species
rgi_mge <- rgi_mge %>%                                        # Create ID by group
  group_by(mic, species) %>%
  dplyr::mutate(order_help_mic_species = cur_group_id()) %>%
  ungroup()
#// write.xlsx(rgi_mge, file = "table/rgi_mge.xlsx")

# * How many manual editing ----
rgi_mge_manual <- rgi_mge %>%
  group_by(species, sample_id, Best_Hit_ARO, mic) %>%
  summarise(arg_copy = n_distinct(ORF_ID)) %>%
  ungroup()
#// write.xlsx(rgi_mge_manual, file = file.path("/Users/jiaxianshen/Library/CloudStorage/OneDrive-SharedLibraries-NorthwesternUniversity/ORG-RSRCH-HARTMANNLABORATORY - CHX_manuscript/manuscript_stage_collaboration/arrange_fig_4to6_v20240814", "rgi_mge_manual.xlsx"))

rgi_mge_manual_ls <- list()
for (ii in c("Stenotrophomonas maltophilia", "Elizabethkingia miricola", "Pseudomonas aeruginosa")){
  rgi_mge_manual_ls[[ii]] <- rgi_mge_manual %>%
    filter(species == ii)
  print(paste(ii, nrow(subset(rgi_mge_manual_ls[[ii]], arg_copy >= 2))))
}
# [1] "Stenotrophomonas maltophilia 4"
# [1] "Elizabethkingia miricola 7"
# [1] "Pseudomonas aeruginosa 2"


# Stenotrophomonas maltophilia ----
# * plot: MIC ----
p_Smalt_mic <- ggplot(subset(rgi_mge, species == "Stenotrophomonas maltophilia"), aes(x = forcats::fct_reorder(sample_id, order_help_mic), y = mic)) +
  geom_point(size = 3, alpha = 1) +
  labs(title = "", x = "Bacterial isolate", y = "CHG MIC\n(\u03BCg/mL)") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Smalt_mic

 # * plot: ARG ----
p_Smalt_ARG <- ggplot(subset(rgi_mge, species == "Stenotrophomonas maltophilia"), aes(x = forcats::fct_reorder(sample_id, order_help_mic), y = Best_Hit_ARO, color =mge_carried_yes, shape = mge_associated_yes)) +
  geom_point(size = 3, stroke = 1.5, alpha=0.7) + 
  scale_color_igv(name = "MGE-carried") +
  scale_shape_manual(name = "MGE-associated",
                     values=c(22, 15)) + # circle: c(1, 19) or square: c(0, 15), c(22, 15)
  # color code: 
  labs(title = "", x = "Bacterial isolate", y = "Antibiotic resistance gene (ARG)") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Smalt_ARG

# * plot: ARG number ----
p_Smalt_ARG_no <- ggplot(subset(rgi_mge, species == "Stenotrophomonas maltophilia"), aes(x = forcats::fct_reorder(sample_id, order_help_mic))) +
  geom_point(aes(y = n_ARG, color = "n_ARG"), size = 3, alpha = 0.6, shape = 7) +
  geom_point(aes(y = n_ARG_mobile, color = "n_ARG_mobile"), size = 3, alpha = 1) +
  geom_point(aes(y = n_ARG_on_plasmid, color  = "n_ARG_on_plasmid"), size = 2.5, alpha = 0.6, shape = 23, stroke = 1.5) +
  labs(title = "", x = "Bacterial isolate", y = "ARG\nnumber") +
  theme_bw() +
  scale_colour_manual(name = "ARG number",
                      labels = c("Total ARGs", "Mobile ARGs", "ARGs on plasmids"),
                      values = c("#000000", "#E69F00", "#CC79A7")) + 
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Smalt_ARG_no

p_Smalt <- patchwork::wrap_plots(
  p_Smalt_ARG_no,  p_Smalt_ARG, p_Smalt_mic,
  ncol = 1, nrow = 3,
  heights = c(0.35, 1,  0.35),
  guides = 'collect') + plot_layout(axes = "collect", axis_titles = 'collect') & theme(legend.position = 'bottom')

p_Smalt

# * save main plots ----
ggsave(filename="figure_4to6_20240814/p_Smalt.pdf", plot=p_Smalt, device=cairo_pdf, width = 10, height = 9, units = "in", dpi = 300) 

# * plot health risk annotation of ARGs ----
p_Smalt_RI <- ggplot(subset(rgi_mge, species == "Stenotrophomonas maltophilia"), aes(x = "Rank", y = Best_Hit_ARO, fill = Rank)) +
  geom_tile() +
  # scale_fill_brewer(palette = "RdYlBu") +
  scale_fill_manual(name = "Health risk index (RI) rank",
                    values = c("#D73027", "#91BFDB", "white")) +
  # used palette "RdYlBu", color code: c("#D73027", "#FC8D59", "#FEE090", "#E0F3F8", "#91BFDB", "#4575B4")
  # scale_fill_brewer(palette = "RdBu") +
  labs(title = "", x = "", y = "Antibiotic resistance gene (ARG)") +
  guides(fill = guide_legend(nrow = 1)) +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Smalt_RI

ggsave(filename="figure/p_Smalt_RI.pdf", plot=p_Smalt_RI, device=cairo_pdf, width = 10, height = 9, units = "in", dpi = 300) 




# Elizabethkingia miricola ----
# * plot: MIC ----
p_Emiri_mic <- ggplot(subset(rgi_mge, species == "Elizabethkingia miricola"), aes(x = forcats::fct_reorder(sample_id, order_help_mic), y = mic)) +
  geom_point(size = 3, alpha = 1) +
  labs(title = "", x = "Bacterial isolate", y = "CHG MIC\n(\u03BCg/mL)") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Emiri_mic

# * plot: ARG ----
p_Emiri_ARG <- ggplot(subset(rgi_mge, species == "Elizabethkingia miricola"), aes(x = forcats::fct_reorder(sample_id, order_help_mic), y = Best_Hit_ARO, color =mge_carried_yes, shape = mge_associated_yes)) +
  geom_point(size = 3, stroke = 1.5, alpha=0.7) + 
  scale_color_igv(name = "MGE-carried" ) +
  scale_shape_manual(name = "MGE-associated",
                     values=c(22, 15)) +
  labs(title = "", x = "Bacterial isolate", y = "Antibiotic resistance gene (ARG)") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Emiri_ARG


# * plot: ARG number ----
p_Emiri_ARG_no <- ggplot(subset(rgi_mge, species == "Elizabethkingia miricola"), aes(x = forcats::fct_reorder(sample_id, order_help_mic))) +
  geom_point(aes(y = n_ARG, color = "n_ARG"), size = 3, alpha = 0.6, shape = 7) +
  geom_point(aes(y = n_ARG_mobile, color = "n_ARG_mobile"), size = 3, alpha = 1) +
  geom_point(aes(y = n_ARG_on_plasmid, color  = "n_ARG_on_plasmid"), size = 2.5, alpha = 0.6, shape = 23, stroke = 1.5) +
  labs(title = "", x = "Bacterial isolate", y = "ARG\nnumber") +
  scale_colour_manual(name = "ARG number",
                      labels = c("Total ARGs", "Mobile ARGs", "ARGs on plasmids"),
                      values = c("#000000", "#E69F00", "#CC79A7")) + 
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Emiri_ARG_no

# * Combine ----
p_Emiri <- patchwork::wrap_plots(
  p_Emiri_ARG_no,  p_Emiri_ARG, p_Emiri_mic,
  ncol = 1, nrow = 3,
  heights = c(0.35, 1,  0.35),
  guides = 'collect') + plot_layout(axes = "collect", axis_titles = 'collect') & theme(legend.position = 'bottom')

p_Emiri 

# * save main plots ----
ggsave(filename="figure_4to6_20240814/p_Emiri.pdf", plot=p_Emiri, device=cairo_pdf, width = 10, height = 9, units = "in", dpi = 300) 

# * plot health risk annotation of ARGs ----
p_Emiri_RI <- ggplot(subset(rgi_mge, species == "Elizabethkingia miricola"), aes(x = "Rank", y = Best_Hit_ARO, fill = Rank)) +
  geom_tile() +
  # scale_fill_brewer(palette = "RdYlBu") +
  scale_fill_manual(name = "Health risk index (RI) rank",
                    values = c("#D73027", "#91BFDB", "white")) +
  # used palette "RdYlBu", color code: c("#D73027", "#FC8D59", "#FEE090", "#E0F3F8", "#91BFDB", "#4575B4")
  # scale_fill_brewer(palette = "RdBu") +
  labs(title = "", x = "", y = "Antibiotic resistance gene (ARG)") +
  guides(fill = guide_legend(nrow = 1)) +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Emiri_RI

ggsave(filename="figure/p_Emiri_RI.pdf", plot=p_Emiri_RI, device=cairo_pdf, width = 10, height = 9, units = "in", dpi = 300) 


# Pseudomonas aeruginosa ----
# * plot: MIC ----
p_Paeru_mic <- ggplot(subset(rgi_mge, species == "Pseudomonas aeruginosa"), aes(x = forcats::fct_reorder(sample_id, order_help_mic), y = mic)) +
  geom_point(size = 3, alpha = 1) +
  labs(title = "", x = "Bacterial isolate", y = "CHG MIC\n(\u03BCg/mL)") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Paeru_mic

# * plot: ARG ----
p_Paeru_ARG <- ggplot(subset(rgi_mge, species == "Pseudomonas aeruginosa"), aes(x = forcats::fct_reorder(sample_id, order_help_mic), y = Best_Hit_ARO, color =mge_carried_yes, shape = mge_associated_yes)) +
  geom_point(size = 3, stroke = 1.5, alpha=0.7) + 
  scale_color_igv(name = "MGE-carried" ) +
  scale_shape_manual(name = "MGE-associated",
                     values=c(22, 15)) +
  labs(title = "", x = "Bacterial isolate", y = "Antibiotic resistance gene (ARG)") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Paeru_ARG


# * plot: ARG number ----
p_Paeru_ARG_no <- ggplot(subset(rgi_mge, species == "Pseudomonas aeruginosa"), aes(x = forcats::fct_reorder(sample_id, order_help_mic))) +
  geom_point(aes(y = n_ARG, color = "n_ARG"), size = 3, alpha = 0.6, shape = 7) +
  geom_point(aes(y = n_ARG_mobile, color = "n_ARG_mobile"), size = 3, alpha = 1) +
  geom_point(aes(y = n_ARG_on_plasmid, color  = "n_ARG_on_plasmid"), size = 2.5, alpha = 0.6, shape = 23, stroke = 1.5) +
  labs(title = "", x = "Bacterial isolate", y = "ARG\nnumber") +
  scale_colour_manual(name = "ARG number",
                      labels = c("Total ARGs", "Mobile ARGs", "ARGs on plasmids"),
                      values = c("#000000", "#E69F00", "#CC79A7")) + 
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 12, angle = 0, hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Paeru_ARG_no

# * combine ----
p_Paeru <- patchwork::wrap_plots(
  p_Paeru_ARG_no,  p_Paeru_ARG, p_Paeru_mic,
  ncol = 1, nrow = 3,
  heights = c(0.1, 1,  0.1),
  guides = 'collect') + plot_layout(axes = "collect", axis_titles = 'collect') & theme(legend.position = 'bottom')

p_Paeru

# * save main plots ----
ggsave(filename="figure_4to6_20240814/p_Paeru.pdf", plot=p_Paeru, device=cairo_pdf, width = 10, height = 16, units = "in", dpi = 300) 


# * plot health risk annotation of ARGs ----
p_Paeru_RI <- ggplot(subset(rgi_mge, species == "Pseudomonas aeruginosa"), aes(x = "Rank", y = Best_Hit_ARO, fill = Rank)) +
  geom_tile() +
  # scale_fill_brewer(palette = "RdYlBu") +
  scale_fill_manual(name = "Health risk index (RI) rank",
    values = c("#D73027", "#FC8D59", "#FEE090", "#4575B4", "#91BFDB", "white")) +
  # used palette "RdYlBu", color code: c("#D73027", "#FC8D59", "#FEE090", "#E0F3F8", "#91BFDB", "#4575B4")
  # scale_fill_brewer(palette = "RdBu") +
  labs(title = "", x = "", y = "Antibiotic resistance gene (ARG)") +
  guides(fill = guide_legend(nrow = 1)) +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Paeru_RI

ggsave(filename="figure/p_Paeru_RI.pdf", plot=p_Paeru_RI, device=cairo_pdf, width = 15, height = 16, units = "in", dpi = 300) 
# 具体缩放比例到时候用inkscape拼接的时候再调整




