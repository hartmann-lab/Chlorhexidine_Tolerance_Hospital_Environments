# Libraries ----
library(dplyr)  # For data manipulation
library(ggplot2)  # For data visualization
library(RColorBrewer)
library(scales)
library(tidyr)
library(rstatix)
library(ggpubr)
library(openxlsx)
library(stringr)
library(Cairo)

setwd("")

# WIP ----
#// save.image("chx_persistence.RData")
#// load("chx_persistence.RData")


# Function ----
# function 1: import CHG concentration raw data and transform to long format
# 24 biological replicates (triplicate + 8 trials)
# unit: concentration - ug/ml, time - h
chx_import <- function(file_name_surface, cleaning_mode){
  # read excel sheet (absorbance part)
  df <- read.xlsx(file_name_surface, sheet = cleaning_mode)[1:18,1:8]  
  
  # Add time and replicate info to the wide format table
  df$time <- rep(c(0,
                   1/6,
                   1,
                   3,
                   6,
                   24), each = 3)
  
  df$replicate <- rep(c(1,2,3), times = 6)
  
  # transform wide format to long format
  df2 <- pivot_longer(df, starts_with("Trial"), names_to = "trial", values_to = "absorbance")
  df2$trial <- str_sub(df2$trial, -1)  # clean trial text
  
  
  # add columns: cleaning mode & surface type
  df2$cleaning <- cleaning_mode
  df2$surface <- str_split_i(file_name_surface, "[.]", 1) 
  
  
  return(df2)
}

# import raw data from 3 surfaces and 6 cleaning modes ----
ls_raw <- list()

file_name_surface <- c("Wood.xlsx", "Metal.xlsx", "Plastic.xlsx")
cleaning_mode <- c("C", "W", "Q", "P", "B", "E")


for (ii in 1:3){
  for (jj in 1:6){
    
    ls_raw[[length(ls_raw)+1]] <- chx_import(file_name_surface[ii], cleaning_mode[jj])
    
  }
}

# merge into one dataframe
df_raw <- do.call("rbind", ls_raw)

# add recovery rate
df_raw <- df_raw %>%
  mutate(recovery_rate = case_when(
    surface == "Wood" ~ 55.58/100 ,
    surface == "Metal" ~ 83.04/100 ,
    surface == "Plastic" ~ 69.79/100
  ))

# calculate from absorbance to concentration per area ----
# unit: con_vol - ug/ml; con_area - ug/cm^2; time - h
# recovery rate was included in the calculation
df <- df_raw %>%
  mutate(con_vol = (absorbance/143.22)*10000,
         con_area = (con_vol*0.8)/(2.54^2)/recovery_rate
         )


# convert data type
df <- df %>%
  mutate(across(c(time, replicate, trial, cleaning, surface), as.factor))

df$cleaning <- factor(df$cleaning, levels = c("C", "W", "Q", "P", "B", "E"))


# Statistical test ----
# * 0 + 0.16 ----
df_imme <- df[df$time %in% c("0", "0.166666666666667" ), ]


ttest.imme <- df_imme %>%
  group_by(surface, cleaning) %>%
  t_test(con_area ~ time,  paired = TRUE,  alternative = "greater") %>%
  add_significance()
#// write.xlsx(ttest.imme, file = "analysis_JS/statistics_ttest_immediate_impact.xlsx")



# * 0 + 24 ----
df_24 <- df[df$time %in% c("0", "24" ), ]

ttest.24 <- df_24 %>%
  group_by(surface, cleaning) %>%
  t_test(con_area ~ time,  paired = TRUE,  alternative = "greater") %>%
  add_significance()
#// write.xlsx(ttest.24, file = "analysis_JS/statistics_ttest_0_24h.xlsx")

# calculate mean and standard error ----
df_mean <- df %>%
  group_by(surface, cleaning, time) %>%
  summarise(con_area_mean = mean(con_area),
            con_area_se = sd(con_area)/sqrt(length((con_area)))) %>%
  ungroup()


