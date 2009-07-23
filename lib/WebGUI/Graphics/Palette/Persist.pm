package WebGUI::Graphics::Palette::Persist;

use strict;

use base qw{ WebGUI::Crud };

sub crud_definition {
    my $class   = shift;
    my $session = shift;

    my $definition = $class->SUPER::crud_definition( $session );

    $definition->{ tableName    } = 'graphics_palette';
    $definition->{ tableKey     } = 'paletteId';

    $definition->{ properties   }->{ name } = {
        fieldType   => 'text',
        label       => 'Name',
    };
      
    return $definition;
}


1;

