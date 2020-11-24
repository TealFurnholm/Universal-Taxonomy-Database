# Universal-Taxonomy-Database
#### *I have advanced metastatic cancer, and am working part-time on stuff that does not directly fund this work. I just did this because I couldn't stand the horrid state of existing taxonomy in public databases, particularly as meta-omics and genome sequencing advances. I cannot add features or debug at this point. Please feel free to use/modify/improve this code, but please acknowledge me somewhere if you publish it - call it a dying wish (though hopefully the treatments work and I won't die soon!).
### PURPOSE: 
The current state of taxonomy of life is deeply broken, creating a tangled and useless "tree" say if you were trying to graph out what organisms you have in your metagenome. This script fixes the extensive taxonomic errors (detailed:https://academic.oup.com/database/article/doi/10.1093/database/baaa062/5881509) in the phylogenies of all named organisms, creating a table of computer-readable phylogenetic lineages with their public database numeric identifiers. Each of the 8 primary taxonomic ranks (kingdom, phylum, class, order, family, genus, species, strain) have been curated to remove synonyms, gaps, and non-conformity to naming conventions. Where no conventions are available, such as for strains, metagenomes and all non-cellular organisms, new conventions were created to minimize modification of existing names but ensuring strict adherence to heirarchical-tree structure without conflicts with other organisms. I specifically tackled the STUPID decision on the part of NCBI, which stopped giving different strains their own unique taxon ID#s: https://link.springer.com/article/10.4056/sigs.4851102
The previous version of this software did not handle strains - placing species and strains into the same column. Why? Because scientists are irresponsible in their naming when they deposit new genomes/data, often putting some junk as a species/strain (eg. "endosymbiont of A. syntrophicus" ) instead of following basic Linnaean format. This script goes through several gyrations to try and figure out and correct species and strain names, but I cant seem to account for all ways people have borked the names. 
### INPUTS:
#### 1. NCBI: Taxonomy data were downloaded from the NCBI FTP site 
 - https://ftp.ncbi.nih.gov/pub/taxonomy/new_taxdump/
 - fullnamelineage.dmp
 - nodes.dmp
 - taxidlineage.dmp
#### 2. IMG OIDS were directly exported from the database: 
 - https://img.jgi.doe.gov/cgi-bin/mer/main.cgi?oldLogin=false
 - click on each of the categories of genomes (archaea/bacteria/plasmids/viruses/eukaryotes...) 
 - make sure the following columns are selected (checkboxes at bottom)
 - "taxon_oid" "NCBI Taxon ID" "Domain" "Phylum" "Class" "Order" "Family" "Genus" "Species" "Genome Name / Sample Name"
 - export as excel (do not add to genome cart - too many genomes/wont fit)
 - make sure/order the columns in excel as shown above, save as "All_IMG_Genomes.txt" and 
 - transfer same folder with other input files
#### 3. Get the structural categories from the International Committee on Taxonomy of Viruses
 - https://talk.ictvonline.org/files/master-species-lists/m/msl/8266/download
 - open in excel, save the 3rd tab - master species list - as a tab delimited text file "ICTV.txt" 
 - put with the rest of the input files
#### 4. Current taxonomy database
### OUTPUTS:
 - TAXONOMY_DB_2020.txt: tab delimited taxonomy database
 - TAXONOMY_DB_2020.cyto: tab delimited network file for cytoscape (really it's too big to graph but you can check the "Target" column for duplicates to find issues in the code)

### NOTE: THIS SOFTWARE IS A BIT BORKED
 - I was doing this during a period when I was contracted for other work - and there are so very MANY ways people have messed up naming organisms that to code for every eventuality was taking too long, so there may be a few remaining naming issues affecting a small proportion of organisms. 
