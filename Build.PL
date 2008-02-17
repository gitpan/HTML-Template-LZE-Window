use strict;
use Module::Build;
use vars qw( $settings $skip);
my $class = Module::Build->subclass(class => "Module::Build::Custom", code => <<'SUBCLASS' );
my $release = 'blib/rhtml/';
my $dir     = 'htdocs/';
my $path = '.';
use lib("lib");
sub ACTION_build {
my $self = shift;
&change($dir);
$release = 'blib/perl/';
$dir     = 'cgi-bin/';
&change($dir);
$self->SUPER::ACTION_build;
}
sub change {
my $d = shift;
chomp($d);
opendir(IN, $d) or warn "cant open $d $!:$/";
my @files = readdir(IN);
closedir(IN);
for(my $i = 0 ; $i <= $#files ; $i++) {
unless ($files[$i] =~ /^\./) {
my $c = $d . $files[$i];
my $e = $c;
$e =~ s/^$dir(.*)/$1/;
unless (-d $d . $files[$i]) {
system(" cp " . $c . " $release/$e") unless (-e $release . "/" . $e && $files[$i] =~ /\~$/);
} else {
system("mkdir -p $release/$e") unless (-e $release . "/" . $e);
&change($d . $files[$i] . "/");
}
}
}
}
SUBCLASS
my $inctance = $class->new(
get_options => {skip => {store => \$skip},},
module_name => 'HTML::Template::LZE::Window',
requires => {
            'Test::More' => 0.7,
            'Module::Build' => 0.2808,
            'Test::Pod' =>  1.26,
            'Test::Pod::Coverage' =>  0.55,
            'CGI::LZE' => 0.25,
            'HTML::Template::LZE' => 0.25,
},
($] >= 5.005 ? (AUTHOR => 'Dirk Lindner <lindnerei@o2online.de>') : ()),
dist_abstract => "Produce a move-,resize-,collapse- and closeable Html Window",
license => "lgpl",
create_makefile_pl => 'passthrough',
);

$inctance->{properties}{htd} = "/srv/www/htdocs";
$inctance->{properties}{cgi}  = "/srv/www/cgi-bin";

eval 'use CGI::LZE::Settings qw($settings loadSettings saveSettings)';
unless ($@) {
        loadSettings();
        *settings    = \$CGI::LZE::Settings::settings;
        $inctance->{properties}{htd}          = $settings->{cgi}{DocumentRoot} if -e $settings->{cgi}{DocumentRoot};
        $inctance->{properties}{cgi}         = $settings->{cgi}{bin} if -e $settings->{cgi}{bin};
}
$inctance->{properties}{cgi}         = $inctance->args('cgi')         if $inctance->args('cgi');
$inctance->{properties}{htd}         = $inctance->args('htd')         if $inctance->args('htd');
unless ($skip){
        $inctance->{properties}{htd}  = Module::Build->prompt("Where is your Document root ?",     $inctance->{properties}{htd} );
         $inctance->{properties}{cgi}  = Module::Build->prompt("Where is your cgi-bin Directory ?",$inctance->{properties}{cgi});
}else{
        print "Document root: $inctance->{properties}{htd}$/cgi-bin Directory:$inctance->{properties}{cgi}$/";
}
$inctance->{properties}{install_path}{perl} = $inctance->{properties}{cgi};
$inctance->{properties}{install_path}{rhtml} = $inctance->{properties}{htd};
$inctance->create_build_script;
