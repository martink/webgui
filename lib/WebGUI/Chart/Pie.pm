package WebGUI::Chart::Pie;

use strict;

use base qw{ WebGUI::Chart::ChartMagick };

#---------------------------------------------------------------------
sub definition {
    my $class       = shift;
    my $session     = shift || die "Pie: no session passed";
    my $definition  = shift || [];

    tie my %chartOptions, 'Tie::IxHash', (
    );

    my %properties = (
        name        => 'Pie chart',
        properties  => \%chartOptions,
        className   => 'WebGUI::Chart::Pie',
        chartClass  => 'Chart::Magick::Chart::Pie',
        axisClass   => 'Chart::Magick::Axis::None'
    );
    push @{ $definition }, \%properties;

    return $class->SUPER::definition( $session, $definition );
};

1;

