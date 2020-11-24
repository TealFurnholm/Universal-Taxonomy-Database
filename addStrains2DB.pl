## This is from an older version and will probably need updating

#input lineages
$inlin = 'TAXONOMY_DB.txt';
print "input lineages\n";
open(INLIN, $inlin)||die;
$max=0;
while(<INLIN>){
		if($_ !~ /\w/){next;}
		$_ = uc($_);
		@stuff = split("\t",$_);
		$stuff[$#stuff] =~ s/[\r\n]+//;
		$tid = shift(@stuff);
		$PHY{$tid} = join(";", @stuff);
		$SPECS{$stuff[6]}=1;
		if($tid>$max){$max=$tid;}
}
close(INLIN);

@mn = split("", $max);
$mc = @mn;
$mc = $mc+2;
$max = "0" x $mc;
$max = "1".$max;
print "max is $max\n";

$indat = 'LocusToStrain.txt';
print "input data\n";
open(INLOC, $indat)||die;
while(<INLOC>){
		if($_ !~ /\w/){next;}
		$_ =~ s/\n//;
		$_ = uc($_);
		(my $file, my $dat) = split("\t", $_);
		if($dat =~ /TAXON\:(\d+)/){
			$tid=$1; 
			if(exists($PHY{$tid}) ){ $TIDS{$file}=$tid; } #&& $PHY{$tid} !~ /^[EM]/
		}
		if($dat =~ /LOCUS\_TAG\=\"([^\"]+)\"/){
			$loc = $1;
			$loc =~ s/\d+$//;			
			if($loc !~ /\w/){next;}
			if(exists($DUP{$loc})){ next;}
			else{$DUP{$loc}=1;}
			$LOCS{$file}=$loc;
		}
		if($dat =~ /STRAIN\=\"([^\"]+)\"/){ 
			$STRS{$file}=$1; 
			$STRS{$file} =~ s/\s+/_/g; 
			$STRS{$file} =~ s/[^\d\w\-\_]+//g;
			$STRS{$file} =~ s/^\_|\_$//g;
		}
}

print "loop thru files\n";
foreach my $file (keys %STRS){
	if(exists($STRS{$file}) && exists($LOCS{$file}) && exists($TIDS{$file})){
		$tid = $TIDS{$file};
		$loc = $LOCS{$file};
		$str = $STRS{$file};
		@stuff = split(";", $PHY{$tid});
		$spe = pop(@stuff);
		$spe2 = $spe;
		$spe2 =~ s/[\-\_\s]+//g;
		$str2 = $str;
		$str2 =~ s/[\-\_\s]+//g;
		if($spe2 =~ /$str2/){next;}		
		if($spe =~ /\w+/){
			$spe .= "_STR_".$str;
			if(exists($SPECS{$spe})){next;}
			else{   
				$max++; 
				push(@stuff, $spe); 
				$lin = join(";", @stuff); 
				$PHY{$max}=$lin;
				$T2L{$max}=$loc;
			}
		}
	}
}

$time = localtime;
$time =~ /(\d\d\d\d)$/;
$year = $1;

$outloc = 'NewTidLoci.txt';
open(OUTLOC, ">", $outloc)||die;
$outlin = "TAXONOMY_DB_".$year.".txt";
open(OUTLIN, ">", $outlin)||die;
foreach my $tid (keys %PHY){
	$PHY{$tid} =~ s/\;/\t/g;
	print OUTLIN "$tid\t$PHY{$tid}\n";
	if(exists($T2L{$tid})){print OUTLOC "$tid\t$T2L{$tid}\n";}
}
