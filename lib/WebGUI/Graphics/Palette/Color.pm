package WebGUI::Graphics::Palette::Color;

use strict;

use base qw{ WebGUI::Crud };

sub crud_definition {
    my $class   = shift;
    my $session = shift;
	my $i18n    = WebGUI::International->new($session, "Graphics");

    my $definition = $class->SUPER::crud_definition( $session );

    # Table defs
    $definition->{ tableName    } = 'graphics_palette_color';
    $definition->{ tableKey     } = 'colorId';
    $definition->{ sequenceKey  } = 'paletteId';
	
	# Create transparencies in 5% increments
	tie my %transparencies, 'Tie::IxHash', (
        '00' => 'Opaque',
        ( map { uc( sprintf( "%02x", 255 / 20 * $_ ) ) => 5 * $_ .'% Transparent' } 1..19 ),
        'ff' => 'Invisible',
    );

    # Column defs
    $definition->{ properties }->{ paletteId    } = {
        fieldType   => 'hidden',
    };
    $definition->{ properties }->{ fillTriplet  } = {
        fieldType   => 'color',
        label       => $i18n->get('fill color'),
        hoverHelp   => $i18n->get('fill color description'),
        maxlength   => 7,
        size        => 7,
    };
    $definition->{ properties }->{ fillAlpha    } = {
        fieldType   => 'selectSlider',
        label       => $i18n->get('fill alpha'),
        hoverHelp   => $i18n->get('fill alpha description'),
        options     => \%transparencies,
        maxlength   => 2,
        editable    => 0,
        size        => 2,
        defaultValue    => '00',
    };
    $definition->{ properties }->{ strokeTriplet} = {
        fieldType   => 'color',
        label       => $i18n->get('stroke color'),
        hoverHelp   => $i18n->get('stroke color description'),
        maxlength   => 7,
        size        => 7,
    };
    $definition->{ properties }->{ strokeAlpha  } = {
        fieldType   => 'selectSlider',
        label       => $i18n->get('stroke alpha'),
        hoverHelp   => $i18n->get('stroke alpha description'),
        options     => \%transparencies,
        maxlength   => 2,
        editable    => 0,
        size        => 2,
        defaultValue => '00',
    };

    return $definition;
}


sub newBySequenceNumber {
    my $class               = shift;
    my $session             = shift;
    my $sequenceNumber      = shift;
    my $sequenceKeyValue    = shift;

    my $iterator = $class->getAllIterator( $session,  { 
        sequenceKeyValue    => $sequenceKeyValue, 
        constraints         => [ 
            { 'sequenceNumber=?'  => $sequenceNumber },
        ],
    } );

    return $iterator->();
}

1;

