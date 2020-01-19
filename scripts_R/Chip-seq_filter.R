#testing geometadb 

library(RSQLite)
library(GEOquery)
library(GEOmetadb)

#Getting SQL file from GEOmetadb - we already had this file
#if(!file.exists('GEOmetadb.sqlite')) getSQLiteFile()

#Getting the SQL file info
file.info('GEOmetadb.sqlite')

#Connecting with SQL file
con <- dbConnect(SQLite(),'GEOmetadb.sqlite')

#checking the list of tables from geometadb
geo_tables <- dbListTables(con)
geo_tables

#checking the fields of lists - example gse
dbListFields(con,'gse')

#getting the schema table for gse -  same information above
dbGetQuery(con, 'PRAGMA TABLE_INFO(gse)')
dbGetQuery(con, 'PRAGMA TABLE_INFO(gsm)')
dbGetQuery(con, 'PRAGMA TABLE_INFO(gds)')
dbGetQuery(con, 'PRAGMA TABLE_INFO(gpl)')

#testing chip-seq queries - simple query for gse only
rs1 <- dbGetQuery(con,paste("select gse,type from gse where",
                            "overall_design like '%ChiP-Seq%'",sep=" "))
dim(rs1)

#testing more complex query for gse only -  9964 GSE
rs_gse <- dbGetQuery(con,paste("select gse,type from gse where",
                            "overall_design like '%ChiP-Seq%' OR",
                            "title like '%ChiP-Seq%' OR",
                            "summary like '%ChiP-Seq%'", sep=" "))
dim(rs_gse)


#testing more complex query for gse only -  9964 GSE 9in this case, I selected all collumns
rs_gse1 <- dbGetQuery(con,paste("select * from gse where",
                               "overall_design like '%ChiP-Seq%' OR",
                               "title like '%ChiP-Seq%' OR",
                               "summary like '%ChiP-Seq%'", sep=" "))
dim(rs_gse1)


#testing more complex query for gds only -not retrieve chip-seq data
rs_gds <- dbGetQuery(con,paste("select gds, gse from gds where",
                               "description like '%ChiP-Seq%'", sep=" "))
rs_gds

#testing more complex query for gpl only - 60 chip-seq data 
rs_gpl <- dbGetQuery(con,paste("select gpl, title from gpl where",
                                "status like '%ChiP-Seq%' OR",
                                "title like '%ChiP-Seq%' OR",
                                "description like '%ChiP-Seq%'", sep=" "))

rs_gpl


#testing more complex query for gsm only - 27328 
rs_gsm <- dbGetQuery(con,paste("select gsm, title from gsm where",
                               "title like '%ChiP-Seq%' OR",
                               "source_name_ch1 like '%ChiP-Seq%' OR",
                               "characteristics_ch1 like '%ChiP-Seq%'", 
                               sep=" "))

NROW(rs_gsm)



#testing more complex query for gsm only with characteristics 1 and 2/ source_name 1/2 - 27328 
rs_gsm_1 <- dbGetQuery(con,paste("select gsm, title from gsm where",
                               "title like '%ChiP-Seq%' OR",
                               "source_name_ch1 like '%ChiP-Seq%' OR",
                               "characteristics_ch1 like '%ChiP-Seq%' OR",
                               "source_name_ch2 like '%ChiP-Seq%' OR",
                               "characteristics_ch2 like '%ChiP-Seq%'", 
                               sep=" "))

NROW(rs_gsm_1)

#Test of example in Bioconductor (with adjustments to run. On the site there are differences that not allowed us to run the script)
sql1 <- dbGetQuery(con,paste("SELECT DISTINCT gse.title,gse.gse",
                             "FROM",
                             "  gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
                             "  JOIN gse ON gse_gsm.gse=gse.gse",
                             "  JOIN gse_gpl ON gse_gpl.gse=gse.gse",
                             "  JOIN gpl ON gse_gpl.gpl=gpl.gpl",
                             "WHERE",
                             "  gsm.molecule_ch1 like '%total RNA%' AND",
                             "  gse.title LIKE '%breast cancer%' AND",
                             "  gpl.organism LIKE '%Homo sapiens%'",sep=" "))
dim(sql1)
sql1

###################################################################################################################################################################
#trying to get the all chip-seq studies - not work
sql_chipseq <- dbGetQuery(con,paste("SELECT DISTINCT gse.title,gse.gse",
             "FROM",
             "  gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
             "  JOIN gse ON gse_gsm.gse=gse.gse",
             "  JOIN gse_gpl ON gse_gpl.gse=gse.gse",
             "  JOIN gpl ON gse_gpl.gpl=gpl.gpl",
             "WHERE",
             "gsm.title like '%ChiP-Seq%' OR",
             "gsm.source_name_ch1 like '%ChiP-Seq%' OR",
             "gsm.characteristics_ch1 like '%ChiP-Seq%' OR",
             "gpl.status like '%ChiP-Seq%' OR",
             "gpl.title like '%ChiP-Seq%' OR",
             "gpl.description like '%ChiP-Seq%' OR",
             "gse.overall_design like '%ChiP-Seq%' OR",
             "gse.title like '%ChiP-Seq%' OR",
             "gse.summary like '%ChiP-Seq%'",
             sep=" "))
