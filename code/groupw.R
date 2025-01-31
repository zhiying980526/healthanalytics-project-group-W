# 加载必要包
library(tidyverse)
library(haven)      # 读取IPUMS数据
library(survey)     # 处理加权数据
library(ipumsr)     # 处理
library(ggplot2)


# 1. 数据读取
# Load data
#ddi <- read_ipums_ddi("nhis_00005.xml")
ddi <- read_ipums_ddi("~/healthanalytics-project-group-W/data/raw/nhis_00007.xml")
ddi <- read_ipums_ddi("/Users/zhiyingzhu/healthanalytics-project-group-W/data/raw/nhis_00007.xml")
data <- read_ipums_micro(ddi, data_file = "~/healthanalytics-project-group-W/data/raw/nhis_00007.dat")
data <- read_ipums_micro(ddi)
str(data)  
# URBRRL在19年之后才有数据 URBRRL     : int+lbl [1:909666] NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
# 查看数据结构
head(data) 
# 查看数据前几行
# 2. 数据清理
# 筛选女性样本
# 清理BIRTHAG ~ EDUCREC2 + MARSTAT 清理了空数据或者不确定和没有值的数据


filtered_data <- data %>%
  drop_na()%>%
  filter(!MARSTAT %in% c(00, 99),!BIRTHAG %in% c(97, 98, 99), (EDUCREC2 != 00 & EDUCREC2 <=60),BIRTHAG >= 18,YEAR==2015,INCFAM97ON2<=96)
filtered_data <- data 

filtered_data <- filtered_data %>%
  drop_na(BIRTHAG, EDUCREC2, MARSTAT)
# filtered_data <- data %>%
#  filter(BIRTHAG >= 18)  
# 只保留18岁及以上女性

# 创建教育水平分组

filtered_data <- filtered_data %>%
  mutate(EDUCATION = case_when(
    EDUCREC2 %in% c(10, 20, 30) ~ "Primary",
    EDUCREC2 %in% c(40, 41, 42) ~ "Secondary",
    EDUCREC2 %in% c(50, 51, 52, 53, 54, 60) ~ "Tertiary",
    TRUE ~ NA_character_
  )) %>%
  mutate(EDUCATION = factor(EDUCATION, levels = c("Primary", "Secondary", "Tertiary")))
filtered_data
print(filtered_data, width = Inf)

# 创建收入水平分组
#filtered_data <- filtered_data %>%
#  mutate(INCOME = case_when(
#    INCFAM97ON2 %in% c(10) ~ "Low",                # $0 - $34,999
#    INCFAM97ON2 %in% c(20) ~ "Medium",             # $35,000 - $74,999
#    INCFAM97ON2 %in% c(30, 31, 32) ~ "High",       # $75,000 and over
#    INCFAM97ON2 %in% c(96) ~ "20k or more (no detail)", # 模糊收入类别
#    INCFAM97ON2 %in% c(97, 98, 99) ~ "Unknown",    # 不详或拒绝回答
#    TRUE ~ NA_character_                      # 其他情况处理为缺失值
#  ))
#检查数据缺失
#summary(filtered_data)


filtered_data <- filtered_data %>%
  mutate(INCOME = case_when(
    INCFAM97ON2 %in% c(0:9)  ~ "Low",       # $0 - $34,999
    INCFAM97ON2 %in% c(10:19) ~ "Medium",   # $35,000 - $74,999
    INCFAM97ON2 %in% c(20:31, 32) ~ "High", # $75,000 and over
    INCFAM97ON2 %in% c(33:95) ~ "20k or more (no detail)", # 具体收入未知
    INCFAM97ON2 %in% c(96:99) ~ "Unknown",  # 不详或拒绝回答
    TRUE ~ NA_character_
  )) %>%
  mutate(INCOME = factor(INCOME, levels = c("Low", "Medium", "High", "20k or more (no detail)", "Unknown")))

summary(filtered_data)
# 3. 描述性统计
# 生成描述性统计表
table <- filtered_data %>%
  group_by(EDUCATION) %>%
  summarise(
    Mean_Birth_Age = mean(BIRTHAG, na.rm = TRUE),
    SD_Birth_Age = sd(BIRTHAG, na.rm = TRUE),
    Count = n()
  )
