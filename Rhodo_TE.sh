#!/bin/bash

#$ -l walltime=2:00:00,vmem=20gb

# Rhodosporidium TE calling

date
cd /N/dc2/scratch/megbehri/Rhodo/
AR=( 10 11 12 13 14 15 16 17 18 19 1 20 21 22 23 24 25 27 29 2 31 33 35 37 39 3 41 43 45 47 49 4 51 53 55 57 58 59 5 60 6 7 8 9)

for i in "${AR[@]}"
do
	cd Sample_RT${i}

    	
	# clean and trim
	echo "#!/bin/bash" > Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "#$ -l vmem=50gb walltime=48:00:00" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "cd /N/dc2/scratch/megbehri/Rhodo/Sample_RT${i}" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "time cutadapt -a AGATCGGAAGAGC -A AGATCGGAAGAGC  -o Sample_RT${i}_R1_rmadapter.fastq -p Sample_RT${i}_R2_rmadapter.fastq Sample_RT${i}_R1.fastq Sample_RT${i}_R2.fastq" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "time cutadapt -q 15,10  -o Sample_RT${i}_R1_filtered.fastq -p Sample_RT${i}_R2_filtered.fastq Sample_RT${i}_R1_rmadapter.fastq Sample_RT${i}_R2_rmadapter.fastq" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "time cutadapt -u 15 -o Sample_RT${i}_R1_trimmed.fastq -p Sample_RT${i}_R2_trimmed.fastq Sample_RT${i}_R1_filtered.fastq Sample_RT${i}_R2_filtered.fastq" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "qsub -l walltime=6:00:00,vmem=64gb Rhodo_${i}_Assemble.sh" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "mkdir fastqc" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "fastqc -o fastqc/ Sample_RT${i}_R1_trimmed.fastq" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "fastqc -o fastqc/ Sample_RT${i}_R2_trimmed.fastq" >> Rhodo_${i}_qc_clean.sh
	echo "" >> Rhodo_${i}_qc_clean.sh
	echo "exit" >> Rhodo_${i}_qc_clean.sh

	
		##### call novel insertion sequences######
	echo "#!/bin/bash" > Rhodo_${i}_RetroSeq.sh
	echo "" >> Rhodo_${i}_RetroSeq.sh
	echo "#$ -l vmem=50gb walltime=2:00:00 " >> Rhodo_${i}_RetroSeq.sh
	echo "" >> Rhodo_${i}_RetroSeq.sh
	echo "cd /N/dc2/scratch/megbehri/Rhodo/Sample_RT${i}" >>Rhodo_${i}_RetroSeq.sh
	echo "mkdir InsSeq" >> Rhodo_${i}_RetroSeq.sh
	echo "cd InsSeq" >>Rhodo_${i}_RetroSeq.sh
	echo "time bwa mem /N/dc2/scratch/megbehri/Rhodo/Ref_Genome/Rhodo_RefGenome.fna ../Sample_RT${i}_R1_trimmed.fastq ../Sample_RT${i}_R2_trimmed.fastq > Sample_RT${i}.sam" >> Rhodo_${i}_RetroSeq.sh
	echo "samtools view -bS -T /N/dc2/scratch/megbehri/Rhodo/Ref_Genome/Rhodo_RefGenome.fna Sample_RT${i}.sam > Sample_RT${i}.bam" >> Rhodo_${i}_RetroSeq.sh
	echo "samtools sort Sample_RT${i}.bam Sample_RT${i}.sorted" >> Rhodo_${i}_RetroSeq.sh
	echo "samtools index Sample_RT${i}.sorted.bam" >> Rhodo_${i}_RetroSeq.sh
	echo "perl /N/dc2/scratch/megbehri/SAM_MURI/Tools/RetroSeq/bin/retroseq.pl -discover -eref /N/dc2/scratch/megbehri/Rhodo/RetroSeq/Fungi_RefFile.txt -bam Sample_RT${i}.sorted.bam -output Sample_RT${i}.IS.Reads -align" >> Rhodo_${i}_RetroSeq.sh
	echo "perl /N/dc2/scratch/megbehri/SAM_MURI/Tools/RetroSeq/bin/retroseq.pl -call -bam Sample_RT${i}.sorted.bam -ref /N/dc2/scratch/megbehri/Rhodo/RefGenome/Rhodo_RefGenome.fna -output Sample_RT${i}.IS -input Sample_RT${i}.IS.Reads -hets" >>Rhodo_${i}_RetroSeq.sh
	echo "" >> Rhodo_${i}_RetroSeq.sh
	echo "exit" >> Rhodo_${i}_RetroSeq.sh
	
		
	chmod u+x Rhodo_${i}_qc_clean.sh
	chmod u+x Rhodo_${i}_RetroSeq.sh
	
	qsub -l walltime=5:00:00,vmem=20gb Rhodo_${i}_qc_clean.sh
	cd ..
	
	done
