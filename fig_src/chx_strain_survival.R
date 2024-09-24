# Libraries ----
library(dplyr)  # For data manipulation
library(ggplot2)  # For data visualisation
library(ggsci)
library(scales)
library(tidyr)
library(ggpubr)
library(openxlsx)
library(stringr)
library(Cairo)

library(rstatix)
library(DescTools)


# Function ----
# function 1: import viability data (CFU) and transform to long format
# unit: concentration - %
chx_via_import <- function(file_name, sheet_name){
  # read excel sheet
  df <- read.xlsx(file_name, sheet = sheet_name)[1:5,1:4]
  # rename column name
  names(df)[names(df) == "%.CHX"] <- "CHX_percent" 
  
  # transform wide format to long format
  df_long <- pivot_longer(df, 2:4, names_to = "replicate", values_to = "CFU") 
  
  # add strain info
  df_long$strain <- sheet_name
  
  return(df_long)
}

# import all data into a list ----
ls_sheet_name <- c("ATCC25922", "ATCC13883", "20-20012", "ATCC29213")

ls_via <- list()

for (ii in 1:length(ls_sheet_name)){
  ls_via[[ii]] <- chx_via_import("Microbial Survival Results_compiled_JS.xlsx", ls_sheet_name[ii])
}

# merge into one dataframe
df_via_all <- do.call("rbind", ls_via)

# change data type
df_via_all <- df_via_all %>%
  mutate(across(c(CHX_percent, CFU), as.numeric))


# calculate CHX (or CHG, need to confirm) concentration to ug/cm2 ----
df_via_all <- df_via_all %>%
  mutate(con_per_area = CHX_percent*10000*0.2/(2.54^2),
         cfu_per_area = CFU/(2.54^2))

df_via_all$con_per_area <- round(df_via_all$con_per_area, 2)

# calculate log10(CFU) and perform t test
df_via_all$log10_cfu_per_area <- log10(df_via_all$cfu_per_area)

# adjust data type
df_via_all <- df_via_all %>%
  mutate(across(c(CHX_percent, replicate, strain, con_per_area), as.factor))


ttest.via.log10CFU_per_area <- df_via_all %>%
  group_by(strain) %>%
  t_test(log10_cfu_per_area ~ con_per_area,  
         ref.group = "0",
         paired = TRUE,
         alternative = "greater",
         p.adjust.method = "BH") %>%
  add_significance()


ttest.via.CFU_per_area <- df_via_all %>%
  group_by(strain) %>%
  t_test(cfu_per_area ~ con_per_area,  
         ref.group = "0",
         paired = TRUE,
         alternative = "greater",
         p.adjust.method = "BH") %>%
  add_significance()





# calculate mean and standard error ----
df_via_all_mean <- df_via_all %>%
  group_by(strain, con_per_area) %>%
  summarise(cfu_area_mean = mean(cfu_per_area),
            cfu_area_se = sd(cfu_per_area)/sqrt(length((cfu_per_area))),
            log10_cfu_area_mean = mean(log10_cfu_per_area),
            log10_cfu_area_se = sd(log10_cfu_per_area)/sqrt(length((log10_cfu_per_area)))
            ) %>%
  ungroup()

#// write.xlsx(df_via_all_mean, file = "output_Microbial Survival Results_mean.xlsx")



# plot ----
# * point plot ----
p_survi_point <- ggplot(df_via_all_mean, aes(x=con_per_area, y=cfu_area_mean, group=strain, color=strain)) +
  geom_line() + 
  geom_point(size = 3.5)+
  geom_errorbar(aes(x=con_per_area, ymin=cfu_area_mean-cfu_area_se, ymax=cfu_area_mean+cfu_area_se), width=.2, position=position_dodge(0.05))+
  xlab(bquote('CHG concentration (\u03BCg/c'*m^2*')'))+ 
  ylab(bquote("Cultivable bacteria (CFU/c"*m^2*')')) +
  scale_y_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  # coord_cartesian(ylim = c(0, 7e5)) +
  # scale_x_discrete(breaks=c("0", "0.16666666666666666", "1", "3", "6", "24"),
  #                  labels=c("0", "0.17", "1", "3", "6", "24")) + 
  # scale_color_discrete(name  ="Bacterial strain",
  #                    c("ATCC25922", "ATCC13883", "20-20012", "ATCC29213"),
  #                    labels=c("Escherichia coli [ATCC25922]", "Klebsiella pneumoniae [ATCC13883]", "Klebsiella pneumoniae [20-20012]", "Staphylococcus aureus [ATCC29213]")) +
  scale_color_jama()+
  theme_bw() +
  theme(axis.text.x = element_text(size = 14, vjust = 0.5, hjust = 0.5),    
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 16, face = "plain"),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 14, face = "italic"),
        legend.position = "none",
        panel.spacing=unit(0, "lines"),
        strip.text = element_text(size=14, face = "italic")) + 
  facet_grid(~strain, labeller = labeller(strain = c(ATCC25922 = "Escherichia coli\n[ATCC25922]", ATCC13883 = "Klebsiella pneumoniae\n[ATCC13883]", "20-20012" = "Klebsiella variicola\n[20-20012]", ATCC29213 = "Staphylococcus aureus\n[ATCC29213]")))


p_survi_point

ggsave(filename="analysis_JS/bacteria_survival_on_CHG_surface_point.pdf", plot=p_survi_point, device=cairo_pdf, width = 9, height = 4, units = "in", dpi = 300) 


