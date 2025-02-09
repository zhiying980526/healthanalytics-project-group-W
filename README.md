# Introduction to Health Analytics - GHM Group 2W

## 📌 Project Overview  
This project explores the **impact of women's educational attainment on their age at first childbirth**, considering **race, region, and marital status** as control variables. Using the **2015 IPUMS NHIS dataset**, we employ regression analysis to examine how different education levels influence women's reproductive decisions.

## 📊 Data Source  
The data is sourced from **IPUMS NHIS (Integrated Health Interview Series, USA)**, provided by the University of Minnesota. Data preprocessing includes:
- Removing invalid data (unknown, non-responses, missing values)
- Computing **respondents' current age** (AGE = YEAR - BIRTHYR)
- Recategorizing the education variable (`EDUCREC2_group`)
- Defining control variables (region, race, marital status)

## 🏗 Methodology  
### **Regression Model**
We apply **Weighted Least Squares (WLS) regression**, progressively introducing control variables:
1. **Model 1**: Baseline regression with no control variables  
2. **Model 2**: Adds **regional fixed effects (REGION_group)**  
3. **Model 3**: Adds **racial group controls (RACE_group)**  
4. **Model 4**: Adds **marital status controls (MARITAL_group)**  

### **Interaction Effect Analysis**
- Examines the interaction between **higher education (Tertiary_dummy) and racial groups (RACE_group)**  
- Assesses **variations in education’s impact across different ethnic groups**  

## 🔑 Key Findings  
1. **Higher education (college and above) significantly delays first childbirth** (by **3.4 years** compared to uneducated women, p < 0.001).  
2. **Low education levels (primary and below) do not significantly affect first birth age**.  
3. **Regional effects**:
   - **Northeast** has the highest average age at first birth.  
   - **South** has the lowest.  
4. **Racial effects**:
   - **Asian women** have the latest first birth (2.7 years later than White women, p < 0.001).  
   - **Black, Native, and other racial groups** tend to have earlier childbirth.  
5. **Marital status effects**:
   - **Married women** tend to have their first child **1.7 years later** than single women (p < 0.001).  
6. **Interaction effects**:
   - **Even with higher education, Black women tend to give birth earlier than White women** (p = 0.009).  

## 📈 Visualization of Results  
- **Density Plot** illustrates the distribution of first birth age across education levels.  
- **Box Plot** shows that higher education groups have a later median first birth age and greater variability.  

## ✅ Robustness Checks  
- **Multicollinearity (VIF Calculation)** confirms no serious correlation among variables.  
- **Residual Analysis** ensures regression assumptions hold.  
- **Log-Transformed Model** validates the consistency of results.  

## ⚠ Study Limitations  
1. **Based on 2015 cross-sectional data only**, not accounting for long-term trends.  
2. **Income and employment were excluded** to avoid biasing the causal effect of education on childbirth timing.  
3. **Limited data representativeness**, potentially underestimating the impact on low-income or rural women.  

## 📢 Policy Recommendations  
- **Enhancing educational opportunities**, especially for low-income and rural women.  
- **Reducing racial disparities in education access**, through scholarships and financial aid.  
- **Improving family support policies**, including marriage education, tax incentives, and parental leave flexibility.  

## 👩‍💻 Statement of Contributions  
**Conceptualization**: Xuzhe Liu, Rex Li  

**Data analysis**: Yuhao Zhang, Zhiying Zhu  

**Interpretation of results**: Haoran Shi, Zihan Lin  

**Drafting report**:  
- **Introduction**: Xuzhe Liu  
- **Data Description**: Yuhao Zhang  
- **Empirical Strategy**: Rex Li, Zhiying Zhu  
- **Results**: Haoran Shi, Zihan Lin  
- **Robustness Check**: Rex Li  
- **Limitations & Policy Recommendation**: Xuzhe Liu  
- **Conclusion**: Haoran Shi  

**Coding**: Zhiying Zhu, Haoran Shi, Zihan Lin, Rex Li, Xuzhe Liu, Yuhao Zhang  


## 📜 References  
- Nitsche, N. & Brückner, H. (2020). *Postponement of first birth among highly educated US women*.  
- Joyce, A. M. et al. (2019). *Births: Final data for 2018*.  
- Danielle, M. E. & Brady, E. H. (2018). *Trends in fertility and mother’s age at first birth*.  
- Su, D. et al. (2021). *Racial and ethnic disparities in birth outcomes*.  