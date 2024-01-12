#!/bin/bash

declare -A variant_callers=(
    ["strelka2"]="strelka/NA12878_75M/NA12878_75M.strelka.variants.vcf.gz"
    ["deepvariant"]="deepvariant/NA12878_75M/NA12878_75M.deepvariant.vcf.gz"
    ["freebayes"]="freebayes/NA12878_75M/NA12878_75M.freebayes.vcf.gz"
    ["haplotypecaller"]="haplotypecaller/NA12878_75M/NA12878_75M.haplotypecaller.filtered.vcf.gz"
)

for READS in 75 200; do
    for variant_caller in "${!variant_callers[@]}"; do
        yq --inplace '
            with(.variant-calls.nf-core-sarek-'"${PIPELINE_VERSION_NO_DOTS}"'-strelka-agilent-'"${READS}"'M.labels;
            .site = "nf-core" |
            .pipeline = "nf-core/sarek v'"${PIPELINE_VERSION}"'" |
            .trimming = "FastP v'"${FASTP_VERSION}"'" |
            .read-mapping = "bwa mem v'"${BWA_VERSION}"'" |
            .base-quality-recalibration = "gatk4 v'"${GATK_VERSION}"'" |
            .realignment = "none" |
            .variant-detection  = "'${variant_caller}' v'"${!variant_caller^^}_VERSION"'" |
            .genotyping = "none" |
            .reads = "'"${READS}"'M" ) |
            with(.variant-calls.nf-core-sarek-'"${PIPELINE_VERSION_NO_DOTS}"'-strelka-agilent-'"${READS}"'M.subcategory;
            . = "NA12878-agilent" ) |
            with(.variant-calls.nf-core-sarek-'"${PIPELINE_VERSION_NO_DOTS}"'-strelka-agilent-'"${READS}"'M.zenodo;
            .deposition = '"${DEPOSITION_ID}"'  |
            .filename = "'"${variant_callers[$variant_caller]}"'" ) |
            with(.variant-calls.nf-core-sarek-'"${PIPELINE_VERSION_NO_DOTS}"'-strelka-agilent-'"${READS}"'M.benchmark;
            . = "giab-NA12878-agilent-'"${READS}"'M" ) |
            with(.variant-calls.nf-core-sarek-'"${PIPELINE_VERSION_NO_DOTS}"'-strelka-agilent-'"${READS}"'M.rename-contigs;
            . = "resources/rename-contigs/ucsc-to-ensembl.txt" )
            '  ncbench-workflow/config/config.yaml
    done
done

