package WebGUI::Content::Graphics;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::AdminConsole;
use WebGUI::Exception::Shop;
use WebGUI::Pluggable;

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my $session = shift;
    my $output  = undef;

    my $graphics    = $session->form->get('graphics');
    my $func        = $session->form->get('func') || 'view'; 

    if ( $graphics eq 'font' ) {
        my $output = eval { WebGUI::Pluggable::instanciate( 'WebGUI::Graphics::Font', "www_$func", [ $session ] ) };
        $session->log->warn( $@ . ' - ' . $! ) if $@;

        return $output;
    }

    return undef;
}

1;