# * plot ---- 
p1 <- ggplot(df_mean, aes(x=time, y=con_area_mean, group=cleaning, color=cleaning)) +
  geom_line() + 
  geom_point(size = 2)+
  geom_errorbar(aes(x=time, ymin=con_area_mean-con_area_se, ymax=con_area_mean+con_area_se), width=.2, position=position_dodge(0.05))+
  xlab("Time (h)")+ 
  ylab(bquote('CHG concentration (\u03BCg/c'*m^2*')')) +
  # coord_cartesian(ylim = c(0, 7e5)) +
  scale_x_discrete(breaks=c("0", "0.166666666666667", "1", "3", "6", "24"),
                   labels=c("0", "0.17", "1", "3", "6", "24")) +
  scale_color_manual(name  ="Cleaning practice",
                    breaks=c("C", "W", "Q", "P", "B", "E"),
                    values = c("black", "#1B9E77", "#D95F02", "#7570B3", "#E7298A", "#66A61E"),
                    labels=c("No cleaning", "Water", "Benzalkonium chloride", "Peracetic acid", "Bleach", "Ethanol")) +
  theme_bw() +
  theme(axis.text.x = element_text(size = 14, vjust = 0.5, hjust = 0.5),    
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 16, face = "plain"),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 14),
        legend.position = "bottom",
        panel.spacing=unit(0, "lines"),
        strip.text = element_text(size=14),
        strip.background=element_rect(fill = NA)) + 
  facet_grid(surface ~ cleaning, labeller = labeller(surface = c(Metal = "Metal [steel]", Plastic = "Plastic [HDPE]", Wood = "Wood"),  cleaning = c(C="No cleaning", W= "Water", Q= "Benzalkonium\nchloride", P= "Peracetic acid", B= "Bleach", E= "Ethanol")))
  

p1

ggsave(filename="analysis_JS/CHG_persistence_on_surface.pdf", plot=p1, device=cairo_pdf, width = 11.5, height = 7.5, units = "in", dpi = 300) 
 

# Reduction ----
# Difference between 10 min (and/or 24 hours) and amount applied. Percent relative to the initial amount
# * 10 min ----
df_rd_imme <- df %>%
  select(c("time", "replicate", "trial",  "cleaning", "surface", "con_area")) %>%
  filter(time %in% c(0, 0.166666666666667)) %>%
  pivot_wider(names_from = time, values_from = con_area) %>%
  mutate(con_area_rd = `0.166666666666667` - `0`,
         con_area_rd_perc = con_area_rd / `0` * 100 )

df_rd_imme_mean <- df_rd_imme %>%
  group_by(surface, cleaning) %>%
  summarise(con_area_rd_perc_mean = mean(con_area_rd_perc),
            con_area_rd_perc_se = sd(con_area_rd_perc)/sqrt(length((con_area_rd_perc)))) %>%
  ungroup()

# ** stats test ----
ttest.rd.imme <- list()
ttest.rd.imme[["all"]] <- df_rd_imme %>%
  group_by(surface) %>%
  pairwise_t_test(con_area_rd_perc ~ cleaning, p.adjust.method = "BH") %>%
  add_significance()
ttest.rd.imme[["ref_C"]] <- df_rd_imme %>%
  group_by(surface) %>%
  pairwise_t_test(con_area_rd_perc ~ cleaning, p.adjust.method = "BH", ref.group = "C",  alternative = "less") %>%
  add_significance()
ttest.rd.imme[["ref_W"]] <- df_rd_imme %>%
  group_by(surface) %>%
  pairwise_t_test(con_area_rd_perc ~ cleaning, p.adjust.method = "BH", ref.group = "W",  alternative = "less") %>%
  add_significance()
openxlsx::write.xlsx(ttest.rd.imme, "analysis_JS/statistics_ttest_reduction_percent_10min.xlsx", rowNames = FALSE)

# ** plot ----
p_rd_imme <- ggplot(df_rd_imme_mean, aes(x=cleaning, y=con_area_rd_perc_mean, fill = cleaning)) +
  geom_col(alpha = 0.8)+
  geom_errorbar(aes(x=cleaning, ymin=con_area_rd_perc_mean-con_area_rd_perc_se, ymax=con_area_rd_perc_mean+con_area_rd_perc_se), width=.2, position=position_dodge(0.05))+
  xlab("Cleaning practice")+ 
  ylab(bquote('Change in CHG concentration: 10 min vs. initial (%)')) +
  scale_x_discrete(breaks=c("C", "W", "Q", "P", "B", "E"),
                   labels=c("No cleaning", "Water", "Benzalkonium\nchloride", "Peracetic\nacid", "Bleach", "Ethanol")) +
  scale_y_continuous(limits = c(-28.7, 17.2)) + 
  scale_fill_manual(name  ="Cleaning practice",
                    breaks=c("C", "W", "Q", "P", "B", "E"),
                    values = c("black", "#1B9E77", "#D95F02", "#7570B3", "#E7298A", "#66A61E"),
                    # this version: brewer.pal(5, "Dark2")
                    # previous version: c("black","#619CFF","#00BA38", "#F8766D", "#B79F00", "#00BFC4"),
                    labels=c("No cleaning", "Water", "Benzalkonium chloride", "Peracetic acid", "Bleach", "Ethanol")) +
  theme_bw() +
  theme(axis.text.x = element_text(size = 14, vjust = 1, hjust = 0.8, angle = 30),    
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 16, face = "plain"),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 14),
        legend.position = "bottom",
        panel.spacing=unit(0, "lines"),
        strip.text = element_text(size=14),
        strip.background=element_rect(fill = NA)) + 
  facet_grid(surface ~ ., labeller = labeller(surface = c(Metal = "Metal [steel]", Plastic = "Plastic [HDPE]", Wood = "Wood")))


