package WebGUI::Wobject::IndexedSearch::Search;

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
use DBIx::FullTextSearch;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::HTML;
use WebGUI::ErrorHandler;
use DBIx::FullTextSearch::StopList;
use WebGUI::Utility;
use WebGUI::Session;
use WebGUI::Privilege;
use HTML::Highlight;
use WebGUI::Macro;

=head1 NAME

Package WebGUI::Wobject::IndexedSearch::Search

=head1 DESCRIPTION

Search implementation for WebGUI. 

=head1 SYNOPSIS

 use WebGUI::Wobject::IndexedSearch::Search;
 my $search = WebGUI::Wobject::IndexedSearch::Search->new();
 $search->indexDocument( { text => 'Index this text',
				  location => 'http://www.mysite.com/index.pl/faq#45',
				  languageId => 3,
				  namespace => 'FAQ'
				});
 my $hits = search->search("+foo -bar koo",{ namespace = ['Article', 'FAQ']} );
 
 $search->close;
			   

=head1 SEE ALSO

This package is an extension to DBIx::FullTextSearch and HTML::Highlight. 
See that packages for documentation of their methods.

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 close ( )

Closes the DBIx::FullTextSearch session.

=cut

sub close {
	my $self=shift;
	$self->DESTROY();
}

#-------------------------------------------------------------------

=head2 create ( [ %options ] )

Creates a new DBIx::FullTextSearch index. 

=over

=item %options

Options to pass to DBIx::FullTextSearch. 
The default options that are used are:

( backend => column, word_length => 20, stoplist => undef )

Please refer to the DBIx::FullTextSearch documentation for a complete list of options.

=back

=cut

sub create {
	my ($self, %options) = @_;
	%options = (%{$self->{_createOptions}}, %options);
	if($options{stemmer}) {
		eval "use Lingua::Stem";
		if ($@) {
			WebGUI::ErrorHandler::warn("IndexedSearch: Can't use stemmer: $@");
			delete $options{stemmer};
		}
	}
	if($options{stoplist}) {
		if(not $self->existsTable($self->getIndexName."_".$options{stoplist}."_stoplist")) {
			DBIx::FullTextSearch::StopList->create_default($self->getDbh, $self->getIndexName."_".$options{stoplist}, $options{stoplist});
		}
		$options{stoplist} = $self->getIndexName."_".$options{stoplist};
	}		
	$self->{_fts} = DBIx::FullTextSearch->create($self->getDbh, $self->getIndexName, %options);
	if (not defined $self->{_fts}) {
		WebGUI::ErrorHandler::fatalError("IndexedSearch: Unable to create index.\n$DBIx::FullTextSearch::errstr");
		return undef;
	}
	$self->{_docId} = 1;
	return $self->{_fts};
}

#-------------------------------------------------------------------

=head2 existsTable ( tableName )

Returns true if tableName exists in database.

=over

=item tableName

The name of table.

=back

=cut

sub existsTable {
        my ($self, $table) = @_;
	return isIn($table, WebGUI::SQL->buildArray("show tables"));
}

#-------------------------------------------------------------------

=head2 getDetails ( docIdList , [ %options ] )

Returns an array reference containing details for each docId.

=over

=item docIdList

An array reference containing docIds.

=item previewLength

The maximum number of characters in each of the context sections. Defaults to "80".

=item highlight

A boolean indicating whether or not to enable highlight. Defaults to "1".

=item highlightColors

A reference to an array of CSS color identificators.

=item 

=back

=cut

