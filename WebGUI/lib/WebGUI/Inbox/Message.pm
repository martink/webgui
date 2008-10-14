package WebGUI::Inbox::Message;

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
use WebGUI::Mail::Send;
use WebGUI::International;

=head1 NAME

Package WebGUI::Inbox::Message;

=head1 DESCRIPTION

This package provides an API for working with inbox messages.

=head1 SYNOPSIS

 use WebGUI::Inbox::Message;

 my $message = WebGUI::Inbox::Message->new($session, $messageId);

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 create ( session, properties ) 

Creates a new message.

=head2 session

A reference to the current session.

=head3 properties

A hash reference containing the properties to update. 

=head4 message

The content of this message.

=head4 subject

The topic of this message. Defaults to 'Notification'.

=head4 status

May be "pending" or "completed". Defaults to "pending". You should set this to completed if this is a message without an action, such as a notification.

=head4 userId

A userId of a user attached to this message.

=head4 groupId

A groupId of a group attached to this message.

=head4 sentBy

A userId that created this message. Defaults to '3' (Admin).

=head4 emailMessage

Email message to use rather than inbox message contents.

=head4 emailSubject

Email subject to use rather than inbox message subject.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $properties = shift;
	my $self = {};
	$self->{_properties}{messageId} = "new";
	$self->{_properties}{status}    = $properties->{status} || "pending";
	$self->{_properties}{subject}   = $properties->{subject} || WebGUI::International->new($session)->get(523);
	$self->{_properties}{message}   = $properties->{message};
	$self->{_properties}{dateStamp} = time();
	$self->{_properties}{userId}    = $properties->{userId};
	$self->{_properties}{groupId}   = $properties->{groupId};
    $self->{_properties}{sentBy}    = $properties->{sentBy} || 3;
	if ($self->{_properties}{status} eq "completed") {
		$self->{_properties}{completedBy} = $session->user->userId;
		$self->{_properties}{completedOn} = time();
	}
	$self->{_messageId} = $self->{_properties}{messageId} = $session->db->setRow("inbox","messageId",$self->{_properties});
	
	my $subject = (defined $properties->{emailSubject}) ? $properties->{emailSubject} : $self->{_properties}{subject};
	my $mail = WebGUI::Mail::Send->create($session, {
		toUser=>$self->{_properties}{userId},
		toGroup=>$self->{_properties}{groupId},
		subject=>$subject,
		});
	if (defined $mail) {
        my $i18n = WebGUI::International->new($session, 'Inbox_Message');
        my $pref = $i18n->get("from user preface");
        $pref .= $session->db->quickScalar("SELECT username FROM users WHERE userId = ?",[$properties->{sentBy}]). ".";
	    my $msg = (defined $properties->{emailMessage}) ? $properties->{emailMessage} : $self->{_properties}{message};
		if ($msg =~ m/\<.*\>/) {
			$mail->addHtml("<p>$pref</p><br />".$msg);
		} else {
			$mail->addText($pref."\n\n".$msg);
		}
		$mail->addFooter;
		$mail->queue;
	}
	$self->{_session} = $session;
	bless $self, $class;
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this message from the inbox.

=cut

sub delete {
	my $self = shift;
	my $sth = $self->session->db->prepare("delete from inbox where messageId=?");
	$sth->execute([$self->getId]);
}

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}

#-------------------------------------------------------------------

=head2 get ( property ) 

Returns the value of a property.

=head3 property

The name of any property of an inbox message. See create() for details. In addition to those settable by create, you may also retrieve these:

=head4 dateStamp

The date the message was created.

=head4 completedBy

The userId of the user that completed the action associated with this message.

=head4 completedOn

An epoch date representing when the action associated with this message was completed.

=cut

sub get {
	my $self = shift;
	my $name = shift;
	return $self->{_properties}{$name};
}


#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID of this message.

=cut

sub getId {
	my $self = shift;
	return $self->{_messageId};
}

#-------------------------------------------------------------------

=head2 new ( session, messageId )

Constructor used to access existing messages.  Use create for making
new messages.

=head3 session

A reference to the current session.

=head3 messageId

The unique id of a message.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $messageId = shift;
	bless {_properties=>$session->db->getRow("inbox","messageId",$messageId), _session=>$session, _messageId=>$messageId}, $class;
}

#-------------------------------------------------------------------

=head2 session

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setCompleted ( [ userId ] ) 

Marks a message completed.

=head4 userId

The id of the user that completed this task. Defaults to the current user.

=cut

sub setCompleted {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	$self->{_properties}{status} = "completed";
	$self->{_properties}{completedBy} = $userId;
	$self->{_properties}{completedOn} = time();
	$self->session->db->setRow("inbox","messageId",$self->{_properties});
}

#-------------------------------------------------------------------

=head2 setStatus ( status,[ userId ] ) 

Marks a message completed.

=head4 status

Status to mark the message

=head4 userId

The id of the user that completed this task. Defaults to the current user.

=cut

sub setStatus {
	my $self = shift;
    my $status = shift;
	my $userId = shift || $self->session->user->userId;
	unless ($status) {
        $self->session->errorHandler->warn("No status passed in for message.  Exit without update");
        return undef;
    }
    
    if($status eq "completed") {
        $self->setCompleted($userId);
        return undef;
    }
    $self->{_properties}{status} = $status;
	$self->session->db->setRow("inbox","messageId",$self->{_properties});
    return undef;
}

1;
