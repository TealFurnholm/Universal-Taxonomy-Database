### THIS ROUND INVOLVES FIXING MID-LEVEL INCONSISTENCIES OR GAPS ###
# 1. FIRST MAKE SURE LEVELS CONFORM TO TAXONOMIC STANDARDS, FIX INCESTUOUS NAMES
# 2. RENAME PREFIX FOR ANY MIXED RANK SYNONYMS THAT CANT BE FIXED WITH SUFFIX CORRECTION
# 3. MAKE SURE MID RANKS CONFORM - NO RESIDUE OF RETIRED LEVEL NAMES ###
# 4. ONCE BEST LEVELS ARE ACHIEVED, RENAME REMAINING SYNONYMS

@PREFIX = ("ALPHA", "BETA", "DELTA", "EPSILON", "GAMMA", "IOTA", "KAPPA", "LAMBDA", "OMEGA", "SIGMA", "THETA", "ZETA","HITOTSU","FUTATSU", "MITTSU","YOTTSU","ITSUTSU","MUTTSU","NANATSU","YATTSU"); 
#ALPHA|BETA|DELTA|GAMMA|IOTA|KAPPA|LAMBDA|OMEGA|SIGMA|THETA|ZETA
#then Japanese numbers - since so many greek

### 1. MAKE MID LEVELS CONFORM TO NAMING SUFFIX STANDARDS BY RANK ###
#use warnings;
$time = localtime;
$time =~ /(\d\d\d\d)$/;
$year = $1;

