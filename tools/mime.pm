package mime;

## hyphop

#use common::sense;

our $def_mime = '<&DATA';
our %loaded;
our %ext;

sub import {
    my $pkg = caller;
    my $p  = shift;
    my $mime_file = shift || $def_mime;
    *{ $pkg . '::get_mime' } = \&get_mime;
#   warn "[i] import $pkg $mime_file";
    load_mime($mime_file) 
}

sub load_mime {

    my $mime_file = $_[0];
    return if $loaded{$mime_file};
    $loaded{$mime_file} = time();

    my $f;
    my $s = open $f, $mime_file;
    while ( my $l = <$f> ) {
        next if $l =~ /^\s*\#/;
        next unless $l =~ /(\S+)\s+(.+)\;?/;
#       warn "[i] $l\n";
        my $m = $1;
        my @l = split /\s+/, $2;
#        while ( my $m = shift @l ) {
            while ( my $e = lc shift @l ) {
#                warn "[i] mime $e $m";
                $ext{ $e } = $m;
            }
#            last;
#        }
    }
    close $f;

    my $mimes = scalar keys %ext;
    
#    warn "[i] load $mimes mime from $mime_file";

    #    text/html                             html htm shtml;
    #    text/css                              css;
    #    text/xml                              xml;

}

sub get_mime {
    $ext{ lc $_[0] };
}

sub get_mime_file {
    $_[0] =~ /(.+)\./;
    get_mime($');
}


1;

__DATA__
image/gif                             gif
image/jpeg                            jpeg jpg
image/png                             png
image/x-icon                          ico
image/svg+xml                         svg svgz
plain/text			      txt