dim(sql_chipseq)

#Trying again with just the gsm, gse, gpl


example <-dbGetQuery(con,paste("select gpl.bioc_package,gsm.gpl", "gsm,gsm.supplementary_file",
                                                                "from gsm join gpl on gsm.gpl=gpl.gpl",
                                                                "where gpl.manufacturer='Affymetrix'",
                                                                "and gsm.supplementary_file like '%CEL.gz' ")) 
                                    
dim(example)
example


##########################################THE FILTER TO ALL GSM RELATED TO ChiP-Seq DATA ########################################################################
sql_all_chipseq <- dbGetQuery(con,paste("SELECT gse.gse, gse.type, gse.title, gse.summary,
                                        gse.overall_design, gse.status, gse.pubmed_id, 
                                        gpl.gpl, gpl.title, gpl.technology, gpl.organism, 
                                        gsm.gsm, gsm.type, gsm.organism_ch1, gsm.source_name_ch1, 
                                        gsm.characteristics_ch1, gsm.supplementary_file, gsm.characteristics_ch2, gsm.status",
                                        "FROM",
                                        " gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
                                        " JOIN gse ON gse_gsm.gse=gse.gse",
                                        " JOIN gse_gpl ON gse_gpl.gse=gse.gse",
                                        " JOIN gpl ON gse_gpl.gpl=gpl.gpl",
                                        "WHERE",
                                        "gsm.title like '%ChiP-Seq%' OR",
                                        "gsm.source_name_ch1 like '%ChiP-Seq%' OR",
                                        "gsm.characteristics_ch1 like '%ChiP-Seq%' OR",
                                        "gpl.status like '%ChiP-Seq%' OR",
                                        "gpl.title like '%ChiP-Seq%' OR",
                                        "gpl.description like '%ChiP-Seq%' OR",
                                        "gse.overall_design like '%ChiP-Seq%' OR",
                                        "gse.title like '%ChiP-Seq%' OR",
                                        "gse.summary like '%ChiP-Seq%'",
                                        sep=" "))

sql_all_chipseq

#see the name of columns
colnames(sql_all_chipseq)

#view the dataframe as table
View(sql_all_chipseq)

#remove a dataframe
rm(sql_chipseq_1)

##########################################FILTER ALL GSM RELATED TO ChiP-Seq DATA AND HOMO SAPIENS ###############################################################
#DID NOT WORK! 
#Let`s check if specification for homo sapiens shown any difference in start or end of the code. First, at the start (not working)
#trying with specifications at the end of script (not working)


############################################# FILTERING DATA FRAME ALL CHIP SEQ BY COLUMN ORGANISM_CH1##########################################

#select rows to H. sapiens - just filtering by column 14 not work. We need to filter by column organism as weel
#HS_df_chipseq <- sql_all_chipseq[sql_all_chipseq[14] == 'Homo sapiens',]

#filtering by two columns related with organism

df_chipseqHS_test <- sql_all_chipseq[(sql_all_chipseq$organism_ch1 == 'Homo sapiens' & sql_all_chipseq$organism == 'Homo sapiens'),]
View(df_chipseqHS_test)
nrow(df_chipseqHS_test)


#saving dataframe as csv file to work in pandas
write.csv(df_chipseqHS_test,"/home/local/USHERBROOKE/frog2901/Documents/R_test/HS_df_chipseq_to_work.csv", row.names = FALSE)


############################################################## INCLUDING COLUMNS TO DF WITH ALL CHIP SEQ DATA##########################################
#including gsm.type in query and get more two columns = gsm.series_ID and gsm.gpl
sql_all_chipseq_1 <- dbGetQuery(con,paste("SELECT gse.gse, gse.type, gse.title, gse.summary,
                                        gse.overall_design, gse.status, gse.pubmed_id, 
                                        gpl.gpl, gpl.title, gpl.technology, gpl.organism, 
                                        gsm.gsm, gsm.title, gsm.type, gsm.gpl, gsm.organism_ch1, gsm.series_id, gsm.source_name_ch1, 
                                        gsm.characteristics_ch1, gsm.supplementary_file, gsm.characteristics_ch2",
                                        "FROM",
                                        " gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
                                        " JOIN gse ON gse_gsm.gse=gse.gse",
                                        " JOIN gse_gpl ON gse_gpl.gse=gse.gse",
                                        " JOIN gpl ON gse_gpl.gpl=gpl.gpl",
                                        "WHERE",
                                        "gsm.title like '%ChiP-Seq%' OR",
                                        "gsm.type like '%ChiP-Seq%' OR",
                                        "gsm.source_name_ch1 like '%ChiP-Seq%' OR",
                                        "gsm.characteristics_ch1 like '%ChiP-Seq%' OR",
                                        "gpl.title like '%ChiP-Seq%' OR",
                                        "gpl.description like '%ChiP-Seq%' OR",
                                        "gse.overall_design like '%ChiP-Seq%' OR",
                                        "gse.title like '%ChiP-Seq%' OR",
                                        "gse.summary like '%ChiP-Seq%'",
                                        sep=" "))

