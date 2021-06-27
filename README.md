# Universal-Taxonomy-Database
#### *I have advanced metastatic cancer and am working on this unfunded between my paid work. I did this because I just couldn't stand the horrid state of existing taxonomy in public databases, particularly as meta-omics and genome sequencing advances. I cannot add features or debug at this point. Please feel free to use/modify/improve this code, but please acknowledge me somewhere if you publish it - call it a dying wish (though hopefully the treatments work and I won't die soon!).
### PURPOSE: 
The current state of taxonomy of life is deeply broken, creating a tangled and useless "tree" say if you were trying to graph out what organisms you have in your metagenome. This script fixes the extensive taxonomic errors (detailed:https://academic.oup.com/database/article/doi/10.1093/database/baaa062/5881509) in the phylogenies of all named organisms, creating a table of computer-readable phylogenetic lineages with their public database numeric identifiers. Each of the 8 primary taxonomic ranks (kingdom, phylum, class, order, family, genus, species, strain) have been curated to remove synonyms, gaps, and non-conformity to naming conventions. Where no conventions are available, such as for strains, metagenomes and all non-cellular organisms, new conventions were created to minimize modification of existing names but ensuring strict adherence to heirarchical-tree structure without conflicts with other organisms. I specifically tackled the STUPID decision on the part of NCBI, which stopped giving different strains their own unique taxon ID#s: https://link.springer.com/article/10.4056/sigs.4851102
The previous version of this software did not handle strains - placing species and strains into the same column. Why? Because scientists are irresponsible in their naming when they deposit new genomes/data, often putting some junk as a species/strain (eg. "endosymbiont of A. syntrophicus" or "[author's name] et. al. 2008") instead of following basic Linnaean format. This script goes through several gyrations to try and figure out and correct species and strain names in order to create a phylogenetic tree of life that doesn't have stupidly tangled branches from bad naming.

### INPUTS:
#### 1. NCBI: Taxonomy data were downloaded from the NCBI FTP site - automatically downloaded
 - https://ftp.ncbi.nih.gov/pub/taxonomy/new_taxdump/
 - fullnamelineage.dmp
 - nodes.dmp
 - taxidlineage.dmp
#### 2. IMG OIDS were directly exported from the database - ** Manually download, yeah it sucks IMG is a manky walled garden
 - https://img.jgi.doe.gov/cgi-bin/mer/main.cgi?oldLogin=false
 - click on each of the categories of genomes (archaea/bacteria/plasmids/viruses/eukaryotes...) 
 - make sure the following columns are selected (checkboxes at bottom)
 - "taxon_oid" "NCBI Taxon ID" "Domain" "Phylum" "Class" "Order" "Family" "Genus" "Species" "Strain" "Genome Name / Sample Name"
 - export as excel (do not add to genome cart - too many genomes/wont fit)
 - make sure to delete/order the columns *in excel* exactly as shown above, save as "All_IMG_Genomes.txt" and 
 - transfer same folder with other input files
#### 3. Get the structural categories from the International Committee on Taxonomy of Viruses - ** Manually download
 - https://talk.ictvonline.org/files/master-species-lists/m/msl/8266/download
 - open in excel, save the 3rd tab - master species list - as a tab delimited text file "ICTV.txt" 
 - put with the rest of the input files
 - *NOTE!: ICTV has already changed their column order once. Make sure the $type/$stuff[16] in the script is outputting the virus type: DNA/RNA positive/negative. 
 - ** If there is a problem: The first column in perl is 0, not 1, so start counting from 0 to the column with the DNA/RNA (right now it is 16, hence $stuff[16]) then change $stuff[16] to whatever the correct column is.

### RUNNING THE SCRIPT
You need perl installed and either have the environment set up so you can just double click on the .pl files (windows) or run the perl scripts. Else put them in the perl "bin" folder. There are 3 scripts to run, each outputs a raw file so if there is a problem you can figure out where the problem occurs.
#### 1. perl Create_Taxonomy_Database_1of3.pl
- inputs the ICTV, NCBI and JGI taxonomy data
- organizes it roughly into the 8 taxonomic ranks
- creates ranks for non-cellular organisms (microbiome, plasmids, viruses...)
- does some specific mid-rank and other name fixes (eg Propionibacterium to Cutibacterium)
#### 2. perl Create_Taxonomy_Database_2of3.pl
- does kingdom/organism type (viruses, satellites, phages, archaea, bacteria, eukaryota...) specific organization and name fixes for species and strain ranks
- fills in missing mid-ranks found in species/strain
- if no Kingdom-Genus ranks, adds mid-rank
- the purpose is to get something more resembling a linnaean species in the species rank, something more unified, and make a distinct species rank
#### 3. perl Create_Taxonomy_Database_3of3.pl
- now that the species rank is streamlined and any mid levels that can be gleaned are filled in
- standardized the mid level suffixes for each rank
- fix synonyms in mixed or same rank levels
- use the collective information to fill in missing ranks

### EXAMPLES: 
start: 1803148	EUKARYOTA	ASCOMYCOTA	SORDARIOMYCETES				XYLARIOMYCETIDAE_SP_ARIZ_AZ0199
<br>end: 1803148	EUKARYOTA	ASCOMYCOTA	SORDARIOMYCETES	UNCLASSIFIED_SORDARIOMYCETES_ORDER	XYLARIOMYCETIDAE	UNCLASSIFIED_XYLARIOMYCETIDAE_GENUS	XYLARIOMYCETIDAE_SP	XYLARIOMYCETIDAE_SP_ARIZ_AZ0199
<br>start: 1000652	MONA	VIRUSES	HERVIVIRICETES	HERPESVIRALES	HERPESVIRIDAE		PROCAVIA_CAPENSIS_GAMMAHERPESVIRUS_2
<br>end: 1000652	MONA	VIRUSES	HERVIVIRICETES	HERPESVIRALES	HERPESVIRIDAE	GAMMAHERPESVIRUS	PROCAVIA_CAPENSIS_GAMMAHERPESVIRUS	PROCAVIA_CAPENSIS_GAMMAHERPESVIRUS_2

### OUTPUTS:
 - TAXONOMY_DB_[current year].txt: tab delimited taxonomy database
 - TAXONOMY_DB_[current year].cyto: tab delimited network file for cytoscape (really it's too big to graph but you can check the "Target" column for duplicates to find issues in the code)
