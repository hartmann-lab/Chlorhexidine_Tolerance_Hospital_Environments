# Introduction ----
# author: Jiaxian Shen (jiaxianshen2022@u.northwestern.edu)
# date: 2019-06-06
# purpose: 



# Libraries ----
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggsci)
library(car)
library(openxlsx)
library(ggpubr)
library(scales)
library(rstatix)
library(ggsignif)
library(viridis)

# Set the working directory ----
setwd("")

# WIP ----
#// save.image("fig_new_v2/CFU_normalized_by_area.RData")
#// load("fig_new_v2/CFU_normalized_by_area.RData")


# Import data ----
# check the data type of columns of interest by str()
area <- read.csv("Data_TSAI/area_location_rectangular.csv")
metadata_a <- read.csv("Data_TSAI/ProcessedData/rush_growth_colony_metadata_A.csv")[-1]
metadata_b <- read.csv("Data_TSAI/ProcessedData/rush_growth_colony_metadata_B.csv")[-1]

# Normalize by area ----
# * metadata_a ----
# merge dataframe (1. area; 2. metadata_a) to add area information into metadata_a 
# PB needs to be treated separately sicne area of PB_1 and PB_2 are different
area$STLO <- paste(area$AssociatedSpaceType, area$Location, sep = "_")

metadata_a$STLO <- paste(metadata_a$AssociatedSpaceType, metadata_a$Location, sep = "_")

# every associated space type except PB
df_meta <- filter(metadata_a, AssociatedSpaceType != "PB")
df_area <- filter(area, AssociatedSpaceType != "PB")

df_meta <- merge(df_meta, df_area, by = "STLO", all.x=TRUE)


# PB
df_meta_pb <- filter(metadata_a, AssociatedSpaceType == "PB")
df_area_pb <- filter(area, AssociatedSpaceType == "PB")

df_area_pb$STLO <- paste(df_area_pb$STSp, df_area_pb$Location, sep = "_")

df_meta_pb$STLO <- paste(df_meta_pb$STSp, df_meta_pb$Location, sep = "_")

df_meta_pb <- merge(df_meta_pb, df_area_pb, by = "STLO", all.x=TRUE)


# sum up the rows in df_meta and df_meta_pb
metadata_a_area <- rbind(df_meta, df_meta_pb)

# select only the columns that I need
metadata_a_area <- dplyr::select(metadata_a_area, Sample_ID, SamplingEvent, AssociatedSpaceType.x, STSp.x, Location.x, Touch , Growth, Count , Diversity, CHX, Dilution, CFU, CFU_CHX, CHX_Res, area_cm2)

# rename to exclude ".x"
metadata_a_area <- rename(metadata_a_area, AssociatedSpaceType = AssociatedSpaceType.x, STSp = STSp.x, Location = Location.x)

# add area_m2 column
metadata_a_area <- mutate(metadata_a_area, area_m2 = area_cm2 / 10000.0)

# calculate cfu per cm2
# * 4.5 because the samples were collected in 4.5 mL buffer for sampling event A
metadata_a_area <- mutate(metadata_a_area, 
                          CFU_cm2 = CFU * 4.5 / area_cm2, 
                          CFU_m2 = CFU * 4.5 / area_m2,
                          CFU_CHX_cm2 = CFU_CHX * 4.5 / area_cm2,
                          CFU_CHX_m2 = CFU_CHX * 4.5 / area_m2)






# * metadata_b ----
# merge dataframe (1. area; 2. metadata_b) to add area information into metadata_b 
# PB needs to be treated separately sicne area of PB_1 and PB_2 are different
metadata_b$STLO <- paste(metadata_b$AssociatedSpaceType, metadata_b$Location, sep = "_")

# every associated space type except PB
df_meta_b <- filter(metadata_b, AssociatedSpaceType != "PB")

df_meta_b <- merge(df_meta_b, df_area, by = "STLO", all.x=TRUE)


# PB
df_meta_b_pb <- filter(metadata_b, AssociatedSpaceType == "PB")

df_meta_b_pb$STLO <- paste(df_meta_b_pb$STSp, df_meta_b_pb$Location, sep = "_")

df_meta_b_pb <- merge(df_meta_b_pb, df_area_pb, by = "STLO", all.x=TRUE)


# sum up the rows in df_meta_b and df_meta_b_pb
metadata_b_area <- rbind(df_meta_b, df_meta_b_pb)

# select only the columns that I need
metadata_b_area <- dplyr::select(metadata_b_area, Sample_ID, SamplingEvent, AssociatedSpaceType.x, STSp.x, Location.x, Touch , Growth, Count , Diversity, CHX, Dilution, CFU, CFU_CHX, CHX_Res, area_cm2)

# rename to exclude ".x"
metadata_b_area <- rename(metadata_b_area, AssociatedSpaceType = AssociatedSpaceType.x, STSp = STSp.x, Location = Location.x)

# add area_m2 column
metadata_b_area <- mutate(metadata_b_area, area_m2 = area_cm2 / 10000.0)

