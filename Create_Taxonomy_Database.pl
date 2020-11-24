#use warnings;

### GET THE STRUCTURAL INFORMATION ABOUT VIRUSES (EG. SSRNA, DSDNA...) ###
print "INPUT ICTV.TXT\n";
$inictv = 'ICTV.txt';
open(INVIR, $inictv)||die "unable to open $inictv: $!\n";
while(<INVIR>){
		if($_ !~/^\d/){next;}
		$_ = uc($_);
		$_ =~ s/[\r\n]+//;
		@stuff = split("\t", $_,-1);
		if(exists($VIRTYPE{$stuff[9]}) && exists($stuff[11]) && exists($stuff[13])){next;}
		
		if($_ =~ /SATELLIT/){
			if($stuff[9]  =~ /\w/){$VIRTYPE{$stuff[9]} ="MONA;VIRUSES;SATELLITES";}
			if($stuff[11] =~ /\w/){$VIRTYPE{$stuff[11]}="MONA;VIRUSES;SATELLITES";}
			if($stuff[13] =~ /\w/){$VIRTYPE{$stuff[13]}="MONA;VIRUSES;SATELLITES";}
			next;
		}
		if($_ =~ /PHAGE/){
 			if($stuff[9]  =~ /\w/){$VIRTYPE{$stuff[9]} ="MONA;VIRUSES;PHAGES";}
			if($stuff[11] =~ /\w/){$VIRTYPE{$stuff[11]}="MONA;VIRUSES;PHAGES";}
			if($stuff[13] =~ /\w/){$VIRTYPE{$stuff[13]}="MONA;VIRUSES;PHAGES";}
			next;
		}

		#CLEAN UP STRUCTURAL CLASS NAMING
		   if($stuff[17] =~ /(...NA).*\(.*\-/ && $stuff[17] =~ /(...NA).*\(.*\+/){ $stuff[17]=$1."_BOTH"; }
		elsif($stuff[17] =~ /(...NA).*\(.*\-/){ $stuff[17]=$1."_NEG";}
		elsif($stuff[17] =~ /(...NA).*\(.*\+/){$stuff[17]=$1."_POS";}
		elsif($stuff[17] =~ /DS(.NA)/ && $stuff[17] =~ /SS(.NA)/ ){$stuff[17]=$1;}
		elsif($stuff[17] =~ /(...NA).*RT/ ){$stuff[17]=$1."_RT";}
		elsif($stuff[17] =~ /(...NA)/){$stuff[17]=$1;}
		else{next;}

		if($stuff[9]  =~ /\w/){$VIRTYPE{$stuff[9]} ="MONA;VIRUSES;$stuff[17]";}
		if($stuff[11] =~ /\w/){$VIRTYPE{$stuff[11]}="MONA;VIRUSES;$stuff[17]";}
		if($stuff[13] =~ /\w/){$VIRTYPE{$stuff[13]}="MONA;VIRUSES;$stuff[17]";}
}


#INPUT THE NAME OF EACH RANK
print "INPUT FULL LINEAGE\n";
$indat = 'fullnamelineage.dmp';
open(INDAT, $indat)||die;
while(<INDAT>){
		if($_ !~/\w/){next;}
		$_ = uc($_);
		$_ =~ s/[\r\n]+//;
		@stuff = split("\t", $_,-1);
		$tid = $stuff[0];
		$name=$stuff[2];
		
		#fix the species/strain name and store %NAMES{ id# } = name
		$name =~ s/([A-Z]+)\s(PROTEOBACTER)(IA|IUM)/$1$2$3/;
		$name =~ s/\bPROPIONIBACTERIUM/CUTIBACTERIUM/g;
		$name =~ s/\bLEPIDOSAURIA/SAURIA/g;
		$name =~ s/ENDOSYMBIONT.OF\s+/ENDOSYMBIONT-/;
		$name =~ s/COMPOSITE.GENOME.*//;
		$name =~ s/MARINE.GROUP.(\w+)/MARINE-GROUP-$1/;
		$name =~ s/\s+METAGENOME//;
		$name =~ s/OOMYCETES/OOMYCOTA/;
		$name =~ s/LILIOPSIDA/MAGNOLIOPSIDA/;

		#remove ambiguous junk
		$name =~ s/(CANDIDATUS|CANDIDATE.\S+|VOUCHERED|UNDESCRIBED|UNSCREENED|UNKNOWN|UNCULTIVATED|UNCULTURED|INCERTAE.SEDIS|UNIDENTIFIED|UNCLASSIFIED|CONTAMINATION SCREENED|UNASSIGNED|PUTATIVE|LIKE)\s*/\_/g;

		#remove junk punctuation/standardize
		$name =~ s/\s+/_/g;
		$name =~ s/[^\w\-]+/_/g;
		$name =~ s/\_+/\_/g;
		$name =~ s/(^\_+|\_+$)//g;
		$name =~ s/\-+\_+/\-/g;
		$name =~ s/\_+\-+/\-/g;
		$name =~ s/^(X|CF)\_//;
		$NAMES{$tid}=$name;

		#GET THE MONAS
		$stuff[4] =~ s/\;\s+/\;/g;
		@NOW=split(";",$stuff[4],-1);
		push(@NOW, $name);
		
		#PLASMIDS & VECTORS
		if(grep {/OTHER.SEQUENCES/} @NOW){
				   if($name =~ /ARTIFICIAL|SYNTHETIC|VECTOR|COSMID/ || $stuff[4] =~ /ARTIFICIAL|SYNTHETIC|VECTOR|COSMID/ ){ $ODD{$tid}="MONA;CONSTRUCTS;"; next;}
				elsif($name =~ /PLASMID|MINICHROMOSOME/ 			|| $stuff[4] =~  /PLASMID|MINICHROMOSOME/			 ){	$ODD{$tid}="MONA;PLASMIDS;";   next;}
				elsif($name =~ /INSERTION.SEQUENCE|TRANSPOSON/	  || $stuff[4] =~ /INSERTION.SEQUENCE|TRANSPOSON/	  ){ $ODD{$tid}="MONA;TRANSPOSONS;";next;}
				else{$name=$name;}
		}
		
		#METAGENOMES
		if(grep {/^METAGENOME/} @NOW){
			if(grep {/ECOLOGICAL/} @NOW){
				if($name !~ /\w/){$name="UNCLASSIFIED";} 
				$ODD{$tid}="MICROBIOME;ENVIRONMENTAL;".$name."_MICROBIOME"; next;}
			if(grep {/ORGANISMAL/} @NOW){
				if($name !~ /\w/){$name="UNCLASSIFIED";} 
				$ODD{$tid}="MICROBIOME;HOST-ASSOCIATED;".$name."_MICROBIOME"; next;}
		}

		#VIRUSES, PHAGES, & SATELLITES
		if(grep {/VIRUSES/} @NOW){
				   if(grep {/(CAUDOVIRALES|ACKERMANNVIRIDAE|AUTOLYKIVIRIDAE|CORTICOVIRIDAE|CYSTOVIRIDAE|INOVIRIDAE)/} @NOW){ $ODD{$tid}="MONA;VIRUSES;PHAGES";}
			   	elsif(grep {/(LEVIVIRIDAE|MICROVIRIDAE|SPHAEROLIPOVIRIDAE|MYOVIRIDAE|PODOVIRIDAE|SIPHOVIRIDAE|TECTIVIRIDAE)/} @NOW){ $ODD{$tid}="MONA;VIRUSES;PHAGES";}	   	
			   	elsif(grep {/(ALBETOVIRUS|AUMAIVIRUS|PAPANIVIRUS|VIRTOVIRUS|SARTHROVIRIDAE|MACRONOVIRUS)/} @NOW){ $ODD{$tid}="MONA;VIRUSES;SATELLITES";}
			   	elsif(grep {/SATELLIT/} @NOW){$ODD{$tid}="MONA;VIRUSES;SATELLITES";}
			   	elsif(grep {/\bPHAGE\b/} @NOW){$ODD{$tid}="MONA;VIRUSES;PHAGES";}
			   	else{
			   		foreach my $lev (@NOW){ if(exists($VIRTYPE{$lev})){ $ODD{$tid}=$VIRTYPE{$lev};} }
			   		if(!exists($ODD{$tid})){next;}
			   	}
		}
}



#TID\TLEVEL
#GET THE TYPE OF EACH TAXONOMIC RANK (EG. SPECIES, CLASS, SUPERKINGDOM...)
print "INPUT LEVELS\n";
$inlevs = 'nodes.dmp';
open(INLEV, $inlevs)||die;
while(<INLEV>){
		if($_ !~/^\d/){next;}
		$_ = uc($_);
		$_ =~ s/[\r\n]+//;
		@stuff = split("\t", $_,-1);
		$tid = $stuff[0];
		$LEVS{$tid} = $stuff[4];
		if($tid == 32561){ $LEVS{$tid} = "CLASS";} #fixes reptiles class
}




#USE THE RANKS AND CORRECTED NAMES TO GENERATE AN ORGANIZED LINEAGE
print "INPUT TAXIDLINEAGES\n";
$inlin = 'taxidlineage.dmp';
open(INLIN, $inlin)||die;
while(<INLIN>){
		if($_ !~/^\d/){next;}
		$_ = uc($_);
		$_ =~ s/[\r\n]+//;
		@stuff = split('\t', $_,-1);	
		@NOW=();
		$tid = shift(@stuff);
		@LIN = split('\s', $stuff[1],-1);
		push(@LIN, $tid);
		
		
		#FIRST GET MAIN 7 RANKS: K/P/C/O/F/G/S
		if($NAMES{$tid} =~ /ENVIRONMENTAL.SAMPLES/){next;}
		foreach my $id (@LIN){
				if($id !~ /^\d+$/){next;}
				if($NOW[6] =~ /\w/){last;}
				if($LEVS{$id}	eq "SPECIES"){		$NOW[6]=$NAMES{$id}; 
					#IF THE ID IS SPECIES AND TID IS NOT ID, THEN TID IS STRAIN
					#THIS WILL CAPTURE ALL SUB-SPECIES RANKS
					if($tid != $id && $NAMES{$tid} ne $NOW[6] ){ $NOW[7]=$NAMES{$tid}; }
					last;
		   		}
				elsif($LEVS{$id} eq "GENUS"){		$NOW[5]=$NAMES{$id}; }
				elsif($LEVS{$id} eq "FAMILY"){		$NOW[4]=$NAMES{$id}; }
				elsif($LEVS{$id} eq "ORDER"){		$NOW[3]=$NAMES{$id}; }
				elsif($LEVS{$id} eq "CLASS"){		$NOW[2]=$NAMES{$id}; }
				elsif($LEVS{$id} eq "PHYLUM"){		$NOW[1]=$NAMES{$id}; }
				elsif($LEVS{$id} eq "SUPERKINGDOM"){$NOW[0]=$NAMES{$id}; }
				else{}
				#DELETE ALL RANKS BELOW SPECIES FROM OLD TAX DB
				if($NOW[6] !~ /\w/ && exists($TAXON{$id}) && $TAXON{$id} !~ /\_.*\d/){ delete($TAXON{$id}); }
		}
		#NOW EXTRA RANKS ARE REMOVED
		
		
		#NEXT FINISH THE MICROBIOME AND THE VECTORS
		if(exists($ODD{$tid})){@NOW[0..2] = split(";", $ODD{$tid},-1);}
		if($NOW[0] eq "MICROBIOME"){ splice(@NOW, 3, $#NOW-3+1); $lin = join(";", @NOW); $TAXON{$oid}=$lin; $micr++; next; }
		if($NOW[6] !~ /\w/ && $NOW[7] !~ /\w/){next;} #skip non-species ranks
		if($NOW[1] =~ /CONSTRUCTS|TRANSPOSONS|PLASMIDS/){ 
				for my $i (2..5){ $NOW[$i] = '';}
				if($NOW[7] =~ /\w/){ @STR = split("_", $NOW[7],-1); foreach my $p (@STR){ if($NOW[6] !~ /$p/){ $NOW[6].="_".$p; }} $NOW[7]=$NOW[6]; }
				else{ $NOW[7] = $NOW[6];}
				$NOW[6] =~ s/(.+\_.*(MINICHROMOSOME|TRANSPOSON|PLASMID|CONSTRUCT|PROMOTER|CASSETTE|MODULE|COSMID|MOLECULE|VECTOR|BACTERIUM|SEQUENCE)[A-Z]*)\_.+?$/$1/i;
				if($NOW[6] eq $NOW[7]){ pop(@NOW); }
				$lin = join(";", @NOW); $TAXON{$oid}=$lin; $mona++; next;
		}
		if($NOW[0] !~ /MONA|EUKARYOTA|BACTERIA|ARCHAEA/){next;}
		if($NOW[6] !~ /\w/ && $NOW[7] !~ /\w/){next;}
		#NOW ONLY VIRUSES BACTERIA ARCHAEA AND EUKARYOTA


		#STORE
		if($NOW[6] !~ /\w/){delete($TAXON{$tid}); next;} #SKIP ALL VIRUSES/EUKARYOTA/BACTERIA/ARCHAEA WITHOUT SPECIES
		$lin = join(";", @NOW);
		$lin =~ s/\;+$//;	
		$TAXON{$tid}=$lin;
		for my $i (0..5){ if($NOW[$i]=~/\w/){$MIDLEV{$NOW[$i]}{$tid}++; }}
		for my $i (2..6){ if($NOW[$i]=~/\w/ && !exists($ALL_LEVS{$NOW[$i]}{$NOW[$i-1]})){ $top = join(";", @NOW[0..$i-1]); $ALL_LEVS{$NOW[$i]}{$NOW[$i-1]}=$top;}}
		if($on%200000==0){ print "on $on NCBI tid $tid $lin\n"; }
		$on++;
}




#INPUT IMG GENOMES
print "INPUT IMG GENOMES\n";
$inimg = 'All_IMG_Genomes.txt';
open(INIMG, $inimg)||die;
while(<INIMG>){
		if($_ !~/^\d/){next;}
		$_ = uc($_);
		$_ =~ s/[\r\n]+//;
		@stuff = split('\t', $_,-1);
		$oid = shift(@stuff);
		$tid = shift(@stuff);
		@NOW = @stuff[0..7];
		@NCBI = split(";", $TAXON{$tid},-1);
		for my $x (0..7){
				#fix the species/strain name and store %NAMES{ id# } = name
				$NOW[$x] =~ s/([A-Z]+)\s(PROTEOBACTER)(IA|IUM)/$1$2$3/;
				$NOW[$x] =~ s/\bPROPIONIBACTERIUM/CUTIBACTERIUM/g;
				$NOW[$x] =~ s/\bLEPIDOSAURIA/SAURIA/g;
				$NOW[$x] =~ s/ENDOSYMBIONT.OF\s+/ENDOSYMBIONT-/;
				$NOW[$x] =~ s/COMPOSITE.GENOME.*//;
				$NOW[$x] =~ s/MARINE.GROUP.(\w+)/MARINE-GROUP-$1/;
				$NOW[$x] =~ s/\s+METAGENOME//;
				$NOW[$x] =~ s/OOMYCETES/OOMYCOTA/;
				$NOW[$x] =~ s/LILIOPSIDA/MAGNOLIOPSIDA/;

				#remove ambiguous junk
				$NOW[$x] =~ s/(CANDIDATUS|CANDIDATE.\S+|VOUCHERED|UNDESCRIBED|UNSCREENED|UNKNOWN|UNCULTIVATED|UNCULTURED|INCERTAE.SEDIS|UNIDENTIFIED|UNCLASSIFIED|CONTAMINATION.SCREENED|UNASSIGNED|PUTATIVE|LIKE)\s*/\_/g;

				#remove junk punctuation/standardize
				$NOW[$x] =~ s/\s+/_/g;
				$NOW[$x] =~ s/[^\w\-]+/_/g;
				$NOW[$x] =~ s/\_+/\_/g;
				$NOW[$x] =~ s/(^\_+|\_+$)//g;
				$NOW[$x] =~ s/\-+\_+/\-/g;
				$NOW[$x] =~ s/\_+\-+/\-/g;
				$NOW[$x] =~ s/^(X|CF)\_//;
		}
		
		#FIRST HANDLE THE MICROBIOME EITHER ENVIRONMENTAL/HOST_ASSOCIATED/ENGINEERED
		#WHILE NCBI/IMG ANNOTATIONS ARE CRAPPY, TMP ONLY UP TO CLASS-LEVEL
		if($NOW[0] =~ /MICROBIOME/){
			@tmp=(); for my $x (0..5){ if($NOW[$x] ne "UNCLASSIFIED" && $NOW[$x] ne ""){ push(@tmp, $NOW[$x]);}}
			@NOW = (); $NOW[0] = "MICROBIOME"; $NOW[1]=$tmp[1]; 
			if($tmp[2] =~ /\w/){ $NOW[2]=$tmp[2]."_MICROBIOME";} 
			else{$NOW[2]="UNCLASSIFIED_MICROBIOME";}
			$lin = join(";", @NOW); $TAXON{$oid}=$lin; $micr++; next;
		}
			
		#SECOND HANDLE THE VECTORS
		if($NOW[0] eq "PLASMID" || grep {/PLASMID\b/} @NOW){
				   if(grep {/ARTIFICIAL|SYNTHETIC|VECTOR|COSMID/} @NOW){	@tmp = split(";", "MONA;CONSTRUCTS;",-1);}
				elsif(grep {/INSERTION.SEQUENCE|TRANSPOSON/} @NOW){			@tmp = split(";", "MONA;TRANSPOSONS;",-1);}
				else{														@tmp = split(";", "MONA;PLASMIDS;",-1);}
				#fix species/strain
				$tmp[6] = $NOW[7]; $tmp[7] = $NOW[7]; @NOW = @tmp; 
				if($NOW[7] =~ /\w/){ @STR = split("_", $NOW[7],-1); foreach my $p (@STR){ if($NOW[6] !~ /$p/){ $NOW[6].="_".$p; }} $NOW[7]=$NOW[6]; }
				else{ $NOW[7] = $NOW[6];}
				$NOW[6] =~ s/(.+\_.*(MINICHROMOSOME|TRANSPOSON|PLASMID|CONSTRUCT|PROMOTER|CASSETTE|MODULE|COSMID|MOLECULE|VECTOR|BACTERIUM|SEQUENCE)[A-Z]*)\_.*?$/$1/i;
				if($NOW[6] eq $NOW[7]){ pop(@NOW); }
				$lin = join(";", @NOW); $TAXON{$oid}=$lin; $mona++; next;
		}

		#THIRD HANDLE VIRUSES, PHAGES, & SATELLITES
		if($NOW[0]=~/VIRUSES/){
			   if(exists($ODD{$tid})){@NOW[0..2]=split(";", $ODD{$tid},-1);}
			elsif(grep {/(CAUDOVIRALES|ACKERMANNVIRIDAE|AUTOLYKIVIRIDAE|CORTICOVIRIDAE|CYSTOVIRIDAE|INOVIRIDAE)/		} @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGES",-1);}
		   	elsif(grep {/(LEVIVIRIDAE|MICROVIRIDAE|SPHAEROLIPOVIRIDAE|MYOVIRIDAE|PODOVIRIDAE|SIPHOVIRIDAE|TECTIVIRIDAE)/} @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGES",-1);}	   	
		   	elsif(grep {/(ALBETOVIRUS|AUMAIVIRUS|PAPANIVIRUS|VIRTOVIRUS|SARTHROVIRIDAE|MACRONOVIRUS)/				   } @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;SATELLITES",-1);}
		   	elsif(grep {/SATELLIT/ } @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;SATELLITES",-1);}
		   	elsif(grep {/\bPHAGE\b/} @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGES",-1);}
		   	else{
		   		foreach my $lev (@NOW){ 
		   			if(exists($VIRTYPE{$lev})){ @NOW[0..2]=split(";", $VIRTYPE{$lev},-1); last;}
		   			else{ @NOW[0..2]=split(";", "MONA;VIRUSES;",-1); }
		}	}	}
		
		#USE NCBI IF SAME SPECIES TO MAINTAIN CONSISTENCY
		if($NOW[6] !~ /\w/ && $NCBI[6] =~ /\w/){ $NCBI[7] = $NOW[7]; @NOW=@NCBI;} #no species but NCBI species
		if(exists($SPE2TOP{$NOW[7]})){ @tmp = split(";", $SPE2TOP{$NOW[7]},-1); @NOW[0..5] = @tmp[0..5];}
		elsif(exists($SPE2TOP{$NOW[6]})){ @tmp = split(";", $SPE2TOP{$NOW[6]},-1); @NOW[0..5] = @tmp[0..5];}
		else{@NOW=@NOW;}

		#STORE
		$lin = join(";", @NOW);
		$lin =~ s/\;+$//;
		$TAXON{$oid}=$lin;
		for my $i (0..5){ if($NOW[$i]=~/\w/){$MIDLEV{$NOW[$i]}{$tid}++; }}
		for my $i (2..6){ if($NOW[$i]=~/\w/ && !exists($ALL_LEVS{$NOW[$i]}{$NOW[$i-1]})){ $top = join(";", @NOW[0..$i-1]); $ALL_LEVS{$NOW[$i]}{$NOW[$i-1]}=$top;}}
		if($on%200000==0){ print "on $on IMG tid $tid $lin\n"; }
		$on++;	
}






#INPUT OLD TAXONOMY DATABASE
print "INPUT OLD TAXONOMY\n";
$intdb = 'C:\Users\TealF\Documents\PNG\TAXONOMY_DB_2018.txt';
open(INTDB, $intdb)||die;
while(<INTDB>){
		if($_ !~/^\d/){next;}
		$_ = uc($_);
		$_ =~ s/[\r\n]+//;
		@NOW = split('\t', $_,-1);
		$tid = shift(@NOW);
		if(exists($TAXON{$tid})){next;}
		else{	
				#REMOVE FILLER AND FIX NAMES
				#if(grep {/MYCOBACTERIUM.TIMQUATROVIRUS|ZINGIBERALES/} @NOW){ print "MT $tid TDB1 @NOW\n";}
				if($NOW[6] =~ /^UNCLASSIFIED.*SPECIES/){next;}
				for my $x (0..5){ if($NOW[$x] =~ /UNCLASSIFIED/){ $NOW[$x]='';}}			
				for my $x (0..$#NOW){
						#fix the species/strain name and store %NAMES{ id# } = name
						$NOW[$x] =~ s/([A-Z]+)\s(PROTEOBACTER)(IA|IUM)/$1$2$3/;
						$NOW[$x] =~ s/\bPROPIONIBACTERIUM/CUTIBACTERIUM/g;
						$NOW[$x] =~ s/\bLEPIDOSAURIA/SAURIA/g;
						$NOW[$x] =~ s/ENDOSYMBIONT.OF\s+/ENDOSYMBIONT-/;
						$NOW[$x] =~ s/COMPOSITE.GENOME.*//;
						$NOW[$x] =~ s/MARINE.GROUP.(\w+)/MARINE-GROUP-$1/;
						$NOW[$x] =~ s/\s+METAGENOME//;
						$NOW[$x] =~ s/OOMYCETES/OOMYCOTA/;
						$NOW[$x] =~ s/LILIOPSIDA/MAGNOLIOPSIDA/;

						#remove ambiguous junk
						$NOW[$x] =~ s/(CANDIDATUS|CANDIDATE.\S+|VOUCHERED|UNDESCRIBED|UNSCREENED|UNKNOWN|UNCULTIVATED|UNCULTURED|INCERTAE.SEDIS|UNIDENTIFIED|UNCLASSIFIED|CONTAMINATION SCREENED|UNASSIGNED|PUTATIVE|LIKE)\s*/\_/g;

						#remove junk punctuation/standardize
						$NOW[$x] =~ s/\s+/_/g;
						$NOW[$x] =~ s/[^\w\-]+/_/g;
						$NOW[$x] =~ s/\_+/\_/g;
						$NOW[$x] =~ s/(^\_+|\_+$)//g;
						$NOW[$x] =~ s/\-+\_+/\-/g;
						$NOW[$x] =~ s/\_+\-+/\-/g;
						$NOW[$x] =~ s/^(X|CF)\_//;
				}
		}
		
		#FIRST HANDLE MICROBIOMES
		#WHILE NCBI/IMG ANNOTATIONS ARE CRAPPY, KEEP ONLY UP TO CLASS-LEVEL
		if($NOW[0] =~ /MICROBIOME/){
			@tmp=(); for my $x (0..5){ if($NOW[$x] ne "UNCLASSIFIED" && $NOW[$x] ne ""){ push(@tmp, $NOW[$x]);}}
			@NOW = (); $NOW[0] = "MICROBIOME"; $NOW[1]=$tmp[1]; 
			if($tmp[2] =~ /\w/){ $NOW[2]=$tmp[2]."_MICROBIOME";} 
			else{$NOW[2]="UNCLASSIFIED_MICROBIOME";}
			$lin = join(";", @NOW); $TAXON{$oid}=$lin; $micr++; next; 
		}
			
		#SECOND HANDLE THE VECTORS
		if($NOW[1] =~ /PLASMID|ARTIFICIAL|INSERTION_SEQUENCES|TRANSPOSONS/ || grep {/PLASMID\b/} @NOW){
				   if(grep {/ARTIFICIAL|SYNTHETIC|VECTOR|COSMID/} @NOW){	@tmp = split(";", "MONA;CONSTRUCTS;",-1);}
				elsif(grep {/INSERTION.SEQUENCE|TRANSPOSON/} @NOW){			@tmp = split(";", "MONA;TRANSPOSONS;",-1);}
				else{														@tmp = split(";", "MONA;PLASMIDS;",-1);}
				#fix species/strain
				$tmp[6] = $NOW[7]; $tmp[7] = $NOW[7]; @NOW = @tmp; 
				if($NOW[7] =~ /\w/){ @STR = split("_", $NOW[7],-1); foreach my $p (@STR){ if($NOW[6] !~ /$p/){ $NOW[6].="_".$p; }} $NOW[7]=$NOW[6]; }
				else{ $NOW[7] = $NOW[6];}
				$NOW[6] =~ s/(.+\_.*(MINICHROMOSOME|TRANSPOSON|PLASMID|CONSTRUCT|PROMOTER|CASSETTE|MODULE|COSMID|MOLECULE|VECTOR|BACTERIUM|SEQUENCE)[A-Z]*)\_.*?$/$1/i;
				if($NOW[6] eq $NOW[7]){ pop(@NOW); }
				$lin = join(";", @NOW); $TAXON{$oid}=$lin; $mona++; next;
		}

		#THIRD HANDLE VIRUSES, PHAGES, & SATELLITES
		if($NOW[1]=~/VIRUSES/){
			   if(exists($ODD{$tid})){@NOW[0..2]=split(";", $ODD{$tid},-1);}
			elsif(grep {/(CAUDOVIRALES|ACKERMANNVIRIDAE|AUTOLYKIVIRIDAE|CORTICOVIRIDAE|CYSTOVIRIDAE|INOVIRIDAE)/		} @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGES",-1);}
		   	elsif(grep {/(LEVIVIRIDAE|MICROVIRIDAE|SPHAEROLIPOVIRIDAE|MYOVIRIDAE|PODOVIRIDAE|SIPHOVIRIDAE|TECTIVIRIDAE)/} @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGES",-1);}	   	
		   	elsif(grep {/(ALBETOVIRUS|AUMAIVIRUS|PAPANIVIRUS|VIRTOVIRUS|SARTHROVIRIDAE|MACRONOVIRUS)/				   } @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;SATELLITES",-1);}
		   	elsif(grep {/SATELLIT/ } @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;SATELLITES",-1);}
		   	elsif(grep {/\bPHAGE\b/} @NOW){ @NOW[0..2]=split(";", "MONA;VIRUSES;PHAGES",-1);}
		   	else{
		   		foreach my $lev (@NOW){ 
		   			if(exists($VIRTYPE{$lev})){ @NOW[0..2]=split(";", $VIRTYPE{$lev},-1); last;}
		   			else{ @NOW[0..2]=split(";", "MONA;VIRUSES;",-1); }
		}	}	}
		
		
		#CHECK THAT NOT BAD PRIOR FIX
		$lin = join(";", @NOW);
		$lin =~ s/\;+$//;
		for my $i (1..5){ 
			$j = 7-$i; #65432
			$xlev = $NOW[$j];
			$xlev =~ s/(ALPHA|BETA|GAMMA|DELTA|EPSILON)//;
			$ylev = $NOW[$j-1];
			$ylev =~ s/(ALPHA|BETA|GAMMA|DELTA|EPSILON)//;
			if($lin =~ /\bLEISHMANIA\b/){ print "LEISHMANIA i $i j $j xlev $xlev ylev $ylev\n"; }
			if( exists($ALL_LEVS{$NOW[$j]}) || exists($ALL_LEVS{$xlev})){  
				$top='';
				if(exists($ALL_LEVS{$NOW[$j]}{$NOW[$j-1]})){ $top = $ALL_LEVS{$NOW[$j]}{$NOW[$j-1]};}
				elsif(exists($ALL_LEVS{$NOW[$j]}{$ylev})){   $top = $ALL_LEVS{$NOW[$j]}{$ylev};}
				elsif(exists($ALL_LEVS{$xlev}{$NOW[$j-1]})){ $top = $ALL_LEVS{$xlev}{$NOW[$j-1]};}
				elsif(exists($ALL_LEVS{$xlev}{$ylev})){ 	 $top = $ALL_LEVS{$xlev}{$ylev};}
				else{}
				if($lin =~ /\bLEISHMANIA\b/){ print "exists top $top\n"; }
				if($lin !~ /$top/){ 
					@NEW = split(";", $top, -1); 
					if($lin =~ /\bLEISHMANIA\b/){ print "new @NEW now @NOW\n"; }
					for my $q (0..$#NEW){ $NOW[$q]=$NEW[$q]; }
					last; 
				}
			}
		}

		#STORE
		$lin = join(";", @NOW);
		$lin =~ s/\;+$//;
		$TAXON{$tid}=$lin;
		for my $i (0..5){ if($NOW[$i]=~/\w/){$MIDLEV{$NOW[$i]}{$tid}++; }}
		$OLDDB{$tid}=1;
		if($on%200000==0){ print "on $on OTDB tid $tid $lin\n"; }
		$on++;		
}


$time = localtime;
$time =~ /(\d\d\d\d)$/;
$year = $1;

$output = "TAXONOMY_DB_".$year."_raw.txt";
open(OUTPUT, ">", $output)||die;
foreach my $tid (keys %TAXON){
	$TAXON{$tid} =~ s/\;/\t/g;
	print OUTPUT "$tid\t$TAXON{$tid}\n";
}




$input = "TAXONOMY_DB_".$year."_raw.txt";
open(INPUT, $input)||die;
$on=0;
BIGLOOP: while(<INPUT>){
		if($_ !~/^\d/){next;}
		$_ = uc($_);
		$_ =~ s/[\r\n]+//;
		@NOW = split("\t", $_,-1);
		$tid = shift(@NOW);
		$lin = join(";", @NOW);
		$TAXON{$tid}=$lin;


		### REMOVE MIDLEVELS FROM SPECIES, SKIP THOSE WITHOUT MID-LEVELS, REMOVE REMAINING WITHOUT SPECIES
		if($NOW[0] =~ /MICROB/ || $NOW[1] =~ /CONSTRUCTS|TRANSPOSONS|PLASMIDS/){next;}
		if(exists($MIDLEV{$NOW[6]})){ delete($TAXON{$tid}); $midlev++; next;}
		if($NOW[6] !~ /\w/){ delete($TAXON{$tid}); next; }
		if($on%100000==0){ print "on $on START tid $tid @NOW\n"; }
		### NOW EVERYTHING SHOULD HAVE SPECIES LEVEL AT LEAST


		### FIX GENUS/SPECIES/STRAIN AMBIGUITY
		if(grep{ /\_(GEN|SENSU_LATO)\_/} @NOW){$NOW[5] =~ s/\_(GEN|SENSU_LATO)\_//g; $NOW[6]=~ s/\_(GEN|SENSU_LATO)\_//g; $NOW[7]=~ s/\_(GEN|SENSU_LATO)\_//g;} #fix stupid Eukaryote genus issue
		if($NOW[6] !~ /\w+/ && $NOW[7] =~ /\w+/){	$NOW[6] = $NOW[7];} #no species but strain
		if($NOW[7] !~ /\w+/ && $NOW[6] =~ /\w/){ 	$NOW[7] = $NOW[6];} #no strain but species
		if($NOW[7] =~ /\Q$NOW[6]\E/){				$NOW[6] = $NOW[7];} #strain contains specis		
		if($NOW[5] =~ /\w/ && $NOW[7] =~ /$NOW[5]/ && $NOW[6] !~ /$NOW[5]/){ $tmp = $NOW[6]; $NOW[6] = $NOW[7]; $NOW[7] = $tmp; } #strain has genus, species doesn't = swap
		if($NOW[6] =~ /\[.*?\]/ && $NOW[5] =~ /\w/){ $NOW[6] =~ s/\[.*?\]/$NOW[5]/; $fixedG++; } #species ambig genus
		if($NOW[7] =~ /\[.*?\]/ && $NOW[5] =~ /\w/){ $NOW[7] =~ s/\[.*?\]/$NOW[5]/; } #strain ambig genus
		### NOW ALL HAVE SPECIES AND STRAIN (MAY BE IDENTICAL AT THE MOMENT)


		### FIX MID-LEVEL INCONSISTENCIES AND INSESTUOUS
		if($NOW[1] =~ /EAE$/){	 $NOW[1] =~ s/EAE$/IA/; 		$EAE2IA++; }
		if($NOW[2] =~ /EAE$/){	 $NOW[2] =~ s/EAE$/IIA/; 		$EAE2IIA++; }
		if($NOW[3] =~ /ACEAE$/){ $NOW[3] =~ s/ACEAE$/ALES/;		$ACEA2ALES++; }
		for my $i (0..5){
			for my $j (0..5){
				if($i==$j){next;}
				if($NOW[$i] eq ''){next;}
				if($NOW[$i] eq $NOW[$j]){
					   if($j == 2 ){$NOW[2] =~ s/[AEIOU]+[^AEIOU]*$/IIA/;	$incestC++; }
					elsif($j == 3 ){$NOW[3] =~ s/[AEIOU]+[^AEIOU]*$/ALES/;	$incestO++; }
					elsif($j == 4 ){$NOW[4] =~ s/[AEIOU]+[^AEIOU]*$/ACEA/;	$incestF++; }
					else{ 	$old = $NOW[5];
							$NOW[5] =~ s/[AEIOU]+[^AEIOU]*$/IUM/;	$incestG++; 
							$NOW[6] =~ s/$old/$NOW[5]/g;
							$NOW[7] =~ s/$old/$NOW[5]/g;
		}	}	}	}
		### NOW MID-LEVEL NAMES CONFORM TO TAXONOMY STANDARDS


		### REMOVE REDUNDANCY IN SPECIES NAME
		@NAME=split("_", $NOW[6],-1);
		@tmp = ();
		while($NAME[0] =~ /\w/){$x = shift(@NAME); if(!grep{/$x/}@tmp){push(@tmp, $x);}}
		$NOW[6] = join("_", @tmp);
		### NOW NO REDUNDANT LABELS WITHIN SPECIES NAME


		### FIX SPECIES AND STRAIN NAMES AND ADD MISSING LOWER LEVEL
		if($NOW[0] eq "MONA" && $NOW[1] eq "VIRUSES"){
				$lin=join(";", @NOW[2..5]);
				$lin=~/([^\;]+)\;*$/; 
				$last = $1;
				if($NOW[2] eq "SATELLITES"){ #DO SATELLITES SEPARATELY BECAUSE NAMES OFTEN HAVE ASSOCIATED VIRUS NAME TOO
						$last=~s/SATELLITES/SATELLITE/;

						#FIX BETASATELLITES
						if($NOW[6] =~ /SATELLITE/){ $NOW[6] =~ s/\_BETA\b|BETA$//; $NOW[7] =~ s/\_BETA\b|BETA$//;}
						else{ $NOW[6] =~ s/BETA\b|BETA$/BETASATELLITE/; $NOW[7] =~ s/BETA\b|BETA$/BETASATELLITE/;}

						#FIX GENUS OR ADD LOWER
						   if( $NOW[6] =~ /$NOW[5]|$last/ || $last !~ /\w/){ $NOW[6]=$NOW[6];} #all is fine or unfixable
						elsif( $NOW[5] =~ /([A-Z]*SATELLITE)/ && $NOW[6] =~ /([A-Z]*SATELLITE)/ && $NOW[6] !~ /$NOW[5]/ ){ #fix satellite name
						   			$NOW[6] =~ s/([A-Z]*SATELLITE)/$last/; 		
						   			$NOW[7] =~ s/([A-Z]*SATELLITE)/$last/; }
						elsif( $NOW[5] =~ /SATELLITE/ && $NOW[6] =~ /(DNA|SEQUENCE|GENOME|PARTICLE|VIRUS)/ ){ #input satellite name
									$NOW[6] =~ s/([A-Z]*(DNA|SEQUENCE|GENOME|PARTICLE|VIRUS)[A-Z]*)/$last/; 		
									$NOW[7] =~ s/([A-Z]*(DNA|SEQUENCE|GENOME|PARTICLE|VIRUS)[A-Z]*)/$last/; }
						elsif( $last =~ /\w/ && $NOW[6] !~ /$last/ ){ #insert lower level
									$NOW[6] =~ s/([A-Z]*(SATELLITE|DNA|SEQUENCE|GENOME|PARTICLE|VIRUS)[A-Z]*)/$last\_$1/; 	
									$NOW[7] =~ s/([A-Z]*(SATELLITE|DNA|SEQUENCE|GENOME|PARTICLE|VIRUS)[A-Z]*)/$last\_$1/;}
						else{$NOW[6]=$NOW[6];}

						#CLEAN UP NAMES
						if($NOW[7] !~ /\w/ && $NOW[6] =~ /.+\_[A-Z]*(SATELLITE|DNA|SEQUENCE|GENOME|PARTICLE|VIRUS)[A-Z]*\_.+?$/){ $NOW[7] = $NOW[6]; }
						elsif($NOW[7] =~ /\w/){ @STR = split("_", $NOW[7],-1); foreach my $p (@STR){ if($NOW[6] !~ /$p/){ $NOW[6].="_".$p; }} $NOW[7]=$NOW[6]; }
						else{ $NOW[7] = $NOW[6];}
						$NOW[6] =~ s/(.+\_.*(SATELLITE|DNA|SEQUENCE|GENOME|PARTICLE|VIRUS)[A-Z]*)\_.+?$/$1/;						
				}
				else{ 	#VIRUSES OR PHAGES
						$last=~s/(VIRUS|PHAGE)S/$1/;
						   if($NOW[6] =~ /$NOW[5]/ && $NOW[5]=~/\w/){ $NOW[6]=$NOW[6];} #all is fine or unfixable
						elsif($NOW[5] =~ /^[A-Z]+(VIRUS|PHAGE)$/ && $NOW[6] =~ /[A-Z]*(VIRUS|PHAGE)/){ #replace with genus in species
						   			$NOW[6] =~ s/[A-Z]*(VIRUS|PHAGE)[A-Z]*/$NOW[5]/; 
						   			$NOW[7] =~ s/[A-Z]*(VIRUS|PHAGE)[A-Z]*/$NOW[5]/;}
						elsif($NOW[5] =~ /^[A-Z]+(VIRUS|PHAGE)$/ && $NOW[7] =~ /[A-Z]*(VIRUS|PHAGE)/){ #replace with genus in strain, swap with species
									$NOW[7] =~ s/[A-Z]*(VIRUS|PHAGE)[A-Z]*/$NOW[5]/; 
									$tmp = $NOW[6]; $NOW[6] = $NOW[7]; $NOW[7] = $tmp;}
						elsif($NOW[6] =~ /(VIRUS|PHAGE|GENOME|PARTICLE|VIROID|MOLECULE|VECTOR|SEQUENCE)/ && $last =~/\w/ && $NOW[6] !~ /$last/){ #prepend with last in species
									$NOW[6] =~ s/([A-Z]*(VIRUS|PHAGE|GENOME|PARTICLE|VIROID|MOLECULE|VECTOR|SEQUENCE)[A-Z]*)/$last\_$1/; 
									$NOW[7] =~ s/([A-Z]*(VIRUS|PHAGE|GENOME|PARTICLE|VIROID|MOLECULE|VECTOR|SEQUENCE)[A-Z]*)/$last\_$1/;}
						elsif($NOW[7] =~ /(VIRUS|PHAGE|GENOME|PARTICLE|VIROID|MOLECULE|VECTOR|SEQUENCE)/ && $last =~/\w/ && $NOW[6] !~ /$last/){ #prepend with last in strain, swap with species
									$NOW[6] =~ s/([A-Z]*(VIRUS|PHAGE|GENOME|PARTICLE|VIROID|MOLECULE|VECTOR|SEQUENCE)[A-Z]*)/$last\_$1/; 
									$NOW[7] =~ s/([A-Z]*(VIRUS|PHAGE|GENOME|PARTICLE|VIROID|MOLECULE|VECTOR|SEQUENCE)[A-Z]*)/$last\_$1/;
									$tmp = $NOW[6]; $NOW[6] = $NOW[7]; $NOW[7] = $tmp;}
						else{$NOW[6]=$NOW[6];}

						#CLEAN UP NAMES
						if($NOW[7] !~ /\w/ && $NOW[6] =~ /.+\_.*(VIRUS|PHAGE|GENOME|PARTICLE|VIROID|MOLECULE|VECTOR|SEQUENCE|SATELLITE)[A-Z]*\_.+?$/){ $NOW[7] = $NOW[6]; }
						elsif($NOW[7] =~ /\w/){ @STR = split("_", $NOW[7],-1); foreach my $p (@STR){ if($NOW[6] !~ /$p/){ $NOW[6].="_".$p; }} $NOW[7]=$NOW[6]; }
						else{ $NOW[7] = $NOW[6];}
						$NOW[6] =~ s/(.+\_.*(VIRUS|PHAGE|GENOME|PARTICLE|VIROID|MOLECULE|VECTOR|SEQUENCE|SATELLITE)[A-Z]*)\_.+?$/$1/;
				}
		}
		else{ 	#IS BACTERIA|EUKARYOTA|ARCHAEA
				#ADD GENUS OR LOWER
				$lin=join(";", @NOW[1..5]);
				$lin=~/([^\;]+)\;*$/; 
				$last = $1;
				if($NOW[5] =~ /\w/ && $NOW[6] !~ /^$NOW[5]/){ 
					if($NOW[6] =~ /BACTERIUM|BIONT|ARCHAEON|ENDOPHYTE|CLONE/){
						$NOW[6] =~ s/^(.*?)\_*([A-Z]*(BACTERIUM|BIONT|ARCHAEON|ENDOPHYTE|CLONE))/$NOW[5]\_$2\_$1/;}	
					elsif($NOW[6] =~ /FUNGUS|CONTAMINANT|PATHOGEN|YEAST|BACTERIA|ASSOCIATE|ISOLATE|FLAGELLATE/){
						$NOW[6] =~ s/^(.*?)\_*([A-Z]*(FUNGUS|CONTAMINANT|PATHOGEN|YEAST|BACTERIA|ASSOCIATE|ISOLATE|FLAGELLATE))/$NOW[5]\_$2\_$1/;}	
					elsif($NOW[6] =~ /^([A-Z]+)\_[A-Z]+/){ $NOW[6] =~ s/^([A-Z]+)/$NOW[5]/; }
					else{ $NOW[6] = $NOW[5]."_".$NOW[6]; }
				}
				elsif($last =~ /\w/ && $NOW[6] !~ /^$last/ ){ 
					if($NOW[6] =~ /BACTERIUM|BIONT|ARCHAEON|ENDOPHYTE|CLONE/){
						$NOW[6] =~ s/^(.*?)\_*([A-Z]*(BACTERIUM|BIONT|ARCHAEON|ENDOPHYTE|CLONE))/$last\_$2\_$1/;}	
					elsif($NOW[6] =~ /FUNGUS|CONTAMINANT|PATHOGEN|YEAST|BACTERIA|ASSOCIATE|ISOLATE|FLAGELLATE/){
						$NOW[6] =~ s/^(.*?)\_*([A-Z]*(FUNGUS|CONTAMINANT|PATHOGEN|YEAST|BACTERIA|ASSOCIATE|ISOLATE|FLAGELLATE))/$last\_$2\_$1/;}
					else{ $NOW[6] = $last."_".$NOW[6]; }
				}
				else{}

				#REMOVE REDUNDANCY IN SPECIES NAME
				@NAME=split("_", $NOW[6],-1);
				@tmp = ();
				while($NAME[0] =~ /\w/){
					$x = shift(@NAME);
					if(!grep{/$x/}@tmp){push(@tmp, $x);}}
				$NOW[6] = join("_", @tmp);
				#NOW NO REDUNDANT LABELS WITHIN SPECIES NAME

				#CLEAN UP STRAIN/SPECIES
				if($NOW[7] !~ /\w/ && $NOW[6] =~ /([A-Z]+\_[A-Z]+)\_.+/){ $NOW[7] = $NOW[6]; }
				elsif($NOW[7] =~ /\w/){ @STR = split("_", $NOW[7],-1); foreach my $p (@STR){ if($NOW[6] !~ /$p/){ $NOW[6].="_".$p; }} $NOW[7]=$NOW[6]; }
				else{ $NOW[7] = $NOW[6];}
				$NOW[6] =~ s/^([A-Z]+\_[A-Z]+)\_.+/$1/;
		}
		### NOW HAVE ADDED GENERA OR LOWER TO SPECIES AND FIXED SPECIES/STRAIN NAMES


		### ADDITIONAL NAME CLEANING AND REMOVAL OF EMPTY OR REDUNDANT NAMING
		if($NOW[6] eq $NOW[7]){ pop(@NOW); }
		if($NOW[6] eq $NOW[5]){ pop(@NOW); }
		if($NOW[6] !~ /\w/){ delete($TAXON{$tid}); $nospe++; next; }
		$pre=''; $NOW[6] =~ /BACTERIA\_([A-Z]*)BACTERIUM/; $pre= $1; 
		if($pre =~ /\w/){ 
			$find = $pre."BACTERIA_".$pre; $replace = $pre."BACTERIA_";
			$NOW[6] =~ s/$find/$replace/; $NOW[7] =~ s/$find/$replace/; 
		}
		for my $y (0..5){ $MIDLEV{$NOW[$y]}{$tid}++; if(exists($MIDLEV{$NOW[6]})){ delete($TAXON{$tid}); next BIGLOOP;}}
		### NOW ALL THE SPECIES LEVELS SHOULD HAVE GENUS/LOWER AND HAVE STRAINS IF ANY


		### GET STATS AND STORE LINEAGES
		   if($NOW[0] =~ /BACTERIA/ ){ $bact++;}
		elsif($NOW[0] =~ /ARCHAEA/  ){ $arch++;}
		elsif($NOW[0] =~ /EUKARYOTA/){ $euka++;}
		elsif($NOW[0] =~ /MONA/	 ){ $mona++;}
		elsif($NOW[0] =~ /MICRO/	){ $micr++;}
		else{ next;}
		$lin = join(";", @NOW); 
		$TAXON{$tid}=$lin;

		if($on%100000==0){ print "on $on END tid $tid @NOW\n"; }
		$on++;
}
$kc = keys %TAXON;


#POPULATE %SYN TO REMOVE JUNK
foreach my $tid (keys %TAXON){
	@NOW=split(";", $TAXON{$tid}, -1);
	if(exists($MIDLEV{$NOW[6]})){ delete($TAXON{$tid}); next;}
	for my $y (0..6){
		$x = $y+1;
		$lev = $NOW[$x];
		$top = join(";", @NOW[0..$y]);
		if($NOW[$x]=~/\w/ && $x > 0 && $x < 7){ $SYNS{$lev}{$top}{$tid}=1;}
	}	
}




#CHECK FOR MIX-LEVEL SYNONYMS, FIXABLE IF ORDER OR FAMILY-LEVEL
#CHECK IF SAME-LEVEL SYNONYMS PRESENT, FILL IN GAPS
$on=0;
CLEANLOOP: foreach my $lev (sort(keys %SYNS)){
	$kc = keys %{$SYNS{$lev}};
	$on++;
	if($kc > 1){
		#COMPARE ALL SYNONYMS IN EACH LEVEL
		foreach my $top (sort(keys %{$SYNS{$lev}})){
			foreach my $old (sort(keys %{$SYNS{$lev}})){
				if($top eq $old){next;}

				#COMPARE NEW AND OLD LEVEL BY LEVEL 
				@NOW = split(";", $top, -1); $nc = @NOW;
				@OLD = split(";", $old, -1); $oc = @OLD;
				if($nc < $oc || $nc > $oc){ #IF DIFFERENT MIXED LEVEL SYNONYMS
					$newlev = $lev;
					   if( $nc == 3 && $newlev !~ /ALES$/ ){ $newlev=~ s/[AEIOU]+[^AEIOU]*$/ALES/; $do = $top;}
					elsif( $nc == 4 && $newlev !~ /ACEA$/ ){ $newlev=~ s/[AEIOU]+[^AEIOU]*$/ACEA/; $do = $top;}
					elsif( $nc == 5 && $newlev !~ /IUM$/  ){ $newlev=~ s/[AEIOU]+[^AEIOU]*$/IUM/;  $do = $top;}
					elsif( $oc == 3 && $newlev !~ /ALES$/ ){ $newlev=~ s/[AEIOU]+[^AEIOU]*$/ALES/; $do = $old;}
					elsif( $oc == 4 && $newlev !~ /ACEA$/ ){ $newlev=~ s/[AEIOU]+[^AEIOU]*$/ACEA/; $do = $old;}
					elsif( $oc == 5 && $newlev !~ /IUM$/  ){ $newlev=~ s/[AEIOU]+[^AEIOU]*$/IUM/;  $do = $old;}
					else{}
					if($newlev ne $lev){
						foreach my $tid (keys %{$SYNS{$lev}{$do}}){ 
							if($TAXON{$tid} =~ /\b$lev/){$TAXON{$tid} =~ s/\b$lev/$newlev/g;}
							$SYNS{$newlev}{$do}{$tid}=1;
						} 
						delete($SYNS{$lev}{$do});
						redo CLEANLOOP;
					}
				}
				else{ 	#SAME LEVEL SYNONYM	- CHECK IF TOP DISCREPANCY							
					@TMP=();
					$good= 0; $empt= 0; $bad = 0; $mid = 0; $fill = 0;
					for my $i (0..$#OLD){

							#REMOVE POTENTIALLY PREVIOUSLY ADDED
							$test1 = $NOW[$i]; if($i > 2 ){$test1 =~ s/(ALPHA|BETA|GAMMA|DELTA|EPSILON|ZETA|THETA|IOTA|KAPPA|LAMBDA)//g;}
							$test2 = $OLD[$i]; if($i > 2 ){$test2 =~ s/(ALPHA|BETA|GAMMA|DELTA|EPSILON|ZETA|THETA|IOTA|KAPPA|LAMBDA)//g;}

							#GET COUNTS OF EACH LEVEL:GOOD EMPTY OR BAD
							if($test1 eq $test2 && $test1 =~ /\w/){ $good++; push(@TMP, $test1); if($i > 1 && $i < 6){ $mid++; }}
							elsif($OLD[$i-1] eq $NOW[$i-1] && $OLD[$i+1] eq $NOW[$i+1] && $NOW[$i-1] =~ /\w/ && $NOW[$i+1] =~ /\w/){
								if($LEVCNT{$NOW[$i]} > $LEVCNT{$OLD[$i]} && $NOW[$i] =~ /\w/){ push(@TMP, $test1); }
								else{ push(@TMP, $test2); }
								$fill++; $good++; 									
							}
							elsif($test1 eq '' && $test2 ne ''){$empt++; push(@TMP, $test2);}
							elsif($test2 eq '' && $test1 ne ''){$empt++; push(@TMP, $test1);}
							else{ $bad++; 
								if(!exists($OLDDB{$tid})){ push(@TMP, $NOW[$i]); }
								elsif($oc>$nc || $OLD[$i] !~ /UNCLASSIFIED/){push(@TMP, $OLD[$i]); }
								else{push(@TMP, $NOW[$i]);}
							}
					}


					#IF GOOD, JUST SMALL DISCREPANCY, REPLACE
					if($good >= 3 && $bad == 1 && $empt > 0){$newtop='';}
					elsif($good >= 3 && $bad < 2 && $mid >= 1){ $newtop = join(";", @TMP); }
					elsif($good > 1 && $bad == 0 ){ $newtop = join(";", @TMP); }
					elsif($#OLD == 1 && $good > 0 && $bad == 0){ print "lev $lev top $top old $old tmp @TMP\n"; $newtop = join(";", @TMP); }
					else{$newtop='';}

					if($lev eq "CRYPTOPHYCIIA"){print "CRYPTOPHYCIIA kc $kc good $good bad $bad empt $empt last $#OLD tmp @TMP\n";}

					#FIX OLD LEVELS AND RESTART LOOP
					if($newtop ne $top && $newtop =~ /\w/){ 
						foreach my $tid (keys %{$SYNS{$lev}{$top}}){ 
							@XOLD = split(";", $TAXON{$tid},-1);
							$b4 = $TAXON{$tid};
							for my $i (0..$#TMP){ $XOLD[$i]=$TMP[$i]; }
							$TAXON{$tid}=join(";", @XOLD); 
							$SYNS{$lev}{$newtop}{$tid}=1;
							if($lev eq "CRYPTOPHYCIIA"){print "tid $tid top $TAXON{$tid}\n";}
						}
						delete($SYNS{$lev}{$top});
					}
					if($newtop ne $old && $newtop =~ /\w/){ 
						foreach my $tid (keys %{$SYNS{$lev}{$old}}){ 
							@XOLD = split(";", $TAXON{$tid},-1);
							$b4 = $TAXON{$tid};
							for my $i (0..$#TMP){ $XOLD[$i]=$TMP[$i]; }
							$TAXON{$tid}=join(";", @XOLD); 
							$SYNS{$lev}{$newtop}{$tid}=1;
							if($lev eq "CRYPTOPHYCIIA"){print "tid $tid top $TAXON{$tid}\n";}
						}
						delete($SYNS{$lev}{$old});
					}
					#redo CLEANLOOP; #START AGAIN FROM SPECIES AND MAKE SURE IT IS FIXED
				}
			}
		}
	}
}
undef(%SYNS);
#FINISHED LEVEL CLEANING LOOP, NOW BLANKS OF SAME ORGANISMS SHOULD BE FILLED, FIXING NAMING DIFFERENCES




#REPOPULATE %SYN TO REMOVE PERSISTENT JUNK
foreach my $tid (keys %TAXON){
	@NOW=split(";", $TAXON{$tid}, -1);
	for my $y (0..6){
		$MIDLEV{$NOW[$y]}{$tid}++;
		$x = $y+1;
		$lev = $NOW[$x];
		$top = join(";", @NOW[0..$y]);
		if($NOW[$x] =~ /\w/ && $x > 0 && $x < 7){ $SYNS{$lev}{$top}{$tid}=1; }
		if($lev eq "SAGITTARIIDAE"){ $kc = keys %{$SYNS{$lev}}; print "SAGITTARIIDAE kc $kc x $x top $top syns $SYNS{$lev}{$top}{$tid}\n"; }
	}
}



#REMAINING SYNONYMS SHOULD ONLY BE REAL DIFFERENCES
@GREEK = ("", "ALPHA", "BETA", "GAMMA", "DELTA", "EPSILON", "ZETA", "THETA", "IOTA", "KAPPA", "LAMBDA"); 
FINLOOP: foreach my $lev (sort(keys %SYNS)){
	$kc = keys %{$SYNS{$lev}};  if($lev eq "SAGITTARIIDAE"){ print "SAGITTARIIDAE kc $kc\n";}
	$on++;

	#CHECK IF MIXED LEVEL SYNONYM AND CORRECT TO STANDARD
	if($kc > 1){ 
			my %NAMES;
			$count = 0;

			#GET COUNTS FOR EACH SYNONYM
			foreach my $top (keys %{$SYNS{$lev}}){ $NAMES{$top} = keys %{$SYNS{$lev}{$top}}; } 	

			#GO THROUGH EACH DIFFERENT TOP LEVEL
			#REPLACE LEVEL AND DOWNSTREAM IF GENUS
			#UPDATE %SYNS AND %TAXON
			foreach my $top (sort {$NAMES{$b} <=> $NAMES{$a}} keys %NAMES){ 
			
					#GET NEW REPLACEMENT LEVEL, MAKING SURE IT DOESNT ALREADY EXIST 
					$greek = $GREEK[$count]; 
					$newlev = $greek.$lev;
					if(exists($CHANGED{$newlev}) && $greek =~ /\w/){
						while(exists($CHANGED{$newlev})){ 
							$count++; 
							$greek = $GREEK[$count]; 
							$newlev = $greek.$lev; 
							if($count>9){last;} 
						}
					}
					elsif($lev =~ /$greek/ && $greek =~ /\w/){$count++; $greek = $GREEK[$count]; $newlev = $greek.$lev;}
					else{$newlev = $greek.$lev;}
					$count++;
					
					if($greek !~ /\w/){next;}
					
					if($lev =~ /SAGITTARIIDAE/ ){print "lev $lev kc $kc greek $greek new $newlev count $count top $top\n";}
					
					#LOOP THROUGH EACH SPECIES, LOOP THROUGH EACH LEVEL, CREATE NEW SYNS ENTRY AND FIX %TAXON, DELETE OLD FROM SYNS
					foreach my $tid (keys %{$SYNS{$lev}{$top}}){  
						@TAX = split(";", $TAXON{$tid}, -1);
						@OLD = @TAX;
						for my $t (0..$#TAX){
							#DO 1 LEVEL AT A TIME, STORE CHANGE IN %CHANGED
							$xtop = join(";", @OLD[0..$t-1]);
							if( $TAX[$t] =~ /\b$lev/ ){ 
									$TAX[$t] =~ s/\b$lev/$newlev/; 
									$CHANGED{$TAX[$t]}=1;
									#if($tid =~ /\b(707182|48131|397529|330206|1823611|1567050|2565498|1160523|668958)\b/){print "lev $lev tid $tid t $t taxt $TAX[$t] delete oldt $OLD[$t] xtop $xtop\n";}
									if($lev eq "SAGITTARIIDAE"){print "lev $lev tid $tid t $t taxt $TAX[$t] delete oldt $OLD[$t] xtop $xtop\n";}									
							}
							$ntop = join(";", @TAX[0..$t-1]);
							if($lev eq "SAGITTARIIDAE"){ print "lev $lev t $t taxt $TAX[$t] ntop $ntop\n"; }
							$SYNS{$TAX[$t]}{$ntop}{$tid}=1;
							if($OLD[$t] eq "SAGITTARIIDAE"){ print "lev $lev t $t delete xtop $xtop tax $TAXON{$tid}\n"; }
							delete($SYNS{$OLD[$t]}{$xtop});
						}
						$TAXON{$tid}=join(";",@TAX);
					}
			}
			#redo FINLOOP;
	}
}


#FILL IN THE BLANKS 
print "OUTPUT FIXED NAMES\n";
@PL=("KINGDOM", "PHYLUM", "CLASS", "ORDER", "FAMILY", "GENUS", "SPECIES");
$output = "TAXONOMY_DB_".$year.".txt";
open(OUTPUT, ">", $output)||die;
foreach my $tid (keys %TAXON){
		$TAXON{$tid} =~ s/[\;\s]+$//g;
		@tmp = split(";", $TAXON{$tid},-1);
		for my $x (1..5){
			if($tmp[$x] !~ /\w/ && $tmp[0] !~ /MICROB/){ 
				$y = $x;
				while($y >= 0){ $y--;
					if($tmp[$y] =~ /\w/ && $tmp[$y] !~ /UNCLASSIFIED/){ $tmp[$x] = "UNCLASSIFIED_".$tmp[$y]."_".$PL[$x]; last;}
				}
			}
		}

		#make cytoscape tree
		$tmp[0] =~ /^(.)/; $king = $1;
		for($i=0; $i<=$#tmp; $i++){
				$type = $king."_".$i;
				if($i == 0){ $phyla = "$type\tROOT\t$tmp[$i]"; $CYTO{$phyla}++;}
				else{ $phyla = "$type\t$tmp[$i-1]\t$tmp[$i]"; $CYTO{$phyla}++;}
		}

		#output
		@OUT=();
		for my $x (0..7){push(@OUT, $tmp[$x]);}
		$out = join("\t", @OUT);
		print OUTPUT "$tid\t$out\n";
}

$outcyto = "TAXONOMY_DB_".$year.".cyto";
open(OUTCYTO, ">", $outcyto)||die;
foreach my $phyla (sort(keys %CYTO)){ print OUTCYTO "$phyla\t$CYTO{$phyla}\n"; }
