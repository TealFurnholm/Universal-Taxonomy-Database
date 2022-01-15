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
3. set your preferences to maximize your genome lists and save columns
![Alt text](https://github.com/TealFurnholm/Universal-Taxonomy-Database/blob/master/setting_IMG_preferences.png)
4. Click on the following categories: archaea, bacteria, plasmids, viruses, eukaryotes, and metagenomes -- you want to use "ALL"  not just JGI genomes
![Alt text](https://github.com/TealFurnholm/Universal-Taxonomy-Database/blob/master/IMG_taxonomy_source.png)
 - since bacteria are so many, paste the follow link: https://img.jgi.doe.gov/cgi-bin/mer/main.cgi?section=TaxonList&page=taxonListAlpha&domain=Bacteria
5. make sure the following columns are selected (checkboxes at bottom)
 - "taxon_oid" "NCBI Taxon ID" "Domain" "Phylum" "Class" "Order" "Family" "Genus" "Species" "Strain" "Genome Name / Sample Name"
6. select all and hit the export button
![Alt text](https://github.com/TealFurnholm/Universal-Taxonomy-Database/blob/master/export_img_taxa.png)
7. open in Excel and order the columns **exactly as shown above**, delete any other columns
8. save as "All_IMG_Genomes.txt" and transfer to wherever you are updating the taxonomy

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
Loop Through Each Taxon ID
- Start
    - Clean Up Poor SPE/STR Names
        - If no SPE but STR, STR = SPE, pop STR
        - Remove redundant name pieces in SPE
            - tid 596240 old MONA;VIRUSES;MAGSAVIRICETES;NODAMUVIRALES;NODAVIRIDAE;BETANODAVIRUS;CHANOS_CHANOS_NERVOUS_NECROSIS_VIRUS
            - tid 596240 new MONA;VIRUSES;MAGSAVIRICETES;NODAMUVIRALES;NODAVIRIDAE;BETANODAVIRUS;CHANOS_NERVOUS_NECROSIS_VIRUS
        - Append STR to SPE, remove redundant name pieces in STR
            - tid 2721755735 old BACTERIA;PROTEOBACTERIA;ALPHAP...CEREIBACTER;CEREIBACTER_SPHAEROIDES;LUTEOVULUM_SPHAEROIDES_MBTLJ_13
            - tid 2721755735 new BACTERIA;PROTEOBACTERIA;ALPHAP...CEREIBACTER;CEREIBACTER_SPHAEROIDES;CEREIBACTER_SPHAEROIDES_LUTEOVULUM_MBTLJ_13
            - ! NOTE: This is mid process, not final - weirdness gets cleaned up later in script
        - Append STR to SPE, remove redundant name pieces in STR
        - If SPE = STR, pop STR
    - Skip
        - Loop thru mid-levels (ex class, order...), remove SPE/STR if mid
            - tid 233254 old EUKARYOTA;CHORDATA;AVES;ACCIPITRIFORMES;ACCIPITRIDAE;BUTEO;BUTEO;BUTEO_BANNERMANI
            - tid 233254 new EUKARYOTA;CHORDATA;AVES;ACCIPITRIFORMES;ACCIPITRIDAE;BUTEO;BUTEO_BANNERMANI
        - if 1. no SPE & no STR (mid only), 2. Quiddam or Microbiome, 3. Plasmids or Constructs
            - ex MONA;PLASMIDS;;;;;PLASMID_PWR60
            - ex MONA;CONSTRUCTS;;;;;EXPRESSION_VECTOR_PINSRT_HM_V3
            - = skip
    - Do True Viruses & Viroids
        - General
            -  -inae to -idae
            -  virid to virus
            -  remove _SP (mixed use of _sp, major conflict when Euk host listed or between taxonomy databases, handled later in script)
        - Fill in missing mids if in SPE/STR
            - seek [A-Z]+(VIRICETES|VIRALES|VIRO*IDAE) in SPE/STR
                - tid 2737683 old MONA;VIRUSES;;;;;PLASMOPARA_VITICOLA_LESION_ASSOCIATED_MYCOBUNYAVIRALES_VIRUS_9
                - tid 2737683 new MONA;VIRUSES;;MYCOBUNYAVIRALES;;;PLASMOPARA_VITICOLA_LESION_ASSOCIATED_MYCOBUNYAVIRALES_VIRUS_9
        - Fill in missing genus
            -  seek [A-Z]+(VIRUS|VIROID) in SPE/STR
        - Coordinate mids/genus to SPE/STR
            - Replace SPE/STR [A-Z]+(VIRICETES|VIRALES|VIRIDAE) with appropriate MID
            - Remove SPE if no \_, ie. SPE=genus
                - tid 1643295 old MONA;VIRUSES;MEGAVIRICETES;IMITERVIRALES;MIMIVIRIDAE;MOUMOUVIRUS;MOUMOUVIRUS;MOUMOUVIRUS_BATTLE49
                - tid 1643295 new MONA;VIRUSES;MEGAVIRICETES;IMITERVIRALES;MIMIVIRIDAE;MOUMOUVIRUS;MOUMOUVIRUS_BATTLE49
        - Add Genus or highest mid to name
            -  tid 1400255 old MONA;VIRUSES;REVTRAVIRICETES;ORTERVIRALES;RETROVIRIDAE;GAMMARETROVIRUS;GALIDIA_ERV
            -  tid 1400255 new MONA;VIRUSES;REVTRAVIRICETES;ORTERVIRALES;RETROVIRIDAE;GAMMARETROVIRUS;GALIDIA_ERV_GAMMARETROVIRUS
        - Check again for mid-only lineages and skip
            - tid 10535 old MONA;VIRUSES;TECTILIVIRICETES;ROWAVIRALES;ADENOVIRIDAE;MASTADENOVIRUS;ADENOVIRUS
            - tid 10535 mid MONA;VIRUSES;TECTILIVIRICETES;ROWAVIRALES;ADENOVIRIDAE;MASTADENOVIRUS;MASTADENOVIRUS
            - tid 10535 new MONA;VIRUSES;TECTILIVIRICETES;ROWAVIRALES;ADENOVIRIDAE;MASTADENOVIRUS
            - tid 2050579 old MONA;VIRUSES;ELLIOVIRICETES;BUNYAVIRALES;;;BUNYAVIRALES_SP
            - tid 2050579 mid MONA;VIRUSES;ELLIOVIRICETES;BUNYAVIRALES;;;BUNYAVIRALES
            - tid 2050579 new MONA;VIRUSES;ELLIOVIRICETES;BUNYAVIRALES
            - ! NOTE: The "species" in these cases are not real identification, hence removal
        - No Genus add Mid
            - get the last (highest) mid, remove all other mids
            - if has _virus/viroid_ prepend last mid
            - else append mid_virus|viroid to name
            - tid 1592774 mid MONA;VIRUSES;MEGAVIRICETES;ALGAVIRALES;PHYCODNAVIRIDAE;;MICROMONAS_PUSILLA_VIRUS_11T
            - tid 1592774 new MONA;VIRUSES;MEGAVIRICETES;ALGAVIRALES;PHYCODNAVIRIDAE;;MICROMONAS_PUSILLA_PHYCODNAVIRIDAE_VIRUS_11T
        - Final remove duplicate name pieces
            - tid 1685077 old MONA;VIRUSES;PISONIVIRICETES;PICORNAVIRALES;CALICIVIRIDAE;NOROVIRUS;NORWALK_VIRUS;NOROVIRUS_HU_GII_4_LVCA_22822_2013_BRA
            - tid 1685077 mid MONA;VIRUSES;PISONIVIRICETES;PICORNAVIRALES;CALICIVIRIDAE;NOROVIRUS;NORWALK_NOROVIRUS;NORWALK_NOROVIRUS_NOROVIRUS_HU_GII_4_LVCA_22822_2013_BRA
            - tid 1685077 new MONA;VIRUSES;PISONIVIRICETES;PICORNAVIRALES;CALICIVIRIDAE;NOROVIRUS;NORWALK_NOROVIRUS;NORWALK_NOROVIRUS_HU_GII_4_LVCA_22822_2013_BRA
            - tid 1211480 old MONA;VIRUSES;MONJIVIRICETES;MONONEGAVIRALES;RHABDOVIRIDAE;CYTORHABDOVIRUS;PERSIMMON_CYTORHABDOVIRUS;PERSIMMON_VIRUS_A
            - tid 1211480 mid MONA;VIRUSES;MONJIVIRICETES;MONONEGAVIRALES;RHABDOVIRIDAE;CYTORHABDOVIRUS;PERSIMMON_CYTORHABDOVIRUS;PERSIMMON_CYTORHABDOVIRUS_CYTORHABDOVIRUS_A
            - tid 1211480 new MONA;VIRUSES;MONJIVIRICETES;MONONEGAVIRALES;RHABDOVIRIDAE;CYTORHABDOVIRUS;PERSIMMON_CYTORHABDOVIRUS;PERSIMMON_CYTORHABDOVIRUS_A
            - tid 658930 old MONA;VIRUSES;PISONIVIRICETES;NIDOVIRALES;CORONAVIRIDAE;GAMMACORONAVIRUS;AVIAN_CORONAVIRUS;INFECTIOUS_BRONCHITIS_VIRUS_NGA_A116E7_2006
            - tid 658930 mid MONA;VIRUSES;PISONIVIRICETES;NIDOVIRALES;CORONAVIRIDAE;GAMMACORONAVIRUS;AVIAN_GAMMACORONAVIRUS;AVIAN_GAMMACORONAVIRUS_INFECTIOUS_BRONCHITIS_GAMMACORONAVIRUS_NGA_A116E7_2006
            - tid 658930 new MONA;VIRUSES;PISONIVIRICETES;NIDOVIRALES;CORONAVIRIDAE;GAMMACORONAVIRUS;AVIAN_GAMMACORONAVIRUS;AVIAN_GAMMACORONAVIRUS_INFECTIOUS_BRONCHITIS_NGA_A116E7_2006
    - Do True Phages
        - General Fixes
            - -INAE to -IDAE
            - Convert loose "phage" to virus (for later conversion)
            - Remove excess virus name pieces
            - tid 2706795968 old MONA;VIRUSES;PHAGE;CAUDOVIRALES;SIPHOVIRIDAE;WIZARDVIRUS;GORDONIA_VIRUS_TWISTER6;GORDONIA_PHAGE_TWISTER6
            - tid 2706795968 mid MONA;VIRUSES;PHAGE;CAUDOVIRALES;SIPHOVIRIDAE;WIZARDVIRUS;GORDONIA_VIRUS_TWISTER6;GORDONIA_VIRUS_TWISTER6
            - tid 2706795968 new MONA;VIRUSES;PHAGE;CAUDOVIRALES;SIPHOVIRIDAE;WIZARDVIRUS;GORDONIA_VIRUS_TWISTER6
        - 


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
