# PUT BUGS TO WORK ON HERE #

# END OF BUG BIN #

#use warnings;
$time = localtime;
$time = uc($time);
$time =~ /^[A-Z]+\s+([A-Z]+)\s+\S+\s+\S+\s+(\d\d\d\d)/;
$month = $1; $year = $2;
$version=$1."_".$2;
$output = "TAXONOMY_DB_".$version."_raw2.txt";
$input = "TAXONOMY_DB_".$version."_raw.txt";


open(INPUT, $input)||die;
print "INPUT RAW $input\n";
while(<INPUT>){
                if($_ !~/^\d/){next;}
                $_ = uc($_);
                $_ =~ s/[\r\n]+//;
                @NOW = split("\t", $_,-1);
                $tid = shift(@NOW);
                $LINEAGES{$tid}= [@NOW];
}

print "CLEANING SPECIES AND STRAIN NAMES\n";
foreach my $tid (keys %LINEAGES){
        @NOW = @{$LINEAGES{$tid}};
        @OLD = @NOW;
        if($NOW[0] =~ /QUIDDAM|MICROBIOME/){next;}

        #IF EMPTY SPECIES, FILL WITH MID LEVEL
        if($NOW[6] !~ /\w/ && $NOW[7] !~ /\w/){
                for my $i (0..5){ if($NOW[$i] !~ /\w/){next;} $last=$i; }
                $NOW[6]=$NOW[$last]."_SP";
                $LINEAGES{$tid}=[@NOW];
                next;
        }

        ### FIRST HANDLE MONA ###
        #########################
        if($NOW[0] eq "MONA"){
                #SKIP CONSTRUCTS, PLASMIDS
                if($NOW[1] !~ /VIRUS/ ){
                        if($NOW[6]=~/\w/){
                                @SPE = split("_",$NOW[6],-1); $NSPE=shift(@SPE);
                                foreach my $x (@SPE){if($NSPE !~ /(\_$x|\_$x\_|$x\_)/){$NSPE.="_".$x;}}
                                $NOW[6]=$NSPE;
                        }
                        if($NOW[7]=~/\w/){
                                @SPE = split("_",$NOW[7],-1); $NSPE=shift(@SPE);
                                foreach my $x (@SPE){if($NSPE !~ /(\_$x|\_$x\_|$x\_)/){$NSPE.="_".$x;}}
                                $NOW[7]=$NSPE;
                        }
                        $LINEAGES{$tid}=[@NOW];
                        next;
                }
                if($NOW[2] !~ /PHAGE|SATELLITE/){ #TRUE VIRUSES

                        #FIX MISSING GENUS AND SPLIT NAMES AND UNIFY *VIRUS
                        if($NOW[5] !~ /\w/ && $NOW[6] =~ /([A-Z]+VIRUS)/){ $NOW[5]=$1; }
                        if($NOW[5] !~ /\w/ && $NOW[7] =~ /([A-Z]+VIRUS)/){ $NOW[5]=$1; }
                        if($NOW[5] =~ /\w/){ #ABSORB SPLIT NAMES AND UNIFY VIRUS
                                @SPE = split("_",$NOW[6],-1);
                                @NSPE=();
                                foreach my $x (@SPE){
                                        if($x =~ /[A-Z]{4,}/ && $NOW[5] =~ /$x/){ $x = $NOW[5]; }
                                        if(grep{/^$x$/} @NSPE){next;}
                                        if($x =~ /\w/){push(@NSPE,$x);}
                                }
                                $NOW[6]=join("_", @NSPE);
                                if($NOW[6]=~/([A-Z]+VIRUS)/){$NOW[5]=$1; $NOW[7] =~ s/[A-Z]+VIRUS/$NOW[5]/;}
                                @SPE = split("_",$NOW[7],-1);
                                @NSPE=();
                                foreach my $x (@SPE){
                                        if($x =~ /[A-Z]{4,}/ && $NOW[5] =~ /$x/){ $x = $NOW[5]; }
                                        if(grep{/^$x$/} @NSPE){next;}
                                        if($x =~ /\w/){push(@NSPE,$x);}
                                }
                                $NOW[7]=join("_", @NSPE);
                        }

                        #GET BEST MID LEVELS AND MAKE SURE VIRUS IN NAME
                        if($NOW[5] !~ /\w/){
                                $NOW[6] =~ s/\_SP[\b\_]|\_SP$//; $NOW[7] =~ s/\_SP[\b\_]|\_SP$//;
                                if($NOW[2] !~ /\w/ && $NOW[6] =~ /([A-Z]+VIRICETES)/){ $NOW[2]=$1; }
                                if($NOW[3] !~ /\w/ && $NOW[6] =~ /([A-Z]+VIRALES)/){   $NOW[3]=$1; }
                                if($NOW[4] !~ /\w/ && $NOW[6] =~ /([A-Z]+VIRIDAE)/){   $NOW[4]=$1; }
                                if($NOW[6] =~ /([A-Z]+VIRICETES)/){ if(length($1)>length($NOW[2])){ $NOW[2]=$1; }}
                                if($NOW[6] =~ /([A-Z]+VIRALES)/){   if(length($1)>length($NOW[3])){ $NOW[3]=$1; }}
                                if($NOW[6] =~ /([A-Z]+VIRIDAE)/){   if(length($1)>length($NOW[4])){ $NOW[4]=$1; }}

                                $hit=10; $last=10;
                                for my $i (2..4){
                                        if($NOW[$i] !~ /\w/){next;} $last=$i;
                                        if($NOW[6] =~ /$NOW[$i]/){$hit=$i;}
                                }
                                #no genus, but mid class-family
                                if($NOW[$last] =~ /\w/ && $NOW[6] !~ /(VIRICETES|VIRALES|VIRIDAE)/ && $last<10){ $new=$NOW[$last]."_VIRUS"; $NOW[6]=~s/VIRUS/$new/;}
                                if($NOW[6] !~ /VIRUS/ && $NOW[6] =~ /(VIRICETES|VIRALES|VIRIDAE)/){$new=$1."_VIRUS"; $NOW[6] =~s/$1/$new/;}
                        }
                        else{ if($NOW[6] !~ /VIRUS/){ $new=$NOW[5]."_VIRUS"; $NOW[6] =~s/$NOW[5]/$new/; }} #has genus, make sure says virus

                        #MERGE STRAIN AND SPECIES
                        @strain = split("_",$NOW[7],-1);
                        foreach my $x (@strain){ if($NOW[6] !~ /$x/ && $x =~ /\w/){ $NOW[6].="_".$x; }}
                        $NOW[7] = $NOW[6];
                        $test = $NOW[6];
                        $test =~ s/VIRUS.*/VIRUS/;
                        if($test eq $NOW[5]){
                                if($NOW[6] =~ /VIRUS\_([A-Z]+|\d+)\_.+/){ $new="VIRUS_".$1; $NOW[6] =~ s/$new.*/$new/;}
                                else{ $NOW[6] =~ s/VIRUS.*/VIRUS_SP/; $NOW[7] =~ s/VIRUS/VIRUS_SP/; $NOW[7] =~ s/(.*?\_SP.*)\_SP/$1/;}
                                if($NOW[6] eq $NOW[5]){ $NOW[6].="_SP"; }
                        }
                        else{$NOW[6]=$test;}
                        if($NOW[7] eq $NOW[6]){ pop(@NOW); }
                }
                elsif($NOW[2] =~ /PHAGE/){

                        #FIX BLANKS, WRONGS AND MISSING PHAGE
                        if($NOW[6] !~ /PHAGE|VIRUS/ && $NOW[7] =~ /PHAGE|VIRUS/){ $tmp=$NOW[6]; $NOW[6]=$NOW[7]; $NOW[7]=$tmp; }
                        $NOW[5] =~ s/VIRUS/PHAGE/g;
                        $NOW[6] =~ s/VIRUS/PHAGE/g;
                        $NOW[7] =~ s/VIRUS/PHAGE/g;
                        if($NOW[5] !~/\w/ && $NOW[6]=~/([A-Z]+PHAGE)/){$NOW[5]=$1;}
                        if($NOW[5] !~/\w/ && $NOW[7]=~/([A-Z]+PHAGE)/){$NOW[5]=$1;}
                        if($NOW[5] =~ /PHAGE/){
                                $NOW[6] =~ s/[A-Z]*PHAGE/$NOW[5]/;
                                $NOW[7] =~ s/[A-Z]*PHAGE/$NOW[5]/;
                        }

                        #MAKE SURE HAS MID
                        $hit=10; $last=10;
                        for my $i (3..5){
                                if($NOW[$i] !~ /\w/){next;}     $last=$i;
                                if($NOW[6] =~ /$NOW[$i]/){$hit=$i;}
                        }
                        if($hit == 10 && $NOW[$last]=~/\w/){ $NOW[6]=$NOW[$last]."_SP_".$NOW[6];}

                        #MERGE STRAIN AND SPECIES
                        @strain = split("_",$NOW[7],-1);
                        foreach my $x (@strain){ if($NOW[6] !~ /$x/ && $x =~ /\w/){ $NOW[6].="_".$x; }}
                        $NOW[7] = $NOW[6];
                        $NOW[6] =~ s/PHAGE.*/PHAGE/;
                        if($NOW[7] eq $NOW[6]){ pop(@NOW); }
                }
                elsif($NOW[2] eq "SATELLITES"){
                        #FIX BLANKS, WRONGS AND MISSING SATELLITE
                        if($NOW[6] !~ /SATELLITE/ && $NOW[7] =~ /SATELLITE/){ $tmp=$NOW[6]; $NOW[6]=$NOW[7]; $NOW[7]=$tmp; }
                        if($NOW[5]=~/VIRUS/){
                                $old = $NOW[5];
                                $NOW[5] =~ s/VIRUS/SATELLITE/;
                                $NOW[6] =~ s/$old/$NOW[5]/;
                                $NOW[7] =~ s/$old/$NOW[5]/;
                        }
                        if($NOW[5] !~ /\w/ && $NOW[6] =~ /([A-Z]+SATELLITE)/){ $NOW[5]=$1;}
                        if($NOW[5] !~ /\w/ && $NOW[7] =~ /([A-Z]+SATELLITE)/){ $NOW[5]=$1;}
                        if($NOW[5] =~ /[A-Z]SATELLITE/){
                                $NOW[6] =~ s/[A-Z]*SATELLITE/$NOW[5]/;
                                $NOW[7] =~ s/[A-Z]*SATELLITE/$NOW[5]/;
                        }
                        #MERGE STRAIN AND SPECIES AND SPLIT
                        @strain = split("_",$NOW[7],-1);
                        foreach my $x (@strain){ if($NOW[6] !~ /$x/ && $x =~ /\w/){ $NOW[6].="_".$x; }}
                        $NOW[7] = $NOW[6];
                        $NOW[6] =~ s/SATELLITE.*/SATELLITE/;
                        if($NOW[7] eq $NOW[6]){ pop(@NOW); }
                }
                else{ print "unknown mona $tid @NOW\n"; die;}

                ### FILL SPECIES if EMPTY WITH MID-LEVEL, ADD _SP if missing ###
                $hit=10;  $last=10;
                for my $i (0..5){ #get last and hit
                        if($NOW[$i] !~ /\w/){next;} $last=$i;
                        if($NOW[6] =~ /$NOW[$i]\_|$NOW[$i]$|$NOW[$i]\b/){$hit=$i;}
                }
                if($hit < 10 && $NOW[6] =~ /^[A-Z]+$/){ $new = $NOW[$hit]."_SP"; $
                        NOW[6] =~ s/$NOW[$hit]/$new/; $NOW[7] =~ s/$NOW[$hit]/$new/;}
                if($NOW[6] !~ /\w/ && $last<10){ $NOW[6] = $NOW[$last]."_SP";}
                if($hit < 5 && $NOW[6] !~ /(\_SP|PHAGE|SATELLITE|VIRUS)/){ $replace=$NOW[$hit]."_SP"; $NOW[6]=~ s/$NOW[$hit]/$replace/; }

                #MAKE SURE THAT SPECIES HAVE MID-LEVEL
                $last=10; for my $i (0..5){ if($NOW[$i] !~ /\w/){next;} $last=$i; } #get last level
                if($NOW[6] !~ /$NOW[$last]/ && $NOW[7] =~ /$NOW[$last]/ && $last<10){
                        $tmp=$NOW[6]; $NOW[6]=$NOW[7]; $NOW[7]=$tmp;}

                #REMOVE EXCESS SP
                $NOW[6] =~ s/\_[\_SP]+\_/\_SP\_/g;
                $NOW[6] =~ s/(\_+SP\_+.*)\_SP\_/$1\_/g;
                $NOW[6] =~ s/(^\_+|\_+$)//g;

                if($NOW[6]=~/$NOW[7]/ && $NOW[7]=~/\w/){print "tid $tid now6 $NOW[6] contain now7 $NOW[7] @NOW\n"; pop(@NOW); }

                #STORE AND NEXT - CELLULAR ORGS BELOW HAVE OTHER THINGS
                $LINEAGES{$tid}=[@NOW];
                next;
        }

        #### CELLULAR ORGANISMS ####
        ############################
        if($NOW[0] eq "BACTERIA"){
                $NOW[6] =~ s/\_BACTERIUM/\_SP/g;
                $NOW[7] =~ s/\_BACTERIUM/\_SP/g;
                $NOW[6] =~ s/^BACTERIUM/BACTERIA_SP/g;
                $NOW[7] =~ s/^BACTERIUM/BACTERIA_SP/g;
                @strain = split("_", $NOW[7],-1);
                foreach my $x (@strain){ if($NOW[6] !~ /$x/ && $x =~ /\w/){ $NOW[6].="_".$x; }}
                $NOW[7] = $NOW[6];

                #IF NO MID LEVELS
                $test = join("",@NOW[1..5]);
                if($test !~ /\w/){ $ch1++;
                        #MAKE SURE BEGINS WITH BACTERIA
                        $NOW[6] =~ s/(.*)\_(BACTERIA.*)/$2\_$1/;
                        $NOW[6] =~ s/(.*)\_([A-Z]+BACTERIA.*)/$2\_$1/;
                        $NOW[6] =~ s/\_BACTERIUM/\_SP/g;
                        if($NOW[6] !~ /BACTERIA/){$NOW[6]="BACTERIA_SP_".$NOW[6];}
                }

                #MOVE HIGHEST NAMED LEVEL TO THE FRONT, ADD _SP, TRACK HIGHEST LEVEL
                $hit=10; $last=10;
                for my $i (0..5){
                        if($NOW[$i] !~ /\w/){next;}
                        $last=$i; $tmp = $NOW[$i];
                        $tmp =~ s/BACTERIA/BACTERIUM/;
                        if($NOW[6] =~ /$NOW[$i]\_|$NOW[$i]$|$NOW[$i]\b/){$hit=$i;}
                        elsif($NOW[6] =~ /$tmp\_|$tmp$/){ $hit=$i; }
                        else{}
                }

                #IF NOT FOUND MIDS, ADD LAST GOOD LEVEL
                if($hit==10 && $last<10){ if($NOW[6] !~ /^[A-Z]{5,}\_[A-Z]+/){$NOW[6]=$NOW[$last]."_SP_".$NOW[6];} $hit=$last;}
                if($last == $hit && $last < 5 && $NOW[6]=~/BACTERIUM/){ $NOW[6]=~s/BACTERIUM/BACTERIA_SP_/; }
                if($last > $hit && $last < 5){ $ch4++; #replace with highest mid-level name
                        $old = $NOW[$hit];
                        if($NOW[6] =~ /[A-Z]BACTERIUM/ && $old =~ /[A-Z]BACTERIA/){ $NOW[6] =~ s/BACTERIUM/BACTERIA/g; }
                        $new = $NOW[$last]."_SP_";
                        $NOW[6] =~ s/[A-Z]*$old[A-Z]*/$new/;
                        $hit=$last;
                }

                #MOVE ANYTHING BEFORE GENUS/MIDLEVEL TO END
                $NOW[6] =~ s/\_BACTERIA//g;
                $NOW[6] =~ s/(.*)\_([A-Z]*$NOW[$hit].*)/$2\_$1/;
                #REMOVE ANY NO-GOOD LOWER LEVELS
                if($last>0 && $last<10){
                        for my $i (0..$last-1){
                                if($NOW[$i]=~/\w/){ $NOW[6] =~ s/\_$NOW[$i]\_|\_$NOW[$i]$/\_/; }
                        }
                }
        }
        elsif($NOW[0] eq "EUKARYOTA"){
                $NOW[6] =~ s/EUKARYOTE/EUKARYOTA/;
                $NOW[7] =~ s/EUKARYOTE/EUKARYOTA/;
                @strain = split("_", $NOW[7],-1);
                foreach my $x (@strain){ if($NOW[6] !~ /$x/ && $x =~ /\w/){ $NOW[6].="_".$x; }}
                $NOW[7] = $NOW[6];

                #GET RID OF "BACTERIA" AS AN NAME!
                $test = join(";",@NOW[0..7]);
                $test =~ s/BACTERIA|ARCHAEA/EUKARYA/g;
                @NOW = split(";",$test,-1);

                #MOVE HIGHEST NAMED LEVEL TO THE FRONT, ADD _SP, TRACK HIGHEST LEVEL
                $hit=10;  $last=10;
                for my $i (0..5){
                        if($NOW[$i] !~ /\w/){next;} $last=$i;
                        if($NOW[6] =~ /$NOW[$i]\_|$NOW[$i]$|$NOW[$i]\b/){$hit=$i;}
                }

                #IF NOT FOUND MIDS, ADD LAST GOOD LEVEL
                if($hit==10 && $last<10){ if($NOW[6] !~ /^[A-Z]{5,}\_[A-Z]+/){$NOW[6]=$NOW[$last]."_SP_".$NOW[6];} $hit=$last;}
                if($last > $hit && $last < 5){ $ch4++; #replace with highest mid-level name
                        $old = $NOW[$hit];
                        $new = $NOW[$last]."_SP_";
                        $NOW[6] =~ s/[A-Z]*$old[A-Z]*/$new/;
                        $hit=$last;
                }

                #MOVE ANYTHING BEFORE GENUS/MIDLEVEL TO END
                $NOW[6] =~ s/\_EUKARYOTA//g;
                $NOW[6] =~ s/(.*)\_([A-Z]*$NOW[$hit].*)/$2\_$1/;
                #REMOVE ANY NO-GOOD LOWER LEVELS
                if($last>0 && $last<10){ for my $i (0..$last-1){ if($NOW[$i]=~/\w/){$NOW[6] =~ s/\_$NOW[$i]\_|\_$NOW[$i]$/\_/; }}}
        }
        elsif($NOW[0] eq "ARCHAEA"){

                #FIX INCONSISTENT ARCHAEA IDs
                $NOW[6] =~ s/(ARCHAEAL|ARCHAEBACTERIAL|ARCHAEON|ARCHEON)/ARCHAEA_SP/;
                $NOW[7] =~ s/(ARCHAEAL|ARCHAEBACTERIAL|ARCHAEON|ARCHEON)/ARCHAEA_SP/;
                $NOW[6] =~ s/ARCHA*EOT[EA]/ARCHAEOTA_SP/;
                $NOW[7] =~ s/ARCHA*EOT[EA]/ARCHAEOTA_SP/;
                @strain = split("_", $NOW[7],-1);
                foreach my $x (@strain){ if($NOW[6] !~ /$x/ && $x =~ /\w/){ $NOW[6].="_".$x; }}
                $NOW[7] = $NOW[6];

                #GET RID OF "BACTERIA" AS AN NAME!
                $test = join(";",@NOW[0..7]);
                $test =~ s/BACTERIA/ARCHAEA/g;
                @NOW = split(";",$test,-1);

                #IF NO MID LEVELS
                $test = join("",@NOW[1..5]);
                if($test !~ /\w/){ $ch1++;
                        #MAKE SURE BEGINS WITH ARCHAEA
                        if($NOW[6]=~/ARCHAEOTA/){ $NOW[6] =~ s/(.*)\_([A-Z]*ARCHAEOTA.*)/$2\_$1/;}
                        else{ $NOW[6] =~ s/(.*)\_([A-Z]*ARCHAEA.*)/$2\_$1/; }
                        if($NOW[6] !~ /ARCHAEA|ARCHAEOTA/){$NOW[6]="ARCHAEA_SP_".$NOW[6];}
                }

                #FIX "ARCHAEOTA"
                if(grep{ /ARCHAEOTA/} @NOW && $NOW[1] !~ /\w/){$NOW[6]=~/([A-Z]*ARCHAEOTA)/; $NOW[1] = $1; } #fill in missing phylum
                if($NOW[1] =~ /ARCHAEOTA/ && $NOW[6] =~ /ARCHAEOTA/){
                        $NOW[6] =~ s/[A-Z]*ARCHAEOTA/$NOW[1]/g;
                        $NOW[6] =~ s/(ARCHAEOTA.*)[A-Z]*(ARCHAEOTA|ARCHAEA)/$1/;
                } #ensure matching archaeotas

                #MOVE HIGHEST NAMED LEVEL TO THE FRONT, ADD _SP, TRACK HIGHEST LEVEL
                $hit=10; $last=10;
                for my $i (0..5){
                        if($NOW[$i] !~ /\w/){next;}     $last=$i;
                        if($NOW[6] =~ /$NOW[$i]\_|$NOW[$i]$|$NOW[$i]\b/){$hit=$i;}
                }

                #IF NOT FOUND MIDS, ADD LAST GOOD LEVEL
                if($hit==10 && $last<10){ $NOW[6]=$NOW[$last]."_SP_".$NOW[6]; $hit=$last;}
                if($last > $hit && $last < 5){ $ch4++; #replace with highest mid-level name
                        $old = $NOW[$hit];
                        $new = $NOW[$last]."_SP_";
                        $NOW[6] =~ s/[A-Z]*$old[A-Z]*/$new/;
                        $hit=$last;
                }

                #MOVE ANYTHING BEFORE GENUS/MIDLEVEL TO END
                $NOW[6] =~ s/\_ARCHAEA//g;
                $NOW[6] =~ s/(.*)\_([A-Z]*$NOW[$hit].*)/$2\_$1/;
                #REMOVE ANY NO-GOOD LOWER LEVELS
                if($last>0 && $last<10){ for my $i (0..$last-1){ if($NOW[$i]=~/\w/){$NOW[6] =~ s/\_$NOW[$i]\_|\_$NOW[$i]$/\_/; }}}
        }
        else{ print "what is this tid $tid @NOW\n"; die;}
        ### NOW ALL NAMES ARE CLEANED ###

        #MAKE SURE THAT VIRUSES, AND CELLULAR ORGANISMS SPECIES HAVE MID-LEVEL
        #OTHERWISE BACTERIA.*ALVINELLA_POMPEJANA_SYMBIONT_7_66 LATER BECOMES
        #GETS A EUKARYOTE SPECIES NAME
        #GET LAST MID-LEVEL
        for my $i (0..5){ if($NOW[$i] !~ /\w/){next;} $last=$i; }
        if($NOW[6] !~ /$NOW[$last]/ && $NOW[7] =~ /$NOW[$last]/ && $last<10){$tmp=$NOW[6]; $NOW[6]=$NOW[7]; $NOW[7]=$tmp;}
        if($NOW[6] !~ /$NOW[$last]/ && $last<10){
                   if($NOW[0] =~ /BACTERIA/){
                        if($NOW[6] =~ /BACTERIUM/ && $NOW[$last]=~/BACTERIA/){$NOW[6]=~s/BACTERIUM/BACTERIA/g;}
                        if($NOW[6] =~ /([A-Z]+(IDAE|INAE|ACEAE))([\b\_]|$)/){
                                $found=$1;
                                if($NOW[4] !~ /\w/ || $NOW[6] =~ /$NOW[4]/){ $NOW[4]=$found;}
                                $replace = $NOW[4]."_SP_";
                                $NOW[6] =~ s/$found/$replace/;
                                $NOW[7] =~ s/$found/$replace/;
                        }
                        elsif($NOW[6] =~ /([A-Z]+ALES)([\b\_]|$)/){
                                $found=$1;
                                if($NOW[3] !~ /\w/ || $NOW[6] =~ /$NOW[3]/ ){ $NOW[3]=$found;}
                                $replace=$NOW[3]."_SP_";
                                $NOW[6] =~ s/$found/$replace/;
                                $NOW[7] =~ s/$found/$replace/;
                        }
                        else{ $NOW[6] = $NOW[$last]."_SP_".$NOW[6];}
                }
                elsif($NOW[0] =~ /EUKARYOTA|ARCHAEA/){
                        if($NOW[6] =~ /([A-Z]+(IDAE|INAE|ACEAE))([\b\_]|$)/){
                                $found=$1;
                                if($NOW[4] !~ /\w/ || $NOW[6] =~ /$NOW[4]/){ $NOW[4]=$found;}
                                $replace = $NOW[4]."_SP_";
                                $NOW[6] =~ s/$found/$replace/;
                                $NOW[7] =~ s/$found/$replace/;
                        }
                        elsif($NOW[6] =~ /([A-Z]+ALES)([\b\_]|$)/){
                                $found=$1;
                                if($NOW[3] !~ /\w/ || $NOW[6] =~ /$NOW[3]/ ){ $NOW[3]=$found;}
                                $replace=$NOW[3]."_SP_";
                                $NOW[6] =~ s/$found/$replace/;
                                $NOW[7] =~ s/$found/$replace/;
                        }
                        else{ $NOW[6] = $NOW[$last]."_SP_".$NOW[6];}
                }
                else{ }#print "not doing @NOW\n"; }
        }

        #REMOVE EXCESS SP
        $NOW[6] =~ s/\_[\_SP]+\_/\_SP\_/g;
        $NOW[6] =~ s/(\_+SP\_+.*)\_SP\_/$1\_/g;
        $NOW[6] =~ s/(^\_+|\_+$|\_\_)//g;

        #DO FINAL CLEANUP - split species & strain
        @SPE=split("_",$NOW[6],-1); @GSPE=();
        foreach my $x (@SPE){ if(!grep{/^$x$/} @GSPE && $x =~ /\w/){ push(@GSPE,$x); }}
        $NOW[6] = join("_", @GSPE); $NOW[7] = $NOW[6];
        if($NOW[6] =~ /\_SP[\b\_]|\_SP$/){ $NOW[6] =~ s/(\_SP[\b\_]|\_SP$).*/\_SP/; }
        else{ $NOW[6] =~ s/^([^\_]+\_[^\_]+).*?$/$1/; }
        if($NOW[6] eq $NOW[7]){ $NOW[7]=''; }

        ### FILL SPECIES if EMPTY WITH MID-LEVEL, ADD _SP if missing ###
        $hit=10; $last=10;
        for my $i (0..5){ if($NOW[$i] !~ /\w/){next;} $last=$i; if($NOW[6] =~ /$NOW[$i]\_|$NOW[$i]$|$NOW[$i]\b/){$hit=$i;}}
        if($NOW[6] !~ /_SP/ && $hit < 10 && $NOW[6] =~ /^[A-Z]+$/){$new = $NOW[$hit]."_SP"; $NOW[6] =~ s/$NOW[$hit]/$new/; }
        if($NOW[6] !~ /\w/ && $last<10){ $NOW[6] = $NOW[$last]."_SP"; }
        $NOW[6] =~ s/(^\_+|\_+$|\_\_)//g;

        #OUTPUT
        if($tid =~ /0000$/){print "tid $tid old @OLD\ntid $tid new @NOW\n"; }
        $LINEAGES{$tid}=[@NOW];
}

print "OUTPUT CLEANED NAMES RAW 2\n";
open(OUTPUT, ">", $output)||die;
foreach my $tid (keys %LINEAGES){
        $lin=join("\t",@{$LINEAGES{$tid}});
        print OUTPUT "$tid\t$lin\n";
}
