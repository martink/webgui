package WebGUI::Account::Profile;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::ProfileCategory;
use WebGUI::ProfileField;
use WebGUI::Utility;
use base qw/WebGUI::Account/;

=head1 NAME

Package WebGUI::Account::Profile

=head1 DESCRIPTION

This is the class which is used to display a users's profile information

=head1 SYNOPSIS

 use WebGUI::Account::Profile;

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 appendCategoryVars ( var, category [,fields, errors] )

    Appends cateogry variables to the hash ref passed in
    
=head3 var

    The hash reference to append template variables to

=head3 category

    WebGUI::ProfileCategory object to append variables for

=head3 fields

    Optional array ref of fields in this category

=head3 errors

    Optional array ref of errors to attach to the category loop

=cut

sub appendCategoryVars {
    my $self     = shift;
    my $var      = shift || {};
    my $category = shift;
    my $fields   = shift;
    my $errors   = shift;
    my $selected = $self->store->{selected} || $self->session->form->get("selected");
    
    my $categoryId         = $category->getId;
    my $categoryLabel      = $category->getLabel;
    my $shortCategoryLabel = $category->getShortLabel;
    my $isActive           = $categoryId eq $selected;

    my $index  = scalar(@{$var->{'profile_category_loop'}}) + 1;

    push(@{ $var->{'profile_category_loop'} }, {
        'profile_category_id'              => $categoryId,
        'profile_category_isActive'        => $isActive,
        'profile_category_is_'.$categoryId => "true",  #Test so users can tell what category they are at in the loop
        'profile_category_label'           => $categoryLabel,
        'profile_category_shortLabel'      => $shortCategoryLabel,
        'profile_category_index'           => $index,
        'profile_fields_loop'              => $fields,
        'profile_errors'                   => $errors,
    });

    $var->{'profile_category_'.$categoryId."_isActive"  } = $isActive; 
    $var->{'profile_category_'.$categoryId."_label"     } = $categoryLabel;
    $var->{'profile_category_'.$categoryId."_shortLabel"} = $shortCategoryLabel;
    $var->{'profile_category_'.$categoryId."_index"     } = $index;
    $var->{'profile_category_'.$categoryId."_fields"    } = $fields;
    

    #Update the isActive flag to determine the default active tab
    $self->store->{hasActiveTab} = ($self->store->{hasActiveTab} || $isActive);

    #return $index;
}

#-------------------------------------------------------------------

=head2 appendCommonVars ( var )

    Appends common template variables that all profile templates use
    
=head3 var

    The hash reference to append template variables to

=cut

sub appendCommonVars {
    my $self          = shift;
    my $var           = shift;
    my $session       = $self->session;
    my $user          = $session->user;
    my $pageUrl       = $session->url->page;

    $self->SUPER::appendCommonVars($var);

    $var->{'edit_profile_url'     } = $self->getUrl("module=profile;do=edit");
    $var->{'invitations_enabled'  } = $session->user->profileField('ableToBeFriend');
    $var->{'profile_category_loop'} = [];

    #Append the categories
    my $categories = WebGUI::ProfileCategory->getCategories($session, { editable=>1 } );
    map { $self->appendCategoryVars($var,$_) } @ { $categories };
    unless ($self->store->{hasActiveTab}) {
        $var->{'profile_category_loop'}->[0]->{'profile_category_isActive'} = 1;
    }    

    #Append the form submit if it's in edit mode
    if($self->method eq "edit" || $self->uid eq "") {
        $var->{'is_edit'      } = "true";
        $var->{'form_header'  } = WebGUI::Form::formHeader($session,{
            action => $self->getUrl("module=profile;do=editSave")
        });
        $var->{'form_footer'  } = WebGUI::Form::formFooter($session);
    }
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $i18n    = WebGUI::International->new($session,'Account_Profile');
    my $f       = WebGUI::HTMLForm->new($session);

	$f->template(
		name      => "profileStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("profile style template label"),
        hoverHelp => $i18n->get("profile style template hoverHelp")
	);
	$f->template(
		name      => "profileLayoutTemplateId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("profile layout template label"),
        hoverHelp => $i18n->get("profile layout template hoverHelp")
	);
	$f->template(
        name      => "profileEditTemplateId",
        value     => $self->getEditTemplateId,
        namespace => "Account/Profile/Edit",
        label     => $i18n->get("profile edit template label"),
        hoverHelp => $i18n->get("profile edit template hoverHelp")
	);
    $f->template(
        name      => "profileViewTemplateId",
        value     => $self->getViewTemplateId,
        namespace => "Account/Profile/View",
        label     => $i18n->get("profile view template label"),
        hoverHelp => $i18n->get("profile view template hoverHelp")
	);
    $f->template(
        name      => "profileErrorTemplateId",
        value     => $self->getErrorTemplateId,
        namespace => "Account/Profile/Error",
        label     => $i18n->get("profile error template label"),
        hoverHelp => $i18n->get("profile error template hoverHelp")
	);


    return $f->printRowsOnly;
}


