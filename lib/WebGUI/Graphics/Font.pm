package WebGUI::Graphics::Font;

use strict;

use WebGUI::Storage;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Graphics::Admin;
use Image::Magick;

use base qw{ WebGUI::Crud };

#-------------------------------------------------------------------
sub crud_definition {
    my $class   = shift, 
    my $session = shift;

    my $definition = $class->SUPER::crud_definition( $session );

    $definition->{ tableName    } = 'graphicsFont';
    $definition->{ tableKey     } = 'fontId';

    $definition->{ properties }{ name } = {
        label           => 'Name',
        fieldType		=> 'text',
        defaultValue	=> '',
    };
    $definition->{ properties }{ fontStorage } = {
        label           => 'Font file',
        fieldType		=> 'file',
        defaultValue	=> undef,
        maxAttachments  => 1,
    };
    $definition->{ properties }{ filename } = {
        fieldType       => 'hidden',
        noFormPost      => 1,
    };

    return $definition;
}

#-------------------------------------------------------------------

=head2 canDelete 

=cut

sub canDelete {
    my $self = shift;

    return 0 if ( $self->getId =~ m/^default/ );
    return 1;
}

#-------------------------------------------------------------------

=head2 delete 

=cut

sub delete {
    my $self = shift;

    if ( $self->canDelete ) {
        my $storage = $self->getStorage;
        $storage->deleteFile( $self->get('filename') );

        $self->SUPER::delete( @_ );
    }
}

#-------------------------------------------------------------------

=head2 getFontList 

=cut

sub getFontList {
    my $self    = shift;
    my $session = shift || $self->session;
    my $db      = $session->db;

    tie my %fonts, 'Tie::IxHash', $db->buildHash( 'select fontId, name from graphicsFont order by name' );

    return \%fonts;
}

#-------------------------------------------------------------------

=head2 getFile 

=cut

sub getFilePath {
    my $self = shift;

    my $storage = $self->getStorage;

    if ( $storage ) {
        return $storage->getPath( $self->get('filename') );
    } else {
        # Default to the default font
        return $self->session->config->getWebguiRoot."/lib/default.ttf"
    }
}

#-------------------------------------------------------------------
sub getPreviewUrl {
    my $self = shift;

    return $self->getStorage->getUrl( '.preview.png' );
}

#-------------------------------------------------------------------

sub getStorage {
    my $self    = shift;
    my $session = $self->session;
    my $storage;

    if ( $self->get('fontStorage') ) {
        $storage = WebGUI::Storage->get( $session, $self->get('fontStorage') );
    }
    else {
        $storage = WebGUI::Storage->create( $session );
    }

    return $storage;
}

#-------------------------------------------------------------------
sub updateFromFormPost {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;

    $self->SUPER::updateFromFormPost( @_ );

    if ( $form->process( 'fontStorage_file' ) ) {
        my $storage     = $self->getStorage;
        my $filename    = $storage->addFileFromFormPost( 'fontStorage_file' );

        $self->update( {
            fontStorage     => $storage->getId,
            filename        => $filename,
        } );

        if ( $filename ) {
            my %properties = (
                gravity     => 'Center',
                text        => $form->process( 'name' ),
                antialias   => 'true',
                font        => $storage->getPath( $filename ),
                fill        => 'black',
                pointsize   => 20,
            );

            my $im = Image::Magick->new();
            $im->Set( size => '100x100' );
            $im->ReadImage( 'xc:white' );

            my @metrics = $im->QueryFontMetrics( %properties );
            my ($width, $height) = @metrics[ 4, 5 ];
            $im->Resize( width => $width, height => $height );
            $im->Annotate( %properties );
            $im->Write( $storage->getPath( '.preview.png' ) );
        }
    }
}

#-------------------------------------------------------------------
sub www_delete {
    my $class   = shift;
    my $session = shift;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;
    
    my $fontId  = $session->form->process( 'fid' );
    my $font    = $class->new( $session, $fontId );
    $font->delete if $font;

    return $class->www_view( $session );
}

#-------------------------------------------------------------------
sub www_edit {
    my $class   = shift;
    my $session = shift;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;
    
    my $font;
    my $fontId  = $session->form->process( 'fid' );

    if ( $fontId eq 'new' ) {
        $font = $class->create( $session );
    }
    else {
        $font = $class->new( $session, $fontId );
    }

    my $f = WebGUI::HTMLForm->new( $session );
    $f->hidden(
        name    => 'graphics',
        value   => 'font',
    );
    $f->hidden(
        name    => 'method',
        value   => 'editSave',
    );
    $f->hidden(
        name    => 'fid',
        value   => $fontId,
    );
    $f->dynamicForm( [ $class->crud_definition( $session ) ], 'properties', $font );
    $f->submit;

    # Make sure we prevent creation of stale entries.
    if ( $fontId eq 'new' ) {
        $font->delete;
    }

    return $admin->getAdminConsole->render( $f->print, 'Edit font' );
}

#-------------------------------------------------------------------
sub www_editSave {
    my $class   = shift;
    my $session = shift;
    my $form    = $session->form;
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;
    
    my $font;
    my $fontId  = $form->process( 'fid' );

    if ( $fontId eq 'new' ) {
        $font = $class->create( $session );
    }
    else {
        $font = $class->new( $session, $fontId );
    }

    $font->updateFromFormPost;

    return $class->www_view( $session );
}

#-------------------------------------------------------------------
sub www_view {
    my $class   = shift;
	my $session = shift;
    my $i18n    = WebGUI::International->new($session, 'Graphics');
    my $admin   = WebGUI::Graphics::Admin->new( $session );

    return $session->privilege->adminOnly unless $admin->canManage;
    
	my $output .= '<table>';
	$output .= '<tr><th></th><th>'.$i18n->get('font name').'</th></tr>';

    my $iterator = $class->getAllIterator( $session );
	while ( my $font = $iterator->() ) {
		$output .= '<tr>';
		$output .= '<td>';
		$output .= $session->icon->delete( 'graphics=font;method=delete;fid=' . $font->getId );
		$output .= $session->icon->edit( 'graphics=font;method=edit;fid=' . $font->getId );
		$output .= '</td>';
		$output .= '<td>' . $font->get('name') . '</td>';
        $output .= '<td><img src="'.$font->getStorage->getUrl( '.preview.png' ).'" /></td>';
		$output .= '</tr>';
	}
	$output .= '</table>';

	$output .= '<a href="'.$session->url->page('graphics=font;method=edit;fid=new').'">'.$i18n->get('add font').'</a><br />';

    return $admin->getAdminConsole->render( $output, 'Manage fonts' );
}

1;

