
package ABXML;

our $opstatus = [
    'status' =>
	'code',
	[],
	'summary',
	'details',
];

our $patchinfodir = [
  'patchinfodir' =>
	'name',
	[[ 'entry' =>
		'name',
		'md5',
		'status',
		'docu',
	]]
];

our $patchinfo = [
  'patchinfo' =>
	[],
	'Filename',
	'MD5SUM',
	'ISSUEDATE',
	'FILEOWNER',
	'PACKAGER',
	'ARCH',
	'CATEGORY',
	'INDICATIONS',
	'CONTRAINDICATIONS',
	'PRE',
	'POST',
	'ScriptsInline',
	'License',
	'Confirm',
	'UpdateOnlyInstalled',
	'ForceInstall',
	'RebootNeeded',
	'ReloginSuggested',
	'AlwaysInstallPackages',
	'InstallOnly',
	'PATCHFILENAME',
	'LEAVEOLDRPMS',
	'PRE_DE',
	'POST_DE',
	'SUMMARY',
	'SUMMARY_DE',
	'SWAMPID',
	'SUBSWAMPID',
	'SWAMPSTATUS',
	'APPROVED',
	'RATING',
	'BS-REQUESTID',
	[ 'DISTRIBUTION' ],
	[ 'PACKAGE' ],
	[ 'PACKAGE-GA' ],
	[ 'SCRIPT' ],
	[ 'PRESCRIPT' ],
	[ 'POSTSCRIPT' ],
	[ 'CD-Produkt-Name' ],
	[ 'CD-Produkt-Version' ],
	[ 'BUGZILLA' ],
	[ 'CVE' ],
	[ 'UPDATESCRIPT' ],
	[ 'OBSOLETES' ],
	[ 'REQUIRES' ],
	[ 'Freshens' ],
	[ 'IMAGE' ],
	[ 'FILES' ],
	[ 'DESCRIPTION' ],
	[ 'DESCRIPTION_DE' ],
	[ 'DIRECTORIES' ],
];

our $patchdocu = [
    'patchdocu' =>
	[],
	'description',
	'keywords',
	'abstract',
	'swampid',
	'priority',
	'lastchanged',
	[ 'bugzilla' =>
	    [ 'bnum', ]
	],
	[ 'products' =>
	    [[ 'product', =>
		[],
		'name',
		'longname',
		'source',
		'patchname',
	    ]],
	],
	[ 'body', =>
	    [],
	    'html',
	    'ascii',
	    'description',
	],
];

our $approve_pi = [
    'approve_pi' =>
	[],
	'user',
	'behalf',
	'md5sum',
];

our $reject_pi = [
    'reject_pi' =>
	[],
	'user',
	'reason',
	'md5sum',
];

our $maintlist = [
    'maintlist' =>
	[],
	'package',
	'type',
	[ 'DISTRIBUTION' ],
];

our @rpm_entry = (
    [[ 'rpm:entry' =>
	'kind',
	'name',
	'flags',
	'epoch',
	'ver',
	'rel',
	'pre',
    ]],
);

our @rpm_entry_2 = (
    [[ 'rpm:entry' =>
	'kind',
	'name',
	'epoch',
	'ver',
	'rel',
	'pre',
	'flags',
    ]],
);

our @suse_entry = (
    [[ 'suse:entry' =>
	'kind',
	'name',
	'flags',
	'epoch',
	'ver',
	'rel',
	'pre',
    ]],
);

our $repomd =  [
    'repomd' =>
	'xmlns',
	'xmlns:rpm',
	'xmlns:suse',
	[],
	'revision',
	[ 'tags' =>
		[ 'content' ],
		[ 'repo' ],
		[[ 'distro' =>
		    'cpeid',
		    '_content',
		]],
	],
	[[ 'data' =>
		'type',
		[ 'location' =>
		    'href',
		],
		[ 'checksum' =>
		    'type',
		    '_content',
		],
		'timestamp',
		'size',
		'open-size',
		[ 'open-checksum' =>
		    'type',
		    '_content',
		],
	]],
];

our $primary = [
    'metadata' =>
	'xmlns',
	'xmlns:rpm',
	'xmlns:suse',
	'packages',
	[[ 'package' =>
	    'xmlns',
	    'type',
	    [],
	    'name',
	    'arch',
	    [ 'version' =>
		'epoch',
		'ver',
		'rel',
	    ],
	    [[ 'checksum', =>
		'type',
		'pkgid',
		'_content',
	    ]],
	    [[ 'summary' =>
		'lang',
		'_content',
	    ]],
	    [[ 'description' =>
		'lang',
		'_content',
	    ]],
	    'packager',
	    'url',
	    [ 'time' =>
		'file',
		'build',
	    ],
	    [ 'size' =>
		'package',
		'installed',
		'archive',
	    ],
	    [ 'location' =>
		'xml:base',
		'href',
	    ],
	    [ 'format' =>
		[],
		'rpm:license',
		'rpm:vendor',
		'rpm:group',
		'rpm:buildhost',
		'rpm:sourcerpm',
		[ 'rpm:header-range' =>
		    'start',
		    'end',
		],
		[ 'rpm:provides' => @rpm_entry ],
		[ 'rpm:requires' => @rpm_entry ],
		[ 'rpm:conflicts' => @rpm_entry ],
		[ 'rpm:obsoletes' => @rpm_entry ],
		[ 'rpm:suggests' => @rpm_entry ],
		[ 'rpm:recommends' => @rpm_entry ],
		[ 'rpm:supplements' => @rpm_entry ],
		[ 'rpm:enhances' => @rpm_entry ],
		[[ 'file' =>
		    'type',
		    '_content',
		]],
	    ],
	    'suse:license-to-confirm',
	]],
];

