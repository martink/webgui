package WebGUI::Commerce::ShoppingCart;

use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Commerce::Item;
use WebGUI::Commerce::Payment;

=head1 NAME

Package WebGUI::Commerce::ShoppingCart

=head1 DESCRIPTION

This package implements a shopping cart for the E-Commerce system of WebGUI. This
shopping cart is tied to the sessionId and, thus, expires when the sessionId expires.

=head1 SYNOPSIS

$shoppingCart = WebGUI::Commerce::ShoppingCart->new;

$shoppingCart->add('myItemId', 'myItem', 3);
$shoppingCart->empty;

($normal, $recurring) = $shoppingCart->getItems;
$normal->[0]->{quantity}	# quantity of first normal item
$recurring->[2]->{period}	# period of third recurring item
$normal->[0]->{item}->id	# the id of the first normal item

=head1 METHODS

This package provides the following methods:

=cut

#-------------------------------------------------------------------

=head2 add ( itemId, itemType, quantity )

This will add qunatity items of type itemType and with id itemId to the shopping cart.

=head3 itemId

The id of the item to add.

=head3 itemType

The type (namespace) of the item that's to be added to the cart.

=head3 quantity

The number of items to add. Defaults to 1 if quantity is not given.

=cut

sub add {
	my ($self, $itemId, $itemType, $quantity);
	$self = shift;
	$itemId = shift;
	$itemType = shift;
	$quantity = shift || 1;

	$self->{_items}{$itemId."_".$itemType} = {
		itemId		=> $itemId,
		itemType	=> $itemType,
		quantity	=> $self->{_items}{$itemId."_".$itemType}{quantity} + $quantity
		};
		
	WebGUI::SQL->write("delete from shoppingCart where sessionId=".quote($self->{_sessionId})." and itemId=".quote($itemId)." and itemType=".quote($itemType));
	WebGUI::SQL->write("insert into shoppingCart ".
		"(sessionId, itemId, itemType, quantity) values ".
		"(".quote($self->{_sessionId}).",".quote($itemId).",".quote($itemType).",".$self->{_items}{$itemId."_".$itemType}{quantity}.")");
}

#-------------------------------------------------------------------

=head2 empty ( )

Invoking this method will putrge all content from the shopping cart.

=cut

sub empty {
	my ($self);
	$self = shift;
	
	WebGUI::SQL->write("delete from shoppingCart where sessionId=".quote($self->{_sessionId}));
}

#-------------------------------------------------------------------

=head2 getItems ( )

This method will return two arrayrefs repectively containing the normal items and the recurring
items in the shoppingcart.

Items are returned as a hashref with the following properties:

=head3 quantity

The quantity of this item.

=head3 period

The duration of a billingperiod if this this is a recurring transaction.

=head3 name

The name of this item.

=head3 price

The price of a single item.

=head3 totalPrice

The total price of this item. Ie. totalPrice = quantity * price.

=head3 item

The instanciated plugin of this item. See WebGUI::Commerce::Item for a detailed API.

For example:


=cut

sub getItems {
	my ($self, $periodResolve, %cartContent, $item, $properties, @recurring, @normal);
	$self = shift;
	
	$periodResolve = WebGUI::Commerce::Payment::recurringPeriodValues;
	%cartContent = %{$self->{_items}};
	foreach (values(%cartContent)) {
		$item = WebGUI::Commerce::Item->new($_->{itemId}, $_->{itemType});
		$properties = {
			quantity        => $_->{quantity},
			period          => lc($periodResolve->{$item->duration}),
			name		=> $item->name,
			price		=> sprintf('%.2f', $item->price),
			totalPrice	=> sprintf('%.2f', $item->price * $_->{quantity}),
			item		=> $item,
			};

		if ($item->isRecurring) {
			push(@recurring, $properties);
		} else {
			push(@normal, $properties);
		}
	}
	
	return (\@normal, \@recurring);
}

#-------------------------------------------------------------------

=head2 new ( sessionId )

Returns a shopping cart object tied to session id sessionId or the current session.

=head3 sessionId

The session id this cart should be tied to. If omitted this will default to the session id 
of the current user.

=cut

sub new {
	my ($class, $sessionId, $sth, $row, %items);
	$class = shift;
	$sessionId = shift || $session{var}{sessionId};

	$sth = WebGUI::SQL->read("select * from shoppingCart where sessionId=".quote($sessionId));
	while ($row = $sth->hashRef) {
		$items{$row->{itemId}."_".$row->{itemType}} = $row;
	}

	bless {_sessionId => $sessionId, _items => \%items}, $class;
}

1;