sub getDetails {
	my ($self, $docIdList, %options) = @_;
	my $docIds = join(',',@$docIdList);
	my (@searchDetails, %namespace);
	foreach my $wobject (@{$session{config}{wobjects}}){
		my $cmd = "WebGUI::Wobject::".$wobject;
		my $w = $cmd->new({namespace=>$wobject, wobjectId=>'new'});
		$namespace{$wobject} = $w->name;
	}
	my $sql = "select * from IndexedSearch_docInfo where docId in ($docIds) and indexName = ".quote($self->getIndexName) ; 
	$sql .= " ORDER BY FIELD(docId, $docIds)";  # Maintain $docIdList order
	my $sth = WebGUI::SQL->read($sql);
	while (my %data = $sth->hash) {
		$data{namespace} = $namespace{$data{namespace}} || ucfirst($data{namespace});
		if ($data{ownerId}) {
			($data{username}) = WebGUI::SQL->quickArray("select username from users where userId = ".quote($data{ownerId}));
			$data{userProfile} = WebGUI::URL::page("op=viewProfile&uid=$data{ownerId}");
		}
		if ($data{bodyShortcut} =~ /^\s*select /i) {
			$data{body} = (WebGUI::SQL->quickArray($data{bodyShortcut}))[0];
		} else {
			$data{body} = $data{bodyShortcut};
		}
		if ($data{headerShortcut} =~ /^\s*select /i) {
			$data{header} = (WebGUI::SQL->quickArray($data{headerShortcut}))[0];
		} else {
			$data{header} = $data{headerShortcut};
		}
		delete($data{bodyShortcut});
		delete($data{headerShortcut});
		if($data{body}) {
			$data{body} = WebGUI::Macro::filter($data{body});
			$data{body} = WebGUI::HTML::filter($data{body},'all');		
			$data{body} = $self->preview($data{body}, $options{previewLength});
			$data{body} = $self->highlight($data{body},undef, $options{highlightColors}) if ($options{highlight});
		}
		if($data{header}) {
			$data{header} = WebGUI::Macro::filter($data{header});
			$data{header} = WebGUI::HTML::filter($data{header},'all');
			$data{header} = $self->highlight($data{header},undef, $options{highlightColors}) if ($options{highlight});
			$data{location} = WebGUI::URL::gateway($data{location});
		}
	#	$data{crumbTrail} = WebGUI::Macro::C_crumbTrail::_recurseCrumbTrail($data{pageId}, ' > ');
	#	$data{crumbTrail} =~ s/\s*>\s*$//;
		push(@searchDetails, \%data);
	}
	$sth->finish;
	return \@searchDetails;	
}

#-------------------------------------------------------------------

=head2 getDbh ( )

Returns the object's database handler.

=cut

sub getDbh {
	my $self = shift;
	return $self->{_dbh};
}

#-------------------------------------------------------------------

=head2 getDocId ( )

Returns the next docId for this object.

=cut

sub getDocId {
	my $self=shift;
	return $self->{_docId};
}

#-------------------------------------------------------------------

=head2 getIndexName ( )

Returns the full index name of this object.

=cut

sub getIndexName {
	my $self = shift;
	return $self->{_indexName};
}

#-------------------------------------------------------------------

=head2 _queryToWords ( [ query ] )

Converts a DBIx::FullTextSearch query to (\@Words, \@Wildcards) suitable to pass to HTML::Highlight

=cut

