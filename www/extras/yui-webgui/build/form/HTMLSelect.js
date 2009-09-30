
// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}

WebGUI.HTMLSelect = function ( id, display ) {
    var select      = YAHOO.util.Dom.get( id );
    this.labels     = {};

    var options     = select.getElementsByTagName( 'option' );
    var items       = [ ];
    for ( var i = 0; i < options.length; i++ ) {
        this.labels[ options[i].value ] = options[i].text;

        items.push( {
            value   : options[i].value,
            text    : display[ options[i].value ]
        } );
    }

    this.button = new YAHOO.widget.Button( {
        id          : 'askALSKL',
        name        : select.name,
        label       : select.options[ select.selectedIndex ].text,
        value       : select.options[ select.selectedIndex ].value,
        lazyloadmenu: false,
        type        : "menu",
        menu        : select,
        container   : select.parentNode
    } );

    var menu = this.button.getMenu();
    menu.clearContent();
    menu.addItems( items );
    menu.render();

    this.button.on( 'selectedMenuItemChange', this.updateButtonLabel, this, true );

    select.parentNode.removeChild( select );
}

WebGUI.HTMLSelect.prototype.updateButtonLabel = function ( e ) {
    var menuItem = e.newValue;

    this.button.set( 'label', this.labels[ menuItem.value ] );
}
