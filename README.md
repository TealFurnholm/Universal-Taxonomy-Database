# Universal-Taxonomy-Database
### PURPOSE: 
This script fixes the extensive taxonomic errors in the phylogenies of all named organisms, creating a table of computer-readable phylogenetic lineages with their public database numeric identifiers. Each of the 8 primary taxonomic ranks (kingdom, phylum, class, order, family, genus, species, strain) have been curated to remove synonyms, gaps, and non-conformity to naming conventions. Where no conventions are available, such as for strains, metagenomes and all non-cellular organisms, new conventions were created to minimize modification of existing names but ensuring strict adherence to heirarchical-tree structure without conflicts with other organisms.
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
