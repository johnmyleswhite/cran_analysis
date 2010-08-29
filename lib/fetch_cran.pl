#!/usr/bin/perl

# Always enforce good Perl programming habits
use strict;
use warnings;

# Use the WWW::Mechanize library for our work.
use WWW::Mechanize;

# We initialize a Mechanize object.
my $mech = WWW::Mechanize->new(autocheck => 1);

# We start from the CRAN homepage and then find all of the existing packages.
my $starting_point = 'http://cran.r-project.org/web/packages';

$mech->get($starting_point);

my @links = $mech->find_all_links(tag       => "a",
                                  url_regex => qr/^\.\.\/\.\.\/web\/packages\//
                                 );

for my $link (@links)
{
    my $package_url = $link->url;
    $package_url =~ s/^\.\.\/\.\.\///;
    my $base         = 'http://cran.r-project.org/';
    my $absolute_url = $base . $package_url;
    print "$absolute_url\n";
    $mech->get($absolute_url);
    my @sub_links =
      $mech->find_all_links(tag       => 'a',
                            url_regex => qr/\/src\/contrib\/.*tar\.gz/);
    for my $sub_link (@sub_links)
    {
        my $src_url = $sub_link->url;
        $src_url =~ s/^\.\.\/\.\.\/\.\.\///;
        $src_url = $base . $src_url;
        my (undef, undef, $filename) = File::Spec->splitpath($src_url);
        $mech->get($src_url, ":content_file" => $filename);
  }
}