print(table)

# 可视化
ggplot(filtered_data, aes(x = EDUCATION, y = BIRTHAG, fill = EDUCATION)) +
  geom_boxplot() +
  labs(title = "Age at First Birth by Education Level",
       x = "Education Level", y = "Age at First Birth") +
  theme_minimal()

# 4. 回归分析
# 简单线性回归
model1 <- lm(BIRTHAG ~ EDUCATION, data = filtered_data)
summary(model1)
# 尝试修改
# filtered_data$INCOME <- as.character(filtered_data$INCOME)
# summary(filtered_data)
# filtered_data$EDUCATION <- as.character(filtered_data$EDUCATION)
# summary(filtered_data)

filtered_data <- data %>%
  select(BIRTHAG, EDUCREC2, URBRRL,INCFAM97ON2, MARSTAT, RACEA)  
filtered_data
#  select(BIRTHAG, EDUCREC2, URBRRL, `INCOME_GROUP`, MARSTAT)  
# 确保保留 INCFAM97ON2
# 加入控制变量 不能实现URBRRL在19年之后才有数据
#model2 <- lm(BIRTHAG ~ EDUCREC2 + INCFAM97ON2 + URBRRL + MARSTAT, data = filtered_data)
model2 <- lm(BIRTHAG ~ EDUCATION + INCOME + MARSTAT, data = filtered_data)
summary(model2)


# 非线性关系
model3 <- lm(BIRTHAG ~ EDUCREC2 + I(EDUCREC2^2), data = filtered_data)
summary(model3)
# ---------待修改：按种族分组运行回归 有问题RACEA数据信息不符合要求 后面的race_models income_models都有问题
race_models <- filtered_data %>%
  group_by(RACEA) %>%
  group_modify(~ {
    model <- lm(BIRTHAG ~ EDUCATION + INCOME + MARSTAT, data = .x)
    return(broom::tidy(model))
  })

# 打印种族分组回归结果
print(race_models)


# ---------待修改：按收入水平分组回归
income_models <- filtered_data %>%
  group_by(INCOME) %>%
  group_modify(~ {
    model <- lm(BIRTHAG ~ EDUCATION + MARSTAT, data = .x)
    return(broom::tidy(model))
  })
# ---------待修改：REGION缺少数据
# 创建 REGION 分组
filtered_data <- filtered_data %>%
  mutate(REGION = case_when(
    URBRRL == 1 ~ "Large Central Metro",
    URBRRL == 2 ~ "Large Fringe Metro",
    URBRRL == 3 ~ "Medium and Small Metro",
    URBRRL == 4 ~ "Nonmetropolitan",
    TRUE ~ NA_character_  # 未知值处理为缺失
  ))

# 按区域分组回归分析
region_models <- filtered_data %>%
  group_by(REGION) %>%
  group_modify(~ {
    model <- lm(BIRTHAG ~ EDUCATION + INCFAM97ON2 + MARSTAT, data = .x)
    return(broom::tidy(model))
  })

# 打印分组回归结果
print(region_models)
# ————————————————————————————————————————————————————————————————————

# 打印收入分组回归结果
print(income_models)

ggplot(filtered_data, aes(x = as.factor(URBRRL), y = BIRTHAG, fill = as.factor(URBRRL))) +
  geom_boxplot() +
  labs(title = "Age at First Birth by Region",
       x = "URBRRL (1 ｜2｜3= Urban, 4 = Rural)", y = "Age at First Birth") +
  scale_fill_manual(values = c("#1b9e77", "#d95f02")) +
  theme_minimal()

ggplot(income_models, aes(x = term, y = estimate, color = INCOME)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = estimate - std.error, ymax = estimate + std.error), width = 0.2) +
  labs(title = "Regression Coefficients by Income Group",
       x = "Regression Term", y = "Estimate") +
  theme_minimal() +
  scale_color_brewer(palette = "Set1")

# 5. 回归结果可视化
library(stargazer)
stargazer(model1,model2,model3, type = "text",
          title = "Regression Results: Education and Age at First Birth")
#stargazer(model1, model2, model3, race_models, income_models, type = "text",
#         title = "Regression Results: Education and Age at First Birth")

# 保存清理后的数据
write.csv(filtered_data, "cleaned_data.csv")
