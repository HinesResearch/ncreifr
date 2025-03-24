#' Main NCREIF Query Function
#'
#' This Function will query the NCREIF SOAP
#' @param SelectString SQl Select String for API, does not include select keyword. Fields are Bracketed. All Fields must be in aggregate function.
#' @param WhereString SQL string for where parameters of query. All Fields must be bracketed.
#' @param GroupByString SQL Group by fields. Each field must be bracketed, seperated with commas. Must include at least one group by field.
#' @param Username NCREIF username
#' @param Password NCREIF Password
#' @param Verbose True/False for development.
#' @param DataType integer defining which NCREIF dataset queried
#' @export
#' @examples
#' SelectString="SUM([NOI]) AS NOI,SUM([CapEx])AS CapEx, SUM([MV]) AS MV,SUM([MVLag1])AS MVLag1, SUM([PSales])AS PSales, Round(SUM([Denom]),4) AS Denom, Round(Sum([NOI]) / Sum([Denom]),4) AS IncomeReturn,Round((Sum([MV])-Sum([MVLag1])-Sum([CapEx])+Sum([PSALES]))/(Sum([DENOM])),4) AS CapitalReturn, Round((Sum([NOI]) / Sum([Denom]))+(Sum([MV])-Sum([MVLag1])-Sum([CapEx])+Sum([PSALES]))/(Sum([DENOM])),4) AS TotalReturn,Count([MV]) AS PropCount"
#' WhereString="[NPI]=1"
#' GroupByString="[Period],[YYYYQ] ,[Year],[Quarter]"
#' NCREIF(SelectString,WhereString,GroupByString,readline("Enter Username"),readline("Enter Password"),FALSE)

NCREIF<-function(SelectString,WhereString,GroupByString,Username,Password,DataType=1,verbose){
  body = paste0('<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
  <ExecuteQuery xmlns="http://tempuri.org/">
  <p_DataTypeId>',DataType,'</p_DataTypeId>
  <p_SelectQuery>',SelectString,'</p_SelectQuery>
<p_WhereClause>',WhereString,'</p_WhereClause>
  <p_GroupbyClause>',GroupByString,'</p_GroupbyClause>
  <p_UserName>',Username,'</p_UserName>
  <p_Password>',Password,'</p_Password>
  </ExecuteQuery>
  </soap:Body>
  </soap:Envelope>')

  h <- curl::new_handle(url = "https://user.ncreif.org/ncreif/webservice/QueryBuilder.asmx", postfields = body)
  curl::handle_setheaders(h,
                          "Content-Type" = "text/xml; charset=utf-8"
  )
  t1<-curl::curl_fetch_memory("https://user.ncreif.org/ncreif/webservice/QueryBuilder.asmx", h)
  if(t1$status_code==200){
  t2<-XML::xmlParse(rawToChar(t1$content))
  results <- XML::xmlToDataFrame(nodes=XML::getNodeSet(t2, "//Result1"))
  if("YYYYQ" %in% colnames(results)){
    results$Date<-data.frame(Date=as.Date(paste(substr(results$YYYYQ,1,4),as.numeric(substr(results$YYYYQ,5,5))*3,ifelse(substr(results$YYYYQ,5,5) %in% c("4","1"),31,30),sep="-"),"%Y-%m-%d"))$Date
  }
  if(verbose){return(t1)}else{
    for(i in which(!colnames(results) %in% c(strsplit(gsub("\\]","",gsub("\\[","",GroupByString)),",")[[1]],"Date","Tranche"))){results[,i]<-as.numeric(results[,i])}
    return(results)}
  }else{

    t2<-XML::xmlParse(rawToChar(t1$content))
    errorstring<-XML::xmlToDataFrame(nodes=XML::getNodeSet(t2, "//faultstring"))
    errorstring<-substr(errorstring,unlist(gregexpr("System.Data.SqlClient.SqlException:",errorstring))[1]+36,nchar(errorstring))
    errorstring<-substr(errorstring,1,unlist(gregexpr("\n",errorstring))[1]-1)
    stop(paste0("API Error: ",errorstring))
  }

}