#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $form    = $session->form;

    $setting->set("profileStyleTemplateId", $form->process("profileStyleTemplateId","template"));
    $setting->set("profileLayoutTemplateId", $form->process("profileLayoutTemplateId","template"));
    $setting->set("profileDisplayLayoutTemplateId", $form->process("profileDisplayLayoutTemplateId","template"));
    $setting->set("profileEditTemplateId", $form->process("profileEditTemplateId","template"));
    $setting->set("profileViewTempalteId", $form->process("profileViewTemplateId","template"));
    $setting->set("profileErrorTemplateId",$form->process("profileErrorTemplateId","template"));

}

#-------------------------------------------------------------------

=head2 getExtrasStyle ( field, fieldErrors, fieldValue )

This method returns the proper field to display for required fields.

=head3 field

field to check

=head3 fieldErrors

errors returned as a result of validation (see $self->validateProfileFields)

=head3 fieldValue

Value of the field to use when returning the style

=cut

sub getExtrasStyle {
    my $self        = shift;
    my $field       = shift;
    my $fieldErrors = shift;
    my $fieldValue  = shift;

    my $requiredStyleOff = q{class="profilefield_required_off"}; 
    my $requiredStyle    = q{class="profilefield_required"};
    my $errorStyle       = q{class="profilefield_error"};     #Required Field Not Filled In and Error Returend

    return $errorStyle if(WebGUI::Utility::isIn($field->getId,@{$fieldErrors}));
    return "" unless ($field->isRequired);
    return $requiredStyle unless($self->session->user->profileField($field->getId) || $fieldValue);
    return $requiredStyleOff;
}

#-------------------------------------------------------------------

=head2 getEditTemplateId ( )

This method returns the template ID for the edit profile page.

=cut

sub getEditTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileEditTemplateId") || "75CmQgpcCSkdsL-oawdn3Q";
}

#-------------------------------------------------------------------

=head2 getErrorTemplateId ( )

This method returns the template ID used to display the error page.

=cut

sub getErrorTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileErrorTemplateId") || "MBmWlA_YEA2I6D29OMGtRg";
}


#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self    = shift;
    my $session = $self->session;
    my $method  = $self->method;
    my $uid     = $self->uid;
    return $session->setting->get("profileLayoutTemplateId") || "FJbUTvZ2nUTn65LpW6gjsA";
}

#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 getViewTemplateId ( )

This method returns the template ID for the view profile page.

=cut

sub getViewTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileViewTemplateId") || "2CS-BErrjMmESOtGT90qOg";
}

#-------------------------------------------------------------------

=head2 www_edit ( )

The edit page for the user's profile.

=cut

sub www_edit {
    my $self        = shift;
    my $errors      = shift || {};
    my $session     = $self->session;
    my $user        = $session->user;
    my $var         = {};

    #Handle errors
    my @errorFields          = ();
    $var->{'profile_errors'} = [];

    if( scalar(keys %{$errors}) ) {
        #Warnings and errors are the same here - set the fields so we can tell which fields errored
        @errorFields = (@{$errors->{errorFields}},@{$errors->{warningFields}});
        #Build the error message loop
        map {
            push( @{$var->{'profile_errors'}},{ error_message => $_ })
        }  @{$errors->{errors}};
    }

    my $count = 0;

    #Set the active flag to the default.  We'll know more later 
    $self->store->{hasActiveTab} = 0;    
    
    #Initialize the category template loop which gets filled inside the loop
    $var->{'profile_category_loop'}  = [];

    #Get the editable categories
    my $categories = WebGUI::ProfileCategory->getCategories($session, { editable => 1 } );
	foreach my $category (@{ $categories } ) {
        my @fields = ();
        use Data::Dumper;
        foreach my $field (@{ $category->getFields( { editable => 1 } ) }) {
            my $fieldId      = $field->getId;
            my $fieldLabel   = $field->getLabel;
            my $fieldForm    = $field->formField({ extras=>$self->getExtrasStyle($field,\@errorFields,$user->profileField($fieldId)) });
            my $fieldSubtext = $field->isRequired ? "*" : undef;
            my $fieldExtras  = $field->getExtras;
            my $fieldPrivacy = WebGUI::Form::radoList($session,{
                name    => "privacy_$fieldId",
                options => $field->getPrivacyOptions($session),
                value   => $user->getProfileFieldPrivacySetting($fieldId)
            });

            #Create a seperate template var for each field
            $var->{'profile_field_'.$fieldId.'_form'   } = $fieldForm;
            $var->{'profile_field_'.$fieldId.'_label'  } = $fieldLabel;
            $var->{'profile_field_'.$fieldId.'_subtext'} = $fieldSubtext;
            $var->{'profile_field_'.$fieldId.'_extras' } = $fieldExtras;
            $var->{'profile_field_'.$fieldId.'_privacy'} = $fieldPrivacy;
            
            push(@fields, {
                'profile_field_id'      => $fieldId,
				'profile_field_form'    => $fieldForm,
				'profile_field_label'   => $fieldLabel,
				'profile_field_subtext' => $field->isRequired ? "*" : undef,
                'profile_field_extras'  => $field->getExtras,
                'profile_field_privacy' => $fieldPrivacy,
			});
        }

        #Append the category variables
        $self->appendCategoryVars($var,$category,\@fields,$var->{'profile_errors'});
    }
 
    #If not category is selected, set the first category as the active one
    unless ($self->store->{hasActiveTab}) {
        $var->{'profile_category_loop'}->[0]->{'profile_category_isActive'} = 1;
    }

    #Call the superclass common vars method cause we don't need to build the categories again
    $self->SUPER::appendCommonVars($var);

    return $self->processTemplate($var,$self->getEditTemplateId);
}


