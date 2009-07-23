package WebGUI::Graphics::Admin;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::AdminConsole;
use WebGUI::International;

readonly    session => my %session;

#---------------------------------------------------------------------
sub canManage {
    my $self = shift;

    # For now, let only admins manage graphics settings.
    return $self->session->user->isAdmin;
}

#---------------------------------------------------------------------
sub getAdminConsole {
    my $self    = shift;
    my $session = $self->session;
    my $url     = $session->url;
	my $i18n    = WebGUI::International->new( $session, "Graphics" );

    my $ac = WebGUI::AdminConsole->new( $session, "graphics" );
	$ac->addSubmenuItem( $url->page( 'graphics=palette' ),                           $i18n->get('manage palettes') );
	$ac->addSubmenuItem( $url->page( 'graphics=font' ),                              $i18n->get('manage fonts')    );
	$ac->addSubmenuItem( $url->page( 'graphics=palette;method=edit;paletteId=new' ), $i18n->get('add palette')     );
	$ac->addSubmenuItem( $url->page( 'graphics=font;method=edit;fid=new' ),          $i18n->get('add font')        ); 
    
    return $ac;
}

#---------------------------------------------------------------------
sub new {
    my $class   = shift;
    my $session = shift;

    my $self = register( $class );

    $session{ id $self } = $session;

    return $self;
}

1;

