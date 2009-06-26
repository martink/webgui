package WebGUI::Chart::Pie;

use strict;

use base qw{ WebGUI::Chart::ChartMagick };

#---------------------------------------------------------------------
sub definition {
    my $class       = shift;
    my $session     = shift || die "Pie: no session passed";
    my $definition  = shift || [];

    tie my %chartOptions, 'Tie::IxHash', (
        radius  => {
            fieldType       => 'integer',
            label           => 'Radius',
            defaultValue    => 100,
            category        => 'chart',
        },
        pieMode => {
            fieldType       => 'selectBox',
            label           => 'Render mode',
            options         => { normal => 'Normal', stepped => 'Stepped' },
            defaultValue    => 'normal',
        },
        explosionLength => {
            fieldType       => 'integer',
            label           => 'Explosion length',
            defaultValue    => 0,
            category        => 'chart',
        },
        scaleFactor => {
            fieldType       => 'integer',
            label           => 'Scale factor',
            defaultValue    => 1,
            category        => 'chart',
        },
        shadeSides => {
            fieldType       => 'yesNo',
            label           => 'Shade sidewalls?',
            defaultValue    => 0,
            category        => 'chart',
        },
        tiltAngle   => {
            fieldType       => 'integer',
            label           => 'Tilt angle',
            size            => 2,
            defaultValue    => 55,
            category        => 'chart',
        },
        startAngle  => {
            fieldType       => 'integer',
            label           => 'Start angle',
            size            => 3,
            defaultValue    => 0,
            category        => 'chart',
        },
        
        stickLength => {
            fieldType       => 'integer',
            label           => 'Stick length',
            defaultValue    => 0,
            category        => 'chart',
        },
        stickColor => {
            fieldType       => 'color',
            label           => 'Stick color',
            defaultValue    => '#333333',
            category        => 'chart',
        },

        labelPosition => {
            fieldType       => 'selectBox',
            label           => 'labelPosition',
            options         => { top => 'Top', middle => 'Middle', bottom => 'Bottom' },
            defaultValue    => 'top',
            category        => 'chart',
        },

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