sub _queryToWords {
	my ($self, $query) = @_;
	my $query ||= $self->{_query};

	# Return the processed words / wildcards from memory if it's cached.
	if ($self->{$query."words"} && $self->{$query."wildcards"}) {
		return ($self->{$query."words"}, $self->{$query."wildcards"});
	}

	# deal with quotes
	my $inQuote=0;
	my (@words, @wildcards);
	foreach (split(/\"/, $query)) {
		if($inQuote == 0) {
			foreach (split(/\s+/, $_)) {
				next if (/^AND$/i);	# boolean AND
				next if (/^OR$/i);	# boolean OR
				next if (/^NOT$/i);	# boolean OR
				next if (/^\-/);		# exclude word
				next if (/^.{0,1}$/);	# at least 2 characters
				if (/\*/) {
					push(@wildcards, '%'); # match any character
				} else {
					push(@wildcards, '*'); # Also match plural of word
				}
				s/['"()+*]+//g;		# remove query operators and quotes 
				push(@words, $_);
			}
		} else {
			my $phrase = $_;
			push(@words, qq/$phrase/);
			push(@wildcards, undef);	# Exact match
		}
		$inQuote = ++$inQuote % 2;
	}
	# Store words / wildcards in memory
	$self->{$query."words"} = \@words;
	$self->{$query."wildcards"} = \@wildcards;

	return (\@words, \@wildcards);
}

#-------------------------------------------------------------------

=head2 highlight ( text [ , query , colors ] )

highlight words or patterns in HTML documents.

=over

=item text

The text to highlight

=item query

A query containing the words to highlight. Defaults to the last used $search->search query.
Special case: When query contains only an asterisk '*', no highlighting is applied.

=item colors

A reference to an array of CSS color identificators.
 
=back

=cut

sub highlight {
	my ($self, $text, $query, $colors) = @_;
	my $query ||= $self->{_query};
	return $text if ($query =~ /^\s*\*\s*$/); # query = '*', no highlight
	my ($words, $wildcards) = $self->_queryToWords($query);
	my $hl = new HTML::Highlight ( 	words => $words, 
					wildcards => $wildcards,
					colors => $colors
						);
	return $hl->highlight($text);
} 

#-------------------------------------------------------------------

=head2 indexDocument ( hashRef )

Adds a document to the index.

This method doesn't store the document itself. Instead, it stores information about words 
in the document in such a structured way that it makes easy and fast to look up what 
documents contain certain words and return id's of the documents.

=over

=item text

The text to index.

=item location

The location of the document. Most likely an URL.

=item contentType

The content type of this document. 

=item docId

The unique Id of this document. Defaults to the next empty docId.

=item pageId

The pageId of the page on which this document resides. Defaults to 0.

=item wobjectId

The wobjectID of the wobject that holds this document. Defaults to 0.

=item ownerId

The ownerId of the document. Defaults to 3.

=item languageId

The languageId of this document. Defaults to undef.

=item namespace

The namespace of this document. Defaults to 'WebGUI'.

=item page_groupIdView

Id of group authorized to view this page. Defaults to '7' (everyone)

=item wobject_groupIdView

Id of group authorized to view this wobject. Defaults to '7' (everyone)

=item wobject_special_groupIdView

Id of group authorized to view the details of this wobject. 

=item headerShortcut

An sql statement that returns the header (title, question, subject, name, whatever)
of this document.

=item bodyShortcut

An sql statement that returns the body (description, answer, message, whatever)
of this document.

=back

=cut

sub indexDocument {
	my ($self, $document) = @_;
	$self->{_fts}->index_document($document->{docId} || $self->{_docId}, $document->{text});
	WebGUI::SQL->write("insert into IndexedSearch_docInfo (	docId, 
										indexName,
										pageId,
										wobjectId, 
										languageId, 
										namespace, 
										location,
										page_groupIdView,
										wobject_groupIdView,
										wobject_special_groupIdView,
										headerShortcut,
										bodyShortcut,
										contentType,
										ownerId  ) 
                                      values (	".
							($document->{docId} || $self->{_docId}).", ". 
							quote($self->getIndexName).", ".
							($document->{pageId} || 0).", ". 
							($document->{wobjectId} || 0).", ". 
							($document->{languageId} || quote('')).", ".
							quote($document->{namespace} || 'WebGUI')." , ".
							quote($document->{location}).", ".
							($document->{page_groupIdView} || 7).", ". 
							($document->{wobject_groupIdView} || 7).", ".
							($document->{wobject_special_groupIdView} || 7).", ".
							quote($document->{headerShortcut})." ,".
							quote($document->{bodyShortcut})." ,".
							quote($document->{contentType})." ,".
							($document->{ownerId} || 3)." )"
				);
	$self->{_docId}++;
}

#-------------------------------------------------------------------

=head2 new ( [ indexName , dbh ] )

Constructor.

=over

=item indexName

The name of the index to open. Defaults to 'default'.

=item $dbh

Database handler to use. Defaults to $WebGUI::Session::session{dbh}.

=back

=cut

sub new {
	my ($class, $indexName, $dbh) = @_;
	$indexName = $indexName || 'default';
	my $self = { _indexName => $indexName,
			 _dbh => $dbh || $WebGUI::Session::session{dbh},
			 _createOptions => {( backend => 'column', 
						    word_length => 20,
						    filter => 'map { lc $_ if ($_ !~ /\^.*;/) }' 
						  )},
			};
	bless $self, $class;
}

#-------------------------------------------------------------------

=head2 open ( )

Opens an existing DBIx::FullTextSearch index.

=cut

sub open {
	my ($self) = @_;
	$self->{_fts} = DBIx::FullTextSearch->open($self->getDbh, $self->getIndexName);
	if (not defined $self->{_fts}) {
		WebGUI::ErrorHandler::fatalError("IndexedSearch: Unable to open index.\n$DBIx::FullTextSearch::errstr");
		return undef;
	}
	($self->{_docId}) = WebGUI::SQL->quickArray("select max(docId) from IndexedSearch_docInfo where indexName = ".quote($self->getIndexName)); 
	$self->{_docId}++;
	return $self->{_fts};
}

#-------------------------------------------------------------------

=head2 preview ( text , [ previewLength , query ] )

Returns a context preview in which words from a search query appear in the resulting documents. 
The words are always in the middle of each of the sections.

=over

=item text

The text to preview

=item previewLength

The maximum number of characters in each of the context sections. Defaults to 80.
A preview length of "0" means no preview, 
while a negative preview length returns the complete text.

=item query

A query containing the words to highlight. Defaults to the last used $search->search query.

=back

=cut

sub preview {
	my ($self, $text, $previewLength, $query) = @_;
	$previewLength = 80 if (not defined $previewLength);
	return '' unless ($previewLength);
	return $text if ($previewLength < 0);
	my $query ||= $self->{_query};
	if(($query =~ /^\s*\*\s*$/) or not $query) {	# Query is '*' or empty. 
		$text = WebGUI::HTML::filter($text,'all');
		$text =~ s/^(.{1,$previewLength})\s+.*$/$1/s;
	} else {
		my ($words, $wildcards) = $self->_queryToWords($query);
		my $hl = new HTML::Highlight ( 	words => $words, 
								wildcards => $wildcards
							);
		my $preview = join('... ',@{$hl->preview_context($text, $previewLength)});
		if ($preview) {
			$text = $preview;
		} else {
			$text = WebGUI::HTML::filter($text,'all');
			$text =~ s/^(.{1,$previewLength})\s+.*$/$1/s;
		}
	}
	$text =~ s/^(\s|&nbsp;)+//;
	$text =~ s/(\s|&nbsp;)+$//;
	if($text ne '') {
		$text = '<STRONG>... </STRONG>'.$text if ($text !~ /^[A-Z]+/); # ... broken up at the beginning
		$text .='<STRONG> ...</STRONG>' if ($text !~ /\.$/); # broken up at the end ...
	}
	return $text;
} 

#-------------------------------------------------------------------

=head2 recreate ( [ %options ] )

Like create, but first drops the existing index. Useful when rebuilding the index.

=over

=item %options

Options to pass to WebGUI::IndexedSearch->create() 

=back

=cut

sub recreate {
	my ($self, %options) = @_;
	$self->{_fts} = DBIx::FullTextSearch->open($self->getDbh, $self->getIndexName);
	if (defined $self->{_fts}) {
		$self->{_fts}->drop;
	}
	$self->{_fts} = $self->create($self->getIndexName, $self->getDbh, %options);
	WebGUI::SQL->write("delete from IndexedSearch_docInfo where indexName = ".quote($self->getIndexName));
	return $self->{_fts};
}

#-------------------------------------------------------------------

=head2 search ( query, \%filter )

Returns an array reference of docId's of documents that match the query. 
If the search has no results, undef is returned.

=over

=item query

user input string. Will be parsed into can-include, must-include and must-not-include words and phrases.
Special case: when query is an asterisk (*), then no full text search is done, and results are returned
using \%filter.

Examples are: 
		+"this is a phrase" -koo +bar foo
		(foo OR baz) AND (bar OR caz)

=item filter

A hash reference containing filter elements.

Example:
        {
                language => [ 1, 3 ],
                namespace => [ 'Article', 'USS' ]
        }

=back

=cut

sub search {
	my ($self, $query, $filter) = @_;
	$self->{_query} = $query;
	my $noFtsSearch = ($query =~ /^\s*\*\s*$/); # query = '*', no full text search
	my @fts_docIds = $self->{_fts}->search($query) unless $noFtsSearch ;
	if(@fts_docIds || $noFtsSearch) {
		my $groups = join(',',@{$self->_getGroups});
		my $docIds = join(',',@fts_docIds);
		my $sql = "select docId from IndexedSearch_docInfo where indexName = ".quote($self->getIndexName);
		$sql .= " and docId in ($docIds)" unless $noFtsSearch;
		$sql .= " and page_groupIdView in ($groups)";
		$sql .= " and wobject_special_groupIdView in ($groups)";
		if ($session{setting}{wobjectPrivileges}) {
			$sql .= " and wobject_groupIdView in ($groups)";
		}
		foreach my $filterElement (keys %{$filter}) {
			$sql .= " AND $filterElement in (".join(',', @{$filter->{$filterElement}}).")";
		}
		# No trash or other garbage
		$sql .= " AND (pageId > 999 or pageId < 0 or pageId = 1) ";
		# Keep @fts_docIds list order
		$sql .= " ORDER BY FIELD(docID,$docIds)" unless $noFtsSearch;
		my $filteredDocIds = WebGUI::SQL->buildArrayRef($sql);
		return $filteredDocIds if (ref $filteredDocIds eq 'ARRAY' and @{$filteredDocIds});
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 _getGroups ( )

Returns an array reference containing all groupIds of groups the user is in.

=cut

sub _getGroups {
	my @groups;
	foreach my $groupId (WebGUI::SQL->buildArray("select groupId from groups")) {
		push(@groups, $groupId) if (WebGUI::Privilege::isInGroup($groupId));
	}
	return \@groups;
}

#-------------------------------------------------------------------
sub DESTROY {
	my $self=shift;
	if (ref($self->{_fts})) {
		$self->{_fts}->DESTROY();
	}
}

1;