our $susedata = [
    'susedata' =>
	'xmlns',
	'packages',
	[[ 'package' =>
	    'pkgid',
	    'name',
	    'arch',
	    [ 'version' =>
		'epoch',
		'ver',
		'rel',
	    ],
	    'eula',
	    [[ 'keyword' =>
		'_content',
	    ]],
	    [ 'diskusage' =>
		[ 'dirs' =>
		    [[ 'dir' =>
			'name',
			'size',
			'count',
		    ]],
		],
	    ],
	]],
];

our $susedata_i18n = [
    'susedata' =>
	'xmlns',
	'packages',
	[[ 'package' =>
	    'pkgid',
	    'name',
	    'arch',
	    [ 'version' =>
		'epoch',
		'ver',
		'rel',
	    ],
	    [ 'summary' =>
		'lang',
		[],
		'_content',
	    ],
	    [ 'description' =>
		'lang',
		[],
		'_content',
	    ],
	    [ 'pattern-category' =>
		'lang',
		[],
		'_content',
	    ],
	    'eula',
	]],
];

our $filelists = [
    'filelists' =>
        'xmlns',
        'packages',
        [[ 'package' =>
            'pkgid',
            'name',
            'arch',
            [ 'version' =>
                'epoch',
                'ver',
                'rel',
            ],
	    [[ 'file' =>
		'type',
		'_content',
	    ]],
        ]],
];

our $otherdata = [
    'otherdata' =>
        'xmlns',
        'packages',
        [],
        [[ 'package' =>
            'pkgid',
            'name',
            'arch',
            [],
            [ 'version' =>
                'epoch',
                'ver',
                'rel',
            ],
	    [[ 'changelog' =>
		'author',
		'date',
		'_content',
	    ]],
        ]],
];

our $suseinfo = [
    'suseinfo' =>
	'xmlns',
	[],
	'expire',
];

our $patch_zypp = [
    'patch' =>
	'xmlns',
	'xmlns:yum',
	'xmlns:rpm',
	'xmlns:suse',
	'patchid',
	'timestamp',
	'engine',
	[],
	'yum:name',
	[[ 'summary' =>
		'lang',
		'_content',
	]],
	[[ 'description' =>
		'lang',
		'_content',
	]],
	[ 'yum:version' =>
		'ver',
		'rel',
	],
	[ 'rpm:provides' => @rpm_entry_2 ],
	[ 'rpm:requires' => @rpm_entry_2 ],
	[ 'rpm:conflicts' => @rpm_entry_2 ],
	[ 'rpm:obsoletes' => @rpm_entry_2 ],
	[ 'rpm:suggests' => @rpm_entry_2 ],
	[ 'rpm:enhances' => @rpm_entry_2 ],
	[ 'rpm:recommends' => @rpm_entry_2 ],
	[ 'rpm:supplements' => @rpm_entry_2 ],
	'reboot-needed',
	'package-manager',
	'category',
	[ 'update-script' =>
		[],
		'do',
		[ 'do-location' =>
			'href',
		],
		[ 'do-checksum' =>
			'type',
			'_content',
		],
	],
	[[ 'license-to-confirm',
		'lang',
		'_content',
	]],
	[ 'atoms' =>
		[[ 'package' =>
			'xmlns',
			'type',
			[],
			'name',
			'arch',
			[ 'version' =>
				'epoch',
				'ver',
				'rel',
			],
			[[ 'checksum', =>
				'type',
				'pkgid',
				'_content',
			]],
			[ 'time' =>
				'file',
				'build',
			],
			[ 'size' =>
				'package',
				'installed',
				'archive',
			],
			[ 'location' =>
				'xml:base',
				'href',
			],
			[ 'format' =>
				[ 'rpm:provides' => @rpm_entry_2 ],
				[ 'rpm:requires' => @rpm_entry_2 ],
				[ 'rpm:conflicts' => @rpm_entry_2 ],
				[ 'rpm:obsoletes' => @rpm_entry_2 ],
				[ 'rpm:suggests' => @rpm_entry_2 ],
				[ 'rpm:enhances' => @rpm_entry_2 ],
				[ 'rpm:recommends' => @rpm_entry_2 ],
				[ 'rpm:supplements' => @rpm_entry_2 ],
				[ 'suse:freshens' => @suse_entry ],
				'install-only',
			],
			[ 'pkgfiles' =>
				'xmlns',
				[[ 'patchrpm' =>
					[ 'location' =>
						'href',
					],
					[[ 'checksum', =>
						'type',
						'pkgid',
						'_content',
					]],
					[ 'time' =>
						'file',
						'build',
					],
					[ 'size' =>
						'package',
						'installed',
						'archive',
					],
					[[ 'base-version' =>
						'epoch',
						'ver',
						'rel',
					]],
				]],
				[[ 'deltarpm' =>
					[ 'location' =>
						'href',
					],
					[[ 'checksum', =>
						'type',
						'pkgid',
						'_content',
					]],
					[ 'time' =>
						'file',
						'build',
					],
					[ 'size' =>
						'package',
						'installed',
						'archive',
					],
					[ 'base-version' =>
						'epoch',
						'ver',
						'rel',
						'md5sum',
						'buildtime',
						'sequence_info',
					],
				]],
			],
		]],
		[[ 'message' =>
			'xmlns',
			'yum:name',
			[ 'yum:version' =>
				'epoch',
				'ver',
				'rel',
			],
			[ 'text' =>
				'lang',
				'_content',
			],
			[ 'rpm:requires' => 
				'pre',
				@rpm_entry_2 
			],
			[ 'suse:freshens' => @suse_entry ],
		]],
		[[ 'script' =>
			'xmlns',
			'yum:name',
			[ 'yum:version' =>
				'epoch',
				'ver',
				'rel',
			],
			'do',
			[ 'do-location' =>
				'href',
			],
			[ 'do-checksum' =>
				'type',
				'_content',
			],
			[ 'rpm:requires' => 
				'pre',
				@rpm_entry_2 
			],
			[ 'suse:freshens' => @suse_entry ],
		]],
	],
];

