####
# prerequisite r scripts to run:
# rgi.R, ARG_within_MGE.R
####


# check number of isolates
metadata %>%
  filter(mic %in% c("128", "256", "512")) %>%
  nrow()


# 1. Plot: ARG (x axis: isolate) ----
# * count manual polishing operations ----
# for p_high_isolates_ARG_1
rgi_mge_manual %>%
  filter(mic %in% c("128", "256", "512") & species != "Pseudomonas aeruginosa") %>%
  summarise(n_operation = sum(arg_copy >= 2))
# 19

# for p_high_isolates_ARG_2
rgi_mge_manual %>%
  filter(mic %in% c("128", "256", "512") & species == "Pseudomonas aeruginosa") %>%
  summarise(n_operation = sum(arg_copy >= 2))
# 0

# * not Pseudomonas aeruginosa ----
p_high_isolates_ARG_1 <- ggplot(subset(rgi_mge, mic %in% c("128", "256", "512") & species != "Pseudomonas aeruginosa"), aes(x = forcats::fct_reorder(sample_id, order_help_mic_species), y = Best_Hit_ARO)) +
  geom_point(aes( color = mge_carried_yes, shape = mge_associated_yes),
              size = 3, stroke = 1.5, alpha=0.7) +
  scale_color_igv(name = "MGE-carried" ) +
  scale_shape_manual(name = "MGE-associated",
                     values=c(22, 15)) +
 # side plot: xside
 geom_xsidetile(aes(y = "Species", xfill = species))  +
 geom_xsidepoint(aes(y = mic), size = 2)  +
 scale_xfill_manual(name = "Species",
                    values = c("#F8766D", "#C49A00", "#53B400", "#00C094", "#00B6EB", "#FB61D7"),
                   guide = guide_legend(label.theme = element_text(face = "italic"))) +
 # side plot: yside
 geom_ysidetile(aes(x = "", yfill = Rank))  +
 scale_yfill_manual(name = "Health risk index (RI) rank",
                    values = c("#D73027", "#FC8D59", "#91BFDB", "white")) +
 # set side plot option
  ggside(x.pos = "bottom", y.pos = "left") +
  labs(title = "", x = "Bacterial isolate", y = "Antibiotic resistance gene (ARG)") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_text(size = 11, face = "plain", hjust = 0.5), # this is smaller than normal
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) +
  guides(colour = guide_legend(order = 1), 
         shape = guide_legend(order = 2))

p_high_isolates_ARG_1

ggsave(filename="figure_4to6_20240814/p_high_isolates_ARG_1.pdf", plot=p_high_isolates_ARG_1, device=cairo_pdf, width = 14, height = 9, units = "in", dpi = 300) 

# ** ARG number ----
p_high_isolates_ARG_1_no <- ggplot(subset(rgi_mge, mic %in% c("128", "256", "512") & species != "Pseudomonas aeruginosa"), aes(x = forcats::fct_reorder(sample_id, order_help_mic_species), y = Best_Hit_ARO)) +
  geom_point(aes(y = n_ARG, color = "n_ARG"), size = 3, alpha = 0.6, shape = 7) +
  geom_point(aes(y = n_ARG_mobile, color = "n_ARG_mobile"), size = 3, alpha = 1) +
  geom_point(aes(y = n_ARG_on_plasmid, color  = "n_ARG_on_plasmid"), size = 2.5, alpha = 0.6, shape = 23, stroke = 1.5) +
  labs(title = "", x = "", y = "ARG\nnumber") +
  theme_bw() +
  scale_colour_manual(name = "ARG number",
                      labels = c("Total ARGs", "Mobile ARGs", "ARGs on plasmids"),
                      values = c("#000000", "#E69F00", "#CC79A7")) + 
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 11, face = "plain", hjust = 0.5), # this is smaller than normal
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_high_isolates_ARG_1_no

ggsave(filename="figure_4to6_20240814/p_high_isolates_ARG_1_no.pdf", plot=p_high_isolates_ARG_1_no, device=cairo_pdf, width = 7.5, height = 3, units = "in", dpi = 300) 

# * Pseudomonas aeruginosa ----
p_high_isolates_ARG_2 <- ggplot(subset(rgi_mge, mic %in% c("128", "256", "512") & species == "Pseudomonas aeruginosa"), aes(x = forcats::fct_reorder(sample_id, order_help_mic_species), y = Best_Hit_ARO)) +
  geom_point(aes(color = mge_carried_yes, shape = mge_associated_yes),
             size = 3, stroke = 1.5, alpha=0.7) + 
  scale_color_igv(name = "MGE-carried" ) +
  scale_shape_manual(name = "MGE-associated",
                     values=c(22, 15)) +
  geom_xsidetile(aes(y = "Species", xfill = species))  +
  geom_xsidepoint(aes(y = mic), size = 2)  +
  scale_xfill_manual(name = "Species",
                     values = c("#A58AFF"),
                     guide = guide_legend(label.theme = element_text(face = "italic"))) +
  geom_ysidetile(aes(x = "", yfill = Rank))  +
  scale_yfill_manual(name = "Health risk index (RI) rank",
                    values = c("#D73027", "#FC8D59", "#FEE090", "#4575B4", "#91BFDB", "white")) +
  ggside(x.pos = "bottom", y.pos = "left") +
  labs(title = "", x = "Bacterial isolate", y = "Antibiotic resistance gene (ARG)") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_text(size = 12, face = "plain", hjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) +
  guides(colour = guide_legend(order = 1), 
         shape = guide_legend(order = 2))

