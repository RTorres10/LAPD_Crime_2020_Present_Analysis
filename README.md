# **LAPD Crime Analysis (2020-2023)**
## Project Background
This report was created to analyze the crimes committed in the city of Los Angeles (LA) from the years 2020 to 2023. The goal of the report is to help the Los Angeles Police Department (LAPD) with resource allocation as well as provide the citizens of LA with a better understanding of the crimes being committed in their city. To enhance exploration, users have the ability to filter through specific years and months to further analyze crime trends. 

The analysis explores 4 key dimensions of crime, those being:
- **Crime Over Time:** When are crimes occurring

- **Crime Characteristics:** What crimes are being committed 

- **Crime Hotspots:** Where crimes are being committed

- **Victim Demographics:** Who the victims of these crimes are 

## Data Model
The LAPD Crime Dataset follows a snowflake schema with 13 overall tables and a total of 877,327 criminal records after some were excluded. The data was also cleaned and modeled before any type of analysis took place. Details on the excluded records can be found [here](#notes--other-caveats) and the cleaning/modeling process [here](/Code/)

The 13 tables consist of: 
- **1 Fact table** (Crime_Data_Fact) 

- **10 Dim tables** (Area_Dim, Premis_Dim, Status_Dim, Date_Dim, Time_Dim, Location_Dim, Weapon_Dim, Victim_Dim, Crime_Dim, and Mocodes_Dim)

- **2 Bridge tables** (Mocodes_Bridge and Crime_Bridge)

![Report Data Model](/Images/LAPD_Crime_Data_Model.png)

## Executive Summary 

The overview page in this report provides a high-level view of the crime in Los Angeles from **2020-2023** with around **877,000** records to analyze from. 

Across all the years, it is reported most of the crimes occur during **quarter 3 and 4** indicating that criminal activity rises in the second half of the year. On **average, 600** crimes are committed a day with criminal activity peaking at **12 PM** and remaining high throughout the **evening (PM)** hours.

The **Central, 77th Street, and Pacific** divisions/areas are where **majority** of crimes are being committed. These crimes are mainly made up of **Simple Assaults, Burglary from Vehicles** and **Other Theft** with individuals aged **30 to 39** being the most affected. From the criminal records that have a known victim sex, **males** were affected slightly more than **females**,  with **53%** and females at **47%**.

A detailed analysis can be found in the following section where the insights of the key dimensions of crime are further explored. The full interactive report can be downloaded [here](/LAPD_Crime_Dashboard.pbix).

![Overview Tab](/Images/Overview_Tab.png)

## Insights
### Crimes Over Time:
- The amount of crimes committed throughout the year tend to be committed in the second half of the year. Specifically, majority of the crimes happened during the summer and early fall with **July, August, and October** each having around **76,000** cases.

- Crimes appear to happen more often towards the end of the day with a signifianct spike at **12 PM** with about **60,000** cases. The following next two hours with high crime activity are **6 PM** with around **52,000** cases and **5 PM** with about **51,000** cases.  

- The amount of crimes throughout the week are relatively balanced. However, crime activity peaks at the end of the work week and the start of the weekend with about **134,000** crimes being committed on **Friday** and about **128,000** crimes on **Saturday**. 

These findings can be correlated to the high activity hours of the community, such as summer vacation, lunchtime, and weekend activities.

![Overview Tab](/Images/Crime_Over_Time_Tab.png)

### Crime Characteristics:
- Out of the overall **890,258 committed crimes** (noting that a criminal record can have multiple offenses), the majority of these crimes involve some form of theft or burglary which are mainly considered Part 1 offenses, the more severe classifitcation. From the top 8 committed crimes, 5 out of the 8 are Part 1 offenses with **Vehicle - theft** being the most frequent with **93,817 occurences**. The remaining 3 committed crimes are Part 2 offenses (less severe) with **Battery - simple assault** being the second most frequent by a noticeable margin with **70,121 cases**. This clearly illustrates why **Part 1** offenses have a higher occurrence (around **517,000**) compared to **Part 2** crimes (around **374,000**).  

- Approximately **35%** of the crimes committed included weapons of physical nature like **Strong-arm (hands, fist, feet, or bodily-forces)** and **Verbal Threat** being in the top 3. This means that most of the crimes that included a weapon tend to be spontaneous since an object was not utilized. **Strong-arm** makes up a significant portion of the percentage with it having about **163,000 occurrences** which is far more than **Unknown weapon/other weapon** with **33,000 occurences**. 

- When examining the methodology on how most crimes were committed, most of the offenses consisted of a **Stranger** with **300,379** occurrences and **Removes victim's property** with **258,429** occurences. These two descriptions have huge margin from the rest, with the third being **Victim knew suspect** with **141,639** incidents. 

We are able to see that a majority of the crimes happening in LA tend to be **property-related**, with **simple types of assaults** following right behind. These findings correlate to the next section about where these crimes are taking place.

![Crime Char Tab](/Images/Crime_Characteristics_Tab.png)

### Crime Hotspots:
- The top premises where crimes are committed the most include public places such as **Street** with about **221,000** cases and **Parking lot** in the top 4 with about **61,000** cases. The second and third most frequent premises are private locations such as **Single family dwelling** with about **149,000 cases** and **Multi-unit dwelling** with about **108,000 cases**. **Street** being the most common premise by a decent margin likely has to do with how a majority of the top committed offenses are vehicle or vandalism related which commonly occur in public properties.

- As examined in the overview page, the top 3 divisions/areas with the highest crime rates are **Central, 77th Street, and Pacific.** However, the next few areas are not far behind with some like **Southwest** having about **49,000** crimes, Hollywood having about **46,000** crimes, and **Southeast** having about **44,000** crimes. 

The map showcases a concentration of crimes that occured in LA. Based on the map, the majority of crimes are committed in the downtown portion of the city, which properly aligns with the findings of the top divisions and premises mentioned above. 

![Crime Hotspots Tab](/Images/Crime_Hotspots_Tab.png)

### Victim Demographics:
- The average victim age for both sexes are similar, with **male** victims being slightly older at **41 years of age** and **female** victims being younger at **39 years of age**.

- The age brackets which are the most affected are **30-39 years of age** with about **174,000 cases**,  **20-29 years of age** with around **159,000 cases**, and **40-49 years of age** with about **117,000 cases**. This shows that young to middle aged adults tend to be the victims of most crimes.  

- For descent, **Hispanic/Latino/Mexicans** tend to be the most frequently affected with **268,000** cases. White and Black victims follow behind with **White** victims being in about **178,000** cases and **Black** victims in around **124,000** cases. 

- The sex distribution across each of these descent groups is fairly **balanced** with **males** having a **higher percentage** in most. However, there are a few instances where females have a higher percentage than males such as **Black** victims where **56%** are **female** and **44%** are **male**.

Overall, the findings indicate that the majority of the victims are working-age adults, mainly in the Hispanic/Latin/Mexican descent group with no particular sex being the main target. 

![Vict Demo Tab](/Images/Victim_Demographics_Tab.png)

## Recommendations
There are a few things that could be done in order to help decrease the crime rates in Los Angeles.

1. **Increase surveillance** and ensure that both law enforcement and monitoring systems are **visibly present** in locations of high crime rates.

2. **Educate the public** on **statistics** of high rated crimes, times of peak activity, locations, and victims being targeted.

3. **Reallocation of patrol and law enforcement** to times and locations of higher crime rates. 

### How will these recommendations help?
-  Criminals often commit crimes when they feel they are not being seen and are unlikely to get caught. **Increasing** and **making surveillance visibly present** will make criminals feel as if they are being monitored making them less motivated to commit crimes.

- Many indivduals become victims of crime because they are uninformed of crime trends, high-crime rated areas, and peak crime times in their city. By **educating them of these patterns**, they will be able to take precautionary measures to reduce the rate of becoming victims. 

- **Strategic allocation of patrol and law enforcement**, such as increasing law enforcement activity in **times** and **areas of higher crime rates**, can result in greater surveillance and quicker response times to discourage criminal activity and improve overall control of the city. 

## Notes & Other Caveats
- Some criminal records stated that the victim's age was zero but the crime committed was very unlikely to happen to them such as vehicle thefts. Since the age of these crimes can be ambigious, as it can mean both infant or unknown, these ages were considered as null (unknown) to avoid any false representation. 

- In Crime_Data_Fact table, there are multiple records where every attribute is identical but with a different Dr_No. While there is a possibility that a crime could be committed at the same time, location, and to victims of same demographics, these records were left in to preserve data integrity.

- Criminal records that occured in 2024 and 2025 were excluded as the data in these years was incomplete and inconsistent. LAPD and other agencies started to implement a new system for recording crimes in early 2024. While they were transitioning, some records were still being recorded in the old system which is why the years 2024 and 2025 had inconsistent and missing records.

## Tools & Resources Used
- **Data Setup:** MySQL (code can be found [here](/Code/Crime_Data_Setup.sql))
- **Data Cleaning:** MySQL (code can be found [here](/Code/Crime_Data_Clean.sql)) & Power Query (in Power BI)

- **Data Modeling:** MySQL (code can be found [here](/Code/Crime_Data_Norm.sql))

- **Data Visualization:** Power BI (DAX)

- **Original Dataset:** The "Crime Data from 2020 to Present" dataset by LAPD can be found [here](https://data.lacity.org/Public-Safety/Crime-Data-from-2020-to-Present/2nrs-mtv8/about_data)