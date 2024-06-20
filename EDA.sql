use data;
select *
from layoffs_staging2;
-- Exploratory Data Analysis

select Max(total_laid_off),max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where total_laid_off=12000;

select * 
from layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc;

select * 
from layoffs_staging2
where percentage_laid_off=1
order by funds_raised_millions desc; 

select company , sum(total_laid_off) as laid_off
from layoffs_staging2
group by company
order by laid_off desc;

select industry , sum(total_laid_off) as laid_off
from layoffs_staging2
group by industry
order by laid_off desc;

select country , sum(total_laid_off) as laid_off
from layoffs_staging2
group by country
order by laid_off desc;

select date , sum(total_laid_off) as laid_off
from layoffs_staging2
group by date
order by laid_off desc;

select year(date) , sum(total_laid_off) as laid_off
from layoffs_staging2
group by year(date)
order by laid_off desc;

select substring(date,1,7) as month,sum(total_laid_off)
from layoffs_staging2
group by month
order by sum(total_laid_off) desc;


with rolling_total as
(
select substring(date,1,7) as month,sum(total_laid_off) as total_off
from layoffs_staging2
group by month
order by sum(total_laid_off) desc
)
select month,total_off ,
sum(total_off) over(order by month)
from  rolling_total;


WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
where dates is not null
ORDER BY dates ASC;