#use warnings;
# PUT BUGS HERE TO WORK ON #
# Fix naming of metagenome/microbiome
# microbiome->environmental->teresstrial/aquatic->paludis/limnic/fluvial/marine
# microbiome->engineered->bioreactor/synthetic_community/man-made_habitat
# microbiome->host-associated->plant/animal/fungal/protozoa/algal->organ
# END OF BUG BIN #


#GET I/O FILES
qx{wget -O new_taxdump.tar.gz https://ftp.ncbi.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz};
my $indat  = qx{tar -tzf new_taxdump.tar.gz | grep -P "^fullnamelineage.dmp"};
my $inlevs = qx{tar -tzf new_taxdump.tar.gz | grep -P "^nodes.dmp"};
my $inlin  = qx{tar -tzf new_taxdump.tar.gz | grep -P "^taxidlineage.dmp"};
my $inmrg  = qx{tar -tzf new_taxdump.tar.gz | grep -P "^merged.dmp"};
qx{tar --extract --occurrence=1 --file=new_taxdump.tar.gz $indat};
qx{tar --extract --occurrence=1 --file=new_taxdump.tar.gz $inlevs};
qx{tar --extract --occurrence=1 --file=new_taxdump.tar.gz $inlin};
qx{tar --extract --occurrence=1 --file=new_taxdump.tar.gz $inmrg};

$inictv = 'ICTV.txt';
$inimg = 'All_IMG_Genomes.txt';
$time = localtime;
$time = uc($time);
$time =~ /^[A-Z]+\s+([A-Z]+)\s+\S+\s+\S+\s+(\d\d\d\d)/;
$month = $1; $year = $2;
$version=$1."_".$2;

$output = "TAXONOMY_DB_".$version."_raw.txt";

open(INVIR, $inictv)||die;
open(INIMG, $inimg)||die;
open(INDAT, $indat)||die;
open(INLEV, $inlevs)||die;
open(INLIN, $inlin)||die;
open(OUTPUT, ">", $output)||die;


##########################################################################
### GET THE STRUCTURAL INFORMATION ABOUT VIRUSES (EG. SSRNA, DSDNA...) ###
##########################################################################
print "INPUT ICTV.TXT\n";
@ODDS=(1,3,5,7,9,11,13);
while(<INVIR>){
        if($_ !~/^\d/){next;}
        $_ = uc($_);
        $_ =~ s/[\r\n]+//;
        @stuff = split("\t", $_,-1);
        $stuff[15]=""; #fixes problem with misid'd satellites
        if(exists($VIRTYPE{$stuff[9]}) && exists($VIRTYPE{$stuff[11]}) && exists($VIRTYPE{$stuff[13]})){next;}
        if($_ =~ /(SATELLIT|ALBETOVIRUS|AUMAIVIRUS|PAPANIVIRUS|VIRTOVIRUS|SARTHROVIRIDAE|MACRONOVIRUS)/){
                foreach my $i (@ODDS){ if($stuff[$i]  =~ /\w/){$VIRTYPE{$stuff[$i]} ="MONA;VIRUSES;SATELLITES";}}
                next;}
        if($_ =~ /(PHAGE|CAUDOVIRALES|ACKERMANNVIRIDAE|AUTOLYKIVIRIDAE|CORTICOVIRIDAE|CYSTOVIRIDAE|INOVIRIDAE)/){
                foreach my $i (@ODDS){ if($stuff[$i]  =~ /\w/){$VIRTYPE{$stuff[$i]} ="MONA;VIRUSES;PHAGE";}}
                next;}
        if($_ =~ /(LEVIVIRIDAE|MICROVIRIDAE|SPHAEROLIPOVIRIDAE|MYOVIRIDAE|PODOVIRIDAE|SIPHOVIRIDAE|TECTIVIRIDAE)/){
                foreach my $i (@ODDS){ if($stuff[$i]  =~ /\w/){$VIRTYPE{$stuff[$i]} ="MONA;VIRUSES;PHAGE";}}
                next;}

        #CLEAN UP STRUCTURAL CLASS NAMING
        $stuff[16]=~/([DS]*.NA)/;               $type = $1;
        $stuff[16]=~/[DS]*.NA.*[DS]*(.NA)/;     $type = $1;
           if($type !~ /\w/){                   $type = ""; }
        elsif($stuff[16]=~/RT|RETRO/){          $type .= "_RT";}
        elsif($stuff[16]=~/\+|POS/){            $type .= "_POS";}
        elsif($stuff[16]=~/\-|NEG/){            $type .= "_NEG";}
        elsif($stuff[16]=~/([\+\-]).*([\+\-])/){$type .= "_BOTH";}
        else{$type=$type;}  #KEEP AN EYE ON THIS IN CASE ICTV ADDS CATEGORY

        #NAME WITH STRUCTURAL CLASS
        $stuff[16]=$type;
        foreach my $i (@ODDS){
                if($stuff[$i]  =~ /\w/){ $VIRTYPE{$stuff[$i]} ="MONA;VIRUSES;$stuff[16]";
                #print "i $i stuffi $stuff[$i] type $type lin $VIRTYPE{$stuff[$i]}\n";
        }}
}



#############################
###   INPUT IMG GENOMES   ###
#############################
print "INPUT IMG GENOMES\n";
while(<INIMG>){
                if($_ !~/^\d/){next;}
                $_ = uc($_);
                $_ =~ s/[\r\n]+//;
                @stuff = split('\t', $_,-1);
                @NOW=();
                $oid = shift(@stuff);
                $tid = shift(@stuff);

                #FIX NAME AND FILL MISSING
                if($stuff[7] =~ /^0$/){$stuff[7]="";}
                if($_ =~ /\bPLASMID\b/ && $stuff[6] !~ /PLASMID/ && $stuff[7] !~/PLASMID/){
                        if($stuff[7]=~/\w/){$stuff[7].="_PLASMID";}
                        else{$stuff[6].="_PLASMID";}
                }
                @TMP = @stuff[0..8];    # 0:Domain 1:Phylum 2:Class 3:Order 4:Family 5:Genus 6:Species 7:Strain 8:Genome/Sample
                if($TMP[0]=~/UNKNOWN/ && $_ =~ /ARCHAEON/){ $TMP[0] = "ARCHAEA";}       #FIX IMG UNKNOWN ARCHAEON ISSUE
                for my $y (0..8){ $TMP[$y] = fix_names($TMP[$y]); }                     #GENERAL NAME CLEAN-UP
                if($TMP[8] !~ /$TMP[7]/ && $TMP[7]=~/\w/){ $TMP[8].="_".$TMP[7];}       #FILL IN STRAIN INFO FROM COL 9
                if($TMP[8]=~/\w/){$TMP[7]=$TMP[8];}                                     #REPLACE WITH FULL STRAIN NAME FROM COL 9
                if($TMP[6] !~ /\w/ && $TMP[5] =~ /\w/){                                 #FILL IN SPECIES WITH GENUS - NEED FOR LATER
                        if($TMP[0] =~ /VIRUS/){$TMP[6]=$TMP[5];}
                        else{$TMP[6]=$TMP[5]."_SP";}
                }
                if($TMP[6] !~ /\w/){ $TMP[6] = $TMP[8];}                                #IF STILL NO SPECIES, FILL WITH GENOME/SAMPLE

                #GET THE HIGHEST MICROBIOME INFO THAT ISN'T TOO SPECIFIC NOR UNCLASSIFIED
                if($TMP[0]=~/MICROBIOME/){ for my $x (2..5){ if($TMP[$x] ne "UNCLASSIFIED" && $TMP[$x] ne ""){ $NOW[2]=$TMP[$x]; }} }
                $line = join(";",@TMP);

                #SET NAMES
                if( $TMP[0] =~ /^(BACTERIA|EUKARYOTA|ARCHAEA)$/ ){ @NOW=@TMP[0..7]; }
                else{   #GET THE MONA AND MICROBIOMES
                        #first sort the microbiome/metagenome
                        #then sort the vectors (plasmids, artificial constructs, IS)
                        #then grab the unknown/other - quiddam
                        #then deal with satellites, phages, and all other viruses
                           if($line=~/(ECOLOGICAL|ENVIRONMENTAL)/        && $line =~ /(METAGENOME|MICROBIOME)/){                        @NOW[0..1]=split(";", "MICROBIOME;ENVIRONMENTAL",-1);}
                        elsif($line=~/(ORGANISMAL|HOST)/                 && $line =~ /(METAGENOME|MICROBIOME)/){                        @NOW[0..1]=split(";", "MICROBIOME;HOST-ASSOCIATED",-1);}
                        elsif($line=~/(ENGINEERED|SYNTHETIC|ARTIFICIAL)/ && $line =~ /(METAGENOME|MICROBIOME)/){                        @NOW[0..1]=split(";", "MICROBIOME;ENGINEERED",-1);}
                        elsif($line=~/(METAGENOME|MICROBIOME)/){                                                                        @NOW[0..1]=split(";", "MICROBIOME;UNCLASSIFIED_MICROBIOME",-1);}
                        elsif($line=~/(ARTIFICIAL|SYNTHETIC|VECTOR|COSMID|CONSTRUCT)/){                                                 @NOW[0..1]=split(";", "MONA;CONSTRUCTS",-1); $NOW[6]=$TMP[7];}
                        elsif($line=~/(INSERTION.SEQUENCE|TRANSPOSON|INTEGRON)/){                                                       @NOW[0..1]=split(";", "MONA;TRANSPOSONS",-1);$NOW[6]=$TMP[7];}
                        elsif($line=~/([^A-Z]PLASMID|PLASMID[^A-Z]|MINICHROMOSOME)/ || $TMP[0]=~/PLASMID/){                             @NOW[0..1]=split(";", "MONA;PLASMIDS",-1);   $NOW[6]=$TMP[7];}
                        elsif($line=~/(UNCLASSIFIED.ENTRIES|OTHER.SEQUENCES)/ || $TMP[0]!~/\w/){                                        @NOW[0..1]=split(";", "QUIDDAM;$TMP[7]",-1);}
                        elsif($line=~/(SATELLITE|VIRUS.*SATELLIT)/){                                                                    @NOW[0..2]=split(";", "MONA;VIRUSES;SATELLITES",-1); @NOW[3..7]=@TMP[3..7];}
                        elsif($line=~/(ALBETOVIRUS|AUMAIVIRUS|PAPANIVIRUS|VIRTOVIRUS|SARTHROVIRIDAE|MACRONOVIRUS)/){                    @NOW[0..2]=split(";", "MONA;VIRUSES;SATELLITES",-1); @NOW[3..7]=@TMP[3..7];}
                        elsif($line=~/PHAGE/ && $line=~/VIRUS/){                                                                        @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGE",-1); @NOW[3..7]=@TMP[3..7];}
                        elsif($line=~/(CAUDOVIRALES|ACKERMANNVIRIDAE|AUTOLYKIVIRIDAE|CORTICOVIRIDAE|CYSTOVIRIDAE|INOVIRIDAE)/){         @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGE",-1); @NOW[3..7]=@TMP[3..7];}
                        elsif($line=~/(LEVIVIRIDAE|MICROVIRIDAE|SPHAEROLIPOVIRIDAE|MYOVIRIDAE|PODOVIRIDAE|SIPHOVIRIDAE|TECTIVIRIDAE)/){ @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGE",-1); @NOW[3..7]=@TMP[3..7];}
                        elsif($line=~/VIRUSES|VIRUS[\_\b]/){
                                @NOW[3..7]=@TMP[3..7];
                                foreach my $lev (@TMP){ if(exists($VIRTYPE{$lev})){                                                     @NOW[0..2]=split(";", $VIRTYPE{$lev},-1);  last;}}
                                if($NOW[0] !~ /MONA/){
                                        $stuff[1]=~/([DS]*.NA)/;                $type = $1;
                                        $stuff[1]=~/[DS]*.NA.*[DS]*(.NA)/;      $type = $1;
                                        if($type !~ /\w/){                      $type = ""; }
                                        elsif($stuff[1]=~/RT|RETRO/){           $type .= "_RT";}
                                        elsif($stuff[1]=~/\+|POS/){             $type .= "_POS";}
                                        elsif($stuff[1]=~/\-|NEG/){             $type .= "_NEG";}
                                        elsif($stuff[1]=~/([\+\-]).*([\+\-])/){ $type .= "_BOTH";}
                                        else{$type=$type;}
                                        $NOW[0]="MONA"; $NOW[1]="VIRUSES"; $NOW[2]=$type;
                                }
                        }
                        else{ @NOW[0..1]=split(";", "QUIDDAM;$TMP[7]",-1);}
                }

                #STORE
                if($NOW[1] =~ /\w/){ $MIDS{$NOW[1]}=1; } #track mid names for later
                if($NOW[2] =~ /\w/){ $MIDS{$NOW[2]}=2; } #track mid names for later
                if($NOW[3] =~ /\w/){ $MIDS{$NOW[3]}=3; } #track mid names for later
                if($NOW[4] =~ /\w/){ $MIDS{$NOW[4]}=4; } #track mid names for later
                if($NOW[5] =~ /\w/){ $MIDS{$NOW[5]}=5; } #track mid names for later
                $LINEAGES{$oid}=[@NOW];
}
#######################################
#######################################



#######################################
###   INPUT THE NAME OF EACH RANK   ###
#######################################
print "INPUT FULL LINEAGE\n";
$on=0;
while(<INDAT>){
                if($_ !~/\w/){next;}
                $_ = uc($_);
                $_ =~ s/[\r\n]+//;
                $line=$_;
                @stuff = split("\t", $_,-1);
                $tid = $stuff[0];

                #FIX NAME
                $name = $stuff[2];
                if($tid==2787854){$name="MONA";}        #make other sequences > mona
                if($tid==2787823){$name="QUIDDAM";}     #make unclassified > quiddam
                if($tid==408169 ){$name="MICROBIOME";}  #makes metagenome > microbiome
                $name = fix_names($name);
                $NAMES{$tid}=$name;

                if($tid == 882018){print "882018 name1 $name\n";}

                #GET THE MONA AND MICROBIOMES
                if($line=~/CELLULAR.ORGANISMS/){next;}
                elsif($line=~/OTHER.SEQUENCES/ && $line =~ /ARTIFICIAL|SYNTHETIC|VECTOR|COSMID|CONSTRUCT/){                     $ODD{$tid}="MONA;CONSTRUCTS";}
                elsif($line=~/OTHER.SEQUENCES/ && $line=~/PLASMID|MINICHROMOSOME/){                                             $ODD{$tid}="MONA;PLASMIDS";}
                elsif($line=~/INSERTION.SEQUENCE|TRANSPOSON|INTEGRON/){                                                         $ODD{$tid}="MONA;TRANSPOSONS";}
                elsif($line=~/(ECOLOGICAL|ENVIRONMENTAL)/                && $line =~ /(METAGENOME|MICROBIOME)/){                $ODD{$tid}="MICROBIOME;ENVIRONMENTAL";}
                elsif($line=~/(ORGANISMAL|HOST)/                                 && $line =~ /(METAGENOME|MICROBIOME)/){        $ODD{$tid}="MICROBIOME;HOST-ASSOCIATED";}
                elsif($line=~/(ENGINEERED|SYNTHETIC|ARTIFICIAL)/ && $line =~ /(METAGENOME|MICROBIOME)/){                        $ODD{$tid}="MICROBIOME;ENGINEERED";}
                elsif($line=~/(METAGENOME|MICROBIOME)/){                                                                        $ODD{$tid}="MICROBIOME;UNCLASSIFIED_MICROBIOME";}
                elsif($line=~/(UNCLASSIFIED.ENTRIES|OTHER.SEQUENCES)/){                                                         $ODD{$tid}="QUIDDAM;$name";}
                elsif($line=~/(SATELLITE|VIRUS.*SATELLIT)/){                                                                    $ODD{$tid}="MONA;VIRUSES;SATELLITES";}
                elsif($line=~/(ALBETOVIRUS|AUMAIVIRUS|PAPANIVIRUS|VIRTOVIRUS|SARTHROVIRIDAE|MACRONOVIRUS)/){                    $ODD{$tid}="MONA;VIRUSES;SATELLITES";}
                elsif($line=~/PHAGE/ && $line=~/VIRUS/){                                                                        $ODD{$tid}="MONA;VIRUSES;PHAGE";}
                elsif($line=~/(CAUDOVIRALES|ACKERMANNVIRIDAE|AUTOLYKIVIRIDAE|CORTICOVIRIDAE|CYSTOVIRIDAE|INOVIRIDAE)/){         $ODD{$tid}="MONA;VIRUSES;PHAGE";}
                elsif($line=~/(LEVIVIRIDAE|MICROVIRIDAE|SPHAEROLIPOVIRIDAE|MYOVIRIDAE|PODOVIRIDAE|SIPHOVIRIDAE|TECTIVIRIDAE)/){ $ODD{$tid}="MONA;VIRUSES;PHAGE";}
                elsif($line=~/VIRUSES|VIRUS[\_\b]/){
                        $stuff[4]=~s/\;\s+/\;/g;
                        @NOW=split(";",$stuff[4]);
                        push(@NOW,$name);
                        foreach my $lev (@NOW){ if(exists($VIRTYPE{$lev})){ $ODD{$tid}=$VIRTYPE{$lev}; }}
                        if($NOW[0] !~ /MONA/){ $ODD{$tid}="MONA;VIRUSES"; }
                }
                else{ $ODD{$tid}="QUIDDAM;$name";}

}
########################################
########################################


print "882018 name2 $NAMES{882018}\n";


###############################################
###   GET THE TYPE OF EACH TAXONOMIC RANK   ###
###   (EG. SPECIES, CLASS, SUPERKINGDOM...) ###
###############################################
print "INPUT LEVELS\n";
while(<INLEV>){
                if($_ !~/^\d/){next;}
                $_ = uc($_);
                $_ =~ s/[\r\n]+//;
                @stuff = split("\t", $_,-1);
                $tid = $stuff[0];
                $LEVS{$tid} = $stuff[4];
                if($tid == 32561){ $LEVS{$tid} = "CLASS";} #fixes reptiles class
                if($tid==2787854){ $LEVS{$tid} = "SUPERKINGDOM";} #makes "other sequences" = "MONA"
                if($tid==2787823){ $LEVS{$tid} = "SUPERKINGDOM";} #makes "unclassified entries" = "quiddam"
                if($tid==408169){  $LEVS{$tid} = "SUPERKINGDOM";} #makes metagenome a superkingdom
                if($LEVS{$tid} eq "SUPERKINGDOM"){      $MIDS{$NAMES{$tid}}=0; } #track mid names for later
                if($LEVS{$tid} eq "PHYLUM"){            $MIDS{$NAMES{$tid}}=1; } #track mid names for later
                if($LEVS{$tid} eq "CLASS"){             $MIDS{$NAMES{$tid}}=2; } #track mid names for later
                if($LEVS{$tid} eq "ORDER"){             $MIDS{$NAMES{$tid}}=3; } #track mid names for later
                if($LEVS{$tid} eq "FAMILY"){            $MIDS{$NAMES{$tid}}=4; } #track mid names for later
                if($LEVS{$tid} eq "GENUS"){             $MIDS{$NAMES{$tid}}=5; } #track mid names for later
}
###############################################
###############################################



print "882018 name3 $NAMES{882018}\n";



############################################
###   USE RANKS AND CORRECTED NAMES TO   ###
###   GENERATE AN ORGANIZED LINEAGE      ###
############################################
print "INPUT TAXIDLINEAGES\n";
$on=0;
while(<INLIN>){
                if($_ !~/^\d/){next;}
                $_ = uc($_);
                $_ =~ s/[\r\n]+//;
                @stuff = split('\t', $_,-1);
                $tid = shift(@stuff);
                @LIN = split('\s', $stuff[1],-1);
                @NLIN = ();
                foreach my $x (@LIN){ if($x =~ /\d/){ push(@NLIN,$x); }}
                @LIN=@NLIN;
                push(@LIN, $tid);

                #FIRST GET MAIN 8 RANKS: K/P/C/O/F/G/S/T
                %HoA=(); @NOW=();
                for my $i (0..$#LIN){
                        $id = $LIN[$i];
                        @NOW=@{$HoA{$tid}};
                        if($id !~ /\d/){next;}
                           if($LEVS{$id} eq "SUPERKINGDOM"){    $HoA{$tid}[0]=$NAMES{$id};  $ch=1;}
                        elsif($LEVS{$id} eq "PHYLUM"){          $HoA{$tid}[1]=$NAMES{$id};  $ch=2;}
                        elsif($LEVS{$id} eq "CLASS"){           $HoA{$tid}[2]=$NAMES{$id};  $ch=3;}
                        elsif($LEVS{$id} eq "ORDER"){           $HoA{$tid}[3]=$NAMES{$id};  $ch=4;}
                        elsif($LEVS{$id} eq "FAMILY"){          $HoA{$tid}[4]=$NAMES{$id};  $ch=5;}
                        elsif($LEVS{$id} eq "GENUS"){           $HoA{$tid}[5]=$NAMES{$id};  $ch=6;}
                        elsif($LEVS{$id} eq "SPECIES"){         $HoA{$tid}[6]=$NAMES{$id};  $ch=7; }
                        elsif($LEVS{$id} eq "STRAIN"){          $HoA{$tid}[7]=$NAMES{$id};  $ch=8; }
                        elsif($HoA{$tid}[6] =~ /\w/ || $HoA{$tid}[7] =~ /\w/){#SPECIES IS FILLED - ALL HIGHER LEVS TREAT AS STRAIN SO LCA WILL BE SPECIES LATER
                                @NOW = @{$HoA{$tid}};  $ch=9;
                                $HoA{$id} = [@NOW];
                                $HoA{$id}[7]=$NAMES{$id};
                        }
                        else{   @NOW=@{$HoA{$tid}}; $HoA{$id} = [@NOW];  $ch=10;} #else is a lower junk level, give curent position id since going in order

                }
                #NOW EXTRA RANKS ARE ACCOUNTED FOR IN PRIMARY RANK CONTEXT


                #LOOP THROUGH TID AND OTHER MID-LEVELS
                foreach my $xid (keys %HoA){
                        @TMP=();
                        @NOW=@{$HoA{$xid}};

                        #GET MICROBIOME AND MONA LEVELS
                        if(exists($ODD{$xid})){
                                @TMP = split(";", $ODD{$xid},-1);
                                if($TMP[0] =~ /QUIDDAM|MICROBIOME/){
                                        #FIND THE MOST DESCRIPTIVE NAME FOR THE MICROBIOME THAT MIGHT BE SHARED
                                        if($TMP[0] eq "MICROBIOME"){ for my $x (2..5){ if($NOW[$x] ne "UNCLASSIFIED" && $NOW[$x] ne ""){ $TMP[2]=$NOW[$x]; }}}
                                        @NOW=@TMP;
                                }
                                else{ for my $i (0..$#TMP){ $NOW[$i]=$TMP[$i]; }} #MONAs
                        }
                        if($NOW[0]=~/VIRUS/){ $NOW[0]="MONA"; $NOW[1]="VIRUSES"; }
                        if($NOW[0]!~/\w/){ $NOW[0]="QUIDDAM"; }


                        #MOVE CLEANED SPECIES BECOME MID-NAMES FROM SPECIES
                        #(unclassified salmonella -> salmonella, move to genus, empty species)
                        if(exists($MIDS{$NOW[6]})){ #species is bad
                                if($NOW[7]=~/\w/){ #strain might be good
                                        if(exists($MIDS{$NOW[7]})){ $NOW[$MIDS{$NOW[6]}]=$NOW[6]; $NOW[6]=''; $NOW[7]=''; } #both bad
                                        else{$NOW[6]=$NOW[7];} #strain was good
                                }
                                else{ $NOW[$MIDS{$NOW[6]}]=$NOW[6]; $NOW[6]=''; }
                        }
                        while($NOW[$#NOW] !~ /\w/){pop(@NOW);}
                        $LINEAGES{$xid}=[@NOW];
                }
                $on++;
}
################################################
################################################



##########################################
###   OUTPUT FIRST DRAFT OF LINEAGES   ###
##########################################
foreach my $tid (keys %LINEAGES){
        @NOW = @{$LINEAGES{$tid}};

        #HANDLE BAD MID-LEVELS (HAVE MIXED/SPLIT/NONSENSE NAMES
        if( $NOW[0] =~ /QUIDDAM|MICROBIOME/ || $NOW[2] =~ /[DR]NA\_/ ){ $lin=join("\t",@{$LINEAGES{$tid}}); print OUTPUT "$tid\t$lin\n"; next;}
        $test = join(";", @NOW[0..5]);
        if($test =~ /\_/){
                if($NOW[4] !~ /\w/ && $NOW[5]=~/([A-Z]+I[ND]AE)\_/){ $NOW[4]=$1; }
                for my $i (0..4){ if($NOW[$i] =~ /\_/){ $NOW[$i]='';}}
                $NOW[5] =~ s/.*\_(GEN|GENUS)\_.*//;
                if($NOW[5]=~/\w/){$NOW[5] =~ s/\_.*//;}
        }

        $LINEAGES{$tid}=[@NOW];
        $lin=join("\t",@{$LINEAGES{$tid}});
        print OUTPUT "$tid\t$lin\n";
}



#######################
###   SUBROUTINES   ###
#######################

sub fix_names{
        my $name = $_[0];

        #fix the species/strain name
        $name =~ s/([A-Z]+)\s(PROTEOBACTER)(IA|IUM)/$1$2$3/;
        $name =~ s/\bPROPIONIBACTERIUM/CUTIBACTERIUM/g;
        $name =~ s/\bLEPIDOSAURIA/SAURIA/g;
        $name =~ s/ENDOSYMBIONT.OF\s+/ENDOSYMBIONT-/;
        $name =~ s/COMPOSITE.GENOME.*//;
        $name =~ s/MARINE.GROUP.(\w+)/MARINE-GROUP-$1/;
        $name =~ s/\s+METAGENOME//;
        $name =~ s/OOMYCETES/OOMYCOTA/;
        $name =~ s/LILIOPSIDA/MAGNOLIOPSIDA/;
        $name =~ s/^NR[^A-Z]//;
        $name =~ s/.*INCERTAE.SEDIS.*//;
        $name =~ s/\_(PHYLUM|CLASS|ORDER|FAMILY|GENUS)[\b\_].*/\_/;
        $name =~ s/ENRICHMENT.CULTURE.CLONES*|ENRICHMENT.CULTURES*//;
        $name =~ s/\_(SENSU\_LATO|AFF|GEN|CF)\_/\_/g;
        $name =~ s/^(SENSU\_LATO|AFF|GEN|CF)\_//g;
        $name =~ s/\b(SENSU\_LATO|AFF|GEN|CF)\_//g;

        #remove ambiguous junk
        $name =~ s/(CANDIDATUS|CANDIDATUAS|CANDIDATE.\S+|VOUCHERED|UNDESCRIBED|UNSCREENED|UNKNOWN|UNCULTIVATED|UNCULTURED)\s*/\_/g;
        $name =~ s/(UNIDENTIFIED|UNCLASSIFIED|CONTAMINATION|SCREENED|UNASSIGNED|PUTATIVE|\-*LIKE)\s*/\_/g;

        #remove junk punctuation/standardize
        $name =~ s/\s+/_/g;
        $name =~ s/[^\w]+/_/g;
        $name =~ s/\_+/\_/g;
        $name =~ s/(^\_+|\_+$)//g;
        $name =~ s/^(X|CF)\_//;

        return($name);
}
