# * plot: ARG (with side plots of MIC and Health risk index) ----
p_Aradi_ARG <- ggplot(subset(rgi_mge, species == "Acinetobacter radioresistens"), 
                      aes(x = forcats::fct_reorder(sample_id, order_help_mic_species), y = Best_Hit_ARO)) +
  geom_jitter(aes(color = mge_carried_yes, shape = mge_associated_yes),
              size = 3,
              stroke = 2,
              height = 0, width = 0.2, alpha=0.7) + 
  scale_color_igv(name = "MGE-carried" ) +
  scale_shape_manual(name = "MGE-associated",
                     values=c(1, 19)) +
  # side plot: xside
  geom_xsidepoint(aes(y = mic))  +
  # side plot: yside
  geom_ysidetile(aes(x = "", yfill = Rank))  +
  scale_yfill_manual(name = "Health risk index (RI) rank",
                     values = c("#91BFDB", "white")) +
  # set side plot option
  ggside(x.pos = "bottom", y.pos = "left") +
  labs(title = "Acinetobacter radioresistens", x = "Bacterial isolate", y = "Antibiotic resistance gene (ARG)") +
  theme_bw() +
  theme(plot.title = element_text(size = 14, face = "italic", hjust = 0.5),
        axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "italic"),
        axis.text.x = element_text(size = 11, face = "plain", hjust = 0.5), # this is smaller than normal
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "right",
        plot.margin = unit(c(0,4,0,4), units = "pt")) +
  guides(colour = guide_legend(order = 1), 
         shape = guide_legend(order = 2))

p_Aradi_ARG

ggsave(filename="figure/p_Aradi_ARG.pdf", plot=p_Aradi_ARG, device=cairo_pdf, width = 5, height = 5, units = "in", dpi = 300) 


# * plot: ARG number ----
p_Aradi_ARG_no <- ggplot(subset(rgi_mge, species == "Elizabethkingia miricola"), aes(x = forcats::fct_reorder(sample_id, order_help_mic))) +
  geom_point(aes(y = n_ARG, color = "n_ARG"), size = 3, alpha = 0.6, shape = 7) +
  geom_point(aes(y = n_ARG_mobile, color = "n_ARG_mobile"), size = 3, alpha = 0.3) +
  geom_point(aes(y = n_ARG_on_plasmid, color  = "n_ARG_on_plasmid"), size = 2.5, alpha = 0.6, shape = 23, stroke = 1.5) +
  labs(title = "", x = "", y = "ARG\nnumber") +
  scale_colour_manual(name = "ARG number",
                      labels = c("Total ARGs", "Mobile ARGs", "ARGs on plasmids"),
                      values = c("#000000", "#E69F00", "#CC79A7")) + 
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, face = "plain", angle = 0, hjust = 0),
        legend.position = "bottom",
        plot.margin = unit(c(0,4,0,4), units = "pt")) 

p_Aradi_ARG_no
ggsave(filename="figure/p_Aradi_ARG_no.pdf", plot=p_Aradi_ARG_no, device=cairo_pdf, width = 4, height = 2.4, units = "in", dpi = 300)

