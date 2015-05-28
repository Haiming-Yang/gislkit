#Import data from the TCGA compressed package as a matrix
importTCGA<-function(path_customized="./", pattern_customized=".rsem.genes.normalized_results", verbose=TRUE){
    fileList=dir(path=path_customized,pattern=pattern_customized)
    example<-read.table(paste(path_customized, fileList[1], sep=""), header=TRUE, sep="\t"   )

    ge<-matrix(0,nrow(example),length(fileList))
    colnames(ge)<-fileList
    rownames(ge)<-as.character(example[,1])
    rm(example)
    for( fileName in fileList){
        e<-read.table(paste(path_customized, fileName, sep=""), header=TRUE, sep="\t"   )
        ge[,fileName]<-as.numeric(e[,2])
        if(verbose==TRUE)
            cat(which(fileList==fileName),"\n")
    }
    rm(e)
    return(ge)
}

#Import data from the TCGA compressed package normalized in the RPKM format as a matrix
importRPKM<-function(path_customized="./", pattern_customized=".gene.quantification.txt", verbose=TRUE){
    fileList=dir(path=path_customized,pattern=pattern_customized)
    example<-read.table(paste(path_customized, fileList[1], sep=""), header=TRUE, sep="\t"   )

    ge<-matrix(0,nrow(example),length(fileList))
    colnames(ge)<-fileList
    rownames(ge)<-as.character(example[,1])
    rm(example)
    for( fileName in fileList){
        e<-read.table(paste(path_customized, fileName, sep=""), header=TRUE, sep="\t"   )
        ge[,fileName]<-as.numeric(e[,4]) #RPKM
        if(verbose==TRUE)
            cat(which(fileList==fileName),"\n")
    }
    rm(e)
    colnames(ge)<-substr(colnames(ge),1,28)

    return(ge)
}

#Converts UUIDs in a TCGA data matrix to TCGA barcodes. 
convertUUID2barcode<-function(ge,path ="./"){
    map<-read.table(paste(path, "FILE_SAMPLE_MAP.txt",sep=""),sep="\t",header=T)
    rownames(map)<-map[,1]
    cn<-map[colnames(ge),2]
    colnames(ge)<-cn
    return(ge)
}

#Extract the overall survival time and status of the subjects from TCGA biotab files
importTCGASurv<-function(TCGA_CLINICAL_PATH="./"){
fileList=dir(path=TCGA_CLINICAL_PATH, pattern=".txt")

    for(i in 1:length(fileList)){
        cl<-read.table(paste(TCGA_CLINICAL_PATH, fileList[i],sep=""), sep="\t" , skip=1, header=1 ,row.name=1, fill=TRUE)

        cancer_type_name=tolower( strsplit( strsplit(fileList[i],"[.]")[[1]][2], "_" )[[1]][4]  ) 

            time_os=as.character( cl[,"days_to_death"] ) 
            status_os=as.character( cl[,"vital_status"] ) 

            time_os[which(time_os=="[Not Available]")]=NA
            time_os[which(time_os=="[Not Applicable]")]=NA
            time_os[which(is.na(time_os))]=as.character( cl[which(is.na(time_os)),"days_to_last_followup"] )

            status_os[which(status_os=="[Not Available]")]=0
            status_os[which(status_os=="Dead")]=1
            status_os[which(status_os=="Alive")]=0
            #Tai-Hsien
            time_os=as.numeric(time_os)
            status_os=as.numeric(status_os)

            if("bcr_patient_barcode"%in% colnames(cl)){
                names(time_os)=as.character( cl[,"bcr_patient_barcode"] )
            }else{
                names(time_os)=as.character( rownames(cl) )
            }
            names(status_os)=names(time_os)

            save(time_os, status_os, file=paste(cancer_type_name, ".surv.rda", sep="") )
            
            cat(i, nrow(cl)-1, cancer_type_name, "\n" )
    }

}