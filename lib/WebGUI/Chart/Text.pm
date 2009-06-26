package WebGUI::Chart::Text;

use strict;

use List::Util qw{ max };

use base qw{ WebGUI::Chart };

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift || [];

    tie my %options, 'Tie::IxHash', (
        width   => {
            fieldType       => 'integer',
            label           => 'Bar width',
            defaultValue    => 150,
        },
        color   => {
            fieldType   => 'color',
            label       => 'Bar color',
        },
    );

    push @{ $definition }, {
        name        => 'Text bars',
        properties  => \%options,
        className   => 'WebGUI::Chart::Text',
    };

    return $class->SUPER::definition( $session, $definition );
}

sub toHtml {
    my $self = shift;

    my ($coords, $values) = @{ $self->datasets->[ 0 ] };
    my $max     = max @{ $values };
    my $divider = $max / $self->get('width');
    my $color   = $self->get('color');

    my $output = "<table border=\"0\" cellspacing=\"2\">";
    for my $i ( 0 .. scalar @$coords - 1 ) {
        my $width = ( $values->[ $i ] / $divider ) . 'px';
        my $label = $self->labels->[ 0 ]->{ $coords->[ $i ] };

        $output .= "<tr><td>$label</td><td>$values->[ $i ]</td><td>";
        $output .= "<table><tr><td width=\"$width\" style=\"background-color: $color\">&nbsp;</td></tr></table>";
        $output .= "</td></tr>";
    }
    $output .= '</table>';

    return $output;
}

1;