$input = "TAXONOMY_DB_".$year."_raw2.txt";
open(INPUT, $input)||die;
print "INPUT RAW $input\n";
$on=0;
while(<INPUT>){
		if($_ !~/^\d/){next;}
		$_ = uc($_);
		$_ =~ s/[\r\n]+//;
		@NOW = split("\t", $_,-1);
		$tid = shift(@NOW);
		@OLD=@NOW;

		#SKIP NON-LINEAGED ENTRIES
		if($NOW[0] eq "QUIDDAM"){
			if($NOW[1]!~/UNKNOWN/ && $NOW[1]=~/\w/){ $NOW[1]="UNKNOWN_".$NOW[1];} 
			$LINEAGES{$tid}= [@NOW]; 
			for my $i (0..$#NOW){ $MIDS{$i}{$NOW[$i]}{$tid}=1;} 
			next;
		}
		if($NOW[0] eq "MICROBIOME"){     
			if($NOW[2]!~/MICROBIOME/ && $NOW[2]=~/\w/){$NOW[2].="_MICROBIOME";} 
			$LINEAGES{$tid}= [@NOW]; 
			for my $i (0..$#NOW){ $MIDS{$i}{$NOW[$i]}{$tid}=1;} 
			next;
		}
		
		### FIX MID-LEVEL NON-CONFORMATION
		$ch1=0; $ch2=0; $ch3=0; $ch4=0; $ch5=0;
		if($NOW[1] =~ /(ACEAE|IDAE|EAE|ALES|IIA|IUM)$/){$tmp=$NOW[1]; $NOW[1] =~ s/(ACEAE|IDAE|EAE|ALES|IIA|IUM)$/IA/;	$NOW[6]=~s/$tmp/$NOW[1]/; $NOW[7]=~s/$tmp/$NOW[1]/; $FIXP++; $ch1++;}
		if($NOW[2] =~ /(ACEAE|IDAE|ALES|EAE|IUM)$/){	$tmp=$NOW[2]; $NOW[2] =~ s/(ACEAE|IDAE|ALES|EAE|IUM)$/IIA/; 	$NOW[6]=~s/$tmp/$NOW[2]/; $NOW[7]=~s/$tmp/$NOW[2]/; $FIXC++; $ch2++;}
		if($NOW[3] =~ /(ACEAE|IDAE|IIA|EAE|IUM)$/){		$tmp=$NOW[3]; $NOW[3] =~ s/(ACEAE|IDAE|IIA|EAE|IUM)$/ALES/;		$NOW[6]=~s/$tmp/$NOW[3]/; $NOW[7]=~s/$tmp/$NOW[3]/; $FIXO++; $ch3++;}
		if($NOW[4] =~ /(ALES|IIA|IUM)$/){				$tmp=$NOW[4]; $NOW[4] =~ s/(ALES|IIA|IUM)$/ACEA/; 				$NOW[6]=~s/$tmp/$NOW[4]/; $NOW[7]=~s/$tmp/$NOW[4]/; $FIXF++; $ch4++;}
		if($NOW[5] =~ /\w\w(ACEAE|IDAE|ALES|EAE|IIA)$/){$tmp=$NOW[5]; $NOW[5] =~ s/I*(ACEAE|IDAE|ALES|EAE|IIA)$/IUM/; 	$NOW[6]=~s/$tmp/$NOW[5]/; $NOW[7]=~s/$tmp/$NOW[5]/; $FIXG++; $ch5++;}

		for my $i (0..5){ $MIDS{$i}{$NOW[$i]}{$tid}=1;}
		$LINEAGES{$tid}= [@NOW];

		#FIX REMAINING INCESTUOUS
		for my $i (1..4){ #loop phylum to family
			if($NOW[$i] eq ''){next;}
			for my $j ($i+1..5){ #loop class to genus
				if($NOW[$i] eq $NOW[$j]){
					#replace with level-specific suffix in %LINEAGES, delete-replace mid tracker %MIDS
				   	if($j == 2 && $NOW[$j] !~ /IIA$/){ 	$tmp=$NOW[$j]; foreach my $tid (keys %{$MIDS{$j}{$tmp}}){ 
					   		$LINEAGES{$tid}[$j]=~ s/[AEIOU]+[^AEIOU]*$/IIA/;
					   		if($LINEAGES{$tid}[6] =~/$tmp/){ $LINEAGES{$tid}[6]=~ s/$tmp/$LINEAGES{$tid}[$j]/;}
					   		if($LINEAGES{$tid}[7] =~/$tmp/){ $LINEAGES{$tid}[7]=~ s/$tmp/$LINEAGES{$tid}[$j]/;}
					   		delete($MIDS{$j}{$tmp}{$tid});
					   		$MIDS{$j}{$LINEAGES{$tid}[$j]}{$tid}=1;
					   		$incestC++; $jns=1;}} 
					if($j == 3 && $NOW[$j] !~ /ALES$/){	$tmp=$NOW[$j]; foreach my $tid (keys %{$MIDS{$j}{$tmp}}){  
					   		$LINEAGES{$tid}[$j]=~ s/[AEIOU]+[^AEIOU]*$/ALES/;
					   		if($LINEAGES{$tid}[6] =~/$tmp/){ $LINEAGES{$tid}[6]=~ s/$tmp/$LINEAGES{$tid}[$j]/;}
					   		if($LINEAGES{$tid}[7] =~/$tmp/){ $LINEAGES{$tid}[7]=~ s/$tmp/$LINEAGES{$tid}[$j]/;}
					   		delete($MIDS{$j}{$tmp}{$tid});
					   		$MIDS{$j}{$LINEAGES{$tid}[$j]}{$tid}=1;
					   		$incestO++; $jns=1;}}
					if($j == 4 && $NOW[$j] !~ /ACEA$/){	$tmp=$NOW[$j]; foreach my $tid (keys %{$MIDS{$j}{$tmp}}){  
					   		$LINEAGES{$tid}[$j]=~ s/[AEIOU]+[^AEIOU]*$/ACEA/;
					   		if($LINEAGES{$tid}[6] =~/$tmp/){ $LINEAGES{$tid}[6]=~ s/$tmp/$LINEAGES{$tid}[$j]/;}
					   		if($LINEAGES{$tid}[7] =~/$tmp/){ $LINEAGES{$tid}[7]=~ s/$tmp/$LINEAGES{$tid}[$j]/;}
					   		delete($MIDS{$j}{$tmp}{$tid});
					   		$MIDS{$j}{$LINEAGES{$tid}[$j]}{$tid}=1;
					   		$incestF++; $jns=1;}}
					if($j == 5 && $NOW[$j] !~ /IUM$/){	$tmp=$NOW[$j]; foreach my $tid (keys %{$MIDS{$j}{$tmp}}){  
					   		$LINEAGES{$tid}[$j]=~ s/[AEIOU]+[^AEIOU]*$/IUM/;
					   		if($LINEAGES{$tid}[6] =~/$tmp/){ $LINEAGES{$tid}[6]=~ s/$tmp/$LINEAGES{$tid}[$j]/;}
					   		if($LINEAGES{$tid}[7] =~/$tmp/){ $LINEAGES{$tid}[7]=~ s/$tmp/$LINEAGES{$tid}[$j]/;}
					   		delete($MIDS{$j}{$tmp}{$tid});
					   		$MIDS{$j}{$LINEAGES{$tid}[$j]}{$tid}=1;
					   		$incestG++; $jns=1;}}
		}	}	}
		### NOW MID-LEVEL NAMES CONFORM TO TAXONOMY STANDARDS - BUT SYNONYMS STILL A PROBLEM
}
undef(%MIDS);



### 2. FIX MID LEVEL SYNONYMS ###
#populate mids
print "POPULATE MIDS HASH\n";
foreach my $tid (keys %LINEAGES){
	@NOW = @{$LINEAGES{$tid}};
	for my $i (0..6){ 
		$mid = $NOW[$i];
		$MIDCNT{$mid}{$i}++; 
		$MIDTID{$mid}{$i}{$tid}=1; 
	}
}

#check for/rename mixed level mids
print "CHECKING FOR MIXED MID LEVELS\n";
foreach my $mid (sort(keys %MIDCNT)){
	if($mid !~ /\w/){next;}
	$kc = keys %{$MIDCNT{$mid}};
	if($kc > 1){ 
		$x=0; @GREEK=@PREFIX;
		#check doesnt have greek, new greek not exist and then add greek
		#keep most numerous as is
		#fix downstream in lineage
		foreach my $i (sort{$MIDCNT{$mid}{$b} <=> $MIDCNT{$mid}{$a}} keys %{$MIDCNT{$mid}}){ 
			if($x==0){ $x++; next;}  
			$greek = shift(@GREEK);
			$newname = $mid;
			$newname =~ s/^(ALPHA|BETA|DELTA|GAMMA|IOTA|KAPPA|LAMBDA|OMEGA|SIGMA|THETA|ZETA)//g; 
			$newname = $greek.$newname;
			while(exists($MIDCNT{$newname})){ 
				$greek = shift(@GREEK); 
				$newname =~ s/^(ALPHA|BETA|DELTA|GAMMA|IOTA|KAPPA|LAMBDA|OMEGA|SIGMA|THETA|ZETA)//g; 
				$newname = $greek.$newname;  
				if($GREEK[0] !~ /\w/){ print "i $i mid $mid count $count greek $greek kc $kc lin $lin \n"; die;}
			}
			foreach my $tid (keys %{$MIDTID{$mid}{$i}}){ 
				$fixmix++;
				@NOW = @{$LINEAGES{$tid}};
				$LINEAGES{$tid}[$i]=$newname; 
				$LINEAGES{$tid}[6]=~s/[A-Z]*$mid/$newname/; 
				$LINEAGES{$tid}[7]=~s/[A-Z]*$mid/$newname/; 
				@NOW = @{$LINEAGES{$tid}};			
			}
		}
	}
}
undef(%MIDCNT);
undef(%MIDTID);



### 3. MAKE SURE MID RANKS CONFORM - NO RETIRED LEVEL NAMES OR OLD BLANKS ###
print "FILL IN MISSING LEVELS\n";
foreach my $tid (sort(keys %LINEAGES)){
	@NOW = @{$LINEAGES{$tid}};
	@NOW = @NOW[0..6];
	for my $i (2..6){ #starting on third element
		$mid = $NOW[$i];
		if($mid !~ /\w/){next;}
		$jlin = join(";", @NOW[0..$i]);

		#fill in blanks
		if(exists($SWPTID{$mid}) && !exists($SWPTID{$mid}{$jlin})){ #now and prior lineages dont match
			foreach my $lin (sort(keys %{$SWPTID{$mid}})){ #either original is bad - delete and replace, or new is bad - fix, or both are unrelated
				$ch=0;
				@LAT=split(";",$lin,-1);
				for my $q (0..4){ #if A - X - B and A -  - B, fill in X
					if($NOW[$q] eq $LAT[$q] && $NOW[$q+1] ne $LAT[$q+1] && $NOW[$q+2] eq $LAT[$q+2] && $NOW[$q]=~/\w/ && $NOW[$q+2]=~/\w/){
						if($NOW[$q+1] !~ /\w/){ #if current has blank fill in current to become like prior
								$NOW[$q+1] = $LAT[$q+1]; 
								$LINEAGES{$tid}[$q+1] = $LAT[$q+1]; 
								$jlin = join(";", @NOW[0..$i]);
						} 
						if($LAT[$q+1] !~ /\w/){ #if prior had blank
								foreach my $xid (sort(keys %{$SWPTID{$mid}{$lin}})){ 
										@BAD = @{$LINEAGES{$xid}};
										$LINEAGES{$xid}[$q+1] = $NOW[$q+1];
										@FIXD = @{$LINEAGES{$xid}};
										#fill in and fix prior lineages, delete prior and replace with real-time changes from %LINEAGES
										for my $p (2..6){ $bid = $BAD[$p];  if($bid !~ /\w/){next;} $blin = join(";", @BAD[0..$p]); delete($SWPTID{$bid}{$blin}{$xid});}
										for my $p (2..6){ $gid = $FIXD[$p]; if($gid !~ /\w/){next;} $glin = join(";", @FIXD[0..$p]); $SWPTID{$gid}{$glin}{$xid}=1;}
								} 
								$ch=1;
						}
					}
				}
				if($ch==1){delete($SWPTID{$mid}{$lin});}
			}
		}
		$SWPTID{$mid}{$jlin}{$tid}=1;
	}
}
undef(%SWPTID);


		
#GET MID COUNTS SO CAN SWAP BAD MIDS
print "GET SWP COUNTS\n";
foreach my $tid (keys %LINEAGES){
	@NOW = @{$LINEAGES{$tid}};
	for my $j (2..6){
		$mid = $NOW[$j];
		if($mid !~ /\w/){next;}
		$lin = join(";", @NOW[0..$j]);
		$plin = join(";",@NOW[0..$j-1]);
		$PLINS{$plin}++;
		$SWPCNT{$j}{$mid}{$lin}++;
		$SWPPL{$j}{$mid}{$lin}=$PLINS{$plin};
	}
}
			
#break ties of tid counts using tid counts of lower level
print "BREAK SWP COUNT TIES\n";
foreach my $j (keys %SWPCNT){
	foreach my $mid (keys %{$SWPCNT{$j}}){
		$kc = keys %{$SWPCNT{$j}{$mid}};
		if($kc > 1){
			$max=0;
			foreach my $lin (sort{ $SWPCNT{$j}{$mid}{$b} <=> $SWPCNT{$j}{$mid}{$a} } keys %{$SWPCNT{$j}{$mid}}){
				 $cnt = $SWPCNT{$j}{$mid}{$lin};
				 $pcnt = $SWPPL{$j}{$mid}{$lin};
				 if($cnt > $max){ $max = $cnt; $maxp = $pcnt; $maxlin=$lin; } #first lin
				 elsif($cnt == $max){ #problem - use %PLINS to break 
				 	$SWPCNT{$j}{$mid}{$lin}=$pcnt;
				 	$SWPCNT{$j}{$mid}{$maxlin}=$maxp;
				 }
				 else{last;}
			}
		}
	}
}
undef(%SWPPL);
undef(%PLINS);


#replace inconsistent mid levels by tid counts
print "FIX OLD RANK IDS\n";
foreach my $tid (sort(keys %LINEAGES)){
	@NOW = @{$LINEAGES{$tid}};
	@NOW = @NOW[0..6];
	for my $i (2..6){ #starting on third element
		$mid = $NOW[$i];
		if($mid !~ /\w/){next;}
		$jlin = join(";", @NOW[0..$i]);
		$newcnt = $SWPCNT{$i}{$mid}{$jlin};
			
		#fill in blanks
		if(exists($SWPTID{$mid}) && !exists($SWPTID{$mid}{$jlin})){ #now and prior lineages dont match
			foreach my $lin (sort(keys %{$SWPTID{$mid}})){ #either original is bad - delete and replace, or new is bad - fix, or both are unrelated
				$ch=0;
				$oldcnt = $SWPCNT{$i}{$mid}{$lin};
				@LAT=split(";",$lin,-1);
				for my $q (0..4){ #if A - X - B and A - Y - B and Y tid count higher, replace X with Y
					if($NOW[$q] eq $LAT[$q] && $NOW[$q+1] ne $LAT[$q+1] && $NOW[$q+2] eq $LAT[$q+2] && $NOW[$q]=~/\w/ && $NOW[$q+2]=~/\w/){
						#sort by count, replace lin with higher count mid
						if($oldcnt >= $newcnt){ #if old is better fix the new
								$NOW[$q+1] = $LAT[$q+1]; 
								$LINEAGES{$tid}[$q+1] = $LAT[$q+1]; 
								$jlin = join(";", @NOW[0..$i]);
						}
						else{ 	#if new is better, fix the old
								foreach my $xid (sort(keys %{$SWPTID{$mid}{$lin}})){ 
										@BAD = @{$LINEAGES{$xid}};
										$LINEAGES{$xid}[$q+1] = $NOW[$q+1];
										$LINEAGES{$xid}[6] =~ s/$LINEAGES{$xid}[$q+1]/$NOW[$q+1]/; #fix any species with changed lower level id
										$LINEAGES{$xid}[7] =~ s/$LINEAGES{$xid}[$q+1]/$NOW[$q+1]/;
										@FIXD = @{$LINEAGES{$xid}};
										#fill in and fix prior lineages, delete prior and replace with real-time changes from %LINEAGES
										for my $p (2..6){ $bid = $BAD[$p];  if($bid !~ /\w/){next;} $blin = join(";", @BAD[0..$p]); delete($SWPTID{$bid}{$blin}{$xid});}
										for my $p (2..6){ $gid = $FIXD[$p]; if($gid !~ /\w/){next;} $glin = join(";", @FIXD[0..$p]); $SWPTID{$gid}{$glin}{$xid}=1;}
								} 
								$ch=1;
						}
					}
				}
				if($ch==1){delete($SWPTID{$mid}{$lin});}
			}
		}
		$SWPTID{$mid}{$jlin}{$tid}=1;
	}
	#STORE FOR FURTHER FILL IN NOW THAT LEVELS DONE STRINGENT FILL/FIX
	@NOW = @{$LINEAGES{$tid}};
	for my $i (0..6){ if($NOW[$i]=~/\w/){$ALLLEVS{$NOW[$i]}{$tid}++;}}
	if($NOW[4]=~/\w/){ $jlin=join(";",@NOW[0..3]); $FILLN{4}{$NOW[4]}{$jlin}{$tid}=1; }
}
undef(%SWPTID);			


print "FILL IN MISSING LEVELS - RELAXED\n";
#FILL IN FAMILY
foreach my $mid (sort(keys %{$FILLN{4}})){
		if($mid !~ /\w/){next;}
		$kc = keys %{$FILLN{4}{$mid}};
		if($kc > 1){ 
			@JLINS=(); foreach my $lin (keys %{$FILLN{4}{$mid}}){push(@JLINS,$lin);}
			@KLINS=@JLINS;
			while($JLINS[0]=~/\w/){ #this way each on gets checked and will be in correct $old/$lin orientation
				$old=shift(@JLINS);
				foreach my $lin (@KLINS){
					if($old eq $lin){next;}
					$old =~ /^(\w+\;\w+)/; $k1=$1;
					$lin =~ /^(\w+\;\w+)/; $k2=$1;
					if($k1 ne $k2){next;}
					if(length($old)>length($lin)){
						#replace with better
						foreach $tid (keys %{$FILLN{4}{$mid}{$lin}}){
							@NOW = @{$LINEAGES{$tid}};
							@NOW[0..3]=split(";",$old,-1); #replace
							$LINEAGES{$tid}=[@NOW]; #fix in lineages
						}
					}
				}
			}
		}
}
delete($FILLN{4});


#FILL IN GENUS
%ALLLEVS=();
foreach my $tid (keys %LINEAGES){
	@NOW = @{$LINEAGES{$tid}};
	#STORE FOR FURTHER FILL IN NOW THAT LEVELS DONE STRINGENT FILL/FIX
	for my $i (0..6){ if($NOW[$i]=~/\w/){$ALLLEVS{$NOW[$i]}{$tid}++;}}
	if($NOW[5]=~/\w/){ $jlin=join(";",@NOW[0..4]); $FILLN{5}{$NOW[5]}{$jlin}{$tid}=1;}
}
foreach my $mid (sort(keys %{$FILLN{5}})){
		if($mid !~ /\w/){next;}
		$kc = keys %{$FILLN{5}{$mid}};
		if($kc > 1){ 
			#FIRST MAKE ALL SUBSTITUTIONS
			@JLINS=(); foreach my $lin (keys %{$FILLN{5}{$mid}}){push(@JLINS,$lin);}
			@KLINS=@JLINS;
			while($JLINS[0]=~/\w/){ #this way each on gets checked and will be in correct $old/$lin orientation
				$old=shift(@JLINS);
				foreach my $lin (@KLINS){
					if($old eq $lin){next;}
					$old =~ /^(\w+)/; $k1=$1;
					$lin =~ /^(\w+)/; $k2=$1;
					if($k1 ne $k2){next;}
					@OLD=split(";",$old);
					@LIN=split(";",$lin);
					$good=0; $bad=0;
					for my $i (1..4){ #fill in case is good
						if($OLD[$i] !~ /\w/ || $LIN[$i] !~ /\w/){next;} 
						if($OLD[$i] eq $LIN[$i]){$good++;} 
						else{$bad++;} 
					}
					if($good >= 2 || $bad == 0){ #since double foreach looping - you'll catch it both times				
						if(length($old) > length($lin)){ #but only once of the double will be old>lin
							#replace with better
							foreach $tid (keys %{$FILLN{5}{$mid}{$lin}}){
								@NOW = @{$LINEAGES{$tid}};
								@NOW[0..4]=split(";",$old,-1); #replace
								$LINEAGES{$tid}=[@NOW]; #fix in lineages
							}
						}
					}
				}
			}
		}
}



#FILL IN SPECIES
%ALLLEVS=();
foreach my $tid (keys %LINEAGES){
	@NOW = @{$LINEAGES{$tid}};
	#STORE FOR FURTHER FILL IN NOW THAT LEVELS DONE STRINGENT FILL/FIX
	for my $i (0..6){ if($NOW[$i]=~/\w/){$ALLLEVS{$NOW[$i]}{$tid}++;}}
	if($NOW[6]=~/\w/){ $jlin=join(";",@NOW[0..5]); $FILLN{6}{$NOW[6]}{$jlin}{$tid}=1;}
}
foreach my $mid (sort(keys %{$FILLN{6}})){
		if($mid !~ /\w/){next;}
		$kc = keys %{$FILLN{6}{$mid}};
		if($kc > 1){ 
			#FIRST DO ALL THE RENAMING
			@JLINS=(); foreach my $lin (keys %{$FILLN{6}{$mid}}){push(@JLINS,$lin);}
			@KLINS=@JLINS;
			while($JLINS[0]=~/\w/){ #this way each on gets checked and will be in correct $old/$lin orientation
				$old=shift(@JLINS);
				foreach my $lin (@KLINS){
					if($old eq $lin){next;}
					$old =~ /^(\w+)/; $k1=$1;
					$lin =~ /^(\w+)/; $k2=$1;
					if($k1 ne $k2){next;}
					@OLD=split(";",$old);
					@LIN=split(";",$lin);
					$good=0; $bad=0;
					for my $i (1..4){ 
						if($OLD[$i] !~ /\w/ || $LIN[$i] !~ /\w/){next;} 
						if($OLD[$i] eq $LIN[$i]){$good++;} 
						else{$bad++;} 
					}
					#rename or replace
					if($good >= 2 || $bad == 0){ #since double foreach looping - you'll catch it both times				
						if(length($old) >= length($lin)){ #but only once of the double will be old>lin
							#replace with better
							foreach $tid (keys %{$FILLN{6}{$mid}{$lin}}){
								@NOW = @{$LINEAGES{$tid}};
								@NOW[0..5]=split(";",$old,-1); #replace
								$LINEAGES{$tid}=[@NOW]; #fix in lineages
							}
						}
					}
				}
			}
		}
}			
			

## 4. NOW ALL THE MID LEVELS ARE FIXED AS FAR AS ANY INCONSISTENT OR BLANK NAMES, SO FINALLY, RENAME RESIDUAL SYNONYMS ##
#get tid counts per lin per level
foreach my $tid (keys %LINEAGES){
		@NOW = @{$LINEAGES{$tid}};
		for my $j (0..6){
			$mid = $NOW[$j];
			if($mid !~ /\w/){next;}
			$ALLLINS{$mid}{$tid}=1;
			$lin = join(";", @NOW[0..$j]);
			$CHECKC{$j}{$mid}{$lin}++;
			$CHECKT{$j}{$mid}{$lin}{$tid}=1;
		}
}



#RENAME SYNONYMS AND THEIR SPECIES/STRAINS
print "RENAME RESIDUAL SYNONYMS\n";
for my $i (0..6){
	foreach my $mid (sort(keys %{$CHECKC{$i}})){
		$kc = keys %{$CHECKC{$i}{$mid}};
		if($kc > 1){
			@GREEK=@PREFIX;
			$count=0;
		
			foreach my $lin (sort{ $CHECKC{$i}{$mid}{$b} <=> $CHECKC{$i}{$mid}{$a} } keys %{$CHECKC{$i}{$mid}}){
				$tc = $CHECKC{$i}{$mid}{$lin};
				$kc = keys %{$CHECKT{$i}{$mid}{$lin}};
				$count++;
				if($count==1){next;} #dont change name of mid with most tids
				
				if($mid =~ /^(ALPHA|BETA|DELTA|GAMMA|IOTA|KAPPA|LAMBDA|OMEGA|SIGMA|THETA|ZETA)/){ 
					$find = $1; $greek = shift(@GREEK); 
					while($greek ne $find){ $greek = shift(@GREEK); }
				}
				$greek = shift(@GREEK);
				$newmid = $mid;
				$newmid =~ s/^(ALPHA|BETA|DELTA|GAMMA|IOTA|KAPPA|LAMBDA|OMEGA|SIGMA|THETA|ZETA)//g; 
				$newmid = $greek.$newmid;
				while(exists($ALLLINS{$newmid})){ 
					$greek = shift(@GREEK); 
					$newmid =~ s/^(ALPHA|BETA|DELTA|GAMMA|IOTA|KAPPA|LAMBDA|OMEGA|SIGMA|THETA|ZETA)//g; 
					$newmid = $greek.$newmid;
					if($GREEK[0] !~ /\w/){ print "mid $mid count $count greek $greek lin $lin \n"; die;}
				}
				
				foreach my $tid (keys %{$CHECKT{$i}{$mid}{$lin}}){
					$ALLLINS{$newmid}{$tid}=1;
					#fix %LINEAGES
					#add new CHECKT/C
					#remove old CHECKT
					@OLD = @{ $LINEAGES{$tid} };
					$LINEAGES{$tid}[$i]=$newmid;
					if($LINEAGES{$tid}[6]=~/\w/){$LINEAGES{$tid}[6]=~s/[A-Z]*$mid/$newmid/; $ALLLINS{$LINEAGES{$tid}[6]}{$tid}=1; }
					if($LINEAGES{$tid}[7]=~/\w/){$LINEAGES{$tid}[7]=~s/[A-Z]*$mid/$newmid/;  }
					@NEW = @{ $LINEAGES{$tid} };
					for my $j (0..$#OLD){
						$olin = join(";", @OLD[0..$j]);
						$nlin = join(";", @NEW[0..$j]);
						$oid = $OLD[$j];
						$nid = $NEW[$j];
						delete($CHECKT{$i}{$oid}{$olin}{$tid});
						delete($CHECKC{$i}{$oid}{$olin});
						$CHECKT{$j}{$nid}{$nlin}{$tid}=1;
						$CHECKC{$j}{$nid}{$nlin}++;
					}
				}
			}
		}
	}
}



%ALLLEVS=();
foreach my $tid (keys %LINEAGES){
	@NOW = @{$LINEAGES{$tid}};
	#STORE FOR FURTHER FILL IN NOW THAT LEVELS DONE STRINGENT FILL/FIX
	for my $i (0..$#NOW){
		if($NOW[$i]=~/\w/){$ALLLEVS{$NOW[$i]}{$i}{$tid}++;}
	}
}	
#FILL IN THE BLANKS 
#FIX duplicate strains
#last duplicate check

print "final levs check and handle non-lineage\n";
foreach my $lev (sort(keys %ALLLEVS)){
	if(keys %{$ALLLEVS{$lev}} > 1){
		$LEVS=();
		$Q=0;
		foreach my $i (sort(keys %{$ALLLEVS{$lev}})){
			foreach my $tid (keys %{$ALLLEVS{$lev}{$i}}){ 
				#sort by key count tids so can rename fewest tids, delete as you go, stop once kc == 1 so you don't extra rename
				@NOW=@{$LINEAGES{$tid}};
				$kc = keys %{$ALLLEVS{$lev}}; print "lev $lev i $i start kc $kc now @NOW\n";
				if($NOW[0] eq "MICROBIOME" && $NOW[2]=~/\w/){ $NOW[2].="_TAXON:".$tid; delete($ALLLEVS{$lev}{$i});}
				if($NOW[0] eq "QUIDDAM" && $NOW[1]=~/\w/){ 	  $NOW[1].="_TAXON:".$tid; delete($ALLLEVS{$lev}{$i});}
				if($NOW[7] =~ /\w/){                          $NOW[7].="_TAXON:".$tid; delete($ALLLEVS{$lev}{$i});}
				$LINEAGES{$tid}=[@NOW];
				@NOW=@{$LINEAGES{$tid}};
				$kc = keys %{$ALLLEVS{$lev}}; print "lev $lev i $i end kc $kc now @NOW\n";				
			}
			$kc = keys %{$ALLLEVS{$lev}};
			if($kc < 2){last;}
		}
		if(keys %{$ALLLEVS{$lev}} > 1){  
			foreach my $i (sort(keys %{$ALLLEVS{$lev}})){
				foreach my $tid (keys %{$ALLLEVS{$lev}{$i}}){ 
					@NOW=@{$LINEAGES{$tid}};
					$NOW[$#NOW].="_TAXON:".$tid; #tried it the nice way, now every remaining synonym gets a taxonid 
				}
			}
		}
	}
}

$kc1=keys %LINEAGES;
open(MERGED,"merged.dmp")||die;
while(<MERGED>){
       	if($_ !~/^\d/){next;}
        $_ = uc($_);
        $_ =~ s/[\r\n]+//;
	$_=~/^(\d+)\D+(\d+)\D/;
	$old=$1;
	$new=$2;
	if(exists($LINEAGES{$new})){
		@NOW = @{$LINEAGES{$new}};
		$LINEAGES{$old}=[@NOW];
	}
	else{$stillmissing++;}
}
$kc2=keys %LINEAGES;
print "new kc $kc1 new and old kc $kc2 stillmissing $stillmissing\n";	



$time = localtime;
$time =~ /(\d\d\d\d)$/;
$year = $1;
$output = "TAXONOMY_DB_".$year.".txt";
open(OUTPUT, ">", $output)||die;
@RANKS=("KINGDOM","PHYLUM","CLASS","ORDER","FAMILY","GENUS","SPECIES","STRAIN");
foreach my $tid (sort(keys %LINEAGES)){
	@NOW = @{$LINEAGES{$tid}};
	
	#remove any trailing empties
	if($NOW[0] eq "MICROBIOME" && $NOW[1] !~ /\w/){$NOW[1]= "UNCLASSIFIED_MICROBIOME";}	
	while($NOW[$#NOW] !~ /\w/){pop(@NOW); if($NOW[0]!~/\w/){ print "ERROR: tid $tid empty\n";}}
	
	#fill in blanks
	$replace=''; $good = '';
	for my $i (0..$#NOW){
		if($NOW[$i]=~/\w/){$good="UNCLASSIFIED_".$NOW[$i]; next;}
		else{ $replace = $good."_".$RANKS[$i]; $NOW[$i]=$replace; }
	}

	#make cytoscape tree
	$NOW[0] =~ /^(.)/; $king = $1;
	if($NOW[0] eq "MICROBIOME"){$king = "Y";}
	for($i=0; $i<=$#NOW; $i++){
			$type = $king."_".$i;
			if($i == 0){ $phyla = "$type\tROOT\t$NOW[$i]";}
			else{ $phyla = "$type\t$NOW[$i-1]\t$NOW[$i]";}
			if($NOW[$i+1]=~/\w/){$NXLVL{$phyla}{$NOW[$i+1]}=1;}
			$CYTO{$phyla}++;
			if(grep{/CYANOBACTERIA/} @NOW){$CYANO{$phyla}=1;}
			if(grep{/ARTHROPODA/} @NOW){$BUGS{$phyla}=1;}
	}

	$out = join("\t", @NOW);
	print OUTPUT "$tid\t$out\n";
}

$outcyto = "TAXONOMY_DB_".$year.".cyto";
open(OUTCYTO, ">", $outcyto)||die;
print OUTCYTO "Level\tSource\tTarget\tSpecies_Count\tSpecies_Count\tNext_Level_Count\tNext_Level_Count\n";
print OUTCYAN "Level\tSource\tTarget\tSpecies_Count\tSpecies_Count\tNext_Level_Count\tNext_Level_Count\n";
print OUTBUG "Level\tSource\tTarget\tSpecies_Count\tSpecies_Count\tNext_Level_Count\tNext_Level_Count\n";
foreach my $phyla (sort(keys %CYTO)){ 
	$nxkc = keys %{$NXLVL{$phyla}};
	print OUTCYTO "$phyla\t$CYTO{$phyla}\t$CYTO{$phyla}\t$nxkc\t$nxkc\n"; 
	if(exists($BUGS{$phyla})){print OUTBUG "$phyla\t$CYTO{$phyla}\t$CYTO{$phyla}\t$nxkc\t$nxkc\n"; }
	if(exists($CYANO{$phyla})){print OUTCYAN "$phyla\t$CYTO{$phyla}\t$CYTO{$phyla}\t$nxkc\t$nxkc\n"; }
}

