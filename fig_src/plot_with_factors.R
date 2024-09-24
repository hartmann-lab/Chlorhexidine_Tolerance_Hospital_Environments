library(openxlsx)
library(dplyr)
library(tidyr)
library(tibble)
library(ggplot2)
library(ggpubr)
library(ggsci)
library(scatterpie)

# WIP ----
#// save.image("plot_with_factors.RData")
#// load("plot_with_factors.RData")

# import
results_all <- read.xlsx("list_isolates_CHX_MIC.xlsx", sheet = "list")[c("ID", "SamplingEvent", "AssociatedSpaceType", "Specification",	"STSp", "Location", "BA", "CHX","MIC_final_37")]

touch <- read.xlsx("/Users/jiaxianshen/Documents/HartmannLab/RushProject/Rush_Culture_DataProcessing/Data_TSAI/touch_frequency.xlsx", sheet = 1)[1:2]
# Modify touch assignment according to Mary's suggestion
touch$Touch[touch$Touch == "Doorsill"] <- "No"




# summarize results_all ----
sum(is.na(results_all$MIC_final_37))   # 0
sum(is.na(results_all$Location))  # 0
sum(is.na(results_all$BA))  # 116
sum(is.na(results_all$CHX))  # 203

# add missing data
results_all$BA[which(is.na(results_all$BA))] <- "Not available"

# count ----
results_all_summary <- results_all %>%
  count(Location, BA, MIC_final_37)

# add touch category ----
results_all_summary$Touch <- touch$Touch[match(results_all_summary$Location, touch$Location )]

# convert data type
results_all_summary <- results_all_summary %>%
  mutate(across(c(Location, BA, MIC_final_37, Touch), as.factor))

# specify factor level order
results_all_summary$MIC_final_37 <- factor(results_all_summary$MIC_final_37, levels = c( "TBD", "not grow", "<=4", "8", "16", "32", "64", "128", "256", "512"))
results_all_summary$Touch <- factor(results_all_summary$Touch, levels = c("High", "Medium", "Low", "No", "Sink" ))
results_all_summary$Location <- factor(results_all_summary$Location, levels = c("BR", 
                                                                                "CALL", "KI", "KO", "SI", "DI", "DO", "SINK"))
# Remove not grow and TBD ----
results_all_summary_mod <- results_all_summary %>%
  filter(!(MIC_final_37 %in% c( "TBD", "not grow")))


# make plots ----
# * scatterpie chart ----
results_all_summary_mod_pie <- results_all_summary_mod %>%
  pivot_wider(names_from = BA, values_from = n)


results_all_summary_mod_pie <- results_all_summary_mod_pie %>%                                        # Create ID by group
  group_by(Location) %>%
  dplyr::mutate(location_id = cur_group_id()) %>%
  ungroup()

results_all_summary_mod_pie <- results_all_summary_mod_pie %>%                                        # Create ID by group
  group_by(MIC_final_37) %>%
  dplyr::mutate(MIC_id = cur_group_id()) %>%
  ungroup()

# Re-order columns
# Reorder column by name
results_all_summary_mod_pie <- results_all_summary_mod_pie[, c("Touch", "Location", "location_id", "MIC_final_37", "MIC_id", "1", "2", "3", "0", "Not available")]

results_all_summary_mod_pie[is.na(results_all_summary_mod_pie)] <- 0


results_all_summary_mod_pie$n <- rowSums(results_all_summary_mod_pie[,c("1", "2", "3", "0", "Not available")])
#write.xlsx(results_all_summary_mod_pie, file = "figures/results_all_summary_mod_pie.xlsx")


# ** scaled based on area ----
p <- ggplot()+
  geom_scatterpie(aes(x=location_id, y=MIC_id, r=0.06*sqrt(n)), cols=c("1", "2", "3", "0", "Not available"), data = results_all_summary_mod_pie) +
  # geom_point(aes(size = n, color = Location)) +
  # geom_text(aes(label = isolate_no), vjust = -0.5, colour = "black") + 
  labs(title=NULL, x="Location", y="CHG MIC at 37 °C (\u03BCg/mL)") +
  scale_x_continuous(breaks=seq(1,7,1)) +
  scale_y_continuous(breaks=seq(1,8,1)) +
  scale_fill_nejm(name = "Blood hemolysis",
                 breaks = c("1", "2", "3", "0", "Not available"),
                 labels = c("\u03B2", "\u03B1", "\u03B3", "no growth", NA)) +
  theme_bw() +
  theme(axis.text.x = element_text(size = 14, vjust = 0.5, hjust = 0.5),  # vjust/hjust is between 0 and 1 
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 16, face = "plain"),  
        legend.title = element_text(size=16, face="plain"),
        legend.text = element_text(size = 14, face = "plain"),
        legend.position = "none")  

p
ggsave(filename="figures/mic_location_scatterpie_scale_20240903.pdf", plot=p2, device=cairo_pdf, width = 6.6, height = 6.4, units = "in", dpi = 300) 