#-------------------------------------------------------------------

=head2 www_editSave ( )

The page which saves the user's profile and returns them to their profile view.

=cut

sub www_editSave {
    my $self       = shift;
    my $session    = $self->session;

    my $fields     = WebGUI::ProfileField->getEditableFields($session);
    my $retHash    = $session->user->validateProfileDataFromForm($fields);
	push (@{$retHash->{errors}},@{$retHash->{warnings}});

    unless(scalar(@{$retHash->{errors}})) {
        $session->user->updateProfileFields( $retHash->{profile} );
    }
    
    #Store the category the error occurred in the object for reference
    $self->store->{selected} = $retHash->{errorCategory};

    return $self->www_edit($retHash);
}

#-------------------------------------------------------------------

=head2 www_view ( )

The display page of the .

=cut

sub www_view {
    my $self     = shift;
    my $session  = $self->session;
    my $var      = {};
    my $uid      = $self->uid;
    my $selected = $session->form->get("selected"); #Allow users to template tabs or other category dividers

    my $active      = 0; #Whether or not a category is selected
    my $counter     = 1; #Count the number of categories being displayed

    #Ensure uid is passed in if they want to view a profile.  This controls the tab state.
    return $self->www_edit unless ($uid);

    my $user     = WebGUI::User->new($session,$uid);

    $self->appendCommonVars($var);

    #Overwrite these
    $var->{'user_full_name'    } = $user->getWholeName;
    $var->{'user_member_since' } = $user->dateCreated;

    #Check user privileges
    unless ($user->profileIsViewable($session->user)) {
        my $i18n = WebGUI::International->new($session,'Account_Profile');
        return $self->showError(
            $var,
            $i18n->get("profile not public error"),
            $var->{'back_url'},
            $self->getErrorTemplateId
        );
    }

    $var->{'profile_category_loop' } = [];
	foreach my $category (@{WebGUI::ProfileCategory->getCategories($session,{ visible => 1})}) {
        my @fields = ();
        foreach my $field (@{$category->getFields({ visible => 1 })}) {
            my $fieldId      = $field->getId;
            my $fieldLabel   = $field->getLabel;
            my $fieldValue   = $field->formField(undef,2,$user);
            my $fieldRaw     = $user->profileField($fieldId);;
            #Create a seperate template var for each field
            $var->{'profile_field_'.$fieldId.'_label' } = $fieldLabel;
            $var->{'profile_field_'.$fieldId.'_value' } = $fieldValue;
            $var->{'profile_field_'.$fieldId.'_raw'   } = $fieldRaw;
            
            push(@fields, {
                'profile_field_id'           => $fieldId,
                'profile_field_is_'.$fieldId => "true",
				'profile_field_label'        => $fieldLabel,
                'profile_field_value'        => $fieldValue,
                'profile_field_raw'          => $fieldRaw
			});
        }

        #Append the category variables
        $self->appendCategoryVars($var,$category,\@fields);
    }

    #If not category is selected, set the first category as the active one
    unless ($self->store->{hasActiveTab}) {
        $var->{'profile_category_loop'}->[0]->{'profile_category_isActive'} = 1;
    }

    my $privacySetting                          = $user->profileField("publicProfile") || "none";
    $var->{'profile_privacy_'.$privacySetting } = "true";

    $var->{'profile_user_id'       } = $user->userId;
    $var->{'can_edit_profile'      } = $uid eq $session->user->userId;
    $var->{'acceptsPrivateMessages'} = $user->acceptsPrivateMessages($session->user->userId);
    $var->{'acceptsFriendsRequests'} = $user->acceptsFriendsRequests($session->user);

    return $self->processTemplate($var,$self->getViewTemplateId);
}

1;