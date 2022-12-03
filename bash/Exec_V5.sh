#!/bin/bash
cort_name="myasmb_s021_"
read_len=100
N=5000
Err_Rate=0.001
read="Read"$read_len
logfile=$cort_name"log.txt"
workpath_r="./Single/ER_0001/N_5000/"$read
mkdir $workpath_r

for i in {1..3}
do
	try="/Try_"$i
        cort_file_name=$cort_name$i
	workpath="./Single/ER_0001/N_5000/"$read$try
	echo -e "<< -- Err rate: $Err_Rate, Single End, N: $N, Reads Length:$read_len, Try"$i >> $logfile

	singularity exec -e MyPRJ.sif wgsim -e $Err_Rate -N $N -r 0.001 -1 $read_len AVCP010274869.1.fa r1.fq r2.fq
	singularity exec -e MyPRJ.sif seqkit fq2fa r1.fq > r1.fa
	singularity exec -e MyPRJ.sif blastn -query r1.fa -subject AVCP010274869.1.fa -outfmt 6 | sort -k9,9 -n > blastnViewR1

	mkdir $workpath

	singularity exec -e MyPRJ.sif SOAPdenovo-63mer all -s my.config -o $workpath/$cort_file_name -p 1  1> log 2>err
	mv ./r1.fq $workpath/r1.fq
	mv ./r2.fq $workpath/r2.fq
	mv ./r1.fa $workpath/r1.fa
	mv ./blastnViewR1 $workpath/blastnViewR1
	mv ./log $workpath/log
	mv ./err $workpath/err 
	egrep "length" $workpath/*contig | tail -n 10 >> $logfile
	cat $workpath/$cort_file_name.scafStatistics >> $logfile
        singularity exec -e MyPRJ.sif seqkit stats $workpath/$cort_file_name.contig >> seqkit_stats.txt        
done
