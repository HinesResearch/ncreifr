# ncreifr
ncreifr is an r package that allows user to query the National Council of Real Estate Investment Fiduciaries (NCREIF) query tool apis. 
This package is independently developed and not associated or endorsed by the NCREIF organization.
The package requires a username and password with access to the NCREIF API. 

The tool is designed to make quering the NCREIF API simple. The NCREIF API requires 4 inputs to recieve data:
1. The Select Statement
2. The Where Statement
3. The Group By Statement
4. Credentials (username and password)

<h1>Getting Started:</h1>

<b>Installation:</b>

The package can be installed from Github with the devtools library:
```r
install.packages("devtools")
devtools::install_github('erikb-thomas/ncreifr')

```


<b>Quering NCREIF:</b>

You can use the NCREIF() function to query the API:
```r
library(NCREIFR)
SelectString="SUM([NOI]) AS NOI,SUM([CapEx])AS CapEx, SUM([MV]) AS MV,SUM([MVLag1])AS MVLag1, SUM([PSales])AS PSales, Round(SUM([Denom]),4) AS Denom, Round(Sum([NOI]) / Sum([Denom]),4) AS IncomeReturn,Round((Sum([MV])-Sum([MVLag1])-Sum([CapEx])+Sum([PSALES]))/(Sum([DENOM])),4) AS CapitalReturn, Round((Sum([NOI]) / Sum([Denom]))+(Sum([MV])-Sum([MVLag1])-Sum([CapEx])+Sum([PSALES]))/(Sum([DENOM])),4) AS TotalReturn,Count([MV]) AS PropCount"
WhereString="[NPI]=1"
GroupByString="[Period],[YYYYQ] ,[Year],[Quarter]"
Username="YourUsername"
Password="YourPassword"
QueryResults=NCREIF(SelectString,WhereString,GroupByString,Username,Password,FALSE)
View(QueryResults)
```