#there is no difference compared with above script in terms of row number, even including gsm.type on query

#filtering to homo sapiens
df_chipseqHS_test_1 <- sql_all_chipseq_1[(sql_all_chipseq_1$organism_ch1 == 'Homo sapiens' & sql_all_chipseq_1$organism == 'Homo sapiens'),]
View(df_chipseqHS_test_1)

#saving dataframe as csv file to work in pandas
write.csv(df_chipseqHS_test_1,"/home/local/USHERBROOKE/frog2901/Documents/R_test/HS_df_chipseq_to_work_1.csv", row.names = FALSE)

############################################## REMOVE SOME COLUMNS TO ORGANIZE THE DF######################################################

sql_all_chipseq_2 <- dbGetQuery(con,paste("SELECT gse.pubmed_id, 
                                        gsm.gsm, gsm.title, gsm.type, gsm.gpl, gsm.series_id, gsm.organism_ch1, gpl.organism, gsm.source_name_ch1, 
                                        gsm.characteristics_ch1, gsm.supplementary_file",
                                          "FROM",
                                          " gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
                                          " JOIN gse ON gse_gsm.gse=gse.gse",
                                          " JOIN gse_gpl ON gse_gpl.gse=gse.gse",
                                          " JOIN gpl ON gse_gpl.gpl=gpl.gpl",
                                          "WHERE",
                                          "gsm.title like '%ChiP-Seq%' OR",
                                          "gsm.type like '%ChiP-Seq%' OR",
                                          "gsm.source_name_ch1 like '%ChiP-Seq%' OR",
                                          "gsm.characteristics_ch1 like '%ChiP-Seq%' OR",
                                          "gpl.title like '%ChiP-Seq%' OR",
                                          "gpl.description like '%ChiP-Seq%' OR",
                                          "gse.overall_design like '%ChiP-Seq%' OR",
                                          "gse.title like '%ChiP-Seq%' OR",
                                          "gse.summary like '%ChiP-Seq%'",
                                          sep=" "))


nrow(sql_all_chipseq_2)
df_chipseqHS_test_2 <- sql_all_chipseq_2[(sql_all_chipseq_2$organism_ch1 == 'Homo sapiens' & sql_all_chipseq_2$organism == 'Homo sapiens'),]

View(df_chipseqHS_test_2)

#saving dataframe as csv file to work in pandas
write.csv(df_chipseqHS_test_2,"/home/local/USHERBROOKE/frog2901/Documents/R_test/HS_df_chipseq_to_work_2.csv", row.names = FALSE)


################################################## REMOVING GPL INFORMATION - INFLATING THE TABLE ########################################
sql_all_chipseq_no_gpl_query <- dbGetQuery(con,paste("SELECT gse.gse, gse.type, gse.title, gse.summary,
                                        gse.overall_design, gse.status, gse.pubmed_id, 
                                        gsm.gsm, gsm.title, gsm.type, gsm.gpl, gsm.organism_ch1, gsm.series_id, gsm.source_name_ch1, 
                                        gsm.characteristics_ch1, gsm.supplementary_file, gsm.characteristics_ch2",
                                          "FROM",
                                          " gsm JOIN gse_gsm ON gsm.gsm=gse_gsm.gsm",
                                          " JOIN gse ON gse_gsm.gse=gse.gse",
                                          "WHERE",
                                          "gsm.title like '%ChiP-Seq%' OR",
                                          "gsm.type like '%ChiP-Seq%' OR",
                                          "gsm.source_name_ch1 like '%ChiP-Seq%' OR",
                                          "gsm.characteristics_ch1 like '%ChiP-Seq%' OR",
                                          "gse.overall_design like '%ChiP-Seq%' OR",
                                          "gse.title like '%ChiP-Seq%' OR",
                                          "gse.summary like '%ChiP-Seq%'",
                                          sep=" "))


df_chipseqHS_no_gpl <- sql_all_chipseq_no_gpl_query[(sql_all_chipseq_no_gpl_query$organism_ch1 == 'Homo sapiens'),]
write.csv(df_chipseqHS_no_gpl,"/home/local/USHERBROOKE/frog2901/Documents/R_test/HS_df_chipseq_to_work_no_gpl.csv", row.names = FALSE)

#NOW SAVE THE FILE, FILTER BY ORGANISM AND SEND TO PANDAS TO CHECK.

dbGetQuery(con, 'PRAGMA TABLE_INFO(gse_gpl)')

dbListFields(con,'gse_gpl')