p_high_isolates_ARG_2

ggsave(filename="figure_4to6_20240814/p_high_isolates_ARG_2.pdf", plot=p_high_isolates_ARG_2, device=cairo_pdf, width = 10, height = 11, units = "in", dpi = 300) 


# ** ARG number ----
p_high_isolates_ARG_2_no <- ggplot(subset(rgi_mge, mic %in% c("128", "256", "512") & species == "Pseudomonas aeruginosa"), aes(x = forcats::fct_reorder(sample_id, order_help_mic_species), y = Best_Hit_ARO)) +
  geom_point(aes(y = n_ARG, color = "n_ARG"), size = 3, alpha = 0.6, shape = 7) +
  geom_point(aes(y = n_ARG_mobile, color = "n_ARG_mobile"), size = 3, alpha = 1) +
  geom_point(aes(y = n_ARG_on_plasmid, color  = "n_ARG_on_plasmid"), size = 2.5, alpha = 0.6, shape = 23, stroke = 1.5) +
  labs(title = "", x = "", y = "ARG\nnumber") +
  theme_bw() +
  scale_colour_manual(name = "ARG number",
                      labels = c("Total ARGs", "Mobile ARGs", "ARGs on plasmids"),
                      values = c("#000000", "#E69F00", "#CC79A7")) + 
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 12, face = "plain", hjust = 0.5), 
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_high_isolates_ARG_2_no

ggsave(filename="figure_4to6_20240814/p_high_isolates_ARG_2_no.pdf", plot=p_high_isolates_ARG_2_no, device=cairo_pdf, width = 4.5, height = 3, units = "in", dpi = 300) 


# 2. Plot: prevalence and abundance of resistance mechanisms across high-mic isolates (x axis: isolate) ----
rgi_mge_high_resis_mech_dis <- rgi_mge %>% 
  filter(mic %in% c("128", "256", "512")) %>%
  count(sample_id, mic, species, order_help_mic_species, Resistance_Mechanism)

# * plot ----
p_high_isolates_resis_mech <- ggplot(rgi_mge_high_resis_mech_dis, aes(x = forcats::fct_reorder(sample_id, order_help_mic_species), y = Resistance_Mechanism)) +
  geom_tile(aes(fill = n)) +
  geom_text(aes(label = n), color = "white") + 
  scale_fill_viridis(name = "Count") +
  geom_xsidetile(aes(y = "Species", xfill = species))  +
  geom_xsidepoint(aes(y = mic))  +
  ggside(x.pos = "bottom") +
  scale_xfill_manual(name = "Species",
                     values = c("#F8766D", "#C49A00", "#53B400", "#00C094", "#00B6EB", "#A58AFF", "#FB61D7"),
                     guide = guide_legend(label.theme = element_text(face = "italic"))) +
  labs(title = "", x = "Bacterial isolate", y = "Resistance mechanism") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_text(size = 11, angle = 0, hjust = 0.5),  # smaller than normal
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_high_isolates_resis_mech

ggsave(filename="figure/p_high_isolates_resistance_mechanism_distribution.pdf", plot=p_high_isolates_resis_mech , device=cairo_pdf, width = 16, height = 7, units = "in", dpi = 300) 
ggsave(filename="figure/p_high_isolates_resistance_mechanism_distribution_with_text.pdf", plot=p_high_isolates_resis_mech , device=cairo_pdf, width = 16, height = 7, units = "in", dpi = 300) 

# 3. Plot: resistance mechanisms | high-mic (x axis: species) ----
# Distribution across species
# df 1
rgi_mge_high_resis_species_mech_dis_pre <- rgi_mge %>% 
  filter(mic %in% c("128", "256", "512")) %>%
  count(sample_id, species, Resistance_Mechanism)

# count how many isolates belonging to each species
rgi_mge_high_resis_species_mech_dis_pre %>%
  group_by(species) %>%
  summarise(n_isolates = n_distinct(sample_id))

rgi_mge_high_resis_species_mech_dis <- rgi_mge_high_resis_species_mech_dis_pre %>%
  group_by(species, Resistance_Mechanism) %>%
  summarise(Count_mean = mean(n))

