package WebGUI::Form::HTMLSelectBox;

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
use base 'WebGUI::Form::SelectBox';
use WebGUI::International;
use WebGUI::SQL;
use JSON qw{ to_json };
=head1 NAME

Package WebGUI::Form::Font

=head1 DESCRIPTION

Creates a font chooser field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectBox.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 areOptionsSettable ( )

Returns 0.

=cut

sub areOptionsSettable {
    return 0;
}

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 size

How many rows should be displayed at once? Defaults to 1.

=head4 multiple

Set to "1" if multiple groups should be selectable. Defaults to 0.

=head4 excludeGroups

An array reference containing a list of groups to exclude from the list. Defaults to an empty array reference.

=head4 defaultValue

This will be used if no value is specified. Should be passed as an array reference. Defaults to 7 (Everyone).

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push( @{ $definition}, {
		size=>{
			defaultValue=>1
			},
		multiple=>{
			defaultValue=>0
			},
		defaultValue=>{
			defaultValue=>[]
			},
        display=>{
            defaultValue=>{},
            },
    } );

    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "CHAR(22) BINARY".

=cut 

sub getDatabaseFieldType {
    return "CHAR(22) BINARY";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return 'Font';
    return WebGUI::International->new($session, 'WebGUI')->get('group');
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as a name.

=cut

sub getValueAsHtml {
    my $self = shift;

    my $font = WebGUI::Graphics::Font->new( $self->session, $self->getOriginalValue );
    if ( $font ) {
        return '<img src="' . $font->getPreviewUrl . '" />';
    }

    return undef;
}


#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Returns a group pull-down field. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.  

=cut

sub toHtml {
	my $self    = shift;
    my $session = $self->session;
    my ($style, $url) = $session->quick( qw{ style url } );
    my $options = {};
    my $images  = {};

    $style->setLink($url->extras('yui/build/button/assets/skins/sam/menu.css'),     {type=>'text/css', rel=>'stylesheet'});
    $style->setLink($url->extras('yui/build/button/assets/skins/sam/button.css'),   {type=>'text/css', rel=>'stylesheet'});
    $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>'text/javascript'} );
    $style->setScript($url->extras('yui/build/container/container_core-min.js'),    {type=>'text/javascript'} );
    $style->setScript($url->extras('yui/build/menu/menu-min.js'),                   {type=>'text/javascript'} );
    $style->setScript($url->extras('yui/build/element/element-min.js'),             {type=>'text/javascript'} );
    $style->setScript($url->extras('yui/build/button/button-min.js'),               {type=>'text/javascript'} );
    $style->setScript($url->extras('yui-webgui/build/form/HTMLSelect.js'),          {type=>'text/javascript'} );
   
    $self->set( id => 'hs_'.$session->id->generate ) unless $self->get( 'id' );
    my $id = $self->get( 'id' );

    my $imageConfig = to_json( $self->get('display') );
    my $javascript = <<EOJS;
<script type="text/javascript">
    YAHOO.util.Event.onDOMReady( function () {
        var klazam = new WebGUI.HTMLSelect( '$id', $imageConfig );
    } )
</script>
EOJS
    $style->setRawHeadTags( $javascript );

    my $output  = $self->SUPER::toHtml;

    return qq{<span class="yui-skin-sam">$output</span>};
}

1;

