package WebGUI::i18n::English::Asset_Layout;

our $I18N = {
	'assetName' => {
		message => q|Page|,
        	lastUpdated => 1128832065,
		context=>q|The name of the layout asset.|
	},

	'layout add/edit title' => {
		message => q|Page, Add/Edit|,
        	lastUpdated => 1106683494,
	},

	'layout add/edit body' => {
                message => q|
<p>Page Assets are used to display multiple Assets on the same time, much like
Pages in version 5 of WebGUI.  The Page Asset consists of a template with
multiple content areas, and Assets that are children of the Page can be assigned
to be displayed in those areas.

<p>Page Assets are Wobjects and Assets, and share the same properties of both.  Page
Assets also have these unique properties:</p>|,
		context => 'Describing Page Add/Edit form specific fields',
		lastUpdated => 1119410129,
	},

        'template description' => {
                message => q|Choose a template from the list to display the contents of the Page Asset and
its children.
<p/>|,
                lastUpdated => 1119410080,
        },

        'assets to hide description' => {
                message => q|This list contains one checkbox for each child Asset of the Page.  Select the
checkbox for any Asset that you do not want displayed in the Page Asset.
<p/>|,
                lastUpdated => 1119410080,
        },

	'layout template title' => {
		message => q|Page Template|,
        	lastUpdated => 1109987374,
	},

	'layout template body' => {
                message => q|<p>The following variables are available in Page Templates:</p>

<P><b>showAdmin</b><br/>
A conditional showing if the current user has turned on Admin Mode and can edit this Asset.

<P><b>dragger.icon</b><br/>
An icon that can be used to change the Asset's position with the mouse via a click and
drag interface.  If showAdmin is false, this variable is empty.

<P><b>dragger.init</b><br/>
HTML and Javascript required to make the click and drag work. If showAdmin is false, this variable is empty.

<P><b>position1_loop, position2_loop, ... positionN_loop</b><br/>
Each position in the template has a loop which has the set of Assets
which are to be displayed inside of it.  Assets that have not been
specifically placed are put inside of position 1.

<blockquote>

<P><b>id</b><br/>
The Asset ID of the Asset.

<P><b>content</b><br/>
The rendered content of the Asset.

</blockquote>

<P><b>attachment.size</b><br/>
The size of the file.

<P><b>attachment.type</b><br/>
The type of the file (PDF, etc.)

		|,
		context => 'Describing the file template variables',
		lastUpdated => 1109987366,
	},

	'assets to hide' => {
		message => q|Assets To Hide.|,
		lastUpdated => 1118942468
	},

	'823' => {
		message => q|Go to the new page.|,
		lastUpdated => 1038706332
	},

	'847' => {
		message => q|Go back to the current page.|,
		lastUpdated => 1039587250
	},

};

1;
