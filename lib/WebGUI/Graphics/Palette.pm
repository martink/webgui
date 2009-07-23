package WebGUI::Graphics::Palette;

use strict;

#use Class::C3;
use Class::InsideOut qw{ :std };
use JSON qw{ to_json from_json };
use WebGUI::Graphics::Admin;
use WebGUI::Graphics::Palette::Persist;
use WebGUI::Graphics::Palette::Color;
use Chart::Magick::Color;
use Chart::Magick::Palette;

use base qw{ Chart::Magick::Palette };

readonly crud       => my %crud;
readonly session    => my %session;

#-------------------------------------------------------------------
sub _buildObj {
    my $class   = shift;
    my $session = shift;
    my $crud    = shift;

    my $self    = $class->SUPER::new;
    register( $self );

    $crud{ id $self } = $crud;
    $session{ id $self } = $session;

    return $self;
}

#-------------------------------------------------------------------
sub _getColorFromFormPost {
    my $class   = shift;
    my $session = shift;
    my $form    = $session->form;

    my $paletteId   = $form->process( 'paletteId'   );
    my $index       = $form->process( 'colorIndex'  );

    my $color   = WebGUI::Graphics::Palette::Color->newBySequenceNumber( $session, $index, $paletteId );

    return $color;
}

#-------------------------------------------------------------------
sub create {
    my $class   = shift;
    my $session = shift;

    my $crud    = WebGUI::Graphics::Palette::Persist->create( $session );

    return $class->_buildObj( $session, $crud );
}

#-------------------------------------------------------------------
sub delete {
    my $self    = shift;
    my $session = $self->session;
    
    my $iterator = WebGUI::Graphics::Palette::Color->getAllIterator( $session, { sequenceKeyValue => $self->getId } );
    while ( my $color = $iterator->() ) {
        $color->delete;
    }

    $self->crud->delete;
}

#-------------------------------------------------------------------
sub getId {
    my $self = shift;

    return $self->crud->getId;
}

#-------------------------------------------------------------------
sub getStorage {
    my $self    = shift;
    my $session = $self->session;
    my $storage;

    if ( $self->crud->get('previewStorage') ) {
        $storage = WebGUI::Storage->get( $session, $self->crud->get('previewStorage') );
    }
    else {
        $storage = WebGUI::Storage->create( $session );
        $self->crud->update( { previewStorage => $storage->getId } );
    }

    return $storage;
}

#-------------------------------------------------------------------
sub generatePreview {
    my $self = shift;

    my $blockWidth   = 40;
    my $blockHeight  = 40;
    my $blockSpacing = 10;
    my $borderOffset = 20;

    my $width   = 2*$borderOffset + $self->getNumberOfColors * ( $blockWidth + $blockSpacing ) - $blockSpacing;
    my $height  = 2*$borderOffset + $blockHeight;

    my $image = Image::Magick->new;
    $image->Set(size => $width .'x'. $height);
    $image->ReadImage('xc:white');


    my $x1 = $borderOffset;
    my $y1 = $borderOffset;
    foreach my $color (@{$self->getColorsInPalette}) {
        my $x2 = $x1 + $blockWidth;
        my $y2 = $y1 + $blockHeight;
$self->session->log->warn( '['.$color->getFillColor .']['. $color->getStrokeColor . ']');

        $image->Draw(
            primitive   => 'rectangle',
            points      => "$x1,$y1 $x2,$y2",
            fill        => $color->getFillColor,
            stroke      => $color->getStrokeColor,
            strokeWidth => 5,
        );

        $x1 += $blockWidth + $blockSpacing;
    }

    my $storage = $self->getStorage;
    $image->Write( $storage->getPath( '.preview.png' ) );

    return $storage->getUrl( '.preview.png' );
}