# calculate cfu per cm2
# * 3.5 because the samples were collected in 3.5 mL buffer for sampling event B
metadata_b_area <- mutate(metadata_b_area, 
                          CFU_cm2 = CFU * 3.5 / area_cm2, 
                          CFU_m2 = CFU * 3.5 / area_m2,
                          CFU_CHX_cm2 = CFU_CHX * 3.5 / area_cm2,
                          CFU_CHX_m2 = CFU_CHX * 3.5 / area_m2)



# Add variables ----
# * touch category ----
touch <- read.xlsx("Data_TSAI/touch_frequency.xlsx", sheet = 1)[1:2]
# Modify touch assignment according to Mary's suggestion
touch$Touch[touch$Touch == "Doorsill"] <- "No"

metadata_a_area$Touch <- touch$Touch[match(metadata_a_area$Location, touch$Location )]
metadata_b_area$Touch <- touch$Touch[match(metadata_b_area$Location, touch$Location )]

# * water availability, isolation level of patient rooms, and patient mobility ----
# sampling A
metadata_a_area$water <- ifelse(metadata_a_area$Location == "SINK", "wet", "dry")

room_isolation_a <- read.xlsx("Data_TSAI/room_isolation.xlsx",
                              sheet = "sampling_event_A")

metadata_a_area$contact_isolation <- room_isolation_a$contact_isolation[match(metadata_a_area$STSp, room_isolation_a$patient_room )]
metadata_a_area$patient_mobility <- room_isolation_a$patient_mobility[match(metadata_a_area$STSp, room_isolation_a$patient_room )]

# sampling B
metadata_b_area$water <- ifelse(metadata_b_area$Location == "SINK", "wet", "dry")

room_isolation_b <- read.xlsx("Data_TSAI/room_isolation.xlsx",
                              sheet = "sampling_event_B")

metadata_b_area$contact_isolation <- room_isolation_b$contact_isolation[match(metadata_b_area$STSp, room_isolation_b$patient_room )]
metadata_b_area$patient_mobility <- room_isolation_b$patient_mobility[match(metadata_b_area$STSp, room_isolation_b$patient_room )]


# Transform data: recording counts below 3 and transform data to log10 scale ----
# * sampling A ----
metadata_a_area$LOQ <- ifelse(metadata_a_area$Count <=3, "N", "Y")  # set 3 as limit of quantification (LOQ)

metadata_a_area <- metadata_a_area %>%
  mutate(Count_mod = ifelse(Count < 3, 1.5, Count), # change Count < 3 to the half of limit of quantification (LOQ)
         CFU_mod = Count_mod*10*Dilution,
         CFU_cm2_mod = CFU_mod * 4.5 / area_cm2,
         CFU_cm2_mod_log = log10(CFU_cm2_mod)
         )  


# * sampling B ----
metadata_b_area$LOQ <- ifelse(metadata_b_area$Count <=3, "N", "Y")  # set 3 as limit of quantification (LOQ)

metadata_b_area <- metadata_b_area %>%
  mutate(Count_mod = ifelse(Count < 3, 1.5, Count), # change Count < 3 to the half of limit of quantification (LOQ)
         CFU_mod = Count_mod*10*Dilution,
         CFU_cm2_mod = CFU_mod * 3.5 / area_cm2,
         CFU_cm2_mod_log = log10(CFU_cm2_mod)
  )  



# Output normalized metadata ----
# write.csv(metadata_a_area, file = "Data_TSAI/ProcessedData/rush_growth_colony_metadata_area_A.csv", row.names = FALSE)
# write.csv(metadata_b_area, file = "Data_TSAI/ProcessedData/rush_growth_colony_metadata_area_B.csv", row.names = FALSE)

# combine sampling A and B
metadata_all_area <- rbind(metadata_a_area, metadata_b_area)


# Plot ----
# * exclude sink samples ----
metadata_all_area_dry <- metadata_all_area[which(!is.na(metadata_all_area$area_cm2)), ]
# metadata_a_area_dry <- metadata_a_area[which(!is.na(metadata_a_area$area_cm2)), ]
# metadata_b_area_dry <- metadata_b_area[which(!is.na(metadata_b_area$area_cm2)), ]  


# * change to factor ----
cols <- c("SamplingEvent","Location", "Touch", "contact_isolation", "patient_mobility", "LOQ")
metadata_all_area_dry <- metadata_all_area_dry %>% mutate_at(cols, factor)
metadata_all_area <- metadata_all_area %>% mutate_at(cols, factor)


metadata_all_area_dry$Touch <- factor(metadata_all_area_dry$Touch, levels = c("High",  "Medium", "Low", "No"))
metadata_all_area_dry$Location <- factor(metadata_all_area_dry$Location, levels = c( "BR","CALL","KI","KO","SI","SO","DI","DO"))
metadata_all_area$Touch <- factor(metadata_all_area$Touch, levels = c("High", "Medium", "Low","No", "Sink"))
metadata_all_area$Location <- factor(metadata_all_area$Location, levels = c( "BR","CALL","KI","KO","SI","SO","DI","DO","SINK"))