rgi_mge_high_resis_species_mech_dis$Count_mean_round <- round(rgi_mge_high_resis_species_mech_dis$Count_mean, 0)

# df2
rgi_mge_high_resis_species_n_ARG_stat <- rgi_mge %>%
  filter(mic %in% c("128", "256", "512")) %>%
  select(species, n_ARG, n_ARG_mobile, n_ARG_on_plasmid)
  
rgi_mge_high_resis_species_n_ARG_stat <- pivot_longer(rgi_mge_high_resis_species_n_ARG_stat, starts_with("n_"), names_to = "Category", values_to = "Count") 
  
rgi_mge_high_resis_species_n_ARG_stat <- rgi_mge_high_resis_species_n_ARG_stat %>%
  group_by(species, Category) %>%
  summarise(Count_mean = mean(Count), Count_se = sd(Count)/sqrt(length(Count))) %>%
  ungroup() %>%
  as.data.frame()

# * plot 1 (species, resis mech) ----
p_high_isolates_species_resis_mech <- ggplot(rgi_mge_high_resis_species_mech_dis, aes(x = species, y = Resistance_Mechanism)) +
  geom_tile(aes(fill = Count_mean_round)) +
  geom_text(aes(label = Count_mean_round), color = "white") + 
  scale_fill_viridis(name = "Count", option = "B") +
  scale_x_discrete(breaks = c('Cupriavidus metallidurans', 
                              'Delftia tsuruhatensis', 
                              'Delftia tsuruhatensis or Delftia acidovorans', 
                              'Delftia tsuruhatensis or Delftia acidovorans or Stenotrophomonas maltophilia', 
                              'Elizabethkingia miricola', 
                              'Pseudomonas aeruginosa', 
                              'Stenotrophomonas maltophilia'), 
                  labels = c('Cupriavidus metallidurans', 
                             'Delftia tsuruhatensis', 
                             'Delftia tsuruhatensis or\nDelftia acidovorans', 
                             'Delftia tsuruhatensis or\nDelftia acidovorans or\nStenotrophomonas maltophilia', 
                             'Elizabethkingia miricola', 
                             'Pseudomonas aeruginosa', 
                             'Stenotrophomonas maltophilia')) +
  labs(title = "", x = "Species", y = "Resistance mechanism") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_text(size = 11, angle = -45, vjust = 0.8, hjust = 0),  # smaller than normal
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_high_isolates_species_resis_mech

# save separate figures
#// ggsave(filename="figure/p_high_species_resistance_mechanism_distribution_element_1.pdf", plot=p_high_isolates_species_resis_mech, device=cairo_pdf, width = 12, height = 6, units = "in", dpi = 300)

# * plot 2 (species, n_ARG) ----
p_high_isolates_species_n_ARG_stat <- ggplot(rgi_mge_high_resis_species_n_ARG_stat, aes(x = species, y = Count_mean, group = Category, color = Category, shape = Category)) +
  geom_point(size = 3, stroke = 1, alpha = 0.9) +
  geom_errorbar(aes(ymin = Count_mean - Count_se, ymax = Count_mean + Count_se), width=.15) +
  labs(title = "", x = "", y = "ARG\nnumber") +
  theme_bw() +
  scale_color_manual(name = "ARG number",
                      breaks = c("n_ARG", "n_ARG_mobile", "n_ARG_on_plasmid"),
                      labels = c("Total ARGs", "Mobile ARGs", "ARGs on plasmids"),
                      values = c("#000000", "#E69F00", "#CC79A7")) +
  scale_shape_manual(name = "ARG number",
                      breaks = c("n_ARG", "n_ARG_mobile", "n_ARG_on_plasmid"),
                      labels = c("Total ARGs", "Mobile ARGs", "ARGs on plasmids"),
                      values = c(7, 16, 23)) +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        # axis.text.x = element_text(size = 11, angle = -30, vjust = 0.8, hjust = 0),  # smaller than normal
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_high_isolates_species_n_ARG_stat

# save separate figures
#// ggsave(filename="figure/p_high_species_resistance_mechanism_distribution_element_2.pdf", plot=p_high_isolates_species_n_ARG_stat, device=cairo_pdf, width = 11, height = 3, units = "in", dpi = 300)


# * cowplot ----
# main plot
p_high_isolates_species <- plot_grid(p_high_isolates_species_n_ARG_stat + theme(legend.position="none"),
                                     NULL,
                                     p_high_isolates_species_resis_mech + theme(legend.position="none"),
                                     ncol = 1, 
                                     align = "vh",
                                     axis = 'lr',
                                     rel_heights = c(0.6, -0.3, 1))

p_high_isolates_species

# save plot
ggsave(filename="figure/p_high_species_resistance_mechanism_distribution.pdf", plot=p_high_isolates_species, device=cairo_pdf, width = 12, height = 9, units = "in", dpi = 300) 