#-------------------------------------------------------------------
sub new {
    my $class       = shift;
    my $session     = shift;
    my $paletteId   = shift;
    
    my $crud    = WebGUI::Graphics::Palette::Persist->new( $session, $paletteId );
    my $self    = $class->_buildObj( $session, $crud );

    # Load colors into palette
    my $iterator = WebGUI::Graphics::Palette::Color->getAllIterator( $session, { sequenceKeyValue => $paletteId } );
    while ( my $color = $iterator->() ) {
        $self->addColor( Chart::Magick::Color->new( {
            map { $_ => $color->get( $_ ) } qw{ fillTriplet fillAlpha strokeTriplet strokeAlpha }
        } ) );
    }

    return $self;
}

#-------------------------------------------------------------------
sub www_deleteColor {
    my $class   = shift;
    my $session = shift;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;

    my $color   = $class->_getColorFromFormPost( $session );
    $color->delete;

    return $class->www_edit( $session );
}

#-------------------------------------------------------------------
sub www_delete {
    my $class   = shift;
    my $session = shift;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;

    my $paletteId   = $session->form->process( 'paletteId' );
    my $palette     = $class->new( $session, $paletteId );
    $palette->delete if $palette;

    return $class->www_view( $session );
}

#-------------------------------------------------------------------
sub www_demoteColor {
    my $class   = shift;
    my $session = shift;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;

    my $color   = $class->_getColorFromFormPost( $session );
    $color->demote;

    return $class->www_edit( $session );
}

#-------------------------------------------------------------------
sub www_edit {
    my $class   = shift;
    my $session = shift;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;

    my $icon        = $session->icon;
    my $paletteId   = $session->form->process( 'paletteId' );
	my $i18n        = WebGUI::International->new( $session, 'Graphics' );
    my $self;

    my $palette;
    if ( $paletteId eq 'new' ) {
        $palette = $class->create( $session );
    }
    else {
        $palette = $class->new( $session, $paletteId );
    }

    my $f = WebGUI::HTMLForm->new( $session );
    $f->hidden(
        name    => 'graphics',
        value   => 'palette',
    );
    $f->hidden(
        name    => 'method',
        value   => 'editSave',
    );
    $f->hidden(
        name    => 'paletteId',
        value   => $paletteId,
    );
    $f->dynamicForm( [ $palette->crud->crud_definition( $session ) ], 'properties', $palette->crud );
    $f->submit;

    my $output = $f->print;

	unless ( $paletteId eq 'new' ) {
        my $index   = 1;

		$output .= '<table>';
		$output .= '<tr><th></th><th>'.$i18n->get('fill color').'</th><th>'.$i18n->get('stroke color').'</th></tr>';

		foreach my $color (@{$palette->getColorsInPalette}) {
			$output .= '<tr>';
			$output .= '<td>';
			$output .= $icon->delete( "graphics=palette;method=deleteColor;paletteId=$paletteId;colorIndex=$index" );
			$output .= $icon->edit( "graphics=palette;method=editColor;paletteId=$paletteId;colorIndex=$index" );
			$output .= $icon->moveUp( "graphics=palette;method=promoteColor;paletteId=$paletteId;colorIndex=$index" );
			$output .= $icon->moveDown( "graphics=palette;method=demoteColor;paletteId=$paletteId;colorIndex=$index" );
			$output .= '</td>';
			$output .= '<td width="30" border="1" height="30" bgcolor="'. $color->fillTriplet   .'"></td>';
			$output .= '<td width="30" border="1" height="30" bgcolor="'. $color->strokeTriplet .'"></td>';
			$output .= '</tr>';

            $index++;
		}
		$output .= '</table>';
	}

	$output .= '<a href="'.$session->url->page( "graphics=palette;method=editColor;paletteId=$paletteId;colorId=new" ).'">'.$i18n->get('add color').'</a><br />';

    # Make sure we prevent creation of stale entries.
    if ( $paletteId eq 'new' ) {
        $palette->delete;
    }

    return $admin->getAdminConsole->render( $output, 'Edit palette' );
}