# metadata_a_area_dry <- metadata_a_area_dry %>% mutate_at(cols, factor)
# metadata_b_area_dry <- metadata_b_area_dry %>% mutate_at(cols, factor)




# * seasonal variation ----
# overall
compare_means(CFU_cm2_mod_log ~ SamplingEvent,  data = metadata_all_area_dry, method = "t.test")

# subset locations
metadata_all_area_dry %>%
  filter(Location != "SO") %>%
  group_by(Location) %>%
  t_test(CFU_cm2_mod_log ~ SamplingEvent, paired = FALSE) %>%
  add_significance()


p_all_event <- ggplot(metadata_all_area_dry, aes(x=Location, y=CFU_cm2_mod_log, color = SamplingEvent)) + 
  geom_boxplot() + 
  geom_point(aes(shape = LOQ, group = SamplingEvent), position = position_dodge(width = 0.5)) +
  scale_x_discrete(breaks = c( "BR","CALL","DI","DO","KI","KO","SI","SO"),
                      labels = c( "Bedrail","Nurse\ncall","Doorsill\ninside","Doorsill\noutside","Keyboard\ninside","Keyboard\noutside","Switch\ninside","Switch\noutside")) +
  scale_shape_discrete(name  ="Above LOQ",
                     breaks=c("Y", "N"), solid = F) +
  scale_color_manual(values = c('#56b4e9', '#ca9161'),
                      name  ="Sampling event",
                      labels = c("February", "July"))+
  theme_bw() +
  labs(x="Location", y=expression("Log"["10"]*("CFU/cm"^2))) +
  theme(axis.title = element_text(size = 14, face = "plain"),
        axis.text.x = element_text(size = 10, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "right")

p_all_event
# ggsave("fig_new_v3/1_seasonal_variation.pdf", width =  7, height = 5, unit = "in", dpi = 300)


# * location + touch (2_CFU_cm2_location_touch.pdf) ----
# no seasonal variation was observed, thus data from the two sampling events were combined in the following analyses 
# anova test
compare_means(CFU_cm2_mod_log ~ Location,  data = metadata_all_area_dry, method = "anova")
compare_means(CFU_cm2_mod_log ~ Touch,  data = metadata_all_area_dry, method = "anova")


# t test
compare_means(CFU_cm2_mod_log ~ Location,  data = metadata_all_area_dry, method = "t.test",  p.adjust.method = "BH", ref.group = ".all.")

metadata_all_area_dry %>%
  group_by(Touch) %>%
  t_test(CFU_cm2_mod_log ~ Location, paired = FALSE) %>%
  add_significance()
# Touch  .y.             group1 group2    n1    n2 statistic    df     p p.adj p.adj.signif
# <fct>  <chr>           <chr>  <chr>  <int> <int>     <dbl> <dbl> <dbl> <dbl> <chr>       
#   1 High   CFU_cm2_mod_log BR     CALL      18    17   -2.14    33.0 0.04  0.04  *           
#   2 Medium CFU_cm2_mod_log KI     KO        17    17   -0.769   24.0 0.45  0.45  ns          
#   3 Low    CFU_cm2_mod_log SI     SO        14    13    1.39    13.4 0.188 0.188 ns          
#   4 No     CFU_cm2_mod_log DI     DO        28    31   -0.0643  56.5 0.949 0.949 ns  

metadata_all_area_dry %>%
  t_test(CFU_cm2_mod_log ~ Touch, paired = FALSE) %>%
  adjust_pvalue(method = "BH") %>%
  add_significance()
# .y.             group1 group2    n1    n2 statistic    df        p    p.adj p.adj.signif
# <chr>           <chr>  <chr>  <int> <int>     <dbl> <dbl>    <dbl>    <dbl> <chr>       
#   1 CFU_cm2_mod_log High   Medium    35    34      4.29  53.4 7.44e- 5 1.12e- 4 ***         
#   2 CFU_cm2_mod_log High   Low       35    27     -8.83  47.5 1.38e-11 4.14e-11 ****        
#   3 CFU_cm2_mod_log High   No        35    59     -3.91  89.0 1.78e- 4 2.14e- 4 ***         
#   4 CFU_cm2_mod_log Medium Low       34    27    -20.1   58.7 5.40e-28 3.24e-27 ****        
#   5 CFU_cm2_mod_log Medium No        34    59     -7.26  71.3 3.79e-10 7.58e-10 ****        
#   6 CFU_cm2_mod_log Low    No        27    59      1.42  67.2 1.6 e- 1 1.6 e- 1 ns  

# plot and manually add significance
p_all_touch <- ggplot(metadata_all_area_dry, aes(x=Location, y=CFU_cm2_mod_log)) + 
  geom_boxplot(aes(color = Touch)) + 
  # geom_violin(aes(color = Touch)) + 
  geom_point(size = 2, aes(shape = LOQ, color = Touch)) +
  geom_text(aes(label = "~ Location, Anova, p = 2.8e-10", x = 0.5, y = 6), hjust = 0, vjust = 1, size = 5) +
  geom_text(aes(label = "~ Touch, Anova, p = 2.4e-12", x = 0.5, y = 5.5), hjust = 0, vjust = 1, size = 5) +
  geom_signif(y_position=c(2.2, 2.5, 4, 3.5,2.9, 1.6), 
              xmin=c(1.5, 3.5, 1.5, 1.5, 3.5, 1), 
              xmax=c(3.5, 5.5, 7.5, 5.5, 7.5, 2), 
              annotation=c("***", "*****", "***", "****", "****", "*"), 
              textsize = 6, size = 0.3) + 
  scale_x_discrete(breaks = c( "BR","CALL","KI","KO","SI","SO", "DI","DO"),
                      labels = c( "Bedrail","Nurse\ncall","Keyboard\ninside","Keyboard\noutside","Switch\ninside","Switch\noutside","Doorsill\ninside","Doorsill\noutside")) +
  scale_shape_discrete(name  ="Above LOQ",
                     breaks=c("Y", "N"), solid = F) +
  scale_color_discrete(name  ="Touch frequency") +
  theme_bw() +
  labs(x="Location", y=expression("Log"["10"]*("CFU/cm"^2))) +
  theme(axis.title = element_text(size = 16, face = "plain"),
        axis.text.x = element_text(size = 14, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 14),
        panel.grid = element_blank(),
        legend.title = element_text(size=16, face="plain"),
        legend.text = element_text(size = 14, face = "plain"),
        #legend.position = "bottom",
        legend.position = "none",
        legend.box = "vertical")

p_all_touch
#// ggsave(filename="fig_new_v3/2_CFU_cm2_location_touch.pdf", 
       plot=p_all_touch, 
       device=cairo_pdf, width = 7.5, height = 6, units = "in", dpi = 300) 

