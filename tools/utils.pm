package utils;

## hyphop ##

use Fcntl 'SEEK_CUR';
use mime;
use MIME::Base64;

our $time_format;
our @DoW;
our @MoY;

BEGIN {
    $time_format = "%02d %s %04d %02d:%02d GMT";
    @DoW = qw(Sun Mon Tue Wed Thu Fri Sat); # ugly bug
    @DOW = qw(Sun Mon Tue Wed Thu Fri Sat);
    @MoY = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
#   warn @DoW;
}

#our @MoY{@MoY} = (1..12);

sub time2str {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($_[0] || time);
    #Thu, 26 Jun 2014 19:11:19 GMT
    #[26/Jun/2014:23:11:24 +0400
    sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT",
	    $DoW[$wday], # # ugly bug
	    $mday, $MoY[$mon], $year+1900,
	    $hour, $min, $sec)
}

sub time2log_full {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($_[0] || time);
    #Thu, 26 Jun 2014 19:11:19 GMT
    #[26/Jun/2014:23:11:24 +0400
    $year+=1900;
    #$DoW[$wday], # # ugly bug

#    my @z = 
#	( ($hour < 10 ? '0' : ''),
#	  ($min  < 10 ? '0' : ''), 
#	  ($sec  < 10 ? '0' : ''),
#	);
#
#    "$DOW[$wday]/$mday/$MoY[$mon]/$year:$z[0]$hour:$z[1]$min:$z[2]$sec"
    "$DOW[$wday]/$mday/$MoY[$mon]/$year:$hour:$min:$sec"
}


sub time2fmt {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday ) =
      gmtime( $_[0] || time );
     sprintf( ($_[1] || $time_format) ,
     $DoW[$wday],
     $mday, $MoY[$mon], $year + 1900, $hour, $min, $sec );
}

sub time2log {
    my @a = localtime($_[0] || time);
    #23:11:24
    sprintf("%02d:%02d:%02d", $a[0],$a[1],$a[2])
}

sub store_data {
	my $data = "{\n";
        foreach my $k ( sort keys %{ $_[0] } ) {
	    my $v = $_[0]->{$k};
	    $v =~ s/\"/\\"/g;
            $data .= qq{\t"$k" => "$v",\n};
        }
	$data .= "}\n";
	return $data;
}

sub store_data2 {
	my $data = '';
	my $space= "\t"x2;
        foreach my $k ( sort keys %{ $_[0] } ) {
	    my $v = $_[0]->{$k};
            $data .= $k . $space . $v ."\n";
        }
	return $data;
}

sub read_data2hash {
    my %h = ${$_[0]} =~ /(\S+)[\ \t]*([^\n]*)\n/g;
    return \%h;
}

sub read_data2 {
    my @a = ${$_[0]} =~ /(\S+)[\ \t]*([^\n]*)\n/g;
    return \@a;
}

sub copy_hash {
    my %data;
    foreach my $k ( sort keys %{ $_[0] } ) {
	$data{$k} = $_[0]->{$k}
    }
    return \%data;
}

sub open_to {
    my $mode = $_[2] || '>';
    my $r = open my $f, "$mode$_[0]";
    binmode $f, $_[3] if defined $_[3];
    sysseek($f, $_[4], 0) if defined $_[4];
    return $f;
}

sub save_to {
    my $mode = $_[2] || '>';
    my $r = open my $f, "$mode$_[0]";
    binmode $f, $_[3] if defined $_[3];

    sysseek($f, $_[4], 0) if defined $_[4];

    $r = syswrite $f, ${ $_[1] };
    warn "save_to $r bytes to $mode $_[0] seek: $_[4] err:$!\n";
#   warn ${ $_[1] };
    close $f;
    return $r
}

sub read_to {
    my $s = -s $_[0];
    return undef unless $s;
    my $r = open my $f, "$_[0]";
    binmode $f, $_[3] if defined $_[3];
    $r = sysread $f, ${ $_[1] }, $s;
    warn "read_to $r bytes to $_[0] err:$!\n";
    close $f;
    return $r
}

sub file {
    my $s = -s $_[0];
#   warn "[e] read $_[0] not found\n";
    return undef unless $s;
    my $r = open my $f, "$_[0]";
    binmode $f, $_[3] if defined $_[3];
    my $data;
    $r = sysread $f, $data, $s;
    warn "read  $r bytes from $_[0] err:$!\n";
    close $f;
    return $data
}

sub get_current_dir {
    my $cwd = readlink "/proc/$$/cwd";
    warn "[i] cwd $cwd\n";
    return $cwd;
}

sub time_sec_to_mins {
    my $m  = int( $_[0] / 60 );
    my $s  = $_[0] - $m * 60;
    my $ss = $s > 9 ? $s : "0$s";
    "$m:$ss";
}

sub file_name {
    return $' if  $_[0] =~ /(.+\/)/;
    $_[0];
}


sub file_inline { 
    my $file = $_[0];
    my $mime_type = mime::get_mime_file($file);

#    warn "$mime_type type $file\n";
    my $data;
    read_to $file => \$data;

    my $base64_data = MIME::Base64::encode_base64 $data, '';

#    my $inline = "data:$mime_type;base64,$base64_data";
#    warn $inline;
#    $inline
    
    "data:$mime_type;base64,$base64_data"


}

1;
