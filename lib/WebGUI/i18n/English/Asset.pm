package WebGUI::i18n::English::Asset;

our $I18N = {
	'purge revision prompt' => {
		message => q|Are you certain you wish to delete this revision of this asset? It CANNOT be restored if you delete it.|,
		lastUpdated => 0,
		context => q|The prompt for purging a revision from the asset tree.|
	},

	'rollback version tag confirm' => {
		message => q|Are you certain you wish to delete this version tag and all content created under it? It CANNOT be restored if you delete it.|,
		lastUpdated => 0,
		context => q|The prompt for purging a version tag from the asset tree.|
	},

	'commit version tag confirm' => {
		message => q|Are you certain you wish to commit this version tag and everything edited under it?|,
		lastUpdated => 0,
		context => q|The prompt for committing a version tag to the asset tree.|
	},

	'enable autocommit of asset versioning' => {
		message => q|Enable autocommit of asset versioning?|,
		lastUpdated => 0,
		context => q|A label for the toggle for asset versioning.|
	},

	'set tag' => {
		message => q|Set As Working Tag|,
		lastUpdated => 0,
		context => q|The label for choosing as a tag to work under.|
	},

	'revisions in tag' => {
		message => q|Revisions In Tag|,
		lastUpdated => 0,
		context => q|The label for displaying the revisions created under a specific tag.|
	},

	'commit' => {
		message => q|Commit|,
		lastUpdated => 0,
		context => q|The label for committing a tag to the asset tree.|
	},

	'rollback' => {
		message => q|Rollback|,
		lastUpdated => 0,
		context => q|The label for purging a revision from the asset tree.|
	},

	'locked' => {
		message => q|Locked|,
		lastUpdated => 0,
		context => q|A label for a column in the asset manager indicating whether the asset is locked for editing.|
	},

	'revisions' => {
		message => q|Revisions|,
		lastUpdated => 0,
		context => q|Context menu item.|
	},

	'manage versions' => {
		message => q|Manage versions.|,
		lastUpdated => 0,
		context => q|Menu item in version tag manager.|
	},

	'manage committed versions' => {
		message => q|Manage committed versions.|,
		lastUpdated => 0,
		context => q|Menu item in version tag manager.|
	},

	'add version tag' => {
		message => q|Add Version Tag|,
		lastUpdated => 0,
		context => q|Admin console label.|
	},

	'content versioning' => {
		message => q|Content Versioning|,
		lastUpdated => 0,
		context => q|Admin console label.|
	},

	'committed versions' => {
		message => q|Committed Versions|,
		lastUpdated => 0,
		context => q|Admin console label.|
	},

	'add a version tag' => {
		message => q|Add a version tag.|,
		lastUpdated => 0,
		context => q|Menu item in version tag manager.|
	},

	'rank' => {
		message => q|Rank|,
		lastUpdated => 0,
		context => q|Column heading in asset manager.|
	},
	
	'type' => {
		message => q|Type|,
		lastUpdated => 0,
		context => q|Column heading in asset manager.|
	},
	
	'size' => {
		message => q|Size|,
		lastUpdated => 0,
		context => q|Column heading in asset manager.|
	},
	
	'last updated' => {
		message => q|Last Updated|,
		lastUpdated => 0,
		context => q|Column heading in asset manager.|
	},
	
	'restore' => {
		message => q|Restore|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'promote' => {
		message => q|Promote|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'demote' => {
		message => q|Demote|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'cut' => {
		message => q|Cut|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'copy' => {
		message => q|Copy|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'create shortcut' => {
		message => q|Create Shortcut|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'view' => {
		message => q|View|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'delete' => {
		message => q|Delete|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'manage' => {
		message => q|Manage|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'edit branch' => {
		message => q|Edit Branch|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'edit' => {
		message => q|Edit|,
		lastUpdated => 0,
		context => q|Used in asset context menus.|
	},
	
	'change' => {
		message => q|Change recursively?|,
		lastUpdated => 1099344172,
		context => q|Used when editing an entire branch, and asks whether the user wants to change this field recursively.|
	},

	'select all' => {
		message => q|Select All|,
		lastUpdated => 1099344172,
		context => q|A label for the select all checkbox on the asset manager|
	},

	'packages' => {
		message => q|Packages|,
		lastUpdated => 1099344172,
		context => q|The title of the package chooser in the asset manager|
	},
	
	'assets' => {
		message => q|Assets|,
		lastUpdated => 1099344172,
		context => q|The title of the asset manager for the admin console.|
	},
	
	'properties' => {
		message => q|Properties|,
		lastUpdated => 1099344172,
		context => q|The name of the properties tab on the edit asset.|
	},
	
	'make package' => {
		message => q|Make package?|,
		lastUpdated => 1099344172,
	},

	'make prototype' => {
		message => q|Make prototype?|,
		lastUpdated => 1099344172,
	},

	'asset id' => {
		message => q|Asset ID|,
		lastUpdated => 1099344172,
	},

        'asset fields body' => {
                message => q|<p>These are the base properties that all Assets share:</p>|,
                context => q|Describing the form to add or edit an Asset.|,
                lastUpdated => 1127426220,
        },

        'asset id description' => {
                message => q|<p>This is the unique identifier WebGUI uses to keep track of this Asset instance. Normal users should never need to be concerned with the Asset ID, but some advanced users may need to know it for things like SQL Reports. The Asset ID is not editable.</P>|,
                lastUpdated => 1127426210,
        },

        '99 description' => {
                message => q|<p>The title of the asset.  This should be descriptive, but not very long.  If left
blank, this will be set to "Untitled".</p>
<P><I>Note:</I> You should always specify a title, even if the Asset template will not use it. In various places on the site, like the Page Tree, Clipboard and Trash, the <B>Title</B> is used to distinguish this Asset from others.</p>|,
                lastUpdated => 1127426207,
        },

        '411 description' => {
                message => q|<p>A shorter title that will appear in navigation. If left blank,
this will default to the <b>Title</b>.<br />
<i>UI level: 1</i></p>|,
                lastUpdated => 1127426204,
        },

        '104 description' => {
                message => q|<p>The URL for this asset.  It must be unique.  If this field is left blank, then
a URL will be made from the parent's URL and the <b>Menu Title</b>.<br />
<i>UI level: 3</i></p>|,
                lastUpdated => 1127426200,
        },

        '886 description' => {
                message => q|<p>Whether or not this asset will be hidden from the navigation menu and site maps.<br />
<i>UI level: 6</i>
</p>|,
                lastUpdated => 1127426198,
        },

        '940 description' => {
                message => q|<p>Select yes to open this asset in a new window.<br />
<i>UI level: 6</i>
</p>|,
                lastUpdated => 1127426196,
        },

        'encrypt page description' => {
                message => q|<p>Should the page containing this asset be served over SSL?<br />
<i>UI level: 6</i>
</p>|,
                lastUpdated => 1127426194,
        },

        '497 description' => {
                message => q|<p>The date when users may begin viewing this asset. Before this date only Content Managers with the rights to edit this asset will see it<br />
<i>UI level: 6</i>.
</p>|,
                lastUpdated => 1127426192,
        },

        '498 description' => {
                message => q|<p>The date when users will stop viewing this asset. After this date only Content Managers with the rights to edit this asset will see it.<br />
<i>UI level: 6</i>
</p>|,
                lastUpdated => 1127426188,
        },

        '108 description' => {
                message => q|The owner of a asset is usually the person who created the asset. This user always has full edit and viewing rights on the asset.<br>
<i>UI level: 6</i>
</p>
<p> <b>NOTE:</b> The owner can only be changed by an administrator.
</p>|,
                lastUpdated => 1119149899,
        },

        '872 description' => {
                message => q|Choose which group can view this asset. If you want both visitors and registered users to be able to view the asset then you should choose the "Everybody" group.<br>
<i>UI level: 6</i>
</p>|,
                lastUpdated => 1119149899,
        },

        '871 description' => {
                message => q|Choose the group that can edit this asset. The group assigned editing rights can also always view the asset.<br>
<i>UI level: 6</i>
</p>|,
                lastUpdated => 1119149899,
        },

        '412 description' => {
                message => q|A short description of this Asset.<br>
<i>UI level: 3</i>
</p>|,
                lastUpdated => 1119149899,
        },

        'extra head tags description' => {
                message => q|These tags will be added to the &lt;head&gt; section of each page that the asset appears on.<br>
<i>UI level: 5</i>
</p>|,
                lastUpdated => 1126471216,
        },

        'make package description' => {
                message => q|Many WebGUI tasks are very repetitive.  Automating such tasks in Webgui, such as
creating an Asset, or sets of Assets, is done by creating a package that can be reused
through the site.  Check yes if you want this Asset to be available as a package.<br>
<i>UI level: 7</i>
</p>|,
                lastUpdated => 1119149899,
        },

        'make prototype description' => {
                message => q|Set this Asset to be a Content Prototype so that others can use it on your site.
<i>UI level: 9</i>|,
                lastUpdated => 1119149899,
        },

        'prototype using title' => {
                message => q|Content Prototypes, Using|,
                lastUpdated => 1127413710,
        },

        'prototype using body' => {
                message => q|<p>Chances are if you like assets to be configured a certain way, then you'll find Prototypes useful. By setting an Asset as a Prototype you can create new items in your Add content menu configured exactly as you like. For instance, if you use the Collaboration System as a photo gallery, then create a photo gallery and mark it as a Prototype. From then on you can just "Add content > New Content > Photo Gallery".</p>
<p>The title of the Asset is used as the name of the Content Prototype in the Add content menu.  If you set the title
of your prototype to be the same as the name of an Asset (Article, DataForm, etc.) then it will replace the WebGUI
default Asset in the menu.</p>|,
                lastUpdated => 1127413713,
        },

	'asset fields title' => {
	    message => q|Asset, Common Fields|,
	    lastUpdated => 1113357557,
	},

        'asset template body' => {
                message => q|
<p>This variable is inserted into every template:</p>
<P><b>controls</b><BR>
These are the icons and URLs that allow editing, cutting, copying, deleting and reordering the Asset.</P>

        |,
        lastUpdated => 1113357523,
  },

	'asset template title' => {
	    message => q|Asset Template Variables|,
	    lastUpdated => 1100463645,
	},


	'asset' => {
		message => q|Asset|,
        	lastUpdated => 1100463645,
		context => 'The default name of all assets.'
	},

	'extra head tags' => {
		message => q|Extra &lt;head&gt; elements (tags)|,
		context => q|label for Asset form|,
        	lastUpdated => 1126381168,
	},

	'create package' => {
		message => q|Make available as package?|,
		context => q|label for Asset form|,
        	lastUpdated => 1106762073,
	},

	'errorEmptyField' => {
		message => q|<p><b>Error: Field name may not be empty.</b></p>|,
		lastUpdated => 1089039511,
	},

	'Select' => {
		message => q|Select...|,
		lastUpdated => 1127958072
	},

	'duplicateField' => {
		message => q|<p><b>Error: Fieldname "%field%" is already in use.</b></p>|,
		lastUpdated => 1089039511
	},

	'Metadata' => {
		message => q|Metadata|,
		lastUpdated => 1089039511
	},

	'Field name' => {
		message => q|Field name|,
		lastUpdated => 1089039511
	},

	'Edit Metadata' => {
		message => q|Edit Metadata property|,
		lastUpdated => 1089039511
	},

	'Add new field' => {
		message => q|Add new metadata property|,
		lastUpdated => 1089039511
	},

	'deleteConfirm' => {
		message => q|Are you certain you want to delete this Metadata property ?|,
		lastUpdated => 1089039511
	},

	'Field Id' => {
		message => q|Field Id|,
		lastUpdated => 1089039511
	},

	'Delete Metadata field' => {
		message => q|Delete Metadata property|,
		lastUpdated => 1089039511
	},

	'content profiling' => {
		message => q|Content Profiling|,
		lastUpdated => 1089039511,
		context => q|The title of the content profiling manager for the admin console.|
	},

	'metadata edit property body' => {
		message => q|
You may add as many Metadata properties to a Wobject as you like.<br>
<br>
<b>Field Name</b><br>
The name of this metadata property.It must be unique. <br>
It is advisable to use only letters (a-z), numbers (0-9) or underscores (_) for
the field names.
<p><b>Description<br>
</b>An optional description for this metadata property. This text is displayed
as mouseover text in the asset properties tab.</p>
<p><b>Data Type<br>
</b>Choose the type of form element for this field.<b><br>
<br>
Possible Values<br>
</b>This field is used only for the Radio List and Select List data types. Enter
the values you wish to appear, one per line.</p>
|,
		lastUpdated => 1100232327
	},

        'metadata manage body' => {
                message => q|
<p>The content profiling system in WebGUI (also known as the metadata system) allows you to identify content. Metadata is
information about the content, and is defined in terms of property-value pairs.</p>
<p>Examples of metadata:</p>
<ul>
  <li>contenttype: sport</li>
  <li>adult content: no</li>
  <li>source: newspaper</li>
</ul>
<p>In the example <b>source: newspaper</b>, this metadata has a <i>property</i> named
<i>source</i> with a <i>value</i> of <i>newspaper</i>.</p>
<p>Metadata properties are defined globally, while Metadata values are set for
each asset under the tab &quot;Meta&quot; in the asset properties.</p>
<p>Before you can use metadata in WebGUI, you have to enable metadata in the WebGUI Settings (Content tab)</p>
<p>Usage of metadata:</p>
<ul>
  <li><p><b>Passive Profiling</b><br>
    When passive profiling is switched on, every wobject viewed by a user will
    be logged.  The WebGUI scheduler summarizes the profiling information on a regular
    basis.
    This is basically content
    ranking based upon the user's Areas of Interest (AOI).<br>
    By default the summarizer runs once a day. However you can change that by
    setting: <b>passiveProfileInterval = &lt;number of seconds&gt;</b> in the
    WebGUI config file.</p>
  </li>
  <li><p><b>Areas of Interest Ranking</b><br>
    Metadata in combination with passive profiling produces AOI (Areas of
    Interest) information. You can retrieve the value of a metadata property
    with the &#94;AOIRank(); and &#AOIHits(); macros.</p>
  </li>
  <li><p><b>Show content based upon criteria<br>
    </b>The Wobject Proxy allows you to select content based upon criteria like:<blockquote>
    contenttype = sport AND source != newspaper</blockquote>
    You can use the AOI macro's described above in the criteria, so you can
    present content based upon the users Areas of Interest. Example:<br>
    type = &#94;AOIRank(contenttype);</p></li>
	<li><p><b>Display</b><br />
	Metadata fields are exposed to the asset templates as their property name. So you can actually display the metadata
	to the rendered page using a template variable like &lt;tmpl_var <i>propertyname</i>&gt;</p></li>
	<li><p><b>Meta tags</b><br />
	Since the meta data is exposed as template variables, you can use that in combination with the &#94;RawHeadTags();
	macro to create meta tags from meta data, including the tags from the Dublin Core standard.</p></li>
</ul>|,
                context => q|Metadata help|,
                lastUpdated => 1110530955
        },

	'metadata edit property' => {
		message => q|Metadata, Edit|,
		lastUpdated => 1089039511
	},

        '1079' => {
                    lastUpdated => 1073152790,
                    message => q|Printable Style|
                  },
        '959' => {
                   lastUpdated => 1052850265,
                   message => q|Empty system clipboard.|
                 },
        'Uploads URL' => {
                           lastUpdated => 1089039511,
                           context => q|Field label for the Export Page operation|,
                           message => q|Uploads URL|
                         },
        '99' => {
                  lastUpdated => 1031514049,
                  message => q|Title|
                },
        'Page Export Status' => {
                                  lastUpdated => 1089039511,
                                  context => q|Title for the Page Export Status operation|,
                                  message => q|Page Export Status|
                                },
        '1083' => {
                    lastUpdated => 1076866510,
                    message => q|New Content|
                  },
        '965' => {
                   lastUpdated => 1099050265,
                   message => q|System Trash|
                 },
        '966' => {
        	         lastUpdated => 1099050265,
                   message => q|System Clipboard|
        	       },
        'Extras URL' => {
                          lastUpdated => 1089039511,
                          context => q|Field label for the Export Page operation|,
                          message => q|Extras URL|
                        },
        '895' => {
                   lastUpdated => 1056292971,
                   message => q|Cache Timeout|
                 },
        '108' => {
                   lastUpdated => 1031514049,
                   message => q|Owner|
                 },
        '872' => {
                   lastUpdated => 1044218038,
                   message => q|Who can view?|
                 },
        '896' => {
                   lastUpdated => 1056292980,
                   message => q|Cache Timeout (Visitors)|
                 },
        'Export as user' => {
                              lastUpdated => 1089039511,
                              context => q|Field label for the Export Page operation|,
                              message => q|Export as user|
                            },
        '871' => {
                   lastUpdated => 1044218026,
                   message => q|Who can edit?|
                 },
        '104' => {
                   lastUpdated => 1031514049,
                   context => q|asset property|,
                   message => q|URL|
                 },
        '11' => {
                  lastUpdated => 1051514049,
                  message => q|Empty trash.|
                },
        '412' => {
                   lastUpdated => 1031514049,
                   message => q|Synopsis|
                 },
        '954' => {
                   lastUpdated => 1052850265,
                   message => q|Manage system clipboard.|
                 },
        '1082' => {
                    lastUpdated => 1076866475,
                    message => q|Clipboard|
                  },
        '107' => {
                   lastUpdated => 1031514049,
                   message => q|Security|
                 },
        '174' => {
                   lastUpdated => 1031514049,
                   message => q|Display the title?|
                 },
        '487' => {
                   lastUpdated => 1031514049,
                   message => q|Possible Values|
                 },
        'Depth' => {
                     lastUpdated => 1089039511,
                     context => q|Field label for the Export Page operation|,
                     message => q|Depth|
                   },
        '964' => {
                   lastUpdated => 1052850265,
                   message => q|Manage system trash.|
                 },
        '105' => {
                   lastUpdated => 1046638916,
                   message => q|Display|
                 },
        '1073' => {
                    lastUpdated => 1070027660,
                    message => q|Style Template|
                  },
        'Export Page' => {
                           lastUpdated => 1089039511,
                           context => q|Title for the Export Page operation|,
                           message => q|Export Page|
                         },
        '951' => {
                   lastUpdated => 1052850265,
                   message => q|Are you certain that you wish to empty the clipboard to the trash?|
                 },
        '950' => {
                   lastUpdated => 1052850265,
                   message => q|Empty clipboard.|
                 },
        '85' => {
                  lastUpdated => 1031514049,
                  message => q|Description|
                },
        '486' => {
                   lastUpdated => 1031514049,
                   message => q|Data Type|
                 },
        '497' => {
                   lastUpdated => 1031514049,
                   message => q|Start Date|
                 },
        '498' => {
                   lastUpdated => 1031514049,
                   message => q|End Date|
                 },
        '949' => {
                   lastUpdated => 1052850265,
                   message => q|Manage clipboard.|
                 },
        '411' => {
                   lastUpdated => 1031514049,
                   message => q|Menu Title|
                 },
        '886' => {
                   lastUpdated => 1044727952,
                   message => q|Hide from navigation?|
                 },
        '43' => {
                  lastUpdated => 1031514049,
                  message => q|Are you certain that you wish to delete this content?|
                },
        '940' => {
                   lastUpdated => 1050438829,
                   message => q|Open in new window?|
                 },
        '493' => {
                   lastUpdated => 1031514049,
                   message => q|Back to site.|
                 },
	'encrypt page' => {
                message => q|Encrypt content?|,
                lastUpdated =>1092748557,
                context => q|asset property|
        },

	'asset list title' => {
		 lastUpdated => 1112220921,
		 message => q|Asset, List of Available|
	       },

	'asset list body' => {
		 lastUpdated => 1112291919,
		 message => q|These Assets are available for use at your site:<p>|
	       },

	'directory index' => {
		 lastUpdated => 1118896675,
		 message => q|Directory Index|,
	       },

        'Depth description' => {
                message => q|Sets the depth of the page tree to export. Use a depth of 0 to export only the current page. </p>|,
                lastUpdated => 1121361557,
        },

        'Export as user description' => {
                message => q|Run the export as this user. Defaults to Visitor.</p>|,
                lastUpdated => 1121361557,
        },

        'directory index description' => {
                message => q|If the URL of the Asset to be exported looks like a directory, the directory index will
be appended to it.</p>|,
                lastUpdated => 1121361557,
        },

        'Extras URL description' => {
                message => q|Sets the Extras URL. Defaults to the configured extrasURL in the WebGUI
config file.</p>|,
                lastUpdated => 1121361557,
        },

        'Uploads URL description' => {
                message => q|Sets the Uploads URL. Defaults to the configured uploadsURL in the WebGUI config file.</p>|,
                lastUpdated => 1121361557,
        },

	'Page Export' => {
                message => q|Page, Export|,
                lastUpdated => 1089039511,
                context => q|Help title for Page Export operation|
        },
	'Page Export body' => {
                message => q|
<p>The Export Page function allows you to export WebGUI pages to static
HTML files on disk.  The &quot;exportPath&quot; variable in the WebGUI
config file must be enabled for this function to be available.</p>
				|,
                lastUpdated => 1121361734,
                context => q|Help body for Page Export operation|
        },

	'topicName' => {
		message => q|Assets|,
		lastUpdated => 1128920336,
	},

};

1;