# * Isolation ----
# ** location+isolation ----
metadata_all_area_dry %>%
  group_by(Location) %>%
  t_test(CFU_cm2_mod_log ~ contact_isolation, paired = FALSE) %>%
  adjust_pvalue(method = "BH") %>%
  add_significance() 

p_location_isolation <- ggplot(subset(metadata_all_area_dry, !is.na(contact_isolation)), aes(x=Location, y=CFU_cm2_mod_log, color = contact_isolation)) + 
  geom_boxplot() + 
  geom_point(aes(shape = LOQ, group = contact_isolation), position = position_dodge(width = 0.5)) +
  scale_x_discrete(breaks = c( "BR","CALL","DI","DO","KI","KO","SI","SO"),
                   labels = c( "Bedrail","Nurse\ncall","Doorsill\ninside","Doorsill\noutside","Keyboard\ninside","Keyboard\noutside","Switch\ninside","Switch\noutside")) +
  scale_shape_discrete(name  ="Above LOQ",
                       breaks=c("Y", "N"), solid = F) +
  scale_color_discrete(name  ="Contact isolation") +
  theme_bw() +
  labs(x="Location", y=expression("Log"["10"]*("CFU/cm"^2))) +
  theme(axis.title = element_text(size = 14, face = "plain"),
        axis.text.x = element_text(size = 10, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "right")

p_location_isolation
# ggsave("fig_new/3_CFU_cm2_location_isolation.pdf", width =  7, height = 5, unit = "in", dpi = 300)


# ** isolation in total ----
# *** A+B ----
stat.test <- metadata_all_area_dry %>%
  t_test(CFU_cm2_mod_log ~ contact_isolation, paired = FALSE) %>%
  add_significance() %>%  # not enough data points to perform t test after grouping by location (SI: n = 4, SO: n = 3)
  add_xy_position(x = "contact_isolation")


p_isolation <- ggplot(subset(metadata_all_area_dry, !is.na(contact_isolation)), aes(x=contact_isolation, y=CFU_cm2_mod_log)) + 
  geom_boxplot() + 
  geom_point(aes(shape = LOQ), position = position_jitter(width = 0.1, height = 0)) +
  scale_shape_discrete(name  ="Above LOQ",
                       breaks=c("Y", "N"), solid = F) +
  theme_bw() +
  coord_cartesian(ylim = c(-1.5, 7)) +
  labs(x="Contact isolation", y=expression("Log"["10"]*("CFU/cm"^2))) +
  theme(axis.title = element_text(size = 14, face = "plain"),
        axis.text.x = element_text(size = 12, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "none") +
  stat_pvalue_manual(stat.test, label = "p.adj", size = 4)

p_isolation
# ggsave("fig_new/4_CFU_cm2_isolation.pdf", width =  3, height = 3, unit = "in", dpi = 300)

# *** A ----
stat.test <- metadata_all_area_dry %>%
  filter(SamplingEvent == "A") %>%
  t_test(CFU_cm2_mod_log ~ contact_isolation, paired = FALSE) %>%
  add_significance() %>%
  add_xy_position(x = "contact_isolation")

stat.test

p_isolation_a <- ggplot(filter(subset(metadata_all_area_dry, !is.na(contact_isolation)),SamplingEvent == "A") , aes(x=contact_isolation, y=CFU_cm2_mod_log)) + 
  geom_boxplot() + 
  geom_point(aes(shape = LOQ), position = position_jitter(width = 0.1, height = 0)) +
  scale_shape_discrete(name  ="Above LOQ",
                       breaks=c("Y", "N"), solid = F) +
  coord_cartesian(ylim = c(-1.5, 7)) +
  theme_bw() +
  labs(x="Contact isolation", y=expression("Log"["10"]*("CFU/cm"^2))) +
  theme(axis.title = element_text(size = 14, face = "plain"),
        axis.text.x = element_text(size = 12, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "none") +
  stat_pvalue_manual(stat.test, label = "p.adj", size = 4)

p_isolation_a
# ggsave("fig_new/5_CFU_cm2_isolation_a.pdf", width =  4, height = 4, unit = "in", dpi = 300)



# *** B ----
stat.test <- metadata_all_area_dry %>%
  filter(SamplingEvent == "B") %>%
  t_test(CFU_cm2_mod_log ~ contact_isolation, paired = FALSE) %>%
  add_significance() %>%
  add_xy_position(x = "contact_isolation")

stat.test

p_isolation_b <- ggplot(filter(subset(metadata_all_area_dry, !is.na(contact_isolation)),SamplingEvent == "B") , aes(x=contact_isolation, y=CFU_cm2_mod_log)) + 
  geom_boxplot() + 
  geom_point(aes(shape = LOQ), position = position_jitter(width = 0.1, height = 0)) +
  scale_shape_discrete(name  ="Above LOQ",
                       breaks=c("Y", "N"), solid = F) +
  theme_bw() +
  coord_cartesian(ylim = c(-1.5, 7)) +
  labs(x="Contact isolation", y=expression("Log"["10"]*("CFU/cm"^2))) +
  theme(axis.title = element_text(size = 14, face = "plain"),
        axis.text.x = element_text(size = 12, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "none") +
  stat_pvalue_manual(stat.test, label = "p.adj", size = 4)
  
p_isolation_b
# ggsave("fig_new/6_CFU_cm2_isolation_b.pdf", width =  4, height = 4, unit = "in", dpi = 300)




# * Frequency below and above LOQ ----
p_frequency_location <- ggplot(metadata_all_area_dry, aes(x = Location)) +
  geom_bar(aes(y = ..count.., fill = LOQ)) +
  scale_fill_simpsons(name  ="Above LOQ",
                      breaks=c("Y", "N")) +
  scale_x_discrete(position = "top") +
  scale_y_reverse() +
  theme_bw() +
  labs(x="", y="Sample number") +
  theme(axis.title = element_text(size = 12, face = "plain"),
        axis.text.x = element_blank(), 
        axis.ticks.x=element_blank(),
        axis.text.y = element_text(size = 11),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=11, face="plain"),
        legend.text = element_text(size = 11, face = "plain"),
        legend.position = "right")

p_frequency_location
# ggsave("fig_new/7_sample_frequency_LOQ_location.pdf", width =  6, height = 2, unit = "in", dpi = 300)




# * CHX_res: location + touch (8_chx_res_location_touch_box) ----
# recode CHX_Res == NA (CFU count = 0) -> 0 
metadata_all_area <- metadata_all_area %>% 
  mutate(CHX_Res_mod = ifelse(is.na(CHX_Res), 0 , CHX_Res))


metadata_all_area %>%
  t_test(CHX_Res_mod ~ Touch, paired = FALSE) %>%
  adjust_pvalue(method = "BH") %>%
  add_significance()

compare_means(CHX_Res_mod ~ Touch,  data = filter(metadata_all_area, Touch != "Sink"), method = "anova")


t <- metadata_all_area %>%
  t_test(CHX_Res_mod ~ Location, paired = FALSE) %>%
  adjust_pvalue(method = "BH") %>%
  add_significance()


# mean and median
metadata_all_area %>%
  group_by(Location) %>%
  summarise(CHX_Res_mod_mean = mean(CHX_Res_mod),
            CHX_Res_mod_median = median(CHX_Res_mod),
            CHX_Res_mod_sum = sum(CHX_Res_mod))

# plot 1
p_chx_box <- ggplot(metadata_all_area, aes(x=Location, y=CHX_Res_mod, color = Touch)) + 
  geom_boxplot() + 
  # geom_violin() +  # violin does not look good
  geom_point(size = 1.5, position = position_dodge2(width = 0.2), shape =5) +
  geom_text(aes(label = "****", x = 9, y = 105), hjust = 0.5, vjust = 0, color="black", size = 5) +
  scale_x_discrete(breaks = c( "BR","CALL","KI","KO","SI","SO","DI","DO","SINK"),
                     labels = c( "Bedrail","Nurse\ncall","Keyboard\ninside","Keyboard\noutside","Switch\ninside","Switch\noutside","Doorsill\ninside","Doorsill\noutside","Sink")) +
  scale_color_manual(name = "",
                      breaks = c("High","Medium","Low","No", "Sink"),
                      values = c("#F8766D","#7CAE00", "#00BFC4", "#C77CFF","#3966F9")) +
  scale_y_continuous(limits = c(-5, 110), breaks=seq(0,100,25)) +  
  theme_bw() +
  labs(x="Location", y="Bacteria proportion growing at\n18.75 \u03BCg/mL CHG at 25 °C") +
  theme(axis.title = element_text(size = 16, face = "plain"),
        axis.text.x = element_text(size = 14, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 14),
        panel.grid = element_blank(),
        legend.title = element_text(size=16, face="plain"),
        legend.text = element_text(size = 14, face = "plain"),
        legend.position = "none")

p_chx_box
#// ggsave(filename="fig_new_v3/8_chx_res_location_touch_box.pdf", plot=p_chx_box, device=cairo_pdf, width = 8.5, height = 6.8, units = "in", dpi = 300) 


# plot 2: frequency bubble plot -> visualize sample size distribution
metadata_all_chx_res_freq <- metadata_all_area %>%
  group_by(Location) %>%
  do(data.frame(table(cut(.$CHX_Res_mod, breaks=seq(0,100,by=20), include.lowest=F))))

df_temp <- metadata_all_area %>%
  group_by(Location) %>%
  dplyr::filter(CHX_Res_mod == 0) %>%
  do(data.frame(table(.$CHX_Res_mod)))

metadata_all_chx_res_freq <- rbind(metadata_all_chx_res_freq, df_temp)

metadata_all_chx_res_freq$Var1 <- factor(metadata_all_chx_res_freq$Var1, levels = c("0", "(0,20]","(20,40]" , "(40,60]" , "(60,80]"  ,"(80,100]" ))

metadata_all_chx_res_freq$Touch <- touch$Touch[match(metadata_all_chx_res_freq$Location, touch$Location )]
metadata_all_chx_res_freq$Touch <- factor(metadata_all_chx_res_freq$Touch, levels = c("High",  "Medium", "Low","No", "Sink"))

p_chx_freq <- ggplot(metadata_all_chx_res_freq, aes(x=Location, y =Var1)) +
  geom_point(aes(size = Freq, color = Touch, alpha = Freq == 0)) +
  scale_alpha_manual(values = c(1,0)) +
  scale_x_discrete(breaks = c( "BR","CALL","KI","KO","SI","SO","DI","DO","SINK"),
                   labels = c( "Bedrail","Nurse\ncall","Keyboard\ninside","Keyboard\noutside","Switch\ninside","Switch\noutside","Doorsill\ninside","Doorsill\noutside","Sink")) +
  scale_color_manual(name = "",
                     breaks = c("High","Medium","Low","No", "Sink"),
                     values = c("#F8766D","#7CAE00", "#00BFC4", "#C77CFF","#3966F9")) +
  theme_bw() +
  labs(y="Location", x="Binned bacteria proportion growing at 18.75 \u03BCg/mL CHG at 25 °C", size = "Sample number") +
  theme(axis.title.x = element_text(size = 16, face = "plain"),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size = 14),
        panel.grid = element_blank(),
        legend.title = element_text(size=16, face="plain"),
        legend.text = element_text(size = 14, face = "plain"),
        legend.position = "bottom") +
  guides(color=FALSE, alpha=FALSE)

p_chx_freq
#// ggsave(filename="fig_new_v3/9(1)_chx_res_location_touch_bin_bubble_legend.pdf", plot=p_chx_freq, device=cairo_pdf, width = 8.5, height = 3.5, units = "in", dpi = 300) 



# plot 3: overall distribution
ggplot(metadata_all_area, aes(y=CHX_Res_mod)) +
  geom_histogram(binwidth = 5) + 
  scale_x_continuous(limits = c(0, 125), breaks=seq(0,125,20)) +
  theme_bw() +
  labs(x="Sample number", y=expression(paste("Proportion of CFU growing at 18.75 ",mu,"g/mL CHG"))) +
  theme(axis.title = element_text(size = 14, face = "plain"),
        axis.text.x = element_text(size = 12, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        # panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "none")

#// ggsave("fig_new/13_chx_res_overall_distribution.pdf", width =  6, height = 5, unit = "in", dpi = 300)


# * CHX_Res: location+isolation ----
# ** location+isolation ----
metadata_all_area %>%
  group_by(Location) %>%
  t_test(CHX_Res_mod ~ contact_isolation, paired = FALSE) %>%
  adjust_pvalue(method = "BH") %>%
  add_significance() 

p_chx_location_isolation <- ggplot(subset(metadata_all_area, !is.na(contact_isolation)), aes(x=Location, y=CHX_Res_mod, color = contact_isolation)) + 
  geom_boxplot() +
  geom_point(aes(shape = LOQ, group = contact_isolation), position = position_dodge(width = 0.5)) +
  scale_x_discrete(breaks = c( "BR","CALL","DI","DO","KI","KO","SI","SO", "SINK"),
                   labels = c( "Bedrail","Nurse\ncall","Doorsill\ninside","Doorsill\noutside","Keyboard\ninside","Keyboard\noutside","Switch\ninside","Switch\noutside", "Sink")) +
  scale_shape_discrete(name  ="Above LOQ",
                       breaks=c("Y", "N"), solid = F) +
  scale_color_discrete(name  ="Contact isolation") +
  theme_bw() +
  labs(x="Location", y=expression(paste("Proportion of CFU growing at 18.75 ",mu,"g/mL CHG"))) +
  theme(axis.title = element_text(size = 14, face = "plain"),
        axis.text.x = element_text(size = 10, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "right")

p_chx_location_isolation 
#// ggsave("fig_new_v3/11_chx_res_location_isolation.pdf", width =  7.8, height = 5, unit = "in", dpi = 300)

# ** isolation ----
stat.test <- metadata_all_area %>%
  t_test(CHX_Res_mod ~ contact_isolation, paired = FALSE) %>%
  add_significance() %>%
  add_xy_position(x="contact_isolation")

p_chx_isolation <- ggplot(subset(metadata_all_area, !is.na(contact_isolation)), aes(x=contact_isolation, y=CHX_Res_mod)) + 
  geom_boxplot() +
  geom_point(aes(shape = LOQ, group = contact_isolation), position = position_dodge(width = 0.5)) +
  scale_shape_discrete(name  ="Above LOQ",
                       breaks=c("Y", "N"), solid = F) +
  theme_bw() +
  labs(x="Contact isolation", y=expression(paste("Proportion of CFU growing at 18.75 ",mu,"g/mL CHG"))) +
  theme(axis.title = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(size = 12, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "none") + 
  stat_pvalue_manual(stat.test, label = "p", size = 4)

p_chx_isolation

#// ggsave("fig_new/12_chx_res_isolation.pdf", width =  4, height = 4, unit = "in", dpi = 300)




# * Sink vs dry: overall CFU ----
metadata_all_area$water <- factor(metadata_all_area$water, levels = c("dry","wet"))
metadata_all_area$CFU_mod_log = log10(metadata_all_area$CFU_mod)


stat.test <- metadata_all_area %>%
  t_test(CFU_mod_log ~ water, paired = FALSE) %>%
  add_significance() %>%
  add_xy_position(x = "water")

p_water <- ggplot(metadata_all_area, aes(x=water, y=CFU_mod_log)) + 
  geom_boxplot() + 
  geom_point(aes(shape = LOQ), position = position_dodge2(width = 0.2)) +
  scale_shape_discrete(name  ="Above LOQ",
                       breaks=c("Y", "N"), solid = F) +
  theme_bw() +
  coord_cartesian(ylim = c(0, 11)) +
  labs(x="", y=expression("Log"["10"]*("CFU"))) +
  scale_x_discrete(breaks = c("dry", "wet"),
                   labels = c( "Dry surfaces","Sink")) +
  theme(axis.title = element_text(size = 14, face = "plain"),
        axis.text.x = element_text(size = 12, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 12),
        plot.title = element_text(lineheight=.8, face="bold", size = 15),
        panel.grid = element_blank(),
        legend.title = element_text(size=12, face="plain"),
        legend.text = element_text(size = 12, face = "plain"),
        legend.position = "none") +
  stat_pvalue_manual(stat.test, label = "p", size = 4,  y.position = 10.4)

p_water
#// ggsave("fig_new/10_CFU_sinkVSsurface.pdf", width =  4, height = 4, unit = "in", dpi = 300)



# * location + touch + water (actual load, overall CFU) ----
# anova test
compare_means(CFU_mod_log ~ Location,  data = metadata_all_area, method = "anova")
# .y.                p    p.adj p.format p.signif method
# <chr>          <dbl>    <dbl> <chr>    <chr>    <chr> 
# CFU_mod_log 1.88e-59 1.90e-59 <2e-16   ****     Anova 
compare_means(CFU_mod_log ~ Touch,  data = metadata_all_area, method = "anova")
# .y.                p p.adj p.format p.signif method
# <chr>          <dbl> <dbl> <chr>    <chr>    <chr> 
# CFU_mod_log 1.02e-63 1e-63 <2e-16   ****     Anova 

# t test
compare_means(CFU_mod_log ~ Location,  data = metadata_all_area, method = "t.test",  p.adjust.method = "BH", ref.group = ".all.")
# .y.         group1 group2        p    p.adj p.format p.signif method
# <chr>       <chr>  <chr>     <dbl>    <dbl> <chr>    <chr>    <chr> 
# 1 CFU_mod_log .all.  BR     1.96e- 4 2.5 e- 4 0.0002   ***      T-test
# 2 CFU_mod_log .all.  CALL   2.31e- 5 3.5 e- 5 2.3e-05  ****     T-test
# 3 CFU_mod_log .all.  KI     2.13e-13 6.40e-13 2.1e-13  ****     T-test
# 4 CFU_mod_log .all.  KO     1.06e- 9 1.9 e- 9 1.1e-09  ****     T-test
# 5 CFU_mod_log .all.  SI     5.17e-11 1.20e-10 5.2e-11  ****     T-test
# 6 CFU_mod_log .all.  SO     8.96e-16 4   e-15 9.0e-16  ****     T-test
# 7 CFU_mod_log .all.  DI     1.59e- 1 1.8 e- 1 0.1592   ns       T-test
# 8 CFU_mod_log .all.  DO     2.96e- 1 3   e- 1 0.2965   ns       T-test
# 9 CFU_mod_log .all.  SINK   1.12e-21 1   e-20 < 2e-16  ****     T-test

metadata_all_area %>%
  t_test(CFU_mod_log ~ Touch, paired = FALSE) %>%
  adjust_pvalue(method = "BH") %>%
  add_significance()
# .y.         group1 group2    n1    n2 statistic    df        p    p.adj p.adj.signif
# <chr>       <chr>  <chr>  <int> <int>     <dbl> <dbl>    <dbl>    <dbl> <chr>       
#   1 CFU_mod_log High   Medium    35    34     3.34   54.0 2   e- 3 2.5 e- 3 **          
#   2 CFU_mod_log High   Low       35    27     4.00   46.4 2.24e- 4 3.2 e- 4 ***         
#   3 CFU_mod_log High   No        35    59    -2.80   87.6 6   e- 3 6.67e- 3 **          
#   4 CFU_mod_log High   Sink      35    31   -19.8    40.2 2.39e-22 1.19e-21 ****        
#   5 CFU_mod_log Medium Low       34    27     0.726  58.0 4.71e- 1 4.71e- 1 ns          
#   6 CFU_mod_log Medium No        34    59    -5.25   70.6 1.53e- 6 2.55e- 6 ****        
#   7 CFU_mod_log Medium Sink      34    31   -22.4    33.4 1.03e-21 3.43e-21 ****        
#   8 CFU_mod_log Low    No        27    59    -5.67   65.7 3.51e- 7 7.02e- 7 ****        
#   9 CFU_mod_log Low    Sink      27    31   -22.9    32.0 2.02e-21 5.05e-21 ****        
#   10 CFU_mod_log No     Sink      59    31   -15.7    59.1 8.53e-23 8.53e-22 **** 

p_load_all <- ggplot(metadata_all_area, aes(x=Location, y=CFU_mod_log, color = Touch)) + 
  geom_boxplot() + 
  geom_point(aes(shape = LOQ), position = position_dodge2(width = 0.2)) +
  geom_text(aes(label = "~ Location, Anova, p = 1.9e-59", x = 4.5, y = 10), hjust = 0, vjust = 1, size = 5, color = "black") +
  geom_text(aes(label = "~ Touch, Anova, p = 1e-63", x = 4.5, y = 9.5), hjust = 0, vjust = 1, size = 5, color = "black") +
  geom_text(aes(label = "****", x = 9, y = 10), hjust = 0.5, vjust = 0, color="black", size = 5) +
  geom_signif(y_position=c(3, 3.7, 5.3, 4.5, 3.3), 
              xmin=c(1.5, 1.5, 1.5, 3.5, 5.5), 
              xmax=c(3.5, 5.5, 7.5, 7.5, 7.5), 
              annotation=c("**", "***", "**", "****", "****"), 
              textsize = 6, size = 0.3, color = "black") + 
  scale_shape_discrete(name  ="Above LOQ",
                       breaks=c("Y", "N"), solid = F) +
  theme_bw() +
  coord_cartesian(ylim = c(0, 11)) +
  labs(x="", y=expression("Log"["10"]*("CFU"))) +
  scale_x_discrete(breaks = c( "BR","CALL","KI","KO","SI","SO","DI","DO", "SINK"),
                   labels = c( "Bedrail","Nurse\ncall","Keyboard\ninside","Keyboard\noutside","Switch\ninside","Switch\noutside", "Doorsill\ninside","Doorsill\noutside","Sink")) +
  scale_color_manual(name = "Touch frequency",
                     breaks = c("High","Medium","Low", "No", "Sink"),
                     values = c("#F8766D","#7CAE00", "#00BFC4", "#C77CFF","#3966F9")) +
  theme(axis.title = element_text(size = 16, face = "plain"),
        axis.text.x = element_text(size = 14, vjust = 0.5, hjust = 0.5, angle = 0),    
        axis.text.y = element_text(size = 14),
        panel.grid = element_blank(),
        legend.title = element_text(size=16, face="plain"),
        legend.text = element_text(size = 14, face = "plain"),
        legend.position = "bottom",
        legend.box = "vertical")

p_load_all
#// ggsave(filename="fig_new_v2/14_CFU_location_touch_water.pdf", plot=p_load_all, device=cairo_pdf, width = 8.6, height = 7, units = "in", dpi = 300) 