our $patch_sat = [
	'update' =>
		'status',
		'from',
		'type',
		'version',
		[],
		'id',
		'title',
		'severity',
		'release',
		[ 'issued' =>
			'date',
		],
		[ 'references' =>
			[[ 'reference' =>
				'href',
				'id',
				'title',
				'type',
			]],
		],
		[ 'description' =>
			'_content',
		],
		[ 'pkglist' =>
			[ 'collection' =>
				[[ 'package' =>
					'name',
					'arch',
					'version',
					'release',
					[],
					'filename',
					'reboot_suggested',
					'relogin_suggested',
					'restart_suggested',
				]],
			],
		],
];

our $bsinfo;

if ($BSXML::request) {
$bsinfo = [
  'bsinfo' =>
      'instance',
      $BSXML::request,
];
};

our $prodfile = [
    'product' =>
	'id',
	'schemeversion',
	[],
	'vendor',
	'name',
	'version',
	'baseversion',
	'patchlevel',
	'migrationtarget',
	'release',
	'arch',
	'endoflife',
	'productline',
	[ 'register' =>
		[],
		'target',
		'release',
		[ 'repositories' =>
			[[ 'repository' =>
				'path',
			]],
		],
	],
        [ 'upgrades' =>
		[],
		[ 'upgrade' =>
			[],
			'name',
			'summary',
			'product',
			'notify',
			'status',
		],
	],
	'updaterepokey',
	'summary',
	'shortsummary',
	'description',
	[ 'linguas' =>
		[[ 'language' => '_content' ]],
	],
	[ 'urls' =>
		[[ 'url' =>
			'name',
			'_content',
		]],
	],
	[ 'buildconfig' =>
		'producttheme',
		'betaversion',
		'allowresolving',
		'mainproduct',
	],
	[ 'installconfig' =>
		'defaultlang',
		'datadir',
		'descriptiondir',
		[],
		[ 'releasepackage' =>
			'name',
			'flag',
			'version',
			'release',
		],
		'distribution',
		[ 'obsoletepackage' ],
	],
	'runtimeconfig',
];

our $productsfile = [
	'products' =>
		[[ 'product' =>
			[],
			'name',
			[ 'version' =>
				'ver',
				'rel',
				'epoch',
			],
			'arch',
			'vendor',
			'summary',
			'description',
		]],
];

our $patchprotocol = [
	'protocol' =>
		[],
		'title',
		'suse',
		'descr',
		[[ 'product' =>
			'name',
			'version',
			'arch',
			'maint',
			[],
			'marketing',
			'path',
			'nppid',
			[[ 'package' =>
				'type',
				'path',
				'name',
			]],
			[[ 'metadata' =>
				'type',
				'cat',
				'path',
				'name',
			]],
		]],
		'had_errors',
];

our $patches = [
	'patches' =>
		'xmlns',
		[[ 'patch' =>
			'id',
			[],
			[ 'checksum' =>
				'type',
				'_content',
			],
			[ 'location' =>
				'href',
			],
			'category',
		]],
];


1;
