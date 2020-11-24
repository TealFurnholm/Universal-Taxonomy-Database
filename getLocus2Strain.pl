#use warnings;
use Parallel::Loops;
my $maxProcs = 20;  # !! set to what number of threads you want

#input the directories from files.txt
open(IN, "files.txt")||die "unable to open files.txt: $!\n";
while(<IN>){
        if($_ !~ /\w/){next;}
        $_ =~s/\s//g;
        push(@DIRS,$_);
}
@DIRS = sort(@DIRS);
$cc=@DIRS;

#start forked loop of download
for my $i (0..$#DIRS){
        push(@CL, $DIRS[$i]);
        $cc=@CL;
        #print "pushing $cc info $DIRS[$i]\n";
        if($i%1000==0 && $i > 500){
                my $pl = Parallel::Loops->new($maxProcs);
                $pl->foreach( \@CL, sub {
                        my $p = $_;
                        $p =~ /([^\/\\]+)$/;
                        $q = $1.".tmpout";
                        $r = $1."_genomic.gbff.gz";
                        #print "doing $p in $q\n";
                        system "timeout 30s wget -r -q -e robots=off --reject \"index.html\" -nH -nd -A \"*genomic.gbff.gz\" --retr-symlink=on --cut-dirs=6 $p -P ./;";
                        system "timeout 1s zgrep -m 1 -H \"locus_tag\" $r >> $q;";
                        system "timeout 1s zgrep -m 1 -H \"taxon\" $r >> $q;";
                        system "timeout 1s zgrep -m 1 -H \"strain=\" $r >> $q;";

                }); #CLOSE PARALLEL
                system "rm *genomic.gbff.gz;";
                system "rm index*;";
                system "cat *.tmpout >> LocusToStrain.txt;";
                system "rm *tmpout;";
                my @CL = ();
        }
        $time = localtime;
        print "doing $i of $#DIRS time $time\n";
}


