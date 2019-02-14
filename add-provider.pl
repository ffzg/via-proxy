#!/usr/bin/perl
use warnings;
use strict;
use autodie;

my @domains = @ARGV;

open(my $fh, '>', "providers/$domains[0].conf");

print $fh qq{# $0 @domains\n\n};

foreach my $domain ( @domains ) {

print $fh qq{

<VirtualHost *:443>
	Include /srv/via-proxy/ssl.conf

	ServerName ${domain}.p.vbz.ffzg.hr

	SSLProxyEngine on
	ProxyAddHeaders Off
	ProxyPass        / https://${domain}/
	ProxyPassReverse / https://${domain}/

	Header edit* Set-Cookie "(.*)(?i:; *domain=)([^;]+)(.*)" "\$1 ; domain=\$2.p.vbz.ffzg.hr \$3"
	#Header edit* Set-Cookie "(.*)(?i:; *secure)" "\$1"
};

foreach ( @domains ) {
	# for maximum compatibility, they should NOT end with /
	print $fh qq{\tHeader edit* Location "https://$_" "https://$_.p.vbz.ffzg.hr"\n};
}

print $fh qq{
	RequestHeader unset Accept-Encoding
};

foreach ( @domains ) {
	print $fh qq{\tSubstitute "s|https://$_|https://$_.p.vbz.ffzg.hr|"\n};
}

print $fh qq{
	FilterDeclare NEWPATHS
	FilterProvider NEWPATHS SUBSTITUTE "%{Content_Type} =~ m|^text/html|"
	FilterProvider NEWPATHS SUBSTITUTE "%{Content_Type} =~ m|^text/css|"
	FilterProvider NEWPATHS SUBSTITUTE "%{Content_Type} =~ m|^text/javascript|"
	FilterProvider NEWPATHS SUBSTITUTE "%{Content_Type} =~ m|^application/javascript|"
	FilterChain NEWPATHS

	CustomLog /var/log/apache2/access-p.vbz.ffzg.hr.log vhost_combined
</VirtualHost>
};

}

print $fh "\n\n## add domains to SSL certificate:\n";
print "## add domains to SSL certificate:\n";
foreach ( @domains ) {
	print $fh qq{# $_.p.vbz.ffzg.hr\n};
	print qq{$_.p.vbz.ffzg.hr\n};
}
