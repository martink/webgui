package WebGUI::Form::Hidden;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::Control';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Hidden

=head1 DESCRIPTION

Creates a hidden field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut


#-------------------------------------------------------------------

=head2 generateIdParameter ( )

A class method that returns a value to be used as the autogenerated ID for this field instance. Returns undef because this field type can have more than one with the same name, therefore autogenerated ID's aren't terribly useful.

=cut

sub generateIdParameter {
	return undef;
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('hidden');
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

A synonym for toHtmlAsHidden.

=cut

sub toHtml {
	my $self = shift;
	$self->toHtmlAsHidden;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders an input tag of type hidden.

=cut

sub toHtmlAsHidden {
	my $self = shift;
 	my $value = $self->getOriginalValue;
    $value = defined $value ? $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters($value))) : '';
	my $idText = $self->get('id') ? ' id="'.$self->get('id').'" ' : '';
	return '<input type="hidden" name="'.($self->get("name")||'').'" value="'.$value.'" '.($self->get("extras")||'').$idText.' />'."\n";
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row. The row is not displayed because there is nothing to display, but it may not be left away because <input> may not be a child of <table> according to the XHTML standard.

=cut

sub toHtmlWithWrapper {
	my $self = shift;
	return '<tr style="display: none"><td></td><td>'.$self->toHtmlAsHidden.'</td></tr>';
}


1;