#-------------------------------------------------------------------
sub www_editSave {
    my $class   = shift;
    my $session = shift;
    my $form    = $session->form;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;
    
    my $palette;
    my $paletteId = $form->process( 'paletteId' );

    if ( $paletteId eq 'new' ) {
        $palette = $class->create( $session );
    }
    else {
        $palette = $class->new( $session, $paletteId );
    }

    $palette->crud->updateFromFormPost;

    return $class->www_view( $session );
}

#-------------------------------------------------------------------
sub www_editColor {
    my $class   = shift;
	my $session = shift;
    my $form    = $session->form;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;

    # Fetch palette
    my $paletteId   = $form->process( 'paletteId' );
    my $colorId     = $form->process( 'colorId' );

    my $color;
    if ( $colorId eq 'new' ) {
        $color      = WebGUI::Graphics::Palette::Color->create( $session );
    }
    else {
        $color      = $class->_getColorFromFormPost( $session );
        $colorId    = $color->getId;
    }

	my $f = WebGUI::HTMLForm->new($session);
    $f->hidden(
        name    => 'graphics',
        value   => 'palette',
    );
	$f->hidden(
		-name	=> 'method',
		-value	=> 'editColorSave',
	);
	$f->hidden(
		-name	=> 'colorId',
		-value	=> $colorId,
	);
    $f->hidden(
        name    => 'paletteId',
        value   => $paletteId,
    );
    $f->dynamicForm( [ $color->crud_definition( $session ) ], 'properties', $color );
	$f->submit;

    if ( $colorId eq 'new' ) {
        $color->delete;
    }

	return $admin->getAdminConsole->render( $f->print, 'Edit color' );
}

#-------------------------------------------------------------------
sub www_editColorSave {
    my $class   = shift;
	my $session = shift;
    my $form    = $session->form;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;

    my $paletteId   = $form->process( 'paletteId' );
    my $colorId     = $form->process( 'colorId' );

    my $color;
    if ( $colorId eq 'new' ) {
        $color  = WebGUI::Graphics::Palette::Color->create( $session, { paletteId => $paletteId } );
    }
    else {
        $color  = WebGUI::Graphics::Palette::Color->new( $session, $colorId );
    }
    
    $color->updateFromFormPost;

    return $class->www_edit( $session );
};

#-------------------------------------------------------------------
sub www_promoteColor {
    my $class   = shift;
    my $session = shift;
    my $admin   = WebGUI::Graphics::Admin->new( $session );
    
    return $session->privilege->adminOnly unless $admin->canManage;
    
    my $color   = $class->_getColorFromFormPost( $session );
    $color->promote;

    return $class->www_edit( $session );
}

#-------------------------------------------------------------------
sub www_view {
    my $class   = shift;
	my $session = shift;
    my $i18n    = WebGUI::International->new( $session, 'Graphics' );
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;

	my $output .= '<table>';
	$output .= '<tr><th></th><th>'.$i18n->get('palette name').'</th></tr>';

    my $iterator = WebGUI::Graphics::Palette::Persist->getAllIterator( $session );
	while ( my $palette = $iterator->() ) {
        # TODO: Change this to only generate previews when something changes. Here now for testing purposes only.
        my $previewUrl = $class->new( $session, $palette->getId )->generatePreview;
		$output .= '<tr>';
		$output .= '<td>';
		$output .= $session->icon->delete('graphics=palette;method=delete;paletteId=' . $palette->getId );
		$output .= $session->icon->edit('graphics=palette;method=edit;paletteId=' . $palette->getId );
		$output .= '</td>';
		$output .= '<td>' . $palette->get('name') . '</td>';
        $output .= qq{<td><img src="$previewUrl" /></td>};
		$output .= '</tr>';
	}
	$output .= '</table>';

	$output .= '<a href="'.$session->url->page('graphics=palette;method=edit;paletteId=new').'">'.$i18n->get('add palette').'</a><br />';

    return $admin->getAdminConsole->render( $output, 'Manage palettes' );
}

1;

