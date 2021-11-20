# Universal-Taxonomy-Database
This script creates a highly curated and organized taxonomy, a heirarchical tree-of-life for use in any community base 'omics  
This is #1 of a series of pipelines that create-curate the Universal Multi-omics Reference and Alignment Database
    <br>1. Universal Taxonomy Database: *this repository*
    <br>2. Universal Compounds Database: [found here](https://github.com/TealFurnholm/Universal_Biological_Compounds_Database/)
    <br>3. Universal Reactions Database: [found here](https://github.com/TealFurnholm/Universal_Biological_Reactions_Database)
    <br>4. Universal Protein Alignment Database: [found here](https://github.com/TealFurnholm/Universal_Microbiomics_Alignment_Database)
    <br>5. Universal ncRNA Alignment Database: [found here](https://github.com/TealFurnholm/Fix_RNACentral_Taxonomy)
    
### PURPOSE: 
The current state of taxonomy of life is deeply broken, creating a tangled and useless "tree" say if you were trying to graph out what organisms you have in your metagenome. This script fixes the extensive taxonomic errors (detailed:https://academic.oup.com/database/article/doi/10.1093/database/baaa062/5881509) in the phylogenies of all named organisms, creating a table of computer-readable phylogenetic lineages with their public database numeric identifiers. 
- Enforce adherence naming standards for all entries
- Reduce excessive, not based in reality, taxonomic ranks to 8 primary taxonomic ranks:kingdom, phylum, class, order, family, genus, species, strain
- Create conventions for strains, metagenomes and all non-cellular organisms
- Modify synonymous names or other inconsistencies to ensure a heirarchical-tree-of-life

### 3 INPUTS
#### NCBI - Automatic
In case the link breaks replace this link (https://ftp.ncbi.nih.gov/pub/taxonomy/new_taxdump/) with the new taxdump URL in the perl script: MakeTaxonomyDB1of3.pl 

#### IMG - !! MANUAL !!
Sorry, but IMG is a crappy "walled garden", too hard for them to make an ftp site
1. You are going to have to get an ER login
2. log in and go to: https://img.jgi.doe.gov/cgi-bin/mer/main.cgi
3. Click on each of the categories of genomes: archaea, bacteria, plasmids, viruses, eukaryotes, and metagenomes 
4. make sure the following columns are selected (checkboxes at bottom)
 - "taxon_oid" "NCBI Taxon ID" "Domain" "Phylum" "Class" "Order" "Family" "Genus" "Species" "Strain" "Genome Name / Sample Name"
5. select all and hit the export button
6. open in Excel and order the columns **exactly as shown above**, delete any other columns
7. save as "All_IMG_Genomes.txt" and transfer to wherever you are updating the taxonomy

#### ICTV - !! MANUAL !!
Get the structural categories from the International Committee on Taxonomy of Viruses
1. Go to: https://talk.ictvonline.org/files/master-species-lists/m/msl/
2. Download and open in excel, save the 3rd tab - master species list - as a tab delimited text file "ICTV.txt" 
 - put with the rest of the input files
 - *NOTE!: ICTV has already changed their column order once. Make sure the $type/$stuff[16] in the script is outputting the virus type: DNA/RNA positive/negative. 
 - ** If there is a problem: The first column in perl is 0, not 1, so start counting from 0 to the column with the DNA/RNA (right now it is 16, hence $stuff[16]) then change $stuff[16] to whatever the correct column is.

### RUN THE SCRIPTS
Manually getting the IMG files will take you longer than to actually run the scripts. As long as you have the 2 manual inputs with the 3 perl scripts, just run the 3 scripts. Takes like 10 minutes.
```
perl Create_Taxonomy_Database_1of3.pl
perl Create_Taxonomy_Database_2of3.pl
perl Create_Taxonomy_Database_3of3.pl
```
### WHAT IS HAPPENING
#### 1. Create_Taxonomy_Database_1of3.pl
- inputs the ICTV, NCBI and JGI taxonomy data
- organizes it roughly into the 8 taxonomic ranks
- creates ranks for non-cellular organisms (microbiome, plasmids, viruses...)
- does some specific mid-rank and other name fixes (eg Propionibacterium to Cutibacterium)
#### 2. Create_Taxonomy_Database_2of3.pl
- does kingdom/organism type (viruses, satellites, phages, archaea, bacteria, eukaryota...) specific organization and name fixes for species and strain ranks
- fills in missing mid-ranks found in species/strain
- if no Kingdom-Genus ranks, adds mid-rank
- the purpose is to get something more resembling a linnaean species in the species rank, something more unified, and make a distinct species rank
#### 3. Create_Taxonomy_Database_3of3.pl
- now that the species rank is streamlined and any mid levels that can be gleaned are filled in
- standardized the mid level suffixes for each rank
- fix synonyms in mixed or same rank levels
- use the collective information to fill in missing ranks


### OUTPUTS:
 - TAXONOMY_DB_[current year].txt
 - TAXONOMY_DB_[current year].cyto
     - a Cytoscape tree of the database
