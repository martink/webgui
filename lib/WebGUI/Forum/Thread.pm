package WebGUI::Forum::Thread;

=head1 LEGAL
                                                                                                                                                             
 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------
                                                                                                                                                             
=cut

use strict;
use WebGUI::DateTime;
use WebGUI::Forum;
use WebGUI::Forum::Post;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

=head1 DESCRIPTION
                                                                                                                                                             
Data management class for forum threads.
                                                                                                                                                             
=head1 SYNOPSIS
                                                                                                                                                             
 use WebGUI::Forum;
 $forum = WebGUI::Forum::Thread->create(\%params);
 $forum = WebGUI::Forum::Thread->new($threadId);
                                                                                                                                                             
=head1 METHODS
                                                                                                                                                             
These methods are available from this class:
                                                                                                                                                             
=cut

sub create {
	my ($self, $data, $postData) = @_;
	$data->{forumThreadId} = "new";
	$postData->{forumThreadId} = WebGUI::SQL->setRow("forumThread","forumThreadId", $data);
	$self = WebGUI::Forum::Thread->new($postData->{forumThreadId});
	$postData->{parentId} = 0;
	my $post = WebGUI::Forum::Post->create($postData);
	$self->set({
		rootPostId=>$post->get("forumPostId"),
		lastPostId=>$post->get("forumPostId"),
		lastPostDate=>$post->get("dateOfPost")
		});
	$self->{_post}{$post->get("forumPostId")} = $post;
	$self->getForum->incrementThreads($post->get("dateOfPost"),$post->get("forumPostId"));
	return $self;
}

sub get {
	my ($self, $key) = @_;
	if ($key eq "") {
		return $self->{_properties};
	}
	return $self->{_properties}->{$key};
}

sub getForum {
	my ($self) = @_;
	unless (exists $self->{_forum}) {
		$self->{_forum} = WebGUI::Forum->new($self->get("forumId"));
	}
	return $self->{_forum};
}

sub getNextThread {
	my ($self) = @_;
	unless (exists $self->{_next}) {
		my ($nextId) = WebGUI::SQL->quickArray("select min(forumThreadId) from forumThread where forumId=".$self->get("forumId")." 
			and forumThreadId>".$self->get("forumThreadId"));
		$self->{_next} = WebGUI::Forum::Thread->new($nextId);
	}
	return $self->{_next};
}

sub getPost {
	my ($self, $postId) = @_;
	unless (exists $self->{_post}{$postId}) {
		$self->{_post}{$postId} = WebGUI::Forum::Post->new($postId);
	}
	return $self->{_post}{$postId};
}

sub getPreviousThread {
	my ($self) = @_;
	unless (exists $self->{_previous}) {
		my ($nextId) = WebGUI::SQL->quickArray("select max(forumThreadId) from forumThread where forumId=".$self->get("forumId")." 
			and forumThreadId<".$self->get("forumThreadId"));
		$self->{_previous} = WebGUI::Forum::Thread->new($nextId);
	}
	return $self->{_previous};
}

sub isLocked {
	my ($self) = @_;
	return $self->get("isLocked");
}

sub incrementReplies {
        my ($self, $dateOfReply, $replyId) = @_;
        WebGUI::SQL->write("update forumThread set replies=replies+1, lastPostId=$replyId, lastPostDate=$dateOfReply 
		where forumThreadId=".$self->get("forumThreadId"));
	$self->getForum->incrementReplies($dateOfReply,$replyId);
}

sub incrementViews {
        my ($self) = @_;
        WebGUI::SQL->write("update forumThread set views=views+1 where forumThreadId=".$self->get("forumThreadId"));
	$self->getForum->incrementViews;
}
                                                                                                                                                             
sub isSticky {
	my ($self) = @_;
	return $self->get("isSticky");
}

sub isSubscribed {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	my ($isSubscribed) = WebGUI::SQL->quickArray("select count(*) from forumThreadSubscription where forumThreadId=".$self->get("forumThreadId")
		." and userId=$userId");
	return $isSubscribed;
}

sub lock {
	my ($self) = @_;
	$self->set({isLocked=>1});
}

sub new {
	my ($class, $forumThreadId) = @_;
	my $properties = WebGUI::SQL->getRow("forumThread","forumThreadId",$forumThreadId);
	if (defined $properties) {
		bless {_properties=>$properties}, $class;
	} else {
		return undef;
	}
}

sub recalculateRating {
	my ($self) = @_;
        my ($count) = WebGUI::SQL->quickArray("select count(*) from forumPost where forumThreadId=".$self->get("forumThreadId")." and rating>0");
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(rating) from forumPost where forumThreadId=".$self->get("forumThreadId")." and rating>0");
        my $average = round($sum/$count);
        $self->set({rating=>$average});
	$self->getForum->recalculateRating;
}
                                                                                                                                                             
sub set {
	my ($self, $data) = @_;
	$data->{forumThreadId} = $self->get("forumThreadId") unless ($data->{forumThreadId});
	WebGUI::SQL->setRow("forumThread","forumThreadId",$data);
	foreach my $key (keys %{$data}) {
                $self->{_properties}{$key} = $data->{$key};
        }
}

sub setLastPost {
	my ($self, $postId, $postDate) = @_;
	$self->set({
		lastPostId=>$postId,
		lastPostDate=>$postDate
		});
}

sub setStatusApproved {
        my ($self) = @_;
        $self->set({status=>'approved'});
}
                                                                                                                                                             
sub setStatusDeleted {
        my ($self) = @_;
        $self->set({status=>'deleted'});
}
                                                                                                                                                             
sub setStatusDenied {
        my ($self) = @_;
        $self->set({status=>'denied'});
}
                                                                                                                                                             
sub setStatusPending {
        my ($self) = @_;
        $self->set({status=>'pending'});
}

sub stick {
	my ($self) = @_;
	$self->set({isSticky=>1});
}

sub subscribe {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	unless ($self->isSubscribed($userId)) {
		WebGUI::SQL->write("insert into forumThreadSubscription (forumThreadId, userId) values (".$self->get("forumThreadId").",$userId)");
	}
}

sub unlock {
	my ($self) = @_;
	$self->set({isLocked=>0});
}

sub unstick {
	my ($self) = @_;
	$self->set({isSticky=>0});
}

sub unsubscribe {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	if ($self->isSubscribed($userId)) {
		WebGUI::SQL->write("delete from forumThreadSubscription where forumThreadId=".$self->get("forumThreadId")." and userId=$userId");
	}
}


1;