p_rd_imme
ggsave(filename="analysis_JS/CHG_change_10min_percent.pdf", plot=p_rd_imme, device=cairo_pdf, width = 5.8, height = 7.3, units = "in", dpi = 300) 

 # * 24 h ----
df_rd_24 <- df %>%
  select(c("time", "replicate", "trial",  "cleaning", "surface", "con_area")) %>%
  filter(time %in% c(0, 24)) %>%
  pivot_wider(names_from = time, values_from = con_area) %>%
  mutate(con_area_rd = `24` - `0`,
         con_area_rd_perc = con_area_rd / `0` * 100)

df_rd_24_mean <- df_rd_24 %>%
  group_by(surface, cleaning) %>%
  summarise(con_area_rd_perc_mean = mean(con_area_rd_perc),
            con_area_rd_perc_se = sd(con_area_rd_perc)/sqrt(length((con_area_rd_perc)))) %>%
  ungroup()


# ** stats test ----
ttest.rd.24 <- list()
ttest.rd.24[["all"]] <- df_rd_24 %>%
  group_by(surface) %>%
  pairwise_t_test(con_area_rd_perc ~ cleaning, p.adjust.method = "BH") %>%
  add_significance()
ttest.rd.24[["ref_C"]] <- df_rd_24 %>%
  group_by(surface) %>%
  pairwise_t_test(con_area_rd_perc ~ cleaning, p.adjust.method = "BH", ref.group = "C",  alternative = "less") %>%
  add_significance()
ttest.rd.24[["ref_W"]] <- df_rd_24 %>%
  group_by(surface) %>%
  pairwise_t_test(con_area_rd_perc ~ cleaning, p.adjust.method = "BH", ref.group = "W",  alternative = "less") %>%
  add_significance()
openxlsx::write.xlsx(ttest.rd.24, "analysis_JS/statistics_ttest_reduction_percent_24.xlsx", rowNames = TRUE)

# ** plot ----
p_rd_24 <- ggplot(df_rd_24_mean, aes(x=cleaning, y=con_area_rd_perc_mean, fill = cleaning)) +
  geom_col(alpha = 0.8)+
  geom_errorbar(aes(x=cleaning, ymin=con_area_rd_perc_mean-con_area_rd_perc_se, ymax=con_area_rd_perc_mean+con_area_rd_perc_se), width=.2, position=position_dodge(0.05))+
  xlab("Cleaning practice")+ 
  ylab(bquote('Change in CHG concentration: 24 h vs. initial (%)')) +
  scale_x_discrete(breaks=c("C", "W", "Q", "P", "B", "E"),
                   labels=c("No cleaning", "Water", "Benzalkonium\nchloride", "Peracetic\nacid", "Bleach", "Ethanol")) +
  scale_y_continuous(limits = c(-28.7, 17.2)) + 
  scale_fill_manual(name  ="Cleaning practice",
                     breaks=c("C", "W", "Q", "P", "B", "E"),
                     values = c("black", "#1B9E77", "#D95F02", "#7570B3", "#E7298A", "#66A61E"),
                     # this version: brewer.pal(5, "Dark2")
                     # previous version: c("black","#619CFF","#00BA38", "#F8766D", "#B79F00", "#00BFC4"),
                     labels=c("No cleaning", "Water", "Benzalkonium chloride", "Peracetic acid", "Bleach", "Ethanol")) +
  theme_bw() +
  theme(axis.text.x = element_text(size = 14, vjust = 1, hjust = 0.8, angle = 30),       
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 16, face = "plain"),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 14),
        legend.position = "bottom",
        panel.spacing=unit(0, "lines"),
        strip.text = element_text(size=14),
        strip.background=element_rect(fill = NA)) + 
  facet_grid(surface ~ ., labeller = labeller(surface = c(Metal = "Metal [steel]", Plastic = "Plastic [HDPE]", Wood = "Wood")))


p_rd_24
ggsave(filename="analysis_JS/CHG_change_24h_percent.pdf", plot=p_rd_24, device=cairo_pdf,  width = 5.8, height = 7.3, units = "in", dpi = 300) 



